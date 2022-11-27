// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./RailRoadPermitOwnership.sol";
import {RailRoadRes as Res} from "./RailRoadLib.sol";

contract RailRoad is RailRoadPermitOwnership {
    constructor() RailRoadPermitOwnership("RailRoad", "RRO") {
        withdrawalAddress = msg.sender;
    }

    function buyPermit(uint256 _cardId, uint256 _quantity)
        external
        payable
        returns (uint256)
    {
        require(_isCardExist(_cardId), Res.invalid_card);
        require(_quantity != 0, Res.invalid_card_quantity);
        require(
            msg.value == costForNumberOf(_cardId, _quantity),
            Res.invalid_card_value
        );

        _purchaseOneCard(_cardId);

        uint256 _newPermitId = _addPermit(_cardId, msg.sender);

        _mint(msg.sender, _newPermitId);

        // TODO : Get the money

        return _newPermitId;
    }

    function buyPermitToken(uint256 _tokenId) external payable {

        address buyer = msg.sender;
        uint256 payedPrice = msg.value;

        require(_exists(_tokenId));
        require(getApproved(_tokenId) == address(this));
        require(payedPrice == getTokenSalePrice(_tokenId));

        // TODO: 
        // pay the seller      

        transferFrom(ownerOf(_tokenId), buyer, _tokenId);

        removeTokenForSale(_tokenId);
    }
}
