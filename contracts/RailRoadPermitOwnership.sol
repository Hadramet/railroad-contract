// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "./RailRoadPermitRegistry.sol";

contract RailRoadPermitOwnership is
    RailRoadPermitRegistry,
    ERC721,
    Pausable,
    ERC721Enumerable
{
    constructor(string memory _name, string memory _symbole)
        ERC721(_name, _symbole)
    {}

    uint256[] _allTokenForSale;
    mapping(uint256 => uint256) private _tokenForSalePrice;

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setForSale(uint256 _tokenId, uint256 _price)
        external
        onlyOwnerOf(_tokenId)
    {
        require(_exists(_tokenId));
        require(_price > 0);

        _approve(address(this), _tokenId);
        _tokenForSalePrice[_tokenId] = _price;
        _allTokenForSale.push(_tokenId);

        address owner = ownerOf(_tokenId);
        emit Approval(owner, address(this), _tokenId);
    }

    function getTokenSalePrice(uint256 _tokenId) public view returns(uint256) {
        require(_exists(_tokenId));
        require(_isTokenForSale(_tokenId));
        return _tokenForSalePrice[_tokenId];
    }

    function removeTokenForSale(uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        require(_exists(_tokenId));
        require(_isTokenForSale(_tokenId));

        delete _tokenForSalePrice[_tokenId];
        delete _allTokenForSale[_tokenId];
    }

    function _isTokenForSale(uint256 _tokenId) internal view returns(bool) {
        return _tokenForSalePrice[_tokenId] != 0 ;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
