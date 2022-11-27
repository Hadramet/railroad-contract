// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./RailRoadCardRegistry.sol";


/**
 * @title RailRoad is the entry point of the contract
 */
contract RailRoad is RailRoadCardRegistry {
    

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

    ///// CARD

    

    

    
}
