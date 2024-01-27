// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract DeliveryUserContract {
    mapping(address => bool) public deliveryUsers;

    event DeliveryUserRegistered(address user);
    event DeliveryUserUnregistered(address user);

    modifier onlyDeliveryUser() {
        require(deliveryUsers[msg.sender], "Not a registered delivery user");
        _;
    }

    function registerAsDeliveryUser() public {
        require(!deliveryUsers[msg.sender], "Already registered as a delivery user");
        deliveryUsers[msg.sender] = true;
        emit DeliveryUserRegistered(msg.sender);
    }

    function unregisterAsDeliveryUser() public {
        require(deliveryUsers[msg.sender], "Not registered as a delivery user");
        delete deliveryUsers[msg.sender];
        emit DeliveryUserUnregistered(msg.sender);
    }
}
