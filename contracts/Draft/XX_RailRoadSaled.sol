// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./RailRoadOwnership.sol";

contract RailRoadSale is RailRoadCardOwnerShip {
    function purchase(
        uint256 _discountId,
        uint256 _quantity,
        address _for
    ) external payable returns (uint256) {
        require(_discountId != 0);
        require(_for != address(0));
        require(_quantity != 0);
        require(msg.value == costForDiscountQuantity(_discountId, _quantity));

        uint256 _spec = uint256(keccak256(bytes.concat(blockhash(block.number - 1)))) ^
            _discountId ^
            (uint256(uint160(_for)));

        uint256 _cardId = _performPurchase(
            _discountId,
            _quantity,
            _for,
            _spec
        );

        if (priceOf(_discountId) > 0  && _for != address(0)){
            //TODO : Get the money
        }
    }

    function _performPurchase(
        uint256 _discountId,
        uint256 _quantity,
        address _for,
        uint256 _spec
    ) internal returns (uint256) {
        _soldOneDiscount(_discountId);
        return _createCard(_discountId, _quantity, _for, _spec);
    }

    function _createCard(
        uint256 _discountId,
        uint256 _quantity,
        address _for,
        uint256 _spec
    ) internal returns (uint256) {
        Card memory _card = Card({
            discountId: _discountId,
            specification: _spec,
            issuedTime: block.timestamp,
            affiliate: _for
        });

        // address indexed owner,
        // address indexed purchaser,
        // uint256 cardId,
        // uint256 discountId,
        // uint256 specification,
        // uint256 issuedTime,
        // uint256 affiliate

        cards.push(_card);
        uint256 newCardId = cards.length - 1;

        emit CardIssued(
            _for,
            msg.sender,
            newCardId,
            _card.discountId,
            _card.specification,
            _card.issuedTime
        );

        _mint(_for, newCardId);
        return newCardId;
    }
}
