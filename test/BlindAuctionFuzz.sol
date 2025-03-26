// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/BlindAuction.sol";
import {Counter} from "../src/Counter.sol";

contract BlindAuctionTest is Test {

    BlindAuction public auction;

    address public creator = address(0x1);
    address public bidder1 = address(0x2);
    address public bidder2 = address(0x3);
    address public bidder3 = address(0x4);


    function setUp() public {
        auction = new BlindAuction();

        vm.deal(creator, 10 ether);
        vm.deal(bidder1, 20 ether);
        vm.deal(bidder2, 50 ether);
        vm.deal(bidder3, 80 ether);
    }

    function testFuzzStartAuction (string memory name, uint256 auctionDuration, uint256 startPrice) public {
        //Check if the entries are valid.
        vm.assume(bytes(name).length > 0);
        vm.assume (auctionDuration > 0 &&  auctionDuration <= 365 * 24);
        vm.assume (startPrice > 0 && startPrice <= 50 ether);
        
        vm.prank (creator);
        auction.startAuction(name, auctionDuration, startPrice);

        (
        address auctionCreator,
        string memory itemName,
        uint256 itemId,
        address highestBidder,
        uint256 highestBid,
        uint256 numberOfBidders,
        uint256 auctionEndTime
        ) = auction.getAuctionDetails(1);

        assertEq(auctionCreator, creator);
        assertEq(itemName, name);
        assertEq(itemId, 1);
        assertEq(highestBidder, address(0));
        assertEq(highestBid, startPrice);
        assertEq(numberOfBidders, 0);
        assertEq(auctionEndTime, block.timestamp + auctionDuration * 3600);
    }

    function testFuzzBid (uint256 bidAmount) public {
        vm.prank(creator);
        auction.startAuction("Item1", 2, 1 ether);

        vm.assume(bidAmount > 1 ether && bidAmount <= 5 ether);
        vm.prank(bidder1);
        auction.bid{value : bidAmount}(1);

        (
        ,
        ,
        ,
        address highestBidder,
        uint256 highestBid,
        uint256 numberOfBidders,
        ) = auction.getAuctionDetails(1);

        assertEq(highestBidder, bidder1);
        assertEq(highestBid, bidAmount);
        assertEq(numberOfBidders, 1);
    }

    function testFuzzEndAuction (uint256 bidAmount1) public {
        vm.prank(creator);
        auction.startAuction("Item1", 2, 1 ether);

        vm.assume(bidAmount1 > 1 ether && bidAmount1 <= 20 ether);
        vm.prank(bidder1);
        auction.bid{value : bidAmount1}(1);

        uint256 bidAmount2 = bidAmount1 + 20 ether;

        vm.prank(bidder2);
        auction.bid{value : bidAmount2}(1);

        vm.warp(block.timestamp + 2 * 3600 + 1);

        uint256 creatorInitialBalance = creator.balance;
        uint256 bidder1InitialBalance = bidder1.balance;
        uint256 bidder2InitialBalance = bidder2.balance;

        vm.prank(creator);
        auction.endAuction(1);


        assertEq(creator.balance, creatorInitialBalance + bidAmount2);
        assertEq(bidder1.balance, bidder1InitialBalance + bidAmount1);
        assertEq(bidder2.balance, bidder2InitialBalance);
    }

    function testFuzzConcurrentBids(uint256 bidAmount1) public {
        vm.prank(creator);
        auction.startAuction("Item1", 2, 1 ether);

        vm.assume(bidAmount1 > 1 ether && bidAmount1 <= 20 ether);
        vm.prank(bidder1);
        auction.bid{value : bidAmount1}(1);

        uint256 bidAmount2 = bidAmount1 + 20 ether;
        uint256 bidAmount3 = bidAmount1 + 50 ether;

        vm.prank(bidder2);
        auction.bid{value : bidAmount2}(1);

        vm.prank(bidder3);
        auction.bid{value : bidAmount3}(1);

        (
        ,
        ,
        ,
        address highestBidder,
        uint256 highestBid,
        uint256 numberOfBidders,
        ) = auction.getAuctionDetails(1);

        assertEq(highestBidder, bidder3);
        assertEq(highestBid, bidAmount3);
        assertEq(numberOfBidders, 3);
    }

}