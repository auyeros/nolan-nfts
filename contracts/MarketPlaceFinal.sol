//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MarketPlaceNFT is ReentrancyGuard {
    //state variables

    address payable public immutable feeAccount; // account receives fees
    uint256 public immutable feePercent;
    uint256 public itemCount;

    struct Item {
        uint256 itemId;
        IERC721 nft;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    address[] public seller;

    mapping(uint256 => Item) public items;

    constructor(uint256 _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    modifier onlyOwner() {
        require(msg.sender == feeAccount);
        _;
    }

    //functions
    ///sell NFT
    function sellNFT(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "price must be greater than zero");
        itemCount++;

        _nft.transferFrom(msg.sender, address(this), _tokenId);

        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );
        emit newNFT(itemCount, address(_nft), _tokenId, _price, msg.sender);
    }

    //buy direct
    function buyNFT(uint256 _itemId) external payable nonReentrant {
        uint256 _totalPrice = getTotalPrice(_itemId); //getting total price
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "item doesnt exist"); //checking item
        require(!item.sold, "item already sold"); /// checking item
        require(
            msg.value >= _totalPrice,
            "not enough ether to cover item price and market fee"
        ); //require anti scam
        item.seller.transfer(item.price); // send value to seller
        feeAccount.transfer(_totalPrice - item.price); //fee for nft marketplace
        item.sold = true; // set sold = true
        item.nft.transferFrom(address(this), msg.sender, item.tokenId); // trasnfer the nft to the buyer
        emit NftPurchased(
            _itemId,
            address(item.nft),
            address(item.seller),
            true,
            msg.sender
        ); //event nft purchased
    }

    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return ((items[_itemId].price * (100 + feePercent)) / 100); //calculate total price
    }

    function setSeller(address payable _seller) public onlyOwner {
        seller.push(_seller); //push seller
    }

    ///events
    event newNFT(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );
    event NftPurchased(
        uint256 itemId,
        address indexed nft,
        address indexed seller,
        bool sold,
        address indexed buyer
    );

    ///////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////// Auction code
    ///////////////////////////////////////////////////////////////////////////////////////////

    enum State {
        //State of items
        Active,
        Inactive,
        Canceled
    }

    struct itemAuction {
        // struct of itemAuction
        uint256 itemId;
        IERC721 nft;
        uint256 tokenId;
        uint256 startPrice;
        address payable seller;
        State state;
        bool sold;
    }
    uint256 public itemCountA; ////itemCount

    mapping(uint256 => itemAuction) public itemsAuction; ///mapping de los items
    mapping(address => uint256) public bids; //bids

    address public highestBidder;
    uint256 public highestBid;

    //change operator
    function changeOperator(uint256 _itemId, State _newState) public onlyOwner {
        itemAuction storage ItemAuction = itemsAuction[_itemId];
        ItemAuction.state = _newState;
    }

    //start nft auction
    function startAuction(
        IERC721 _nftA,
        uint256 _tokenId,
        uint256 _startPrice
    ) public {
        require(_startPrice > 0, "price must be greater than zero");
        itemCountA++;
        _nftA.transferFrom(msg.sender, address(this), _tokenId);
        itemsAuction[itemCountA] = itemAuction(
            itemCountA,
            _nftA,
            _tokenId,
            _startPrice,
            payable(msg.sender),
            State.Active,
            false
        );
    }

    function placeOffering(uint256 _itemId) public payable {
        itemAuction storage itemA = itemsAuction[_itemId];
        require(State.Active == itemA.state);
        require(itemA.sold == false);
        require(msg.value > highestBid);
         itemA.startPrice = msg.value;
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }
        highestBid = msg.value;
        highestBidder = msg.sender;
        emit Bid(highestBidder, highestBid);
    }

    event Bid(address bidderAddress, uint256 bidderOffer); // event with best bidder

    function closeOffering(uint256 _itemId) external {
        itemAuction storage itemA = itemsAuction[_itemId];
        require(State.Active == itemA.state);
        require(itemA.sold == false);
        itemA.sold = true;
        itemA.seller.transfer(itemA.startPrice); // send value to seller


        //feeAccount.transfer(highestBid - item.price); 
        //   require(block.timestamp >= endAt, "Auction is still ongoing!");
        // if (highestBidder != address(0)) {
        //    (bool sent, bytes memory data) = owner.call{value: highestBid}("close");
        // require(sent, "Could not pay seller!");
   //     nft.transferFrom(address(this), highestBidder, nftId);
        //      owner.transfer(highestBid);

        //require(highestBidder.transfer(highestBid, address(this), (sent / 100) * 3), "Error transfer fee"); // fee 3%

        //    } else {
        //        nft.transfer(owner, nftId);
        //   }

        //  status = State.Inactive;
        emit End(highestBidder, highestBid);
    }

event End(address Winner, uint BestOffer);
}
