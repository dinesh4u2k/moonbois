// SPDX-License-Identifier: NO LICENSE
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Moonbois is ERC20 {
    using SafeMath for uint256;
    uint public BURN_PERCENTAGE = 5;
    uint public TRANSFER_TOKEN_REWARD_PERCENTAGE = 5;
    uint256 public totalTokenSupply = 100000000000000000000000000;
    address public owner;
    address public stakingContract;

    // TOKEN SYMBOL HEX = 0x7761676d69000000000000000000000000000000000000000000000000000000(WAGMI)
    constructor(
        string memory name,
        string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, totalTokenSupply);
        owner = msg.sender;
        stakingContract = 0xEEc09845DcEA44dDCA9151226900DfADB338528a;
    }

    // Override transfer func to handle burning and transfer tax fee
    function transfer(address _recipientAddress, uint256 _amount) public override returns (bool){
        if(msg.sender == owner){
            _transfer(_msgSender(), _recipientAddress, _amount);
        }else{
            uint burnTokenAmount = _amount.mul(BURN_PERCENTAGE) / 100;
            _burn(_msgSender(), burnTokenAmount);
            uint taxAmount = _amount.mul(TRANSFER_TOKEN_REWARD_PERCENTAGE) / 100;
            _transfer(_msgSender(), _recipientAddress, _amount.sub(burnTokenAmount).sub(taxAmount));
            _transfer(_msgSender(), stakingContract, taxAmount);
        }
        return true;
    }

    // Setting up different staking contract to maintain same token
    function setStakingContract(address _contract) public virtual {
        require(
        msg.sender == owner,
        "Not owner"
        );
        stakingContract = _contract;
    }

}