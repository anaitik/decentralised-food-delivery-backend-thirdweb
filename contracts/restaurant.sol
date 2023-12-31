// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract FoodDeliveryPlatform {
    struct Restaurant {
        uint256 id;
        string name;
        string location;
        // Add other restaurant details as needed
    }

    struct FoodDish {
        uint256 id;
        uint256 restaurantId;
        string name;
        // Add other food dish details as needed
    }

    mapping(uint256 => Restaurant) public restaurants;
    uint256 public nextRestaurantId = 1;

    mapping(uint256 => FoodDish[]) public restaurantToFoodDishes;

    event RestaurantCreated(uint256 id, string name, string location);
    event FoodDishAdded(uint256 restaurantId, uint256 foodDishId, string name);

    function createRestaurant(string memory _name, string memory _location) public {
        uint256 restaurantId = nextRestaurantId;

        restaurants[restaurantId] = Restaurant({
            id: restaurantId,
            name: _name,
            location: _location
            // Add other restaurant details as needed
        });

        nextRestaurantId++;

        emit RestaurantCreated(restaurantId, _name, _location);
    }

    function addFoodDish(uint256 _restaurantId, string memory _name) public {
        uint256 foodDishId = restaurantToFoodDishes[_restaurantId].length;

        restaurantToFoodDishes[_restaurantId].push(FoodDish({
            id: foodDishId,
            restaurantId: _restaurantId,
            name: _name
            // Add other food dish details as needed
        }));

        emit FoodDishAdded(_restaurantId, foodDishId, _name);
    }

    function getAllRestaurants() public view returns (Restaurant[] memory) {
        Restaurant[] memory allRestaurants = new Restaurant[](nextRestaurantId - 1);

        for (uint256 i = 1; i < nextRestaurantId; i++) {
            allRestaurants[i - 1] = restaurants[i];
        }

        return allRestaurants;
    }

    function getFoodDishesByRestaurant(uint256 _restaurantId) public view returns (FoodDish[] memory) {
        return restaurantToFoodDishes[_restaurantId];
    }

    // Add other functions as needed
}
