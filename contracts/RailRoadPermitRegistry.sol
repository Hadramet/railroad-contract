// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./RailRoadCardRegistry.sol";

contract RailRoadPermitRegistry is RailRoadCardRegistry {
    struct Permit {
        uint256 cardId;
        uint256 issuedTime;
        address owner;
    }

    event PermitPurchased(
        address indexed owner,
        address indexed purchaser,
        uint256 permitId,
        uint256 cardId,
        uint256 issuedTime
    );

    /// @dev For now we are using the lenght of this tab
    /// as token id for the permit.
    /// @dev can use more advance structure for storing permits
    Permit[] permits;

    modifier onlyOwnerOf(uint256 _tokenId) {
        require(_permitOwner(_tokenId) == msg.sender);
        _;
    }

    // ********************************************************************
    //  EXTERNAL
    // ********************************************************************

    // permit owner
    function premitOwner(uint256 _tokenId) external view returns (address) {
        return _permitOwner(_tokenId);
    }

    // permit infos
    function permitInfos(uint256 _tokenId)
        external
        view
        returns (
            uint256,
            uint256,
            address
        )
    {
        return (
            _permitCardId(_tokenId),
            _permitIssuedTime(_tokenId),
            _permitOwner(_tokenId)
        );
    }

    // ********************************************************************
    //  INTERNAL
    // ********************************************************************

    //add permit (internal)
    function _addPermit(uint256 _cardId, address _owner)
        internal
        returns (uint256)
    {
        require(_isCardExist(_cardId));
        require(_owner != address(0));

        uint256 _issuedTime = block.timestamp;

        Permit memory _permit = Permit({
            cardId: _cardId,
            issuedTime: _issuedTime,
            owner: _owner
        });

        permits.push(_permit);

        uint256 _permitId = permits.length - 1;

        emit PermitPurchased(
            address(0),
            _owner,
            _permitId,
            _cardId,
            _issuedTime
        );

        return _permitId;
    }

    function _permitCardId(uint256 _permitId) internal view returns (uint256) {
        require(_isValidPermit(_permitId));
        return permits[_permitId].cardId;
    }

    function _permitIssuedTime(uint256 _permitId)
        internal
        view
        returns (uint256)
    {
        require(_isValidPermit(_permitId));
        return permits[_permitId].issuedTime;
    }

    function _permitOwner(uint256 _permitId) internal view returns (address) {
        require(_isValidPermit(_permitId));
        return permits[_permitId].owner;
    }

    function _isValidPermit(uint256 _permitId) internal view returns (bool) {
        return permits[_permitId].cardId != 0;
    }
}
