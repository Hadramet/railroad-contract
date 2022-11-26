// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./RailRoadLib.sol";
import "./RailRoadBase.sol";

contract RailRoadInventory is RailRoadBase {
    using RailRoadMath for uint256;

    event DiscountCreated(
        uint256 id,
        uint256 price,
        uint256 discount,
        uint256 avalaible
    );
    event DiscountInventoryUpdated(uint256 id, uint256 avalaible);
    event DiscountPriceUpdated(uint256 id, uint256 price);

    struct Discount {
        uint256 id;
        uint256 price;
        uint256 discount;
        uint256 avalaible;
        uint256 sold;
    }

    // @notice all discount in existence
    uint256[] public allDiscountIds;

    // @notice a mapping from discount id to discount
    mapping(uint256 => Discount) public discounts;

    // **************************************************************************
    //  INTERNAL
    // **************************************************************************

    function _discountExists(uint256 _discountId) internal view returns (bool) {
        return discounts[_discountId].id != 0;
    }

    function _discountDoesNotExist(uint256 _discountId)
        internal
        view
        returns (bool)
    {
        return discounts[_discountId].id == 0;
    }

    function _createDiscount(
        uint256 _discountId,
        uint256 _initialDiscount,
        uint256 _initialPrice,
        uint256 _initialQuantity
    ) internal {
        require(_discountDoesNotExist(_discountId));
        require(_initialQuantity > 0);
        require(_initialDiscount > 0);

        Discount memory _discount = Discount({
            id: _discountId,
            price: _initialPrice,
            discount: _initialDiscount,
            avalaible: _initialQuantity,
            sold: 0
        });

        discounts[_discountId] = _discount;
        allDiscountIds.push(_discountId);

        emit DiscountCreated(
            _discount.id,
            _discount.price,
            _discount.discount,
            _discount.avalaible
        );
    }

    function _increaseInventory(uint256 _discountId, uint256 _value) internal {
        require(_discountExists(_discountId));
        uint256 newQuantity = discounts[_discountId].avalaible.add(_value);
        discounts[_discountId].avalaible = newQuantity;
    }

    function _decreaseInventory(uint256 _discountId, uint256 _value) internal {
        require(_discountExists(_discountId));
        uint256 newQuantity = discounts[_discountId].avalaible.sub(_value);
        discounts[_discountId].avalaible = newQuantity;
    }

    function _clearInventory(uint256 _discountId) internal {
        require(_discountExists(_discountId));
        discounts[_discountId].avalaible = 0;
    }

    function _availableInventory(uint256 _discountId)
        internal
        view
        returns (uint256)
    {
        require(_discountExists(_discountId));
        return discounts[_discountId].avalaible;
    }

    function _increaseSoldByOne(uint256 _discountId) internal {
        require(_discountExists(_discountId));
        discounts[_discountId].sold = discounts[_discountId].sold.add(1);
    }

    function _soldOneDiscount(uint256 _discountId) internal {
        require(_discountExists(_discountId));
        require(_availableInventory(_discountId) > 0);

        _decreaseInventory(_discountId, 1);
        _increaseSoldByOne(_discountId);
    }

    function _setPrice(uint256 _discountId, uint256 _price) internal {
        require(_discountExists(_discountId));
        discounts[_discountId].price = _price;
    }

    // **************************************************************************
    //  EXTERNAL API
    // **************************************************************************

    /**
     * @notice createDiscount creates a new discount in the system
     * @param _discountId - the id of the product to use (cannot be changed)
     * @param _initialDiscount - discount value  (cannot be changed)
     * @param _initialPrice - the starting price (price can be changed)
     * @param _initialQuantity - the initial inventory (inventory can be changed)
     */
    function createDiscount(
        uint256 _discountId,
        uint256 _initialDiscount,
        uint256 _initialPrice,
        uint256 _initialQuantity
    ) external onlyOwner {
        _createDiscount(
            _discountId,
            _initialDiscount,
            _initialPrice,
            _initialQuantity
        );
    }

    /**
     * @notice increaseInventory - increments the inventory of a discount
     * @param _discountId - the discount id
     * @param _value - the amount to increment
     */
    function increaseInventory(uint256 _discountId, uint256 _value)
        external
        onlyOwner
    {
        _increaseInventory(_discountId, _value);
        emit DiscountInventoryUpdated(
            _discountId,
            _availableInventory(_discountId)
        );
    }

    /**
     * @notice decreaseInventory - decrements the inventory of a discount
     * @param _discountId - the discount id
     * @param _value - the amount to decrement
     */
    function decreaseInventory(uint256 _discountId, uint256 _value)
        external
        onlyOwner
    {
        _decreaseInventory(_discountId, _value);
        emit DiscountInventoryUpdated(
            _discountId,
            _availableInventory(_discountId)
        );
    }

    /**
     * @notice clearInventory - clear the inventory of a discount
     * @param _discountId - the discount id
     * @dev set the available amount to zero
     */
    function clearInventory(uint256 _discountId) external onlyOwner {
        _clearInventory(_discountId);
        emit DiscountInventoryUpdated(
            _discountId,
            _availableInventory(_discountId)
        );
    }

    /**
     * @notice setPrice - set the price of the discount
     * @param _discountId - the discount id
     * @param _price - the discount new price
     */
    function setPrice(uint256 _discountId, uint256 _price) external onlyOwner {
        _setPrice(_discountId, _price);
        emit DiscountPriceUpdated(_discountId, _price);
    }

    /**
     * @notice The price of the discount
     * @param _discountId - the discount id
     */
    function priceOf(uint256 _discountId) public view returns (uint256) {
        require(_discountExists(_discountId));
        return discounts[_discountId].price;
    }

    /**
     * @notice The available inventory of the discount
     * @param _discountId - the discount id
     */
    function availableOf(uint256 _discountId) public view returns (uint256) {
        return _availableInventory(_discountId);
    }

    /**
     * @notice The discount card sold
     * @param _discountId - the discount id
     */
    function totalSold(uint256 _discountId) public view returns (uint256) {
        require(_discountExists(_discountId));
        return discounts[_discountId].sold;
    }

    /**
     * @notice The discount value in percent
     * @param _discountId - the discount id
     */
    function discountOf(uint256 _discountId) public view returns (uint256) {
        require(_discountExists(_discountId));
        return discounts[_discountId].discount;
    }

    /**
     * @notice The discount info
     * @param _discountId - the discount id
     */
    function discountInfo(uint256 _discountId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        require(_discountExists(_discountId));
        return (
            priceOf(_discountId),
            availableOf(_discountId),
            discountOf(_discountId),
            totalSold(_discountId)
        );
    }

    /**
     * @notice Get all discount ids
     */
    function getAllDiscountIds() public view returns (uint256[] memory) {
        return allDiscountIds;
    }

    function costForDiscountQuantity(uint256 _discountId, uint256 _quantity)
        public
        view
        returns (uint256)
    {
        return priceOf(_discountId).mul(_quantity);
    }
}
