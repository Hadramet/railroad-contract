// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./RailRoadPermitRegistry.sol";
import "./RailRoadERC721.sol";

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

    function balanceOf(address _owner)
        external
        view
        override
        returns (uint256)
    {
        return 0;
    }

    function ownerOf(uint256 _tokenId)
        external
        view
        override
        returns (address)
    {
        return address(0);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external payable override {}

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {}

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable override {}

    function approve(address _approved, uint256 _tokenId)
        external
        payable
        override
    {}

    function setApprovalForAll(address _operator, bool _approved)
        external
        override
    {}

    function getApproved(uint256 _tokenId)
        external
        view
        override
        returns (address)
    {
        return address(0);
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        override
        returns (bool)
    {
        return false;
    }

    function supportsInterface(bytes4 interfaceID)
        external
        view
        override
        returns (bool)
    {
        return
            interfaceID == this.supportsInterface.selector || // ERC165
            interfaceID == 0x6466353c; // ERC-721 on 3/7/2018
    }
}
