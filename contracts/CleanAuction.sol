// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

interface IERC721 {
    function transfer(address, uint) external;

    function transferFrom(
        address,
        address,
        uint
    ) external;
}

contract Auction {
    event OperatorChanged(string );
     event auctionStarted(string);
    event End(address highestBidder, uint highestBid);
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event balanceWithdrawn(string
    );
    address payable public owner;

    uint public endAt;
   enum State{
        Inactive,
        Active,
        Cancelled
    }

    State public status = State.Inactive;

          
              
    IERC721 public nft;
    uint public nftId;

    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bids;

    constructor () {
        owner = payable(msg.sender);
    }
 modifier Onlyowner() {
       require(owner == msg.sender, "you need to be the project owner");
       _;
   }


       //changeOperator
       function changeOperator(State newSate) public Onlyowner{
       status = newSate; 
       emit OperatorChanged("auction closed");// emit event
   }

    function start(IERC721 _nft, uint _nftId, uint startingBid) external Onlyowner{
        require (status == State.Inactive);
        require(msg.sender == owner, "You did not start the auction!");
        highestBid = startingBid;
        nft = _nft;
        nftId = _nftId;
        nft.transferFrom(msg.sender, address(this), nftId);
        status = State.Active;
       // endAt = block.timestamp + 7 days; this is how long the auction would last
        emit auctionStarted("new auction");
    }

    function placeOffering() external payable {
        require (status == State.Active, "aucition no active");
        require(block.timestamp < endAt, "Ended!");
        require(msg.value > highestBid);

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        emit Bid(highestBidder, highestBid);
    }

    function withdraw() external payable {
        require (status == State.Active);
        require(highestBidder != msg.sender);
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        (bool sent, bytes memory data) = payable(msg.sender).call{value: bal}("");
        require(sent, "Could not withdraw");

        emit Withdraw(msg.sender, bal);
    }

    function end() external Onlyowner{
      require (status == State.Active);
        require(block.timestamp >= endAt, "Auction is still ongoing!");
       

        if (highestBidder != address(0)) {
            nft.transfer(highestBidder, nftId);
            (bool sent, bytes memory data) = owner.call{value: highestBid}("");
            require(sent, "Could not pay seller!");
          //  require(highestBid(msg.sender, address(this), (sent / 100) * 3), "Error transfer fee"); // fee 3%

        } else {
            nft.transfer(owner, nftId);
        }

       status = State.Active;
        emit End(highestBidder, highestBid);
    }
    

    //withdrawBalance from the dapp
function withdrawBalance()public  Onlyowner{
    require(address(this).balance > 0);
    require (status == State.Inactive);
        owner.transfer(address(this).balance);
        emit balanceWithdrawn("withdrawn balance from the dapp"); // emit event 
    }
}