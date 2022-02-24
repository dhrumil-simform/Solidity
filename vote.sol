// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Vote{
    struct Voter{
        bool voted;
        bool right;
        address to;
    }

    struct Candidate{
        address candidateAddress;
        string name;
        uint count;
    }

    address public chairperson;

    mapping(address=>Voter) voters;
    Candidate[] public candidates;

    constructor(){
        chairperson = msg.sender;
    }

    function giveRights(address _voter) external{
        require(msg.sender == chairperson, "Only chairperson can give right to vote.");
        require(!voters[_voter].right, "Voter has already been given right to vote.");
        require(!voters[_voter].voted, "The voter already voted.");
        
        voters[_voter].right = true;
    }

    function addCandidate(address _candidateAddress, string memory _name) external{
        require(msg.sender == chairperson, "Only chairperson can add a candidate");
        for(uint i=0; i<candidates.length; i+=1){
            require(candidates[i].candidateAddress != _candidateAddress, "Same candidate cannot be added twice");
        }
        candidates.push(Candidate({
            candidateAddress: _candidateAddress,
            name: _name,
            count: 0
        }));
    }

    function vote(uint id) public{
        require(voters[msg.sender].right, "Voter has not been given right to vote.");
        require(!voters[msg.sender].voted, "The voter already voted.");
        require(id<candidates.length, "Select a valid candidate");
        voters[msg.sender].voted = true;
        candidates[id].count += 1;
    }

    function winner() public view returns(string memory,uint){
        uint maxVote;
        uint winnerCandidate ;
        
        for(uint i=0; i<candidates.length; i+=1){
            if(maxVote < candidates[i].count){
                maxVote = candidates[i].count;
                winnerCandidate = i;
            }
        }
        return (candidates[winnerCandidate].name,candidates[winnerCandidate].count);
    }
}
