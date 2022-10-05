// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract MarketPlace{

 address payable public owner; 

 enum State {Active, Inactive}  

 State public state = State.Inactive;

mapping(address => uint) biddersData;

uint calculateAmount = biddersData[msg.sender] + msg.value;

constructor(){

    owner = payable(msg.sender);
}

 modifier Onlyowner() {
       require(owner == msg.sender, "you need to be the project owner");
       _;
   }
   
   function changeOperator(State newSate) public Onlyowner{
       state = newSate;
   }
function putBid() public payable{
    //verify value is not zero 
    require (state == State.Active);
     require(msg.value >0, "bid amount cannot be 0");
    biddersData[msg.sender] = msg.value;
}

function getBidderBid(address _address) public view returns(uint){
return biddersData[_address];

}
function withdrawBalance()public payable Onlyowner{
        owner.transfer(address(this).balance);
    }
}