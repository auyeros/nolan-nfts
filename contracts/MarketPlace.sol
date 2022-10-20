// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract MarketPlace{
    
   // owner
address payable public owner;
  //high offer 
address highestBidder;
uint highestOffer;

IERC721 s_NFT;
   //emum
enum State {Active, Inactive, Canceled}  

struct Sale{
      address seller;
      uint256 nftId;
      uint256 price;
      State Status;
}

State public state = State.Inactive;

 //mappings
 mapping(address => uint) biddersData;
 mapping(uint256 => Sale) public s_sales;
 mapping(uint256 => uint256) public s_refNFTs;
mapping(uint256 => uint256) public s_security;



// counters
using Counters for Counters.Counter;

Counters.Counter s_counter;

//events
 event OferringPlaced(
         string placeOfer  
 );
event offeringClosed(
    string offerClosed
);
event balanceWithdrawn(
    string withdrawB
);
 event OperatorChanged(
  string newSate
);
event AuctionEnded(address winner, uint amount);


// function modifier
 modifier Onlyowner() {
       require(owner == msg.sender, "you need to be the project owner");
       _;
   }

     modifier securityFrontRunning(uint256 p_nftID){
          require(s_security[p_nftID] ==0 || s_security[p_nftID] > block.number, "error security");
          s_security[p_nftID] = block.number;
          _;
     }

   //constructor
constructor(){
    owner = payable(msg.sender);
}

   //changeOperator()
 function changeOperator(State newSate) public Onlyowner{
       state = newSate; 
       emit OperatorChanged("auction closed");// emit event
   }

   //placeOffering()
 function placeOfferring() public payable{
    //verify value is not zero 
    uint calculateAmount = biddersData[msg.sender] + msg.value;
    require (state == State.Active);
    require(msg.value >0, "bid amount cannot be 0");
    require(calculateAmount >highestOffer, "Highest bid alredy present");
    biddersData[msg.sender] = calculateAmount;
    highestOffer = calculateAmount;
    highestBidder=msg.sender;
    emit OferringPlaced("offer sent"); // emit event
}


//closeOffering function
 function closeOffering() public Onlyowner{
  require (state == State.Active);       

        emit AuctionEnded(highestBidder, highestOffer);
      // owner.transfer(highestOffer);
      state = State.Inactive;
      emit offeringClosed("Offering Closed"); // emit event
}
// highest offer
 function highestBid()public view returns (uint){
    return highestOffer;
}
// highest offer address
 function addressFromHB()public view returns(address){
    return highestBidder;
}
//viewBalance
 function viewBalance(address _address) public view returns(uint){
return biddersData[_address];
}
 function withdrawUserBalance(address payable _address) public {
    require(state == State.Active);
    
    if(biddersData[_address]>0){
        _address.transfer(biddersData[_address]);
    }
}


function viewOfferingNft() public view returns(address){
   
     return highestBidder;
}
//withdrawBalance from the dapp
function withdrawBalance()public payable Onlyowner{
    require(state == State.Inactive);
        owner.transfer(address(this).balance);
        emit balanceWithdrawn("balance of the dApp withdrawn"); // emit event 
    }
}