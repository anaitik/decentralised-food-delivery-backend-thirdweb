// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DiscountApplication is Ownable {
    mapping(uint256 => mapping(uint256 => uint256)) public restaurantDiscounts;

    event DiscountApplied(uint256 restaurantId, uint256 foodDishId, uint256 discountPercent);
    event DiscountRemoved(uint256 restaurantId, uint256 foodDishId);

    modifier onlyRestaurantOwner(uint256 _restaurantId) {
        require(owner() == msg.sender, "Only the restaurant owner can set discounts");
        _;
    }

    function setDiscount(uint256 _restaurantId, uint256 _foodDishId, uint256 _discountPercent) public onlyRestaurantOwner(_restaurantId) {
        require(_discountPercent <= 100, "Invalid discount percentage");

        restaurantDiscounts[_restaurantId][_foodDishId] = _discountPercent;

        emit DiscountApplied(_restaurantId, _foodDishId, _discountPercent);
    }

    function removeDiscount(uint256 _restaurantId, uint256 _foodDishId) public onlyRestaurantOwner(_restaurantId) {
        restaurantDiscounts[_restaurantId][_foodDishId] = 0;

        emit DiscountRemoved(_restaurantId, _foodDishId);
    }

    function getDiscount(uint256 _restaurantId, uint256 _foodDishId) public view returns (uint256) {
        return restaurantDiscounts[_restaurantId][_foodDishId];
    }
}
