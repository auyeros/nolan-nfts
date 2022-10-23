// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Marketplace{
  IERC20 s_token; 
  IERC721 s_NFTs;
 //state 
  address  payable  isOwner;

// state in The sale
  enum Status{
        Inactive,
        Active,
        Cancelled
    }

  struct Sale {
      address owner;
      uint256 price;
      Status status;
  }
        
//mappings        
  mapping(uint256 => Sale) public s_sales;
  mapping(uint256 => uint256) s_security;

////////////////////////////////////////////////////////////////////////
  // auction 
// state of the auction 
 enum StateOfAuction {Active, Inactive, Canceled}  

uint highestOffer;
  StateOfAuction public stateA = StateOfAuction.Inactive;

  // struc for the nft in the auction
  struct SaleAuction {
      address owner;
      uint256 price;
      StateOfAuction status;
  }
  uint public highestBid;
  address public highestBidder;
  mapping(address => uint) biddersData;
  mapping(uint256 => SaleAuction) public s_salesA;
//counters
  using Counters for Counters.Counter;
  Counters.Counter s_counter;

                     //modifiers
               //onlyowner
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
       constructor (address p_stableCoinUsdContract, address p_nftsContract) {
         isOwner = payable(msg.sender);
        s_token = IERC20(p_stableCoinUsdContract);
        s_NFTs = IERC721(p_nftsContract);
    }

//////////////////////////////////////////////
///////////////DIRECT BUY
/////////////////////////////////////////////

// open sale(for sale one nft)
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
       
// cancel sale(for cancel one sale of nft)
   function cancelSale(uint256 p_nftID) public securityFrontRunning(p_nftID) {
        require(
            msg.sender == s_sales[p_nftID].owner,
            "Without permission"
        );

        require(s_sales[p_nftID].status == Status.Active, "Is not Open");

        s_sales[p_nftID].status = Status.Cancelled;

        s_NFTs.transferFrom(address(this), s_sales[p_nftID].owner, p_nftID);
    }

//buy(for buy direct one nft)
     function buy(uint256 p_nftID, uint256 p_price) public  securityFrontRunning(p_nftID) {
        require(s_sales[p_nftID].status == Status.Active, "Is not Open");

        address oldOwner = s_sales[p_nftID].owner;
        uint256 price = s_sales[p_nftID].price;
        
        require(price == p_price, "Manipulated price");

        s_sales[p_nftID].owner = msg.sender;
        s_sales[p_nftID].status = Status.Inactive;

       require(s_token.transferFrom(msg.sender, oldOwner, price), "Error transfer token - price");
       require(s_token.transferFrom(msg.sender, address(this), (price / 100) * 3), "Error transfer fee"); // fee 3%

        s_NFTs.transferFrom(address(this), msg.sender, p_nftID);
    }


     // withdrawBalance from the dapp
    function withdrawBalance() public onlyOwner{
     require(msg.sender == isOwner);
        isOwner.transfer(address(this).balance);
        emit balanceWithdrawn("balance"); // emit event 
    }
////////////////////////////////////////////////////////////////////////   
////////////////////auction
/////////////////////////////////////////

//////////////////////////////////////////
  //change operator of the auction
////////////////////////////////////////
  function changeOperator(StateOfAuction newSate) public onlyOwner{
       stateA = newSate; 
       emit OperatorChanged("auction closed");// emit event
   }
///////////////
// StartAuction
//////////////
   function startAuction(uint256 p_nftID, uint256 p_price) public securityFrontRunning(p_nftID) {
        if (s_salesA[p_nftID].owner == address(0)) {
            s_NFTs.transferFrom(msg.sender, address(this), p_nftID);

            s_salesA[p_nftID] = SaleAuction(
                msg.sender,
                p_price,
                StateOfAuction.Active
            );
        } else {
            require(
                msg.sender == s_salesA[p_nftID].owner,
                "Without permission"
            );

            s_NFTs.transferFrom(msg.sender, address(this), p_nftID);

            s_salesA[p_nftID].status = StateOfAuction.Active;
            s_salesA[p_nftID].price = p_price;
        }
  }









////////////////////////////
////place offering
///////////////////////////

function placeOfferring(uint256 p_nftID) public payable{
    //verify value is not zero
    uint calculateAmount = biddersData[msg.sender] + msg.value;
    require (s_salesA[p_nftID].status == StateOfAuction.Active);
    require(msg.value >0, "bid amount cannot be 0");
    require(calculateAmount >highestOffer, "Highest bid alredy present");  
    biddersData[msg.sender] = calculateAmount;
    highestOffer = calculateAmount;
    highestBidder=msg.sender;
    emit OferringPlaced("offer sent"); // emit event
  }

 //////////////////////
 //////Close offering
 /////////////////////
     function closeOffering(uint256 p_nftID) public securityFrontRunning(p_nftID){
        require(s_salesA[p_nftID].owner == msg.sender);
        s_salesA[p_nftID].status = StateOfAuction.Inactive;


              emit auctionClosed("auction closed");                                
     }  
    //events 

    event OperatorChanged(
      string newSate
   );

    event auctionClosed(
      string
    );

    event balanceWithdrawn(
      string balanceInApp
    );
    event OferringPlaced(
      string offer
    );
            
}