// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./RailRoadBase.sol";

contract RailRoadCardRegistry is RailRoadBase {

    uint256[] private allCardIds;
    mapping(uint256 => Card) private cards;

    event NewCard(
        uint256 id,
        uint256 price,
        uint256 discount,
        uint256 totalSellable
    );
    event CardStockUpdated(uint256 id, uint256 available);
    event CardPriceUpdated(uint256 id, uint256 newPrice);
    event CardUriUpdated(uint256 id, string  uri);


    // ********************************************************************
    //  EXTERNAL
    // ********************************************************************

     // Get all card id
    function getAllCardIds() external view returns (uint256[] memory) {
        return allCardIds;
    }

    // Create cards
    function addCard(
        uint256 _id,
        uint256 _price,
        uint256 _discount,
        uint256 _totalSellable
    ) external onlyOwner {
        _addCard(_id, _price, _discount, _totalSellable);
    }

    // Set card price
    function setPrice(uint256 _cardId, uint256 _price) external onlyOwner {
        require(_isCardExist(_cardId));
        cards[_cardId].price = _price;
        emit CardPriceUpdated(_cardId, _price);
    }

    // Set card InfoUri
    function setUri(uint256 _cardId, string memory _uri) external onlyOwner {
        require(_isCardExist(_cardId));
        cards[_cardId].uri = _uri;
        emit CardUriUpdated(_cardId, _uri);
    }

    // Cost for number of Card
    function costForNumberOf(uint256 _cardId, uint256 number) public view returns(uint256) {
        require(_isCardExist(_cardId));
        return cards[_cardId].price * number;
    }

    // Get card Infos
    function getInfos(uint256 _cardId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            string memory
        )
    {
        return (
            _getPrice(_cardId),
            _getDiscount(_cardId),
            _getAvailable(_cardId),
            _getSold(_cardId),
            _getTotalSellable(_cardId),
            _getUri(_cardId)
        );
    }

    // ********************************************************************
    //  INTERNAL
    // ********************************************************************

    function _purchaseOneCard(uint256 _cardId) internal {
        require(_isCardExist(_cardId));
        require(cards[_cardId].available > 0);

        cards[_cardId].available--;
        cards[_cardId].sold++;

        emit CardStockUpdated(_cardId, cards[_cardId].available);
    }

    function _getPrice(uint256 _cardId) internal view returns (uint256) {
        require(_isCardExist(_cardId));
        return cards[_cardId].price;
    }

    function _getDiscount(uint256 _cardId) internal view returns (uint256) {
        require(_isCardExist(_cardId));
        return cards[_cardId].discount;
    }

    function _getAvailable(uint256 _cardId) internal view returns (uint256) {
        require(_isCardExist(_cardId));
        return cards[_cardId].available;
    }

    function _getSold(uint256 _cardId) internal view returns (uint256) {
        require(_isCardExist(_cardId));
        return cards[_cardId].sold;
    }

    function _getTotalSellable(uint256 _cardId)
        internal
        view
        returns (uint256)
    {
        require(_isCardExist(_cardId));
        return cards[_cardId].totalSellable;
    }

    function _getUri(uint256 _cardId) internal view returns (string memory) {
        require(_isCardExist(_cardId));
        return cards[_cardId].uri;
    }

    function _addCard(
        uint256 _id,
        uint256 _price,
        uint256 _discount,
        uint256 _totalSellable
    ) internal {
        require(!_isCardExist(_id), "Card id already exist");
        require(_totalSellable > 0);
        require(_discount > 0);

        Card memory _card = Card({
            id: _id,
            price: _price,
            discount: _discount,
            available: _totalSellable,
            sold: 0,
            totalSellable: _totalSellable,
            uri: ""
        });

        cards[_id] = _card;
        allCardIds.push(_id);

        emit NewCard(_id, _price, _discount, _totalSellable);
    }

    function _isCardExist(uint256 _cardId) internal view returns (bool) {
        return cards[_cardId].id != 0;
    }
}