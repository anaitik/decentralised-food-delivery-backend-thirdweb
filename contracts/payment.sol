// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./OrderContract.sol";

contract FoodDeliveryPayments is Ownable {
    mapping(address => uint256) public userBalances;
    mapping(address => uint256) public userDeposits;
    mapping(address => mapping(uint256 => bool)) public userTransactions;

    uint256 public nextPaymentId = 1;

    event PaymentMade(uint256 paymentId, address from, address to, uint256 amount, bool isToken, address tokenAddress);
    event DepositMade(address account, uint256 amount, bool isToken, address tokenAddress);
    event WithdrawalMade(address account, uint256 amount, bool isToken, address tokenAddress);
    event RefundMade(uint256 paymentId, address from, address to, uint256 amount, bool isToken, address tokenAddress);

    OrderContract public orderContract;

    constructor(address _orderContractAddress) {
        orderContract = OrderContract(_orderContractAddress);
    }

    modifier onlyAdmin() {
        require(owner() == msg.sender, "Only the owner can call this function");
        _;
    }

    function makePayment(address _to, uint256 _amount, bool _isToken, address _tokenAddress) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");

        userBalances[msg.sender] -= _amount;
        userBalances[_to] += _amount;

        recordTransaction(msg.sender, _to);

        emit PaymentMade(nextPaymentId, msg.sender, _to, _amount, _isToken, _tokenAddress);
        nextPaymentId++;
    }

    function deposit(uint256 _amount, bool _isToken, address _tokenAddress) public payable {
        if (_isToken) {
            require(_amount > 0, "Amount must be greater than 0");
            IERC20 token = IERC20(_tokenAddress);
            require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
            userBalances[msg.sender] += _amount;
            userDeposits[msg.sender] += _amount;
            emit DepositMade(msg.sender, _amount, true, _tokenAddress);
        } else {
            require(msg.value > 0, "Ether amount must be greater than 0");
            userBalances[msg.sender] += msg.value;
            userDeposits[msg.sender] += msg.value;
            emit DepositMade(msg.sender, msg.value, false, address(0));
        }
    }

    function withdraw(uint256 _amount, bool _isToken, address _tokenAddress) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");

        if (_isToken) {
            IERC20 token = IERC20(_tokenAddress);
            require(token.transfer(msg.sender, _amount), "Token transfer failed");
            userBalances[msg.sender] -= _amount;
            emit WithdrawalMade(msg.sender, _amount, true, _tokenAddress);
        } else {
            userBalances[msg.sender] -= _amount;
            payable(msg.sender).transfer(_amount);
            emit WithdrawalMade(msg.sender, _amount, false, address(0));
        }
    }

    function refund(uint256 _paymentId, bool _isToken, address _tokenAddress) public onlyAdmin {
        require(_paymentId < nextPaymentId, "Invalid payment ID");

        address from = msg.sender;
        address to = userTransactions[from][_paymentId] ? from : owner(); // Refund to the customer or owner
        uint256 amount = userBalances[from];

        if (_isToken) {
            IERC20 token = IERC20(_tokenAddress);
            require(token.transfer(to, amount), "Token transfer failed");
        } else {
            payable(to).transfer(amount);
        }

        emit RefundMade(_paymentId, from, to, amount, _isToken, _tokenAddress);
    }

    function getBalance(address _user) public view returns (uint256) {
        return userBalances[_user];
    }

    function getDeposit(address _user) public view returns (uint256) {
        return userDeposits[_user];
    }

    function isAdmin() public view returns (bool) {
        return owner() == msg.sender;
    }

    function recordTransaction(address _from, address _to) internal {
        userTransactions[_from][nextPaymentId] = true;
        userTransactions[_to][nextPaymentId] = true;
    }

    function getTransactionStatus(address _user, uint256 _paymentId) public view returns (bool) {
        return userTransactions[_user][_paymentId];
    }

    // Owner/Admin functions

    function setAdmin(address _admin) public onlyOwner {
        transferOwnership(_admin);
    }

    function withdrawEtherFromContract(uint256 _amount) public onlyAdmin {
        require(_amount > 0 && address(this).balance >= _amount, "Invalid withdrawal amount");
        payable(owner()).transfer(_amount);
    }

    function withdrawTokenFromContract(address _tokenAddress, uint256 _amount) public onlyAdmin {
        require(_amount > 0, "Amount must be greater than 0");
        IERC20 token = IERC20(_tokenAddress);
        require(token.transfer(owner(), _amount), "Token transfer failed");
    }
}
