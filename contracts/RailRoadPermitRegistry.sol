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
        require(_ownerOf(_tokenId) == msg.sender);
        _;
    }

    // ********************************************************************
    //  EXTERNAL
    // ********************************************************************

    // permit owner
    function premitOwner(uint256 _tokenId) external view returns (address) {
        return _ownerOf(_tokenId);
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
            _ownerOf(_tokenId)
        );
    }

    // ********************************************************************
    //  INTERNAL
    // ********************************************************************

    //add permit (internal)
    function _addPermit(uint256 _cardId, address _owner)
        internal
        returns (uint256 tokenId)
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

    function _permitCardId(uint256 _tokenId) internal view returns (uint256) {
        require(_isValidToken(_tokenId));
        return permits[_tokenId].cardId;
    }

    function _permitIssuedTime(uint256 _tokenId)
        internal
        view
        returns (uint256)
    {
        require(_isValidToken(_tokenId));
        return permits[_tokenId].issuedTime;
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        require(_isValidToken(_tokenId));
        return permits[_tokenId].owner;
    }

    function _isValidToken(uint256 _tokenId) internal view returns (bool) {
        return permits[_tokenId].cardId != 0;
    }
}
