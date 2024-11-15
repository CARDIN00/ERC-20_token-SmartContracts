// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
//simplest ERC20 token contract
contract myToken{
    //mapping to store balance
    mapping(address => uint) public balances;
    uint private total_suply;

    //constructor to set initial supply
    constructor(uint _initialSupply){
        total_suply =_initialSupply;
        balances[msg.sender]= _initialSupply;// all tokens are assigned to deployer
    }

    function totalSupply()public view returns(uint){
        return total_suply;
    }

    function checkBalance(address _account) public view returns (uint){
        return balances[_account];
    }


}