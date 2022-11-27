// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import {RailRoadRes as Res} from "./RailRoadLib.sol";


contract RailRoadBase is Ownable {

    address public withdrawalAddress;

    struct Card {
        uint256 id;
        uint256 price;
        uint256 discount;
        uint256 available;
        uint256 sold;
        uint256 totalSellable; //immutable
        string uri;
    }

    
    function setWithdrawalAddress(address _newWithdrawalAddress)
        external
        onlyOwner
    {
        require(_newWithdrawalAddress != address(0), Res.invalid_address);
        withdrawalAddress = _newWithdrawalAddress;
    }
}
