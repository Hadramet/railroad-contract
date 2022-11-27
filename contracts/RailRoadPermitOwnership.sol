// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./RailRoadPermitRegistry.sol";
import "./RailRoadERC721.sol";
import {RailRoadRes as Res} from "./RailRoadLib.sol";

contract RailRoadPermitOwnership is RailRoadPermitRegistry, RailRoadERC721 {

    // Total amount of tokens
    uint256 private totalTokens;

    // Mapping from token ID to owner
    mapping(uint256 => address) private tokenOwner;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private tokenApprovals;

    // Mapping from owner address to operator address to approval
    mapping(address => mapping(address => bool)) private operatorApprovals;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private ownedTokensIndex;

    function totalSupply() public view returns (uint256) {
        return totalTokens;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < totalSupply(), Res.invalid_index);
        return _index;
    }

    function balanceOf(address _owner)
        external
        view
        override
        returns (uint256)
    {
        require(_owner != address(0), Res.invalid_address);
        return ownedTokens[_owner].length;
    }

    function ownerOf(uint256 _tokenId)
        external
        view
        override
        returns (address)
    {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0), Res.invalid_owner_addr);
        return owner;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external payable override {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {
        require(_isApprovedSender(_tokenId), Res.sender_not_approved);
        _transferFrom(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId)
        external
        payable
        override
        onlyOwnerOf(_tokenId)
    {
        _approve(_approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved)
        external
        override
    {
        _setApprovalForAll(_operator, _approved);
    }

    function getApproved(uint256 _tokenId)
        external
        view
        override
        returns (address)
    {
        return tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        override
        returns (bool)
    {
        return operatorApprovals[_owner][_operator];
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceID == this.supportsInterface.selector || // ERC165
            interfaceID == 0x80ac58cd; // ERC-721
    }

    // ********************************************************************
    //  INTERNAL
    // ********************************************************************

    function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0), Res.invalid_address);
        _addToken(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    function _setApprovalForAll(address _operator, bool _approved) internal {
        require(_operator != msg.sender, Res.sender_not_opperator);
        require(_operator != address(0), Res.invalid_address);

        if (_approved) {
            operatorApprovals[msg.sender][_operator] = true;
            emit ApprovalForAll(msg.sender, _operator, true);
        } else {
            delete operatorApprovals[msg.sender][_operator];
            emit ApprovalForAll(msg.sender, _operator, false);
        }
    }

    function _approve(address _approved, uint256 _tokenId) internal {
        address owner = _ownerOf(_tokenId);
        require(_approved != owner, Res.sender_not_owner);
        if (tokenApprovals[_tokenId] != address(0) || _approved != address(0)) {
            tokenApprovals[_tokenId] = _approved;
            emit Approval(owner, _approved, _tokenId);
        }
    }

    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal {
        require(_isApprovedSender(_tokenId), Res.sender_not_approved);
        require(_ownerOf(_tokenId) == _from, Res.invalid_token_owner);
        require(_to != address(0), Res.invalid_address);
        require(_isValidPermit(_tokenId), Res.invalid_permit); // RailRoadBase

        _transferFrom(_from, _to, _tokenId);

        if (_isSmartContract(_to)) {
            bytes4 tokenReceiver = ERC721TokenReceiver(_to).onERC721Received{
                gas: 50000
            }(_to, _from, _tokenId, _data);
            require(
                tokenReceiver ==
                    bytes4(
                        keccak256(
                            "onERC721Received(address,address,uint256,bytes)"
                        )
                    ),
                Res.receiver_not_erc721
            );
        }
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        require(_to != address(0), Res.invalid_address);
        require(_to != _ownerOf(_tokenId), Res.sender_not_owner);
        require(_isValidPermit(_tokenId), Res.invalid_permit);

        // Clear approval
        require(_ownerOf(_tokenId) == _from, Res.invalid_owner_addr);
        tokenApprovals[_tokenId] = address(0);
        emit Approval(_from, address(0), _tokenId);

        // Remove token
        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = _balanceOf(_from) - 1;
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];

        tokenOwner[_tokenId] = address(0);
        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;

        ownedTokens[_from].pop();
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
        totalTokens--;

        // add token
        _addToken(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function _addToken(address _to, uint256 _tokenId) private {
        require(tokenOwner[_tokenId] == address(0), Res.invalid_address);
        tokenOwner[_tokenId] = _to;
        uint256 length = _balanceOf(_to);
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
        totalTokens++;
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0), Res.invalid_address);
        return owner;
    }

    function _balanceOf(address _owner) internal view returns (uint256) {
        require(_owner != address(0), Res.invalid_address);
        return ownedTokens[_owner].length;
    }

    function _isSmartContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function _isApprovedSender(uint256 _tokenId) internal view returns (bool) {
        return _ownerOf(_tokenId) == msg.sender;
    }
}
