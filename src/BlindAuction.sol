// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract BlindAuction is ReentrancyGuard {
    
    //Structs
    struct ItemToAuction{
        address auctionCreator;
        string itemName;
        uint256 itemId;
        address highestBidder;
        uint256 highestBid;
        uint256 numberOfBidders;
        uint256 auctionEndTime;
       
    }

    //Errors
    error InvalidStartPrice();
    error NonCreator();
    error AuctionNonEnded();
    error AuctionAlreadyEnded();
    error FailedToExecuteTransaction();
    error InvalidBid();

    //Arrays
    ItemToAuction[] private items;


    //Mappings
    mapping(uint256 => address[]) public itemToBidders;
    mapping(uint256 => mapping(address => uint256)) public itemToBidderAmount;
    mapping(uint256 => mapping(address => bool)) public itemHasBidded;

    //Modifiers
    modifier onlyCreator (uint256 _itemId) {
        if (msg.sender != items [_itemId - 1 ].auctionCreator) {
            revert NonCreator();
        }
        _;
    }

    //Events
    event HighestBidIncreased(address indexed, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);

    //Functions
    function startAuction (string memory _name, uint256 _auctionDuration, uint256 startPrice) public {
        if ( startPrice == 0) {
            revert InvalidStartPrice();
        }
        uint256 auctionEndTime = block.timestamp + (_auctionDuration * 3600);

        items.push(ItemToAuction ({
            auctionCreator:msg.sender,
            itemName: _name,
            itemId: items.length +1,
            highestBidder: address(0),
            highestBid: startPrice,
            numberOfBidders: 0,
            auctionEndTime: auctionEndTime
        }));
    }

    function endAuction(uint256 _itemId) public onlyCreator (_itemId) nonReentrant {
        ItemToAuction storage item = items [_itemId - 1];

        if (block.timestamp < item.auctionEndTime) {
            revert AuctionNonEnded();

        }

        (bool sentToCreator, ) = payable(item.auctionCreator).call { value: item.highestBid }("");

        if(!sentToCreator) {
            revert FailedToExecuteTransaction();
        }

        for (uint i = 0; i < itemToBidders[_itemId].length; i++) {
            address bidder = itemToBidders[_itemId][i];

            if (bidder != item.highestBidder) {
                uint256 refundAmount = itemToBidderAmount[_itemId][bidder];
                (bool sentToBidder, ) = payable(bidder).call { value: refundAmount }("");

                 if(!sentToBidder) {
                    revert FailedToExecuteTransaction();
                }
            }

        }

        emit AuctionEnded(item.highestBidder, item.highestBid);

    }

    function bid (uint256 _itemId) external payable {
        ItemToAuction storage item = items [_itemId - 1];

        if(block.timestamp > item.auctionEndTime) {
            revert AuctionAlreadyEnded();
        }

        uint totalBid = itemToBidderAmount [_itemId] [msg.sender] + msg.value;

        if (totalBid <= item.highestBid) {
            revert InvalidBid();
        }

        itemToBidderAmount [_itemId] [msg.sender] = totalBid;
        item.highestBidder = msg.sender;
        item.highestBid = totalBid;

        if(!itemHasBidded[_itemId][msg.sender]) {
            itemHasBidded[_itemId][msg.sender] = true;
            itemToBidders[_itemId].push(msg.sender);
            item.numberOfBidders++;
        }  

        emit HighestBidIncreased(msg.sender, totalBid);   
    }


    function getAuctionDetails(uint256 _itemId) public view returns (
        address auctionCreator,
        string memory itemName,
        uint256 itemId,
        address highestBidder,
        uint256 highestBid,
        uint256 numberOfBidders,
        uint256 auctionEndTime
        
    ) {
        ItemToAuction memory item = items[_itemId - 1];
        return (
            item.auctionCreator,
            item.itemName,
            item.itemId,
            item.highestBidder,
            item.highestBid,
            item.numberOfBidders,
            item.auctionEndTime
        );
    }
    

}