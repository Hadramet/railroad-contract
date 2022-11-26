// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract RailRoadAccessControl {
    
    /**
     * @notice Owner address
     */
    address public ownerAddress;

    /**
     * @notice withdrawal address
     */
    address public withdrawalAddress;

    /**
     * @dev Modifier to make a function only callable by owner
     */
    modifier onlyOwner() {
        require(msg.sender == ownerAddress);
        _;
    }

    /**
     * @notice Set a new withdrawal Address
     * @param _newWithdrawalAddress - the address where we'll send the funds
     */
    function setWithdrawalAddress(address _newWithdrawalAddress) external onlyOwner{
        require(_newWithdrawalAddress != address(0));
        withdrawalAddress = _newWithdrawalAddress;
    }

    /**
     * @notice Withdraw the balance to the withdrawalAddress
     * @dev we use a withdrawal address to separate from the owner.
     */
    function withdrawBalance() external onlyOwner {
        require(withdrawalAddress != address(0));
        payable(withdrawalAddress).transfer(address(this).balance);
    }
}