// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./RailRoadLib.sol";
import "./RailRoadInventory.sol";

interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the
    /// recipient after a `transfer`. This function MAY throw to revert and reject the transfer. Return
    /// of other than the magic value MUST result in the transaction being reverted.
    /// @notice The contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    /// unless throwing
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) external returns (bytes4);
}

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f
/* is ERC721 */
interface ERC721Metadata {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external pure returns (string memory _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external pure returns (string memory _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

contract RailRoadCardOwnerShip is RailRoadInventory, ERC165, ERC721Metadata {
    using RailRoadMath for uint256;
    /// @dev ERC721 this emits when ownership of any Card NFT changes by any mechanism.
    /// This event emits when Card NFTs are created (`from` == 0) and destroyed
    /// (`to` == 0). Exception : during contract creation, any number of NFTs
    /// may be created and assigned without emitting Transfer. At the time of any
    /// transfer, the approved address fro that NFT (if any) is reset to none.
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    /// @dev ERC721 This emits when the approved address for an NFT is changed or
    /// reaffirmed. The zero address indicates there is no approved address.
    /// When a Transfer event emits, this also indicates that the approved
    /// address for that NFT (if any) is reset to none.
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    /// @dev ERC721 This emits when an operator is enabled or disabled for an owner.
    /// The operator can manage all NFTs of the owner.
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    // Total amount of tokens
    uint256 private totalTokens;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private ownedTokens;

    // Mapping from token ID to owner
    mapping(uint256 => address) private tokenOwners;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private tokenApprovals;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private ownedTokensIndex;

    // Mapping from owner address to operator address to approval
    mapping(address => mapping(address => bool)) private operatorApprovals;

    modifier onlyOwnerOf(uint256 _tokenId) {
        require(_ownerOf(_tokenId) == msg.sender);
        _;
    }

    string public constant NAME = "RailRoad";
    string public constant SYMBOL = "ETH";
    string public tokenMetadataBaseURI = "https://api.railroad.io/";

    function name() external pure override returns (string memory) {
        return NAME;
    }

    function symbol() external pure override returns (string memory) {
        return SYMBOL;
    }

    function tokenURI(uint256 _tokenId)
        external
        view
        override
        returns (string memory infoUrl)
    {
        return tokenMetadataBaseURI;
    }

    /// @notice ERC721 Find the owner of an NFT
    /// @dev 1 - NFTs assigned to zero address are considered invalid, and this
    /// function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return  The number of NFTs owned by `_owner`, possibly zero.
    function balanceOf(address _owner) external view returns (uint256) {
        return _balanceOf(_owner);
    }

    /// @notice ERC721 Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    /// about them do throw.
    /// @param _tokenId the identifier for an NFT
    /// @return the address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _ownerOf(_tokenId);
    }

    /// @notice ERC721 Transfers the ownership of an NFT from one address to another
    ///
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    /// operator, or the approved address for this NFT.
    /// @dev Throws if `_from` not the current owner.
    /// @dev Throws if `_to` is zero address.
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @dev When transfer is complete, this function checks if `_to` is a smart contract (code size > 0).
    /// If so, it calls `onERC721Received` on `_to` and throws if the return value is not
    /// ``bytes4(keccak256("onERC21Received(address,address,uint256,bytes)"))`.
    ///
    /// @param _from the current owner of the NFT
    /// @param _to the new owner
    /// @param _tokenId the NFT to transfer
    /// @param _data additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external payable {
        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    /// @notice Transfers the ownership of an NFT from one address to another addres
    /// @dev This works identically to the other function with an extra data parameter,
    /// except this function just sets data to ""
    ///
    /// @param _from the current owner of the NFT
    /// @param _to the new owner
    /// @param _tokenId the NFT to transfer.
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    /// TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE THEY MAY BE
    /// PERMANENTLY LOST
    ///
    /// @dev Throws unless `msg.sender` is the current owner, an authorize operator,
    /// or the approved address for this NFT.
    /// @dev Throws `_tokenId` is not a valid NFT.
    ///
    /// @param _from the current owner of the NFT
    /// @param _to the new owner
    /// @param _tokenId the NFT to transfer.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _transferFrom(_from, _to, _tokenId);
    }

    /// @notice Set or reaffirm the approved address for an NFT
    ///
    /// @dev The zero address indicates there is no approved address.
    /// @dev Throws unless `msg.sender` is the current NFT owner, or an auhorized operator,
    /// or the current owner.
    ///
    /// @param _approved the new approved NFT controller
    /// @param _tokenId the NFT to approve.
    function approve(address _approved, uint256 _tokenId)
        external
        payable
        onlyOwnerOf(_tokenId)
    {
        _approve(_approved, _tokenId);
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage all of
    /// `msg.sender`'s assets.
    ///
    /// @dev Emits the approvalforAll event. The contract MUST allow multiple operators
    /// per owner.
    ///
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operator is approved, false to revoke approval.
    function setApprovalForAll(address _operator, bool _approved) external {
        _setApprovalForAll(_operator, _approved);
    }

    /// @notice Get the approved address fro a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT
    ///
    /// @param _tokenId the NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if is none
    function getApproved(uint256 _tokenId) external view returns (address) {
        return tokenApprovals[_tokenId];
    }

    /// @notice Query if an address is an authorized operator for another address
    ///
    /// @param _owner the address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner.
    /// @return True if `_operatorr` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator)
        external
        view
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
            interfaceID == this.supportsInterface.selector || //ERC165
            // interfaceID == 0x5b5e139f || // ERC721Metadata
            interfaceID == 0x6466353c; //| // ERC-721 on 3/7/2018
        // interfaceID == 0x780e9d63; // ERC721Enumerable
    }

    /// INTERNAL //////////////////////////////////////////////////////////////////////////

    function _mint(address _to, uint256 _tokenId) internal {
        require(_to != address(0));
        _addToken(_to, _tokenId);
        _transferFrom(address(0), _to, _tokenId);
    }

    function _setApprovalForAll(address _operator, bool _approved) internal {
        require(_operator != msg.sender);
        require(_operator != address(0));

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
        require(_approved != owner);
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
        require(_isApprovedSender(_tokenId));
        require(_ownerOf(_tokenId) == _from);
        require(_to != address(0));
        require(_isValidCard(_tokenId)); // RailRoadBase

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
                    )
            );
        }
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        require(_isApprovedSender(_tokenId));
        require(_ownerOf(_tokenId) == _from);
        require(_to != address(0));
        require(_to != _ownerOf(_tokenId));
        require(_isValidCard(_tokenId));

        // Clear approval
        tokenApprovals[_tokenId] = address(0);
        emit Approval(_from, address(0), _tokenId);

        // Remove token
        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = _balanceOf(_from).sub(1);
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];

        tokenOwners[_tokenId] = address(0);
        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;

        ownedTokens[_from].pop();
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
        totalTokens = totalTokens.sub(1);

        // add token
        _addToken(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function _addToken(address _to, uint256 _tokenId) private {
        require(tokenOwners[_tokenId] == address(0));
        tokenOwners[_tokenId] = _to;
        uint256 length = _balanceOf(_to);
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
        totalTokens = totalTokens.add(1);
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        address owner = tokenOwners[_tokenId];
        require(owner != address(0));
        return owner;
    }

    function _balanceOf(address _owner) internal view returns (uint256) {
        require(_owner != address(0));
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
