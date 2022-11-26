// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./RailRoadAccessControl.sol";

contract RailRoadBase is RailRoadAccessControl {

    /**
     * @notice CardSold is emitted when a new card is issued
     */
   event CardIssued(
        address indexed owner,
        address indexed purchaser,
        uint256 cardId,
        uint256 discountId,
        uint256 specification,
        uint256 issuedTime
    );

    struct Card {
        uint256 discountId;
        uint256 specification;
        uint256 issuedTime;
        address affiliate;
    }

    /**
     * @notice All card sold in existence.
     * @dev The ID of each card is an index in this array.
     */
    Card[] cards;

    // ** INTERNAL ** //
    function _cardDiscountId(uint256 _cardId) internal view returns(uint256){
        return cards[_cardId].discountId;
    }

    function _isValidCard(uint256 _cardId) internal view returns(bool){
        return _cardDiscountId(_cardId) != 0 ;
    }

    //** EXTERNAL **//

    /**
     * @notice Get a card's discountId
     * @param _cardId the card id
     */
    function cardDiscountId(uint256 _cardId) public view returns(uint256) {
        require(_isValidCard(_cardId));
        return _cardDiscountId(_cardId);
    }

    /**
     * @notice Get a card's specification
     * @param _cardId the card id
     */
    function cardSpecification(uint256 _cardId) public view returns(uint256){
        require(_isValidCard(_cardId));
        return cards[_cardId].specification;
    }

    /**
     * @notice Get a card's sale time
     * @param _cardId the card id
     */
    function cardSaleTime(uint256 _cardId) public view returns(uint256){
        require(_isValidCard(_cardId));
        return cards[_cardId].issuedTime;
    }

    /**
     * @notice Get the affiliate credited for the sale of this license
     * @param _cardId the card id
     */
    function cardAffiliate(uint256 _cardId) public view returns(address){
        require(_isValidCard(_cardId));
        return cards[_cardId].affiliate;
    }

    
    /**
     * @notice Get a card's info
     * @param _cardId the card id
     */
    function cardInfo(uint256 _cardId) 
        public view returns (uint256, uint256, uint256, address)
    {
        return(
            cardDiscountId(_cardId),
            cardSpecification(_cardId),
            cardSaleTime(_cardId),
            cardAffiliate(_cardId)
        );
    }
}