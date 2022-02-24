// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Auction{
    address payable public beneficiary;
    uint public auctionTime;
    uint public highestBid;
    address public highestBidder;
    bool ended;

    mapping(address=>uint) bidders;

    error AuctionEnded();
    error BidNotHighEnough(uint highestBid);
    error AuctionNotYetEnded();

    event BidPlaced(string, uint);
    event AuctionEnd(string, uint);

    constructor(uint endTime,address payable beneficiaryAddress){
        auctionTime = block.timestamp + endTime;
        beneficiary = beneficiaryAddress;
    }

    function bid() external payable{
        require(msg.sender != beneficiary, "You cannot bid as you are the beneficiary");
        if(block.timestamp > auctionTime){
            revert AuctionEnded();
        }
        if(msg.value <= highestBid){
            revert BidNotHighEnough(highestBid);    
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidders[msg.sender] += msg.value;
        emit BidPlaced("Bid placed succussfully. Highest Bid: ", bidders[msg.sender]);
    }

    function withdraw() external{
        require(msg.sender != highestBidder, "You cannot withdraw as you are highest bidder");
        if(bidders[msg.sender] > 0){
            uint amount = bidders[msg.sender];
            bidders[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    function auctionEnd() external{
        require(msg.sender == beneficiary, "You cannot end the auction");
        require(!ended, "Auction has ended");
        if (block.timestamp < auctionTime)
        {
            revert AuctionNotYetEnded();
        }
        ended = true;
        beneficiary.transfer(highestBid);

        emit AuctionEnd("Auction ended with highest bid of ", highestBid);
    }
}
