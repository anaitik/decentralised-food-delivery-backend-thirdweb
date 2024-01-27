// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CartContract {
    using SafeMath for uint256;

    struct CartItem {
        uint256 dishId;
        uint256 quantity;
    }

    mapping(address => CartItem[]) public userCarts;

    event ItemAddedToCart(address user, uint256 dishId, uint256 quantity);
    event ItemRemovedFromCart(address user, uint256 dishId, uint256 quantity);

    function addItemToCart(uint256 _dishId, uint256 _quantity) public {
        require(_quantity > 0, "Quantity must be greater than 0");

        address user = msg.sender;
        CartItem[] storage cart = userCarts[user];

        bool itemExists = false;

        for (uint256 i = 0; i < cart.length; i++) {
            if (cart[i].dishId == _dishId) {
                cart[i].quantity = cart[i].quantity.add(_quantity);
                itemExists = true;
                break;
            }
        }

        if (!itemExists) {
            cart.push(CartItem({ dishId: _dishId, quantity: _quantity }));
        }

        emit ItemAddedToCart(user, _dishId, _quantity);
    }

    function removeItemFromCart(uint256 _dishId, uint256 _quantity) public {
        require(_quantity > 0, "Quantity must be greater than 0");

        address user = msg.sender;
        CartItem[] storage cart = userCarts[user];

        for (uint256 i = 0; i < cart.length; i++) {
            if (cart[i].dishId == _dishId) {
                if (_quantity >= cart[i].quantity) {
                    _quantity = cart[i].quantity;
                    cart[i] = cart[cart.length - 1];
                    cart.pop();
                } else {
                    cart[i].quantity = cart[i].quantity.sub(_quantity);
                }

                emit ItemRemovedFromCart(user, _dishId, _quantity);
                break;
            }
        }
    }

    function getUserCart() public view returns (CartItem[] memory) {
        return userCarts[msg.sender];
    }
}
