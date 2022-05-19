// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Staking {
  error NotOwnerError();
  address owner;
  uint256 public rewardRate;
  uint256 public totalStaked;
  uint256 public percentPerBlock;
  uint256 public duration;

  // Add Whitelist Token
  mapping(bytes32 => address) public whitelistedToken;

  // map accounts to account balances
  mapping(address => mapping(bytes32 => uint256)) public accountBalances;

  // map staker to total staking time
  mapping(address => uint256) public stakingTime;

  constructor() {
    owner = msg.sender;
    rewardRate = 1 ether;
    percentPerBlock = 1;
    duration = 1 days;
  }

  // Compliance 
  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert NotOwnerError();
    }
    _;
  }

  // Add Whitelist token
  function whitelistToken(bytes32 symbol, address tokenAddress)
    external
    onlyOwner
  {
    whitelistedToken[symbol] = tokenAddress;
  }

  // Tokenlock duration
  function setTokenStakeDuration(uint256 _dur) external onlyOwner {
    duration = _dur;
  }

  function getWhitelistedTokenAddresses(bytes32 token)
    external
    virtual
    returns (address)
  {
    return whitelistedToken[token];
  }

  // Adjust Rate of Reward
  function setRewardRate(uint256 _reward) external onlyOwner {
    rewardRate = _reward;
  }

  // Stake Tokens
  function depositTokens(uint256 amount, bytes32 symbol) external {
    accountBalances[msg.sender][symbol] += amount;
    if (stakingTime[msg.sender] == 0) {
      stakingTime[msg.sender] += block.timestamp;
    }
    totalStaked += amount;
    ERC20(whitelistedToken[symbol]).transferFrom(
      msg.sender,
      address(this),
      amount
    );
  }

  // Get Stake pool balance
  function getPoolBalance(bytes32 symbol)
    external
    view
    returns (uint256 balance)
  {
    uint256 balanceToken = 0;
    balanceToken = ERC20(whitelistedToken[symbol]).balanceOf(address(this));
    return balanceToken;
  }

  // Unstake tokens
  function withdrawTokens(uint256 amount, bytes32 symbol) external {
    require(accountBalances[msg.sender][symbol] >= amount, "Insufficent funds");
    require(
      block.timestamp >= (stakingTime[msg.sender] + duration),
      "Too early"
    );
    totalStaked -= amount;
    accountBalances[msg.sender][symbol] -= amount;
    if (accountBalances[msg.sender][symbol] == 0) {
      stakingTime[msg.sender] = 0;
    }

    ERC20(whitelistedToken[symbol]).transfer(msg.sender, amount);
  }

  // Claim staking rewards
  function claimReward(bytes32 symbol) external {
    uint256 earned = 0;
    require(accountBalances[msg.sender][symbol] >= 0, "Insufficent funds");
    require(
      ERC20(whitelistedToken[symbol]).balanceOf(address(this)) >= 0,
      "Insufficent reward funds"
    );
    uint256 stakedAt = stakingTime[msg.sender];
    earned +=
      ((((accountBalances[msg.sender][symbol] / 1 ether) * rewardRate) *
        (block.timestamp - stakedAt)) / 10) /
      1 days;

    stakingTime[msg.sender] = block.timestamp;

    ERC20(whitelistedToken[symbol]).transfer(msg.sender, earned);
  }

  // Check earning info
  function earningInfo(address _user, bytes32 symbol)
    external
    view
    returns (uint256 info)
  {
    uint256 earned = 0;
    uint256 stakedAt = stakingTime[_user];
    earned +=
      (
        ((((accountBalances[_user][symbol] / 1 ether) * rewardRate) *
          (block.timestamp - stakedAt)) / 10)
      ) /
      1 days;
    return earned;
  }

  function withdraw() external payable virtual {
    require(msg.sender == owner, "This function only called by owner");
    // This will transfer the remaining contract balance to the owner (contractOwner address).
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = msg.sender.call{ value: address(this).balance }("");
    require(os);
    // =============================================================================
  }
}
