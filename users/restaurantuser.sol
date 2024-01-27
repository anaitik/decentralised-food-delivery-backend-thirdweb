// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract RestaurantUserContract {
    struct RestaurantUser {
        string name;
        string phoneNumber;
        string email;
        // Additional parameters for restaurant user
        string restaurantName;
        string restaurantLocation;
    }

    mapping(address => RestaurantUser) public restaurantUsers;

    event RestaurantUserCreated(
        address userAddress,
        string name,
        string phoneNumber,
        string email,
        // Additional parameters in the event
        string restaurantName,
        string restaurantLocation
    );

    event RestaurantUserUpdated(
        address userAddress,
        string name,
        string phoneNumber,
        string email,
        // Additional parameters in the event
        string restaurantName,
        string restaurantLocation
    );

    modifier onlyRestaurantUser() {
        require(bytes(restaurantUsers[msg.sender].name).length > 0, "Not a registered restaurant user");
        _;
    }

    function createRestaurantUser(
        string memory _name,
        string memory _phoneNumber,
        string memory _email,
        // Additional parameters in the function
        string memory _restaurantName,
        string memory _restaurantLocation
    ) public {
        RestaurantUser storage newRestaurantUser = restaurantUsers[msg.sender];

        newRestaurantUser.name = _name;
        newRestaurantUser.phoneNumber = _phoneNumber;
        newRestaurantUser.email = _email;
        // Assigning additional parameters
        newRestaurantUser.restaurantName = _restaurantName;
        newRestaurantUser.restaurantLocation = _restaurantLocation;

        emit RestaurantUserCreated(
            msg.sender,
            _name,
            _phoneNumber,
            _email,
            // Emitting additional parameters
            _restaurantName,
            _restaurantLocation
        );
    }

    function editRestaurantUser(
        string memory _name,
        string memory _phoneNumber,
        string memory _email,
        // Additional parameters to edit
        string memory _restaurantName,
        string memory _restaurantLocation
    ) public onlyRestaurantUser {
        RestaurantUser storage user = restaurantUsers[msg.sender];

        user.name = _name;
        user.phoneNumber = _phoneNumber;
        user.email = _email;
        // Updating additional parameters
        user.restaurantName = _restaurantName;
        user.restaurantLocation = _restaurantLocation;

        emit RestaurantUserUpdated(
            msg.sender,
            _name,
            _phoneNumber,
            _email,
            // Emitting additional parameters
            _restaurantName,
            _restaurantLocation
        );
    }
}
