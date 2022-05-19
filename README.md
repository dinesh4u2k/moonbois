# moonbois

Moonbois ERC20 smart contract => https://mumbai.polygonscan.com/address/0xf01f8c9ff2ea50ef3bf700db403228dcb58daaec

Moonbois staking smart contract => https://mumbai.polygonscan.com/address/0xeec09845dcea44ddca9151226900dfadb338528a

Moonbois consists of 2 smart contracts moonbois and staking, 

Moonbois is ERC20 smart contract that has the 3 major functions minting, transfer, and setup staking smart contract. The contract will mint the total supply at the time of deployment and transfer it to the owner's wallet. And transfer function overrides the base contract to add functionality like punishing paper hands for selling the moonbois token by taking a 10% fee on every transaction, In 10% we burn 5% and the balance 5% is added to the staking pool to reward more users who lockup their funds. 

And staking contract, Which stores whitelist a token address, user stake balances, and staked block time to pay rewards on each block. setting reward rate to 1% and token stake lock duration to 1 day as a variable so that we can tweak changes later. After Approve the staking contract to access moonbois contract and setting the allowance to the max, the user can stake multiple times and whenever he wants with a single approval. The reward pool is managed manually for now but later it can be integrated with the chainlink keeper to fill the reward pool automatically. Transaction taxes are being transferred to the reward pool so the token staking users will yield more rewards which lead to more tokens being staked. Users can check their rewards at any time and claim any time since rewards are calculated as per block timestamp. And user can Unstake their token after 1 day this can be changed based on their needs.
