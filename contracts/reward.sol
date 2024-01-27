// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WalletAndRewardSystem is Ownable {
    mapping(address => uint256) public userWallets;
    mapping(address => uint256) public userRewards;

    uint256 public rewardPerOrder = 1; // Reward points earned per food order
    uint256 public rewardThreshold = 10; // Reward points needed to qualify for a reward

    event FundsDeposited(address user, uint256 amount);
    event FundsWithdrawn(address user, uint256 amount);
    event RewardPointsEarned(address user, uint256 points);
    event RewardRedeemed(address user, uint256 points);

    modifier hasSufficientFunds(address _user, uint256 _amount) {
        require(userWallets[_user] >= _amount, "Insufficient funds");
        _;
    }

    function depositFunds() public payable {
        userWallets[msg.sender] += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    function withdrawFunds(uint256 _amount) public hasSufficientFunds(msg.sender, _amount) {
        userWallets[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit FundsWithdrawn(msg.sender, _amount);
    }

    function transferFunds(address _to, uint256 _amount) public hasSufficientFunds(msg.sender, _amount) {
        userWallets[msg.sender] -= _amount;
        userWallets[_to] += _amount;
        emit FundsWithdrawn(msg.sender, _amount);
        emit FundsDeposited(_to, _amount);
    }

    function earnRewardPoints() public {
        userRewards[msg.sender] += rewardPerOrder;
        emit RewardPointsEarned(msg.sender, rewardPerOrder);

        if (userRewards[msg.sender] >= rewardThreshold) {
            redeemReward();
        }
    }

    function redeemReward() public {
        require(userRewards[msg.sender] >= rewardThreshold, "Insufficient reward points");

        uint256 rewardAmount = userRewards[msg.sender] * rewardThreshold;
        userRewards[msg.sender] = 0;

        // You can customize the reward logic here, for example, transfer ERC20 tokens as a reward
        // For simplicity, we'll transfer Ether in this example.
        payable(msg.sender).transfer(rewardAmount);

        emit RewardRedeemed(msg.sender, rewardAmount);
    }

    function getUserBalance() public view returns (uint256) {
        return userWallets[msg.sender];
    }

    function getUserRewards() public view returns (uint256) {
        return userRewards[msg.sender];
    }

    // Owner/Admin functions

    function setRewardPerOrder(uint256 _rewardPerOrder) public onlyOwner {
        rewardPerOrder = _rewardPerOrder;
    }

    function setRewardThreshold(uint256 _rewardThreshold) public onlyOwner {
        rewardThreshold = _rewardThreshold;
    }

    function withdrawEtherFromContract(uint256 _amount) public onlyOwner {
        require(_amount > 0 && address(this).balance >= _amount, "Invalid withdrawal amount");
        payable(owner()).transfer(_amount);
    }

    function withdrawTokenFromContract(address _tokenAddress, uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        IERC20 token = IERC20(_tokenAddress);
        require(token.transfer(owner(), _amount), "Token transfer failed");
    }
}
