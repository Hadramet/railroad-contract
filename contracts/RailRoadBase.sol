// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract RailRoadBase {

    address public ownerAddress;
    address public withdrawalAddress;

    modifier onlyOwner() {
        require(msg.sender == ownerAddress);
        _;
    }

    struct Card {
        uint256 id;
        uint256 price;
        uint256 discount;
        uint256 available;
        uint256 sold;
        uint256 totalSellable; //immutable
        string uri;
    }

    struct Permit {
        uint256 cardId;
        uint256 issuedTime;
        address owner;
    }


}
