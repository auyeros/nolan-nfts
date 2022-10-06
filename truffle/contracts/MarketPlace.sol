// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract MarketPlace{

 address payable public owner;
 //high offer 
 address highestBidder;
 uint highestOffer;

 //emum
 enum State {Active, Inactive}  

 State public state = State.Inactive;

mapping(address => uint) biddersData;



constructor(){

    owner = payable(msg.sender);
}

 modifier Onlyowner() {
       require(owner == msg.sender, "you need to be the project owner");
       _;
   }

   //changeOperator()
function changeOperator(State newSate) public Onlyowner{
       state = newSate;
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
}
// highest offer
function highestBid()public view returns(uint){
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

//withdrawBalance from the dapp
function withdrawBalance()public payable Onlyowner{
        owner.transfer(address(this).balance);
    }
}