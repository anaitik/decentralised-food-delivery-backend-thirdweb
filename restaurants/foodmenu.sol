// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract FoodMenuContract {
    struct FoodDish {
        uint256 id;
        string name;
        uint256 price;
        // Add other food dish details as needed
    }

    mapping(uint256 => FoodDish) public foodDishes;
    uint256 public nextFoodDishId = 1;

    event FoodDishAdded(uint256 dishId, string name, uint256 price);

    function addFoodDish(string memory _name, uint256 _price) public {
        uint256 dishId = nextFoodDishId;

        foodDishes[dishId] = FoodDish({
            id: dishId,
            name: _name,
            price: _price
            // Add other food dish details as needed
        });

        nextFoodDishId++;

        emit FoodDishAdded(dishId, _name, _price);
    }

    function getFoodDish(uint256 _dishId) public view returns (FoodDish memory) {
        return foodDishes[_dishId];
    }

    function getAllFoodDishes() public view returns (FoodDish[] memory) {
        FoodDish[] memory allFoodDishes = new FoodDish[](nextFoodDishId - 1);

        for (uint256 i = 1; i < nextFoodDishId; i++) {
            allFoodDishes[i - 1] = foodDishes[i];
        }

        return allFoodDishes;
    }
}
