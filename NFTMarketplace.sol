//SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

/// @title An NFT Marketplace for selling,buying fashion nfts
/// @author sana m ummer 
/// @notice You can use this contract for selling fashion item created here
/// @dev All function calls are currently implemented without side effects
/// @custom:project This is an project for CED course.

 contract NFTMarketplace is ERC721URIStorage{
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    
  /*tokenIds tracks the number of items minted
    tolenSold shows the no of items sold on the marketplace*/

    Counters.Counter private tokenIds;
    Counters.Counter private tokenSold;

  /// @notice setting var for marketplace owner or admin 
    address payable public immutable marketAdmin;
    uint public immutable listingFee;

    constructor(uint fee)ERC721("FashionToken", "FASH"){
        marketAdmin = payable(msg.sender);
        listingFee = fee;
    }

    struct Item{
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price; // in ether
      bool sold;
    }

    mapping(uint => Item)private idToItem;

    event ItemCreated(
      uint256 indexed tokenId,
      address payable seller,
      address payable owner,
      uint256 price,
      bool sold);
    
    ///@dev returns listing fee specified in the contract after deployment
    function getListingFee()public view returns(uint){
        return listingFee;
    }
  
    ///@dev to mint new token and list that into marketplace 
    function createItem(string memory tokenURI,uint256 price)public payable returns(uint){
        require(msg.value == listingFee,"Invalid amount");
        tokenIds.increment();
        uint256 newTokenId = tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        listItems(newTokenId,price);
        return newTokenId;
    }
    ///@dev to list item in marketplace
    function listItems(uint256 tokenId,uint256 price)public{
        require(price>0,"Price must be greater than zero");

        idToItem[tokenId] = Item(
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        price,
        false
        );
        _transfer(msg.sender, address(this), tokenId);
        emit ItemCreated(  
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        price,
        false);
    }
    /* allows someone to resell a token they have purchased */
    function resellToken(uint256 tokenId, uint256 price) public payable {
      require(idToItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
      require(msg.value == listingFee, "Price must be equal to listing price");
      idToItem[tokenId].sold = false;
      idToItem[tokenId].price = price;
      idToItem[tokenId].seller = payable(msg.sender);
      idToItem[tokenId].owner = payable(address(this));
      tokenSold.decrement();

      _transfer(msg.sender, address(this), tokenId);
    }
 
    ///@dev make items for sale by transferring fund and ownership between buyer and seller
    function executeSale(uint256 tokenId)public payable{
        uint price = idToItem[tokenId].price;
        address seller = idToItem[tokenId].seller;
        require(msg.value == price,"Invalid amount");
        idToItem[tokenId].owner = payable(msg.sender);
        idToItem[tokenId].sold = true;
        idToItem[tokenId].seller = payable(address(this));
        tokenSold.increment();
        _transfer(address(this),msg.sender,tokenId);
        payable(marketAdmin).transfer(listingFee);
        payable(seller).transfer(msg.value);
    }
    ///@dev to return all unsold item to market for sale
    function fetchItems()public view returns(Item[] memory){
        uint totalTokenCount = tokenIds.current();
        uint unsoldTokenCount = tokenIds.current() - tokenSold.current();
        uint index = 0 ;
        Item[] memory items = new Item[] (unsoldTokenCount);
        for(uint i=0; i< totalTokenCount; i++){
            if(idToItem[i+1].owner == address(this)){
                uint Id = i + 1;
                Item storage currentItem = idToItem[Id];
                items[index] = currentItem;
                index += 1;
            }
        }
        return items;
    }
    ///@dev to list items that has been purchased by user
    function fetchMyItem()public view returns(Item[] memory){
        uint totalTokenCount = tokenIds.current();
        uint itemCount = 0;
        uint index = 0;

      for (uint i = 0; i < totalTokenCount; i++) {
        if (idToItem[i + 1].owner == msg.sender) {
          itemCount += 1;
        }
      }
        Item[] memory items = new Item[] (itemCount);
        for(uint i=0; i< totalTokenCount; i++){
            if(idToItem[i+1].owner == msg.sender){
                uint Id = i+1;
                   Item storage currentItem = idToItem[Id];
                items[index] = currentItem;
                index += 1;
            }
        }
        return items;
    }
    ///@dev to fetch items that a particular user has isted on market
    function fetchListedItems() public view returns (Item[] memory) {
      uint totalTokenCount = tokenIds.current();
      uint itemCount = 0;
      uint index = 0;

      for (uint i = 0; i < totalTokenCount; i++) {
        if (idToItem[i + 1].seller == msg.sender) {
          itemCount += 1;
        }
      }

      Item[] memory items = new Item[](itemCount);
      for (uint i = 0; i < totalTokenCount; i++) {
        if (idToItem[i + 1].seller == msg.sender) {
          uint Id = i + 1;
          Item storage currentItem = idToItem[Id];
          items[index] = currentItem;
          index += 1;
        }
      }
      return items;
    }

}
