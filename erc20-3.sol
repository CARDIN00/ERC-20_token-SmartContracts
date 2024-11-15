// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
//simplest ERC20 token contract
contract myToken{
    //mapping to store balance
    address public Owner;

    mapping(address => uint) public balances;

    //mapping for allowance of the thier party by the owner.
    mapping (address =>mapping (address => uint)) public allowances;
    uint private total_suply;

    //constructor to set initial supply
    constructor(uint _initialSupply){
        Owner = msg.sender;
        total_suply =_initialSupply;
        balances[msg.sender]= _initialSupply;// all tokens are assigned to deployer
    }

    //EVENTS to log the important actions
    event Transfer(address indexed from, address indexed  To, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);


    modifier OwnerCall{
        require(msg.sender ==Owner);
        _;
    }



    function totalSupply()public view returns(uint){
        return total_suply;
    }

    function checkBalance(address _account) public view returns (uint){
        return balances[_account];
    }

    function transfer(address _getter, uint _amount)public returns (bool){
        require(balances[msg.sender]>= _amount,"you dont have enough balance");
        require(_getter != address(0) && _getter != msg.sender);
        balances[msg.sender] -= _amount;
        balances[_getter] += _amount;

        //emit the log
        emit Transfer(msg.sender, _getter, _amount);

        return  true;
    }

    // approve a third party address of an allowance
    function approval(address _spender, uint _amount) public OwnerCall returns(bool){
        require(_spender != address(0));
        allowances[msg.sender][_spender] = _amount;

        //emit the log
        emit Approval(Owner, _spender, _amount);
        return true;
    }

    //return the allowance given
    function allowanceGiven( address _spender) public view returns(uint){
        return allowances[Owner][_spender];   
    }

    //increase allowance
    function IncreaseAllowance(address _spender, uint _increase)public  returns (bool){
        require(_spender != address(0));
        
        allowances[msg.sender][_spender] += _increase;
        emit Approval(msg.sender, _spender, _increase);
        return true;

    }
    //decrease allowance
    function decreaseAllowance(address _spender, uint _decrese)public  returns (bool){
        require(_spender != address(0));
        require(allowances[msg.sender][_spender] >= _decrese);

        allowances[msg.sender][_spender] -= _decrese;
        emit Approval(msg.sender, _spender, _decrese);

        return  true;
    }


    //function to let the allowed person transfer the amount
    function transferFromThirdParty( address _recipient, uint _amount)public returns (bool){
        require(allowances[Owner][msg.sender] > _amount,"you are not elligibe for this mush transfer");
        require(balances[Owner]> _amount);
        require(_recipient != address(0));

        balances[Owner] -= _amount;// balance from the owner is deducted
        allowances[Owner][msg.sender] -= _amount;// allowance amount is deducted

        balances[_recipient] += _amount;

        //emit the transfer log
        emit Transfer(Owner, _recipient, _amount);
        return  true;
    }


}
