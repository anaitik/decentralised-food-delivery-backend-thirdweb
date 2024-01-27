// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract NotificationSystem is Ownable {
    enum NotificationType { OrderStatus, Promotion }

    struct Subscription {
        bool isSubscribed;
        mapping(NotificationType => bool) notificationTypes;
    }

    mapping(address => Subscription) public userSubscriptions;

    event SubscriptionStatusChanged(address user, bool isSubscribed, NotificationType notificationType);

    function subscribeToNotification(NotificationType _notificationType) public {
        require(_notificationType == NotificationType.OrderStatus || _notificationType == NotificationType.Promotion, "Invalid notification type");

        Subscription storage subscription = userSubscriptions[msg.sender];
        subscription.isSubscribed = true;
        subscription.notificationTypes[_notificationType] = true;

        emit SubscriptionStatusChanged(msg.sender, true, _notificationType);
    }

    function unsubscribeFromNotification(NotificationType _notificationType) public {
        require(_notificationType == NotificationType.OrderStatus || _notificationType == NotificationType.Promotion, "Invalid notification type");

        Subscription storage subscription = userSubscriptions[msg.sender];
        subscription.notificationTypes[_notificationType] = false;

        // If no notification types are subscribed, set overall subscription status to false
        if (!subscription.notificationTypes[NotificationType.OrderStatus] && !subscription.notificationTypes[NotificationType.Promotion]) {
            subscription.isSubscribed = false;
        }

        emit SubscriptionStatusChanged(msg.sender, false, _notificationType);
    }

    function isUserSubscribed(address _user) public view returns (bool) {
        return userSubscriptions[_user].isSubscribed;
    }

    function getNotificationTypes(address _user) public view returns (bool, bool) {
        Subscription storage subscription = userSubscriptions[_user];
        return (subscription.notificationTypes[NotificationType.OrderStatus], subscription.notificationTypes[NotificationType.Promotion]);
    }

    // Owner/Admin functions

    function setSubscriptionStatus(address _user, bool _isSubscribed) public onlyOwner {
        userSubscriptions[_user].isSubscribed = _isSubscribed;
        emit SubscriptionStatusChanged(_user, _isSubscribed, NotificationType.OrderStatus);
        emit SubscriptionStatusChanged(_user, _isSubscribed, NotificationType.Promotion);
    }

    function setNotificationTypeStatus(address _user, NotificationType _notificationType, bool _status) public onlyOwner {
        require(_notificationType == NotificationType.OrderStatus || _notificationType == NotificationType.Promotion, "Invalid notification type");
        userSubscriptions[_user].notificationTypes[_notificationType] = _status;
        emit SubscriptionStatusChanged(_user, _status, _notificationType);
    }
}
