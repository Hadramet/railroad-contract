// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library RailRoadMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     *  @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
}

library RailRoadRes {
    string constant invalid_address = "Invalid address provided";
    string constant invalid_owner_addr = "Invalid owner address";
    string constant invalid_card = "Should provide a valid card informations.";
    string constant invalid_card_quantity = "Quantity is less than zero";
    string constant invalid_card_value = "Value is not price * quantity.";
    string constant invalid_index = "Invalid index";
    string constant sender_not_approved = "Sender not approved";
    string constant sender_not_opperator = "Action forbiden for the operator";
    string constant sender_not_owner = "Action forbiden for the owner";
    string constant invalid_token_owner = "Invalid owner";
    string constant invalid_permit = "Permit id not valid";

    string constant receiver_not_erc721 = "Receiver does not implement ERC721";
}
