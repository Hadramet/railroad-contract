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
}
