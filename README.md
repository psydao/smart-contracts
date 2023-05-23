# Solidity Take Home Assessment

You are required to develop the smart contracts and test files for a simple guessing game. You must clone this repository to one of your own private repo's and add your assesors as reviewers.

### Game Overview:

The game must allow a player to guess either 'red' or 'black'. On guessing, a player should pay a specified entrance fee in a ERC20 compliant token which you will create. The player is trying to guess the same colour as the player to guess after them. If a player is correct / wins the game, they will receive double their entrance fee and a 'Champion' NFT. If a player loses, they will receive nothing. A player is only ever allowed to play once.

### The Entrance Fee:

To play the game, a player will need to deposit a certain amount of ERC20's. This entrance fee should be set by the owner of the contract. The fee should also be updateable for only the owner to change when they feel necessary. 

The ERC20 used for entrance should be one you create in this task. It should have a 1/1 ratio with ETH. Meaning, if you would like to mint 50 ERC20's, you need to pay 50 ETH.

### The Champion NFT:

Upon winning the game, the player should receive a basic NFT which you are tasked to create. The NFT should be bound to the player who won it. In other words, they should not be able to sell / transfer it to anyone else.

### Example:

Alice enters the game and pays 40 ERC20 tokens. She guesses 'Black'. She now waits until a new player comes along to guess. Bob then enters the game, paying his 40 ERC20 tokens and guesses 'Black'. Alice has won and will now recieve a 'Champion' NFT and double her money back (her initial entrance * 2). If Bob had guessed 'Red', Alice would have lost and her funds would be held by the game. No matter the outcome for Alice, Bob now waits for the next player to guess.

### Other points to consider:

1. A backend service will be running to store every users guess, therefore, you do not need to store this on-chain to save storage. However, you will need to store any data needed for the winning / losing calculations.
2. When the game first begins, the owner will send in an original guess to be used for the first player. As well as seeding the contract with some ERC20 funds.

# Bonus Task:

1. Allow the contract to handle multiple games happening at the same time. A user can select a game they would like to join and participate in that game.
2. Each game should have it's own personal Champion NFT which is uniquie to that game.
3. Deploy the contracts to goerli.

# Setup

The provided repo uses Foundry and has already been populated with the 3 contracts and test files you need to use to complete the task.
