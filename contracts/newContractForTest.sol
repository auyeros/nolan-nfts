//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import "./ERC721Nolan.sol";  // import the ERC721Nolan contract
import "erc721a/contracts/IERC721A.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

error NotApprovedForMarketplace();

contract MarketPlaceNFT is ReentrancyGuard {
    //state variables

    address payable public immutable feeAccount; // account receives fees
    uint256 public immutable feePercent; //fee percentage
    uint256 public itemCount; //item count for the items in the marketplace

    mapping(uint256 => uint256) s_security;

    struct Item {
        uint256 itemId;
        address nft;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    } // item struct for the marketplace

    address[] public seller; // sellers list

    mapping(uint256 => Item) public items; // list of items in the marketplace

    modifier securityFrontRunning(uint256 _itemId) {
        Item storage item = items[_itemId];
        require(
            s_security[_itemId] == 0 || s_security[_itemId] > block.number,
            "error security"
        );

        s_security[_itemId] = block.number;
        _;
    } // security modifier to prevent frontrunning

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
        address _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "price must be greater than zero");
        itemCount++;
        IERC721A nft = IERC721A(_nft);
        if (nft.getApproved(_tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }
        // _nft.transferFrom(msg.sender, address(this), _tokenId);

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
    function buyNFT(uint256 _itemId)
        external
        payable
        nonReentrant
        securityFrontRunning(_itemId)
    {
        uint256 _totalPrice = getTotalPrice(_itemId); //getting total price
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "item doesnt exist"); //checking item
        require(!item.sold, "item already sold"); /// checking item
        require(
            msg.value >= _totalPrice,
            "not enough ether to cover item price and market fee"
        ); //require anti scam
        feeAccount.transfer(_totalPrice - item.price); //fee for nft marketplace
        item.seller.transfer(item.price); // send value to seller
        item.sold = true; // set sold = true
        IERC721A(item.nft).safeTransferFrom(
            item.seller,
            msg.sender,
            item.tokenId
        ); // trasnfer the nft to the buyer
        emit NftPurchased(
            _itemId,
            address(item.nft),
            address(item.seller),
            true,
            msg.sender
        ); //event nft purchased
        delete (items[_itemId]);
    }

    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return ((items[_itemId].price * (100 + feePercent)) / 100); //calculate total price
    }

    function setSeller(address payable _seller) public onlyOwner {
        seller.push(_seller); //push seller
    }
    
    function cancelSell(uint256 _itemId)
        external
        securityFrontRunning(_itemId)
    {
        Item storage item = items[_itemId];
        require(msg.sender == item.seller, "you dont are the owner of the nft");
        require(item.sold != true);
        delete (items[_itemId]); // delete select item
        item.sold = true;
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

    //State of items
    enum State {
        Active,
        Inactive,
        Canceled
    }

    struct itemAuction {
        // struct of itemAuction
        uint256 itemId;
        address nft;
        uint256 tokenId;
        uint256 startPrice;
        address payable seller;
        State state;
        bool sold;
        uint256 startAt;
        uint256 endAt;
        address payable highestBidder; // best bidder address
        uint256 highestBid; // best bid amount
    }
    uint256 public itemCountA; ////itemCount

    mapping(uint256 => itemAuction) public itemsAuction; ///mapping de los items
    mapping(address => uint256) public bids; //bids

    modifier securityFrontRunningAuction(uint256 _itemId) {
        itemAuction storage ItemAuction = itemsAuction[_itemId];
        require(
            s_security[_itemId] == 0 || s_security[_itemId] > block.number,
            "error security"
        );

        s_security[_itemId] = block.number;
        _;
    }

    //change operator
    function changeOperator(uint256 _itemId, State _newState) public {
        itemAuction storage ItemAuction = itemsAuction[_itemId];
        _itemId = ItemAuction.itemId;
        require(
            msg.sender == ItemAuction.seller,
            "you dont are the owner of the nft"
        );
        ItemAuction.state = _newState;
    }

    ///get total price for auction
    function getTotalPriceAuction(uint256 _itemId)
        public
        view
        returns (uint256)
    {
        return (itemsAuction[_itemId].highestBid / feePercent); //calculate total price
    }

    //start nft auction
    function startAuction(
        address _nftA,
        uint256 _tokenId,
        uint256 _startPrice
    ) public {
        require(_startPrice > 0, "price must be greater than zero");
        itemCountA++;
        //  _nftA.transferFrom(msg.sender, address(this), _tokenId);     
        IERC721A nftA = IERC721A(_nftA);
         if (nftA.getApproved(_tokenId) != address(this)) {
            revert NotApprovedForMarketplace();
        }
        itemsAuction[itemCountA] = itemAuction(
            itemCountA,
            _nftA,
            _tokenId,
            _startPrice,
            payable(msg.sender),
            State.Active,
            false,
            block.timestamp,
            block.timestamp + 7 days,
            payable(address(0)),
            0
        );
        emit newNFTAuction(
            itemCountA,
            address(_nftA),
            _tokenId,
            _startPrice,
            msg.sender
        );
    }

    function placeOffering(uint256 _itemId) public payable {
        itemAuction storage itemA = itemsAuction[_itemId];
        require(State.Active == itemA.state, "error state is inactive");
        require(itemA.sold == false, "error item sold");
        require(msg.value > itemA.startPrice, "error we need more ether");
        require(msg.value > itemA.highestBid, "error you need send more ether");
        require(itemA.endAt > block.timestamp, "error auction is over");
        if (itemA.highestBidder != msg.sender) { //security
            itemA.highestBidder.transfer(itemA.highestBid); //trasnfer money for old best bidder
        }
        itemA.highestBid = msg.value; // value sent
        itemA.highestBidder = payable(msg.sender); //new best bidder address
        emit Bid(itemA.highestBidder, itemA.highestBid); // event new best bidder
    }

    function closeOffering(uint256 _itemId) external payable {
        uint256 _totalPrice = getTotalPriceAuction(_itemId);
        itemAuction storage ItemAuction = itemsAuction[_itemId];
        require(State.Active == ItemAuction.state, "error state is inactive");
        require(
            msg.sender == ItemAuction.seller,
            "you dont are the owner of the nft"
        );
        require(ItemAuction.endAt < block.timestamp, "error time is not over");
        require(ItemAuction.sold == false, "error nft sold");
        ItemAuction.sold = true;
        ItemAuction.state = State.Inactive;
        feeAccount.transfer(_totalPrice); //fee for nft marketplace
        //  withdraw(ItemAuction.highestBid); //trasnfer money for nft creator
        ItemAuction.seller.transfer(ItemAuction.highestBid - _totalPrice); // send value to seller
        IERC721A(ItemAuction.nft).safeTransferFrom(
            ItemAuction.seller,
            ItemAuction.highestBidder,
            ItemAuction.tokenId
        );
        emit End(
            ItemAuction.highestBidder,
            ItemAuction.highestBid,
            ItemAuction.tokenId
        );
        delete (itemsAuction[_itemId]);
    }

    function cancelAuction(uint256 _itemId) external {
        itemAuction storage ItemAuction = itemsAuction[_itemId];
        require(
            msg.sender == ItemAuction.seller,
            "you dont are the owner of the nft"
        );
        require(ItemAuction.sold != true);
        delete (itemsAuction[_itemId]);
    }

    event Bid(address bidderAddress, uint256 bidderOffer); // event with best bidder
    event End(address Winner, uint256 BestOffer, uint256 tokenId);
    event newNFTAuction(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );
}
