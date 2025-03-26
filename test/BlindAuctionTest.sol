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

    function setUp() public {
        //Deploy contract
        auction = new BlindAuction();
        //Set up the balances
        vm.deal(creator, 10 ether);
        vm.deal(bidder1, 10 ether);
        vm.deal(bidder2, 10 ether);
    }

    function testStartAuction() public {
        //Create an auction
        vm.prank (creator);
        auction.startAuction("Item 1", 2, 1 ether);

        (
        ,
        string memory itemName,
        uint256 itemId,
        address highestBidder,
        uint256 highestBid,
        uint256 numberOfBidders,
        ) = auction.getAuctionDetails(1);

        assertEq (itemName, "Item 1");
        assertEq (itemId, 1);
        assertEq(highestBidder, address(0));
        assertEq(highestBid, 1 ether);
        assertEq(numberOfBidders, 0);
    }


    function testBidIncreasesHighestBid() public {
        //Create an auction
        vm.prank (creator);
        auction.startAuction("Item 1", 2, 1 ether);

        //Bidder 1 bids
        vm.prank (bidder1);
        auction.bid{value: 2 ether} (1);

        (
        ,
        string memory itemName,
        uint256 itemId,
        address highestBidder,
        uint256 highestBid,
        uint256 numberOfBidders,
        ) = auction.getAuctionDetails(1);

        assertEq (itemName, "Item 1");
        assertEq (itemId, 1);
        assertEq(highestBidder, bidder1);
        assertEq(highestBid, 2 ether);
        assertEq(numberOfBidders, 1);
    }


    function testBidBelowHighestBidReverts() public {
        // Create an auction
        vm.prank(creator);
        auction.startAuction("Item 1", 2, 1 ether);

        // Bidder 1 bids
        vm.prank(bidder1);
        auction.bid{value: 2 ether}(1);

        // Bidder 2 tries to bid below the highest bid, expect reversion
        vm.prank(bidder2);
        vm.expectRevert(BlindAuction.InvalidBid.selector);
        auction.bid{value: 1 ether}(1);

        // Verify the state remains unchanged
        (
            ,
            ,
            ,
            address highestBidder,
            uint256 highestBid,
            uint256 numberOfBidders,
        ) = auction.getAuctionDetails(1);

        assertEq(highestBidder, bidder1);
        assertEq(highestBid, 2 ether);
        assertEq(numberOfBidders, 1);
    }

    function testAuction () public {
        // Create an auction
        vm.prank(creator);
        auction.startAuction("Item 1", 2, 1 ether);

        // Bidder 1 bids
        vm.prank(bidder1);
        auction.bid{value: 2 ether}(1);

        // Advance the time to ends the auction
        vm.warp(block.timestamp + 3 hours);

        vm.prank(creator);
        auction.endAuction(1);

        assertEq(creator.balance, 12 ether);
    }

    function testRevertIfEndAuctionEarly() public {
        // Create an auction
        vm.prank(creator);
        auction.startAuction("Item 1", 2, 1 ether);

        // Expect reversion if trying to end auction early
        vm.prank(creator);
        vm.expectRevert(BlindAuction.AuctionNonEnded.selector);
        auction.endAuction(1);
    }

    function testRefundToLoser() public {
         // Create an auction
        vm.prank(creator);
        auction.startAuction("Item 1", 2, 1 ether);

        // Bidder 1 bids
        vm.prank(bidder1);
        auction.bid{value: 2 ether}(1);

        // Bidder 2 bids
        vm.prank(bidder2);
        auction.bid{value: 3 ether}(1);

        // Advance the time to ends the auction
        vm.warp(block.timestamp + 3 hours);

        vm.prank(creator);
        auction.endAuction(1);

        assertEq(creator.balance, 13 ether);
        assertEq(bidder1.balance, 10 ether);
        assertEq(bidder2.balance, 7 ether);
    }

   function testAuctionHighestBidIncreased() public {
        // Create an auction
        vm.prank(creator);
        auction.startAuction("Item 1", 2, 1 ether);

        // Bidder 1 bids
        vm.prank(bidder1);
        auction.bid{value: 2 ether}(1);

        // Bidder 2 bids higher and expect the event
        vm.prank(bidder2);

        vm.expectEmit(true, true, false, true);

        emit BlindAuction.HighestBidIncreased(bidder2, 3 ether);
        
        auction.bid{value: 3 ether}(1);

        // Verify the state
        (
            , 
            , 
            , 
            address highestBidder, 
            uint256 highestBid,
            ,
        ) = auction.getAuctionDetails(1);


        assertEq(highestBidder, bidder2);
        assertEq(highestBid, 3 ether);

    }

}
