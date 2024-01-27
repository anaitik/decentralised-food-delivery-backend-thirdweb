// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DeliveryContract.sol";

contract DeliveryTrackingContract is Ownable {
    DeliveryContract public deliveryContract;

    event DeliveryStatusTracked(uint256 deliveryId, uint256 deliveryStatus);

    constructor(address _deliveryContractAddress) {
        deliveryContract = DeliveryContract(_deliveryContractAddress);
    }

    modifier onlyDeliveryUser(uint256 _deliveryId) {
        require(deliveryContract.getDeliveryInfo(_deliveryId).deliveryAddress == msg.sender, "Not authorized as delivery user");
        _;
    }

    function trackDeliveryStatus(uint256 _deliveryId) public onlyDeliveryUser(_deliveryId) {
        DeliveryContract.Delivery memory delivery = deliveryContract.getDeliveryInfo(_deliveryId);
        emit DeliveryStatusTracked(_deliveryId, delivery.deliveryStatus);
    }
}

