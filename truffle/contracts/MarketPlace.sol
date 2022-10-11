// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract MarketPlace{
// owner
 address payable public owner;
 //high offer 
 address highestBidder;
 uint highestOffer;
 //emum
 enum State {Active, Inactive}  
 State public state = State.Inactive;
 mapping(address => uint) biddersData;


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

constructor(){
    owner = payable(msg.sender);
}
// function modifier
 modifier Onlyowner() {
       require(owner == msg.sender, "you need to be the project owner");
       _;
   }

   //changeOperator()
 function changeOperator(State newSate) public Onlyowner{
       state = newSate; 
       emit OperatorChanged("auction closed");
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


function viewOfferingNft() public view {
     
}
//withdrawBalance from the dapp
function withdrawBalance()public payable Onlyowner{
    require(state == State.Inactive);
        owner.transfer(address(this).balance);
        emit balanceWithdrawn("balance of the dApp withdrawn"); // emit event 
    }
}