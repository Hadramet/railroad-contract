// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
