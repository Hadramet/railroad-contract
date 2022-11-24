// SPDX-License-Identifier: MIT
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
        uint256 id;
        string cardId ;
        string cardName;
        string cardImageUri;
        uint256 cardPrice;
        uint256 cardDiscountRatio;
        string cardDescription;
        address customer;
        uint256 createdAt;
    }

    enum Status { PENDING, COMPLETED, CANCEL }

    struct CardPuchasedTransaction{
        uint256 id;
        
        string  cardPurchasedId;
        string  cardPurchasedName;
        uint256 cardPurchasedPrice;
        string  cardPurchasedImageUri;
        string  cardPurchasedDescription;

        uint256 Price; // Selling price specified by card owner        
        address Owner;
        address Buyer;
        Status  State;
        bool    lock;
        uint256 lockedAt;
        uint256 createdAt;
    }
}

contract RailRoadSystem {

    address private owner;
    uint256 private purchaseCardCounts;

    
    // cardId => Card
    mapping(string => CardLib.Card) public cards;

    
    mapping(address => bool) isCustomer;
    
    // customerAddress => purchasedCardId
    mapping(address => CardLib.CardPurchased[] ) public customerPurchasedCard;
    mapping(uint256 => CardLib.CardPurchased) private _cardPurchased;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event NewCard(string indexed name, uint256 indexed price);


    modifier onlyOwner {
        require(msg.sender == owner, "only Owner can invoke the function");
        _;
    }

    modifier onlyCustomer() {
        require(
            isCustomer[msg.sender],
            "Only customer that have already bought some cards."
        );
        _;
    }

    constructor () {
        owner = payable(msg.sender);
        emit OwnerSet(address(0), owner);
    }

    // TODO : get list of purchased card for user
    function getCardPurchased() public view onlyCustomer returns(CardLib.CardPurchased[] memory){
        uint256 cardsPurchasedCount = customerPurchasedCard[msg.sender].length;
        
        CardLib.CardPurchased[] memory cardsPurchased = new CardLib.CardPurchased[](cardsPurchasedCount);
        for (uint256 i = 0; i < cardsPurchasedCount; i++) {
            cardsPurchased[i] = customerPurchasedCard[msg.sender][i];
        }

        return cardsPurchased;
    }
    // TODO : get list of avalaible card to buy

    function addPurchasedCard(address _user, string memory _cardId) 
    internal returns(uint256){

        // get the card
        CardLib.Card storage card = cards[_cardId] ;
        
        // add card purchased
        purchaseCardCounts++;
        CardLib.CardPurchased memory cardPurshased;
        cardPurshased = CardLib.CardPurchased({
            id: purchaseCardCounts,
            cardId: _cardId,
            cardName : card.name,
            cardImageUri: card.imageUri,
            cardPrice: card.price,
            cardDiscountRatio: card.discountRatio,
            cardDescription : card.description,
            customer: _user,
            createdAt : block.timestamp
        });

        // add customerPurchasedCard
        customerPurchasedCard[_user].push(cardPurshased);        
        isCustomer[_user] = true;

        // reduce the card max quantity
        card.maxQuantity--;

        return purchaseCardCounts;
    }

    function purchaseCard(string memory _cardId) payable 
    public returns(uint256) {

        CardLib.Card storage card = cards[_cardId] ;

        require(card.maxQuantity > 0, "There is not enough of this type of card for sales.");
        require(msg.value == card.price, "The amount sent does not cover the price of the card");
        
        (bool sent, ) =  payable(owner).call{value: msg.value}("");

        require(sent, "Failed to send Ether");
        
        (uint256 result) = addPurchasedCard(msg.sender, _cardId);

        return result;

    }

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