// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CustomerUserContract {
    struct CustomerUser {
        string name;
        string phoneNumber;
        string email;
        // Additional parameters for customer user
        string deliveryAddress;
    }

    mapping(address => CustomerUser) public customerUsers;

    event CustomerUserCreated(
        address userAddress,
        string name,
        string phoneNumber,
        string email,
        // Additional parameters in the event
        string deliveryAddress
    );

    event CustomerUserUpdated(
        address userAddress,
        string name,
        string phoneNumber,
        string email,
        // Additional parameters in the event
        string deliveryAddress
    );

    modifier onlyCustomerUser() {
        require(bytes(customerUsers[msg.sender].name).length > 0, "Not a registered customer user");
        _;
    }

    function createCustomerUser(
        string memory _name,
        string memory _phoneNumber,
        string memory _email,
        // Additional parameters in the function
        string memory _deliveryAddress
    ) public {
        CustomerUser storage newCustomerUser = customerUsers[msg.sender];

        newCustomerUser.name = _name;
        newCustomerUser.phoneNumber = _phoneNumber;
        newCustomerUser.email = _email;
        // Assigning additional parameters
        newCustomerUser.deliveryAddress = _deliveryAddress;

        emit CustomerUserCreated(
            msg.sender,
            _name,
            _phoneNumber,
            _email,
            // Emitting additional parameters
            _deliveryAddress
        );
    }

    function editCustomerUser(
        string memory _name,
        string memory _phoneNumber,
        string memory _email,
        // Additional parameters to edit
        string memory _deliveryAddress
    ) public onlyCustomerUser {
        CustomerUser storage user = customerUsers[msg.sender];

        user.name = _name;
        user.phoneNumber = _phoneNumber;
        user.email = _email;
        // Updating additional parameters
        user.deliveryAddress = _deliveryAddress;

        emit CustomerUserUpdated(
            msg.sender,
            _name,
            _phoneNumber,
            _email,
            // Emitting additional parameters
            _deliveryAddress
        );
    }
}
