// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./RailRoadPermitOwnership.sol";

/**
 * @title RailRoad is the entry point of the contract
 */
contract RailRoad is RailRoadPermitOwnership {
    constructor() {
        ownerAddress = msg.sender;
        withdrawalAddress = msg.sender;
    }

    function setWithdrawalAddress(address _newWithdrawalAddress)
        external
        onlyOwner
    {
        require(_newWithdrawalAddress != address(0));
        withdrawalAddress = _newWithdrawalAddress;
    }

    ///// Selling Permit

    function buyPermit(uint256 _cardId, uint256 _quantity)
        external
        payable
        returns (uint256)
    {
        require(
            _isCardExist(_cardId),
            "Should provide a valid card informations."
        );
        require(_quantity != 0, "Quantity to buy must be more that zero.");
        require(
            msg.value == costForNumberOf(_cardId, _quantity),
            "Value should be equale to the price of the card times the quantity."
        );

        _purchaseOneCard(_cardId);

        uint256 _newPermitId = _addPermit(_cardId, msg.sender);

        _mint(msg.sender, _newPermitId);

        // TODO : Get the money

        return 0;
    }
}
