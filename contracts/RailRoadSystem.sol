// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.7.0 <0.9.0;

library GuardsLib {

    function guardAgainstEmptyString(string memory args) public pure returns(bool){
        return bytes(args).length > 0;
    }

    function guardAgainstZeroUint256(uint256 args) public pure returns(bool){
        return args > 0;
    }

    function guardAgainstZeroUint(uint args) public pure returns(bool){
        return args > 0;
    }
}

library CardLib {

    struct Card {
        string id;
        string name;
        uint256 price;
        string imageUri;
        uint maxQuantity;
        uint256 discountRatio;
        string description;
        uint256 createdAt;
    }

    struct CardPurchased {
        string cardId ;
        string cardName;
        string cardImageUri;
        uint256 cardPrice;
        uint256 cardDiscountRatio;
        string cardDescription;
        address customer;
        uint256 createdAt;
    }

}

contract RailRoadSystem {

    address private owner;
    

    constructor (address _owner) {
        owner = _owner;
    }


    // *************************************************************
    // Storage for card
    // *************************************************************

    // cardId => Card
    mapping (string => CardLib.Card) public cards;

    // more here

    

    // *************************************************************
    // Events
    // *************************************************************
    
    event NewCard(string indexed name, uint256 indexed price);


    // *************************************************************
    // Modifier
    // *************************************************************

    // TODO : ..
    modifier onlyOwner {
        require(msg.sender == owner, "only Owner can invoke the function");
        _;
    }

    // *************************************************************
    // Functions
    // *************************************************************
    // 100000000000000000 wei --> 1eth
    function getOwner() public view returns(address){
        return owner;
    }
    
    function createCard(
        string memory _cardId,
        string memory _cardName,
        string memory _cardImageUri,
        string memory _cardDescription,
        uint256 _cardPrice,
        uint _cardMaxQuantity,
        uint256 _cardDiscountRatio

        ) onlyOwner public  {

        
        require(GuardsLib.guardAgainstEmptyString(_cardId), "card Id should not be empty.");
        require(GuardsLib.guardAgainstEmptyString(_cardName), "card name should not be empty.");
        require(GuardsLib.guardAgainstEmptyString(_cardImageUri), "card image url should not be empty.");
        require(GuardsLib.guardAgainstZeroUint256(_cardPrice), "you must provide a card price");
        require(GuardsLib.guardAgainstZeroUint256(_cardDiscountRatio), "you must provide a card discount ratio");
        require(GuardsLib.guardAgainstZeroUint(_cardMaxQuantity), "you must provide a card maximum quantity");

        CardLib.Card memory cardObject;

        cardObject = CardLib.Card({
            id : _cardId,
            name : _cardName,
            price : _cardPrice,
            imageUri : _cardImageUri,
            maxQuantity : _cardMaxQuantity,
            discountRatio : _cardDiscountRatio,
            description : _cardDescription,
            createdAt : block.timestamp
        });

        cards[_cardId] = cardObject;
        emit NewCard(_cardName, _cardPrice);
    }

}