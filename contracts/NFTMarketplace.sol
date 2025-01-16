//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NFTMarketplace is ERC721URIStorage {


address payable owner;

using Counters for Counters.Counter;
Counters.Counter private _tokenIds;
Counters.Counter private _itemsSold;

uint256 listPrice = 0.001 ether;

    constructor () ERC721("NFTMarketplace", "NFTM") {

        owner = payable(msg.sender);
    }



struct ListedToken {
    uint256 tokenId;
    address payable owner;
    address payable seller;
    uint256 price;
    bool currentlyListed;
}

mapping(uint256 => ListedToken) private idToListedToken;

function updateListPrice(uint256 _listPrice) public payable {
    require(owner == msg.sender, "Only the owner can update the list price");
    listPrice = _listPrice;
}

function getListPrice() public view returns (uint256) {
    return listPrice;
}

function getLatestIdToListedToken() public view returns (ListedToken memory) {
 uint256 currentTokenId = _tokenIds.current();
 return idToListedToken[currentTokenId];

}

function getListedForTokenId(uint256 tokenId) public view returns (ListedToken memory) {
    return idToListedToken[tokenId];
}

function getCurrentTokenId() public view returns (uint256) {
    return _tokenIds.current();
}