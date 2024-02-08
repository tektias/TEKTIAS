// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract TEKTIAS {
    address public owner;
    string public name = "TEKTIAS";
    string public symbol = "TEKTIAS";
    uint8 public decimals = 18;

    uint256 public totalSupply;
    uint256 public maxSupply = 15_000_000 * (10**18);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isBurner;
    mapping(address => bool) public isHold;

    uint256 private snapshotId;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint256 value);
    event Hold(address indexed holder);
    event Release(address indexed holder);
    event SnapshotTaken(uint256 snapshotId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier notOnHold(address account) {
        require(!isHold[account], "Account is on hold");
        _;
    }

    modifier onlyBurner() {
        require(isBurner[msg.sender], "Caller is not a burner");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalSupply = 15_000_000 * (10**18);
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address to, uint256 value) external notOnHold(msg.sender) notOnHold(to) returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external notOnHold(from) notOnHold(to) returns (bool) {
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Transfer to the zero address");
        require(balanceOf[from] >= value, "Insufficient balance");

        unchecked {
            balanceOf[from] -= value;
        }
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function burn(uint256 value) external onlyBurner {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        unchecked {
            balanceOf[msg.sender] -= value;
            totalSupply -= value;
        }
        emit Burn(msg.sender, value);
    }

    function addToHold(address account) external onlyOwner {
        isHold[account] = true;
        emit Hold(account);
    }

    function releaseHold(address account) external onlyOwner {
        isHold[account] = false;
        emit Release(account);
    }

    function setBurner(address burner, bool status) external onlyOwner {
        isBurner[burner] = status;
    }

    function takeSnapshot() external onlyOwner {
        snapshotId++;
        emit SnapshotTaken(snapshotId);
    }
}
