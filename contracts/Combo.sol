// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Marketplace{
    //state 
  IERC721 s_NFTs;

  address  payable  isOwner;

// state in The sale
  enum Status{
        Inactive,
        Active,
        Cancelled
    }
 //state of contract 
    enum StateOfAuction {Active, Inactive, Canceled}  


  StateOfAuction public stateA = StateOfAuction.Inactive;


  struct Sale {
      address owner;
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
       constructor (address p_NftsContract){
           s_NFTs = IERC721(p_NftsContract);
       }

    function openSale(uint256 p_nftID, uint256 p_price) public securityFrontRunning(p_nftID) {
        if (s_sales[p_nftID].owner == address(0)) {
            s_NFTs.transferFrom(msg.sender, address(this), p_nftID);

            s_sales[p_nftID] = Sale(
                msg.sender,
                p_price,
                Status.Active
            );
        } else {
            require(
                msg.sender == s_sales[p_nftID].owner,
                "Without permission"
            );

            s_NFTs.transferFrom(msg.sender, address(this), p_nftID);

            s_sales[p_nftID].status = Status.Active;
            s_sales[p_nftID].price = p_price;
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

         function buy(uint256 p_nftID, uint256 p_price) public  securityFrontRunning(p_nftID) {
        require(s_sales[p_nftID].status == Status.Active, "Is not Open");

        address oldOwner = s_sales[p_nftID].owner;
        uint256 price = s_sales[p_nftID].price;
        
        require(price == p_price, "Manipulated price");

        s_sales[p_nftID].owner = msg.sender;
        s_sales[p_nftID].status = Status.Inactive;

       // require(s_token.transferFrom(msg.sender, oldOwner, price), "Error transfer token - price");
       // require(s_token.transferFrom(msg.sender, address(this), (price / 100) * 3), "Error transfer fee"); // fee 3%

        s_NFTs.transferFrom(address(this), msg.sender, p_nftID);
    }
     // withdrawBalance
        function withdrawBalance() public onlyOwner{
     require(msg.sender == isOwner);
        isOwner.transfer(address(this).balance);
        emit balanceWithdrawn("balance"); // emit event 
    }

      
  function changeOperator(StateOfAuction newSate) public onlyOwner{
       stateA = newSate; 
       emit OperatorChanged("auction closed");// emit event
   }

     
    //events 

event OperatorChanged(
  string newSate
);

    event balanceWithdrawn(
      string balanceInApp
    );
            
}