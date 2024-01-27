// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract FoodDeliveryPlatform {
    struct User {
        string name;
        string phoneNumber;
        string email;
        string countryCode;
        // Additional parameters
        string addressLine1;
        string addressLine2;
        string pincode;
    }

    mapping(uint256 => User) public users;
    uint256 public nextUserId = 1;

    event UserCreated(
        uint256 userId,
        string name,
        string phoneNumber,
        string email,
        string countryCode,
        // Additional parameters in the event
        string addressLine1,
        string addressLine2,
        string pincode
    );

    event UserUpdated(
        uint256 userId,
        string name,
        string phoneNumber,
        string email,
        string countryCode,
        // Additional parameters in the event
        string addressLine1,
        string addressLine2,
        string pincode
    );

    function createUser(
        string memory _name,
        string memory _phoneNumber,
        string memory _email,
        string memory _countryCode,
        // Additional parameters in the function
        string memory _addressLine1,
        string memory _addressLine2,
        string memory _pincode
    ) public {
        uint256 userId = nextUserId;

        User storage newUser = users[userId];

        newUser.name = _name;
        newUser.phoneNumber = _phoneNumber;
        newUser.email = _email;
        newUser.countryCode = _countryCode;
        // Assigning additional parameters
        newUser.addressLine1 = _addressLine1;
        newUser.addressLine2 = _addressLine2;
        newUser.pincode = _pincode;

        nextUserId++;

        emit UserCreated(
            userId,
            _name,
            _phoneNumber,
            _email,
            _countryCode,
            // Emitting additional parameters
            _addressLine1,
            _addressLine2,
            _pincode
        );
    }

    function editUser(
        uint256 _userId,
        string memory _name,
        string memory _phoneNumber,
        string memory _email,
        string memory _countryCode,
        // Additional parameters to edit
        string memory _addressLine1,
        string memory _addressLine2,
        string memory _pincode
    ) public {
        User storage user = users[_userId];

        require(bytes(user.name).length > 0, "User does not exist");

        user.name = _name;
        user.phoneNumber = _phoneNumber;
        user.email = _email;
        user.countryCode = _countryCode;
        // Updating additional parameters
        user.addressLine1 = _addressLine1;
        user.addressLine2 = _addressLine2;
        user.pincode = _pincode;

        emit UserUpdated(
            _userId,
            _name,
            _phoneNumber,
            _email,
            _countryCode,
            // Emitting additional parameters
            _addressLine1,
            _addressLine2,
            _pincode
        );
    }
}
