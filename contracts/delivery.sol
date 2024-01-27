// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Delivery {
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

    function createDelivery(
        uint256 _orderId,
        uint256 _restaurantId,
        uint256 _customerId,
        address _deliveryAddress,
        uint256 _deliveryFee,
        uint256 _estimatedDeliveryTime
    ) public {
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

    function updateDeliveryStatus(uint256 _deliveryId, uint256 _deliveryStatus) public {
        Delivery storage delivery = deliveries[_deliveryId];

        require(delivery.deliveryId > 0, "Delivery does not exist");
        require(_deliveryStatus >= 0 && _deliveryStatus <= 3, "Invalid delivery status");

        delivery.deliveryStatus = _deliveryStatus;

        emit DeliveryStatusUpdated(_deliveryId, _deliveryStatus);
    }

    function getDeliveryStatus(uint256 _deliveryId) public view returns (uint256) {
        return deliveries[_deliveryId].deliveryStatus;
    }

    function completeDelivery(uint256 _deliveryId, uint256 _actualDeliveryTime, uint256 _customerRating) public {
        Delivery storage delivery = deliveries[_deliveryId];

        require(delivery.deliveryId > 0, "Delivery does not exist");
        require(delivery.deliveryStatus == 1, "Cannot complete a non-transit or cancelled delivery");
        require(_customerRating >= 0 && _customerRating <= 5, "Invalid customer rating");

        delivery.deliveryStatus = 2; // Set delivery status to delivered
        delivery.actualDeliveryTime = _actualDeliveryTime;
        delivery.customerRating = _customerRating;

        emit DeliveryCompleted(_deliveryId, _actualDeliveryTime, _customerRating);
    }

    function cancelDelivery(uint256 _deliveryId) public {
        Delivery storage delivery = deliveries[_deliveryId];

        require(delivery.deliveryId > 0, "Delivery does not exist");
        require(delivery.deliveryStatus == 0 || delivery.deliveryStatus == 1, "Cannot cancel delivered or cancelled orders");

        delivery.deliveryStatus = 3; // Set delivery status to cancelled

        emit DeliveryStatusUpdated(_deliveryId, 3); // Emitting cancelled status
    }

    function getDeliveryInfo(uint256 _deliveryId) public view returns (Delivery memory) {
        return deliveries[_deliveryId];
    }

    function calculateDeliveryCost(uint256 _deliveryId) public view returns (uint256) {
        Delivery memory delivery = deliveries[_deliveryId];
        return delivery.deliveryFee;
    }
}
