// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DeliveryContract is Ownable {
    struct Delivery {
        uint256 deliveryId;
        uint256 orderId;
        uint256 restaurantId;
        uint256 customerId;
        address deliveryAddress;
        uint256 deliveryStatus; // 0: Pending, 1: In Transit, 2: Delivered, 3: Cancelled
        uint256 deliveryFee;
        uint256 estimatedDeliveryTime; // in minutes
        uint256 actualDeliveryTime; // in minutes
        uint256 customerRating; // 0 (unrated) to 5 (excellent)
    }

    mapping(uint256 => Delivery) public deliveries;
    uint256 public nextDeliveryId = 1;

    event DeliveryCreated(uint256 deliveryId, uint256 orderId, uint256 restaurantId, uint256 customerId, address deliveryAddress, uint256 estimatedDeliveryTime);
    event DeliveryStatusUpdated(uint256 deliveryId, uint256 deliveryStatus);
    event DeliveryCompleted(uint256 deliveryId, uint256 actualDeliveryTime, uint256 customerRating);
    event DeliveryCancelled(uint256 deliveryId);
    event DeliveryRewardPaid(uint256 deliveryId, address deliveryUser, uint256 rewardAmount);

    modifier onlyDeliveryUser(uint256 _deliveryId) {
        require(deliveries[_deliveryId].deliveryAddress == msg.sender, "Not authorized as delivery user");
        _;
    }

    function createDelivery(
        uint256 _orderId,
        uint256 _restaurantId,
        uint256 _customerId,
        address _deliveryAddress,
        uint256 _deliveryFee,
        uint256 _estimatedDeliveryTime
    ) public onlyOwner {
        uint256 deliveryId = nextDeliveryId;

        deliveries[deliveryId] = Delivery({
            deliveryId: deliveryId,
            orderId: _orderId,
            restaurantId: _restaurantId,
            customerId: _customerId,
            deliveryAddress: _deliveryAddress,
            deliveryStatus: 0, // Set delivery status to pending
            deliveryFee: _deliveryFee,
            estimatedDeliveryTime: _estimatedDeliveryTime,
            actualDeliveryTime: 0,
            customerRating: 0
        });

        nextDeliveryId++;

        emit DeliveryCreated(deliveryId, _orderId, _restaurantId, _customerId, _deliveryAddress, _estimatedDeliveryTime);
    }

    function updateDeliveryStatus(uint256 _deliveryId, uint256 _deliveryStatus) public onlyOwner {
        Delivery storage delivery = deliveries[_deliveryId];

        require(delivery.deliveryId > 0, "Delivery does not exist");
        require(_deliveryStatus >= 0 && _deliveryStatus <= 3, "Invalid delivery status");

        if (delivery.deliveryStatus != _deliveryStatus) {
            delivery.deliveryStatus = _deliveryStatus;

            if (_deliveryStatus == 2) {
                // If the delivery is completed, emit an event and pay the reward to the delivery user
                emit DeliveryCompleted(_deliveryId, delivery.actualDeliveryTime, delivery.customerRating);
                payDeliveryReward(_deliveryId, delivery.deliveryAddress);
            } else if (_deliveryStatus == 3) {
                // If the delivery is cancelled, emit an event and refund the delivery user
                emit DeliveryCancelled(_deliveryId);
                refundDeliveryReward(_deliveryId, delivery.deliveryAddress);
            } else {
                emit DeliveryStatusUpdated(_deliveryId, _deliveryStatus);
            }
        }
    }

    function completeDelivery(uint256 _deliveryId, uint256 _actualDeliveryTime, uint256 _customerRating) public onlyOwner {
        Delivery storage delivery = deliveries[_deliveryId];

        require(delivery.deliveryId > 0, "Delivery does not exist");
        require(delivery.deliveryStatus == 1, "Cannot complete a non-transit or cancelled delivery");
        require(_customerRating >= 0 && _customerRating <= 5, "Invalid customer rating");

        delivery.deliveryStatus = 2; // Set delivery status to delivered
        delivery.actualDeliveryTime = _actualDeliveryTime;
        delivery.customerRating = _customerRating;

        emit DeliveryCompleted(_deliveryId, _actualDeliveryTime, _customerRating);
        payDeliveryReward(_deliveryId, delivery.deliveryAddress);
    }

    function cancelDelivery(uint256 _deliveryId) public onlyOwner {
        Delivery storage delivery = deliveries[_deliveryId];

        require(delivery.deliveryId > 0, "Delivery does not exist");
        require(delivery.deliveryStatus == 0 || delivery.deliveryStatus == 1, "Cannot cancel delivered or cancelled orders");

        delivery.deliveryStatus = 3; // Set delivery status to cancelled

        emit DeliveryCancelled(_deliveryId);
        refundDeliveryReward(_deliveryId, delivery.deliveryAddress);
    }

    function getDeliveryInfo(uint256 _deliveryId) public view returns (Delivery memory) {
        return deliveries[_deliveryId];
    }

    function calculateDeliveryCost(uint256 _deliveryId) public view returns (uint256) {
        Delivery memory delivery = deliveries[_deliveryId];
        return delivery.deliveryFee;
    }

    function payDeliveryReward(uint256 _deliveryId, address _deliveryUser) internal {
        // In a real-world scenario, you might use a token contract for rewards.
        // Here, we'll transfer Ether for simplicity.
        uint256 rewardAmount = deliveries[_deliveryId].deliveryFee;
        payable(_deliveryUser).transfer(rewardAmount);

        emit DeliveryRewardPaid(_deliveryId, _deliveryUser, rewardAmount);
    }

    function refundDeliveryReward(uint256 _deliveryId, address _deliveryUser) internal {
        // Refund the delivery user in case of cancellation
        uint256 refundAmount = deliveries[_deliveryId].deliveryFee;
        payable(_deliveryUser).transfer(refundAmount);
    }
}
