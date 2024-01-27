// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract RestaurantContract {
    struct Restaurant {
        uint256 id;
        string name;
        string location;
        // Add other restaurant details as needed
    }

    mapping(uint256 => Restaurant) public restaurants;
    uint256 public nextRestaurantId = 1;

    event RestaurantCreated(uint256 id, string name, string location);

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

    function getRestaurant(uint256 _restaurantId) public view returns (Restaurant memory) {
        return restaurants[_restaurantId];
    }

    function getAllRestaurants() public view returns (Restaurant[] memory) {
        Restaurant[] memory allRestaurants = new Restaurant[](nextRestaurantId - 1);

        for (uint256 i = 1; i < nextRestaurantId; i++) {
            allRestaurants[i - 1] = restaurants[i];
        }

        return allRestaurants;
    }
}
