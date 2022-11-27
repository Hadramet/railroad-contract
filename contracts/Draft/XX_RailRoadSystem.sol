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
        
        uint256 cardPurchasedId;
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

    address private _owner;
    uint256 private _purchaseCardCounter;
    uint256 private _transactionCounter;


    mapping(address => bool) _isCustomer;
    mapping(string => CardLib.Card) public cards;    
    mapping(address => CardLib.CardPurchased[]) private _customerPurchasedCard;

    CardLib.CardPuchasedTransaction[] private _cardTransactionRegistry;



    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event NewCard(string indexed name, uint256 indexed price);


    modifier onlyOwner {
        require(
            msg.sender == _owner,
            "only Owner can invoke the function");
        _;
    }

    modifier onlyCustomer() {
        require(
            _isCustomer[msg.sender],
            "Only customer that have already bought some cards."
        );
        _;
    }

    constructor () {
        _owner = payable(msg.sender);
        emit OwnerSet(address(0), _owner);
    }

    

    function userHasCard(uint256 _card) private view returns(bool) {
        uint256 cardsPurchasedCount = _customerPurchasedCard[msg.sender].length;
        bool result = false;

        for (uint256 i = 0; i < cardsPurchasedCount; i++) {
            if ( _customerPurchasedCard[msg.sender][i].id == _card ){
                result = true;
                break;
            }
        }

        return result;
    }

    function _getUserCard(address _user, uint256 _card) 
    private view returns(CardLib.CardPurchased memory) {
        uint256 cardsPurchasedCount = _customerPurchasedCard[_user].length;
        CardLib.CardPurchased memory result;

        for (uint256 i = 0; i < cardsPurchasedCount; i++) {
            if ( _customerPurchasedCard[_user][i].id == _card ){
                result =  _customerPurchasedCard[_user][i];
                break;
            }
        }

        return result;
    }

    function _getUserCardIndex(address _user, uint256 _card) 
    private view returns(uint256) {
        uint256 cardsPurchasedCount = _customerPurchasedCard[_user].length;
        uint256 result;

        for (uint256 i = 0; i < cardsPurchasedCount; i++) {
            if ( _customerPurchasedCard[_user][i].id == _card ){
                result =  i;
                break;
            }
        }

        return result;
    }

    // 1000000000000000000 
    function isValidTransaction(uint256 _transactionId) private view returns(bool) {
        uint256 count = _cardTransactionRegistry.length;
        bool result = false;
        for (uint256 i = 0; i < count; i++) {
            if ( _cardTransactionRegistry[i].id == _transactionId ){
                result =true;
                break;
            }
        }
        return result;
    }
    function _getTransactionIndex(uint256 _transactionId) private view returns(uint256) {
        uint256 count = _cardTransactionRegistry.length;
        uint256 result ;
        for (uint256 i = 0; i < count; i++) {
            if ( _cardTransactionRegistry[i].id == _transactionId ){
                result = i;
                break;
            }
        }
        return result;
    }

    function buyUserCard(uint256 _transactionId) public payable  {
        require(isValidTransaction(_transactionId), "This transaction is not registerd");

        uint256 transactionInex = _getTransactionIndex(_transactionId);
        CardLib.CardPuchasedTransaction storage transaction = _cardTransactionRegistry[transactionInex];

        require(transaction.State == CardLib.Status.PENDING, "This transaction can no longer be proceed");
        require(!transaction.lock, "The transaction has been locked");
        require(msg.value == transaction.Price, "The amount sent does not cover the price of the card");

        (bool sent, ) =  payable(transaction.Owner).call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        // REFACTOR
        // get purchased card
        CardLib.CardPurchased memory card = _getUserCard(transaction.Owner, transaction.cardPurchasedId);
        uint256 cardIndex = _getUserCardIndex(transaction.Owner, transaction.cardPurchasedId);

        // set purchased card to buyer
        card.customer = msg.sender;

        // add buyer card 
         _customerPurchasedCard[msg.sender].push(card);        
        _isCustomer[msg.sender] = true;

        // remove purchased card from owner
        delete _customerPurchasedCard[transaction.Owner][cardIndex];
        
        // update transaction in registry and lock
        transaction.Buyer = msg.sender;
        transaction.State = CardLib.Status.COMPLETED;
        transaction.lock  = true;
        transaction.lockedAt = block.timestamp;

    }

    function getCardSellgRegistry() public view returns(CardLib.CardPuchasedTransaction[] memory){
        return _cardTransactionRegistry;
    }


    function registerCardForSell(uint256 _card) public onlyCustomer {
        require(userHasCard(_card), "No card correspond to this id");

        CardLib.CardPurchased memory card = _getUserCard(msg.sender,_card);

        CardLib.CardPuchasedTransaction memory transaction;
        transaction = CardLib.CardPuchasedTransaction({
            id: _transactionCounter,
            cardPurchasedId: card.id,
            cardPurchasedName: card.cardName,
            cardPurchasedPrice : card.cardPrice,
            cardPurchasedImageUri: card.cardImageUri,
            cardPurchasedDescription: card.cardDescription, 
            Price : card.cardPrice,   
            Owner : msg.sender,
            Buyer : address(0),
            State : CardLib.Status.PENDING,
            lock  : false, 
            lockedAt: 0,
            createdAt: block.timestamp
        });

        _cardTransactionRegistry.push(transaction);
    }

    function getCardPurchased() public view onlyCustomer returns(CardLib.CardPurchased[] memory){
        uint256 cardsPurchasedCount = _customerPurchasedCard[msg.sender].length;
        
        CardLib.CardPurchased[] memory cardsPurchased = new CardLib.CardPurchased[](cardsPurchasedCount);
        for (uint256 i = 0; i < cardsPurchasedCount; i++) {
            cardsPurchased[i] = _customerPurchasedCard[msg.sender][i];
        }

        return cardsPurchased;
    }

    // TODO : get list of avalaible card to buy

    function _addPurchasedCard(address _user, string memory _cardId) private returns(uint256){

        // get the card
        CardLib.Card storage card = cards[_cardId] ;
        
        // add card purchased
        _purchaseCardCounter++;
        CardLib.CardPurchased memory cardPurshased;
        cardPurshased = CardLib.CardPurchased({
            id: _purchaseCardCounter,
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
        _customerPurchasedCard[_user].push(cardPurshased);        
        _isCustomer[_user] = true;

        // reduce the card max quantity
        card.maxQuantity--;

        return _purchaseCardCounter;
    }

    function purchaseCard(string memory _cardId) payable public returns(uint256) {

        CardLib.Card storage card = cards[_cardId] ;

        require(card.maxQuantity > 0, "There is not enough of this type of card for sales.");
        require(msg.value == card.price, "The amount sent does not cover the price of the card");
        
        (bool sent, ) =  payable(_owner).call{value: msg.value}("");

        require(sent, "Failed to send Ether");
        
        (uint256 result) = _addPurchasedCard(msg.sender, _cardId);

        return result;

    }

    function getOwner() public view returns(address){
        return _owner;
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