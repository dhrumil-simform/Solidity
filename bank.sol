// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract Bank{
    mapping(address=>uint) accounts;
    
    function checkBalance() public view returns(uint){
        return accounts[msg.sender];
    }

    function totalVolume() public view returns(uint){
        return address(this).balance;
    }
    
    function deposit() public payable{
        accounts[msg.sender] += msg.value;
    }

    function withdraw(uint amount) public{
        require((amount*(10**18))<accounts[msg.sender], "Not enough balance");
        uint amt = amount*(10**18);
        payable(msg.sender).transfer(amt);
        accounts[msg.sender] -= amt;
    }
    function transfer(address addr, uint amount) public{
        require(accounts[msg.sender] >= (amount*(10**18)), "Not enough balance");
        uint amt = amount*(10**18);
        accounts[addr] += amt;
        accounts[msg.sender] -= amt;
    }
}

