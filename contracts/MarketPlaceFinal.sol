//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract MarketPlaceNFT is ReentrancyGuard{
//state variables
  
address payable public immutable feeAccount; // account receives fees
uint public immutable feePercent;
uint public itemCount;

struct Item{
    uint itemId;
    IERC721 nft;
    uint tokenId;
    uint price;
    address payable seller;
    bool sold;
}
 

 mapping(uint => Item) public items;


constructor(uint256 _feePercent){
    feeAccount = payable(msg.sender);
    feePercent = _feePercent;
}


//functions
   function makeItem(IERC721 _nft, uint _tokenId, uint _price) external nonReentrant{
       require(_price > 0, "price must be greater than zero");
       itemCount ++;
        
       _nft.transferFrom(msg.sender, address(this), _tokenId);

       items[itemCount] = Item(
           itemCount,
           _nft,
           _tokenId,
           _price,
           payable(msg.sender),
           false
       );
       emit offer(
           itemCount,
           address(_nft),
           _tokenId,
           _price,
           msg.sender
       );

   }
//buy direct
   function buyItem(uint _itemId) external payable nonReentrant{
       uint _totalPrice = getTotalPrice(_itemId);
       Item storage item = items[_itemId];      
       require(!item.sold, "item already sold");
       require(msg.value == _totalPrice, "not enough ether to cover item price and market fee");
       item.seller.transfer(item.price);
       feeAccount.transfer(_totalPrice - item.price);
       item.sold = true; // 
       item.nft.transferFrom(address(this), msg.sender, item.tokenId); // trasnfer the nft to the buyer
   }


   function getTotalPrice(uint _itemId) public view returns(uint){
      return(items[_itemId].price*(100 + feePercent )/100);
   }



///events
 event offer(
    uint itemId,
    address indexed nft,
    uint tokenId,
    uint price,
    address indexed seller
  );

}