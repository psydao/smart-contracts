# Solidity Take Home Assessment

## Task:

You are tasked with developing the smart contracts AND testing suite for a simple yet fun guessing game. You may use Foundry or hardhat as your preffered environment.

### The game will have the following rules: 

1. A player will need to guess either 'red' or 'black'. 
2. As entrance to the game, the player must pay an entrance fee at the time of their guess. This fee should be updateable via only the owner of the contract.The fee should be the games very own ERC20 token you create.
3. To win the game, the player's guess should be exactly the same as the next players guess. Here is an example:

Bob pays x amount of a token. He guesses the 'red'. When Alice comes along, she places a guess. If she also guessed 'red'. Bob wins, and he receives Alices entry fee as a reward. If Alice guessed another 'black', Bob loses and his money is kept by the protocol.

The goal is to guess a different colour from the previous player but to guess the same colour as the next player.

### What do you get for winning:

If you successfully guess correctly, you will receive double your entrance fee as a reward as well as a special Champion NFT. This NFT can be extremely simple but should be created by you. 

### Other points to consider:

1. A player should only be allowed to play once in their lifetime.
2. A backend service will be running to store every users guess, therefore, you do not need to store this on-chain to save storage. However, you will need to store any data needed for the winning / losing calculations.
4. When the game first begins, the owner will send in an original guess to be used for the first player. As well as seeding the contract with some ERC20 funds.
5. The ERC20 should be on a 1-1 value with ETH. Meaning, for users to buy your ERC20 token, they should use an equal amount of ETH.
6. The 'Champion' NFT should be soulbound.

## Bonus Task:

1. Allow the contract to handle multiple games happening at the same time. A user can select a game they would like to join and participate in that game.
2. Each game should have it's own personal Champion NFT which is uniquie to that game.
3. Deploy the contracts to goerli.
