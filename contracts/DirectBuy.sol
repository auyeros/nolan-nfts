// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Marketplace{
    //state 
  IERC721 s_NFTs;

  address isOwner;
 //state of contract 

  enum Status{
        Inactive,
        Active,
        Cancelled
    }
  
  struct Sale {
      address owner;
      uint256 nftID;
      uint256 price;
      Status status;
  }
        
//mappings        
  mapping(uint256 => Sale) public s_sales;
  mapping(uint256 => uint256) s_refNFTs;
  mapping(uint256 => uint256) s_security;

//counters
  using Counters for Counters.Counter;
  Counters.Counter s_counter;

//modifier
//only owner
  modifier onlyOwner{
      isOwner == payable(msg.sender);
      _;
  }
//securityFrontRunning security
  modifier securityFrontRunning(uint256 p_nftID){
      require(
          s_security[p_nftID] == 0 || s_security[p_nftID] > block.number,
           "error security");
               
          s_security[p_nftID] = block.number;
          _;         
  }
       //constructor
       constructor(address p_NftsContract){
           s_NFTs = IERC721(p_NftsContract);
       }

     function openSale(uint256 p_nftID, uint256 p_price) public securityFrontRunning(p_nftID) onlyOwner{
         if(s_refNFTs[p_nftID] == 0){
             s_NFTs.transferFrom(msg.sender, address(this), p_nftID);

             s_counter.increment();
             s_sales[s_counter.current()] = Sale(
                 msg.sender,
                 p_nftID,
                 p_price,
                 Status.Active
             );
             s_refNFTs[p_nftID] = s_counter.current(); 
         }else{
             uint256 pos = s_refNFTs[p_nftID];
             require(msg.sender == s_sales[pos].owner,
             "not allowed");
             s_NFTs.transferFrom(msg.sender, address(this), p_nftID);
             s_sales[pos].status = Status.Active;
             s_sales[pos].price = p_price;
         }

     }   
       

       function cancelSale(uint p_nftID) public securityFrontRunning(p_nftID) onlyOwner{
         uint256 pos = s_refNFTs[p_nftID];

         require(
           msg.sender == s_sales[pos].owner, "you need be a owner");
         require(s_sales[pos].status == Status.Active);
         s_sales[pos].status = Status.Cancelled;
         s_NFTs.transferFrom(address(this), s_sales[pos].owner, p_nftID);
       }

       function buy(uint p_nftID) public securityFrontRunning(p_nftID){
         uint256 pos = s_refNFTs[p_nftID];
         require(s_sales[pos].status == Status.Active, "The buy is not active");
         address oldOwner = s_sales[pos].owner;
         uint256 price = s_sales[pos].price;
         s_sales[pos].owner = msg.sender;
         s_sales[pos].status = Status.Inactive;
        // require(value.transferFrom(msg.sender, oldOwner, price), "error transfer token");

       }

}