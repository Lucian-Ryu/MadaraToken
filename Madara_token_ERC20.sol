// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MadaraToken is IERC20 {
    address public owner;
    uint _totalSupply;
    uint mintedSupply;

    string public constant name = "MadaraToken";
    string public constant symbol = "MDR";
    uint8 public constant decimals = 2;

    mapping(address => uint256) public balances;
    mapping(address => mapping (address => uint256)) public allowed;

    constructor(uint _totalTokenSupply ) {
        owner = msg.sender;
        _totalSupply = _totalTokenSupply;
        mintedSupply = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    function totalSupply() public override view returns (uint256) {
        return address(this).balance;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens > 0 && numTokens <= balances[msg.sender] && msg.sender != receiver);
        payable(msg.sender).transfer(numTokens);
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        require(msg.sender != delegate && numTokens > 0);
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address _owner, address delegate) public override view returns (uint) {
        return allowed[_owner][delegate];
    }

    function transferFrom(address _owner, address reciever, uint256 numTokens) public override returns (bool) {
        require(numTokens > 0 && numTokens <= balances[_owner],"number of tokens should be > 0, and <= balance");
        if (msg.sender != _owner){
           require (numTokens <= allowed[_owner][msg.sender],"number of tokens is > allowed");
        }
        require (_owner != reciever);
        payable(_owner).transfer(numTokens);
        allowed[_owner][msg.sender] -= numTokens;
        balances[reciever] += numTokens;
        emit Transfer(_owner, reciever, numTokens);
        return true;
    }



 function mint(address receiver, uint256 numTokens) public  {
        require(numTokens > 0);
        require(numTokens + mintedSupply <= totalSupply());
        balances[receiver] += numTokens;
        mintedSupply += numTokens;
        emit Transfer(address(0), receiver, numTokens);
    }


    function burn(uint256 numTokens) public  {
        require(numTokens > 0 && numTokens <= balances[msg.sender]);
        balances[msg.sender] -= numTokens;
        payable(address(0)).transfer(numTokens);
        emit Transfer(msg.sender, address(0), numTokens);
    }
}
