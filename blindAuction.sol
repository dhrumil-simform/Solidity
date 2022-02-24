// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract blindAuction{
    address payable public beneficiary;
    address public highestBidder;
    uint public highestBid;
    uint public auctionTime;
    bool ended;

    struct Bid{
        bytes32 blindedBid;
        uint deposit;
    }

    mapping(address=>Bid[]) public bidders;
    mapping(address=>uint) pendingReturns;

    error AuctionNotYetEnded();

    constructor(uint biddingTime, address payable beneficiaryAddress){
        auctionTime = block.timestamp+biddingTime;
        beneficiary = beneficiaryAddress;
    }

    function bid(bytes32 hashedBid) payable external{
        bidders[msg.sender].push(Bid({
            blindedBid: hashedBid,
            deposit: msg.value
        }));
    }

    function reveal(uint[] calldata values, bool[] calldata fakes, string[] calldata secrets) external {
        uint totalBids = bidders[msg.sender].length;
        require(values.length == totalBids);
        require(fakes.length == totalBids);
        require(secrets.length == totalBids);

        uint refund;
        for(uint i = 0; i < totalBids; i++){
            Bid storage currentBid = bidders[msg.sender][i];
            if(currentBid.blindedBid != keccak256(abi.encodePacked(values[i], fakes[i], secrets[i]))){
                continue;
            }
            refund += currentBid.deposit;
            if(!fakes[i] && currentBid.deposit>=values[i]){
                if(placeBid(msg.sender, values[i]) && !ended){
                    refund -= values[i];
                }   
            }
            currentBid.blindedBid=bytes32(0);
        }
        payable(msg.sender).transfer(refund);
    }

    function placeBid(address bidder, uint value) private returns(bool){
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    function withdraw() external {
        require(msg.sender != highestBidder, "You cannot withdraw as you are highest bidder");
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    function endAuction() external{
        require(msg.sender == beneficiary, "You cannot end the auction");
        require(!ended, "Auction has ended");
        if (block.timestamp < auctionTime)
        {
            revert AuctionNotYetEnded();
        }
        ended = true;
        beneficiary.transfer(highestBid);
    }
}
