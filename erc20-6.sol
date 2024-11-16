// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
//simplest ERC20 token contract

// ERC20 interface
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract myToken {
    
    address public Owner;
    string public TokenName;
    string public TokenSymbol;
    uint public DescimalValue;// specifies the smallet divisible unit of the token value. 

    // for the Pausing function
    bool public Paused;
    uint PausedAt;// fot the timestamps of pausing and unpausing
    uint UnPausedAt;

    //for Taxing functions
    address public TaxCollector;
    uint public  TaxRate; 

    //mapping to store balance
    mapping(address => uint) public balances;

    //mapping for allowance of the thier party by the owner.
    mapping (address =>mapping (address => uint)) public allowances;
    uint private total_suply;



    //CONSTRUCTOR to set initial supply
    constructor(
    uint _initialSupply,
    string memory _name,
    string memory _symbol, 
    uint _descimal,
    uint _taxRate,
    address _feeCollector
    )
    {
        Owner = msg.sender;
        TokenName =_name;
        TokenSymbol =_symbol;
        DescimalValue =_descimal;

        total_suply =_initialSupply *(10 ** _descimal);
        balances[msg.sender]= _initialSupply;// all tokens are assigned to deployer

        require((_feeCollector != address(0)));
        TaxRate = _taxRate;
        TaxCollector =_feeCollector;      
    }


    //EVENTS to log the important actions
    event Transfer(address indexed from, address indexed  To, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event TransferOfOwnership(address indexed  from, address indexed To);
    event PausedBy(address indexed _By, uint Timestamp);
    event UnPusedBy(address indexed _By, uint Timestamp);
    event MintCoins( address indexed To, uint amount);
    event BurnCoins(address indexed From,  uint amount);
    event TaxDeduction(address indexed  From, uint taxamount, address indexed feeCollector);
    


    //MODIFIERS
    modifier OwnerCall{
        require(msg.sender ==Owner);
        _;
    }

    modifier WhenNotPaused(){
      require(!Paused, "the contract is paused right now");
      _;
    }


    // FUNCTIONS
    function totalSupply()public view returns(uint){
        return total_suply;
    }
    function BalanceOf(address _account) public view returns (uint){
        return balances[_account];
    }



    function tokenname()public view returns(string memory){
        return TokenName;
    }
    function tokenSymbol()public view returns (string memory){
        return TokenSymbol;
    }
    function tokenDescimalValue()public view returns (uint){
        return DescimalValue;
    }



    function updateTaxRate(uint _newTaxRate)public OwnerCall{
        require(_newTaxRate != 0 && _newTaxRate <100);
        TaxRate =_newTaxRate;
    }

    function UpdateFeeCollectore(address _newCollector)public OwnerCall{
        require(_newCollector != address(0));
        TaxCollector =_newCollector;
    }



    function transfer(address _getter, uint _amount)public returns (bool){
        uint tax =(_amount * TaxRate) /100;
        //this way the sender will know how much more money he needs to put in.
        uint TotalAmount = _amount +tax;


        require(balances[msg.sender]>= TotalAmount,"you dont have enough balance");
        require(_getter != address(0) && _getter != msg.sender);
        balances[msg.sender] -= TotalAmount;
        balances[_getter] += _amount;

        //emit the log
        emit Transfer(msg.sender, _getter, _amount);
        emit TaxDeduction(msg.sender, tax, TaxCollector);

        return  true;
    }

    // approve a third party address of an allowance
    function approve(address _spender, uint _amount) public OwnerCall returns(bool){
        require(_spender != address(0));
        allowances[msg.sender][_spender] = _amount;

        //emit the log
        emit Approval(Owner, _spender, _amount);
        return true;
    }

    //return the allowance given
    function allowance( address _spender) public view returns(uint){
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
    function transferFrom( address _from,address _to, uint _amount)public returns (bool){
         uint tax =(_amount * TaxRate) /100;
        //this way the sender will know how much more money he needs to put in.
        uint TotalAmount = _amount +tax;
        
        require(allowances[_from][msg.sender] > TotalAmount,"you are not elligibe for this mush transfer");
        require(balances[_from]> TotalAmount);
        require(_to != address(0));

        balances[Owner] -= TotalAmount;// balance from the owner is deducted
        allowances[Owner][msg.sender] -= TotalAmount;// allowance amount is deducted

        balances[_to] += _amount;

        //emit the transfer log
        emit Transfer(_from, _to, _amount);
        emit TaxDeduction(_from, tax, TaxCollector);
        return  true;
    }

    //MINT the tokens
    function MintTokens(address _to, uint _amount)public OwnerCall returns (bool){
        require(_to != address(0),"you need to enter valid address");

        uint scaledAmount = _amount*(10**DescimalValue);
        balances[_to] += scaledAmount;
        total_suply += scaledAmount;
        
        emit MintCoins( _to, scaledAmount);
        emit Transfer(address(0), _to, scaledAmount);
        return true;
    }

    // BURN the tokens
    function BurnTokens( uint _amount) public OwnerCall returns(bool){
        uint scaledAmount = _amount*(10**DescimalValue);

        require(balances[msg.sender] > scaledAmount,"not enough  tokens to burn");
        balances[msg.sender] -= scaledAmount;
        total_suply -= scaledAmount;
        
        emit MintCoins( msg.sender, scaledAmount);
        emit Transfer(msg.sender,address(0), scaledAmount);
        return true;
    }

    //transfer OwnerShio
    function TransferOwnership(address _newOwner) public OwnerCall returns (bool){
        require(_newOwner != address(0));
        
        emit TransferOfOwnership(Owner , _newOwner);// emit before changinf the ownership

        Owner = _newOwner;
        return  true;
    }

    //Pause the contract
    function pause()public OwnerCall{
        require(!Paused, "contract is already paused");
        Paused =true;
        PausedAt =block.timestamp;

        emit PausedBy(msg.sender, PausedAt);
    }

    //unpause the contracct
    function Unpause()public OwnerCall{
        require(Paused, "contract is NOT paused");
        Paused =false;
        UnPausedAt =block.timestamp;

        emit PausedBy(msg.sender, UnPausedAt);
    }


}