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

uint256 listPrice = 0.0001 ether;

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

function createToken(string memory tokenURI, uint256 price) 
public payable returns (uint){
require (msg.value == listPrice, "Please pay the list price to create a token");
require (price > 0, "Price must be greater than 0");

_tokenIds.increment();
uint256 currentTokenId = _tokenIds.current();
_safeMint(msg.sender, currentTokenId);

_setTokenURI(currentTokenId, tokenURI);

createListedToken(currentTokenId, price);

return currentTokenId;
}

function createListedToken(uint256 tokenId, uint256 price) private {
    idToListedToken[tokenId] = ListedToken(tokenId,
    payable (address(this)), 
    payable(msg.sender),
    price,
    true
      );
 _transfer(msg.sender, address(this), tokenId);
}

function getAllNFTs() public view returns (ListedToken[] memory) {
    uint nftCount = _tokenIds.current();
    ListedToken[] memory tokens = new ListedToken[](nftCount);


    uint currentIndex = 0;

    for (uint i = 1; i <= nftCount; i++) {
        uint currentId = i+1;
        ListedToken storage currentItem = idToListedToken[currentId];
        tokens[currentIndex] = currentItem;
        currentIndex += 1;
        }

        return tokens;
    }

    function getMyNFTs() public view returns (ListedToken[] memory) {

        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0; 
        uint currentIndex = 0;

        for (uint i=0; i < totalItemCount; i++) {
        
        if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller == msg.sender) {
            itemCount += 1;
        }
}


ListedToken[] memory items = new ListedToken[](itemCount);
for (uint i=0; i < totalItemCount; i++) {
    if(idToListedToken[i+1].owner == msg.sender || idToListedToken[i+1].seller == msg.sender) {
        uint currentId = i+1;
        ListedToken storage currentItem = idToListedToken[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
    }
 }

 return items;

    }

    function executeSale(uint256 tokenId) public payable {
    uint price = idToListedToken[tokenId].price;
    require(msg.value == price, "Please pay the asking price to execute the sale");

    // Get the seller's address
    address payable seller = idToListedToken[tokenId].seller;

    // Ensure the token is currently listed
    require(idToListedToken[tokenId].currentlyListed, "Token is not currently listed for sale");

    // Ensure the buyer is not the seller
    require(msg.sender != seller, "Seller cannot buy their own token");

    // Update token details to reflect the sale
    idToListedToken[tokenId].currentlyListed = false;
    idToListedToken[tokenId].seller = payable(msg.sender); // Update seller to the new owner
    idToListedToken[tokenId].owner = payable(msg.sender); // Update ownership
    _itemsSold.increment(); // Increment items sold counter

    // Transfer the token from the contract to the buyer
    _transfer(address(this), msg.sender, tokenId);

    // Transfer the listing fee to the marketplace owner
    payable(owner).transfer(listPrice);

    // Transfer the sale proceeds (minus the listing fee) to the seller
    seller.transfer(msg.value - listPrice);
}


    // function executeSale(uint256 tokenId) public payable {

    //     uint price = idToListedToken[tokenId].price;
    //     require(msg.value == price, "Please pay the asking price to execute the sale");


    //     address seller = idToListedToken[tokenId].seller;
       
       
    //     idToListedToken[tokenId].currentlyListed = true;
    //     idToListedToken[tokenId].seller = payable(msg.sender);
    //     _itemsSold.increment();



    //     payable(address(this), msg.sender, tokenId);

    //     approve(address(this), tokenId);

    //     payable(owner).transfer(listPrice);
    //     payable(seller).transfer(msg.value);

    // }

}