
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./CartContract.sol";

contract OrderContract {
    using SafeMath for uint256;

    struct Order {
        uint256 orderId;
        address customer;
        uint256[] dishIds;
        uint256[] quantities;
        uint256 totalAmount;
        bool isDelivered;
    }

    mapping(uint256 => Order) public orders;
    uint256 public nextOrderId = 1;

    event OrderPlaced(uint256 orderId, address customer, uint256[] dishIds, uint256[] quantities, uint256 totalAmount);
    event OrderDelivered(uint256 orderId);

    CartContract public cartContract;

    constructor(address _cartContractAddress) {
        cartContract = CartContract(_cartContractAddress);
    }

    modifier onlyCustomer() {
        require(msg.sender == tx.origin, "Only customers can call this function");
        _;
    }

    function placeOrder() public onlyCustomer {
        address customer = msg.sender;
        CartContract.CartItem[] memory userCart = cartContract.getUserCart();

        require(userCart.length > 0, "No items in the cart");

        uint256[] memory dishIds = new uint256[](userCart.length);
        uint256[] memory quantities = new uint256[](userCart.length);
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < userCart.length; i++) {
            dishIds[i] = userCart[i].dishId;
            quantities[i] = userCart[i].quantity;
            totalAmount += userCart[i].quantity * cartContract.getFoodDishPrice(userCart[i].dishId);
        }

        orders[nextOrderId] = Order({
            orderId: nextOrderId,
            customer: customer,
            dishIds: dishIds,
            quantities: quantities,
            totalAmount: totalAmount,
            isDelivered: false
        });

        emit OrderPlaced(nextOrderId, customer, dishIds, quantities, totalAmount);
        nextOrderId++;

        // Clear the user's cart after placing the order
        cartContract.clearUserCart();
    }

    function getOrder(uint256 _orderId) public view returns (Order memory) {
        return orders[_orderId];
    }

    function getAllOrders() public view returns (Order[] memory) {
        Order[] memory allOrders = new Order[](nextOrderId - 1);

        for (uint256 i = 1; i < nextOrderId; i++) {
            allOrders[i - 1] = orders[i];
        }

        return allOrders;
    }

    function markOrderDelivered(uint256 _orderId) public onlyOwner {
        Order storage order = orders[_orderId];
        require(!order.isDelivered, "Order is already delivered");

        order.isDelivered = true;
        emit OrderDelivered(_orderId);
    }
}
