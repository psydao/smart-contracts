# PLEASE FOLLOW THESE INSTRUCITON CAREFULLY WHEN DEPLOYING THE TOKENSALE.SOL

## How to Deploy

To deploy the TokenSale.sol contract you will need to follow the following steps:

1. Make a copy of the .env.example file and name it .env and then remove all fields except the relevant URL (mainnet, sepolia etc), it should look something like SEPOLIA_RPC_URL. Also keep ETHERSCAN_API_KEY and PRIVATE_KEY. If you are deploying the TokenSale.sol for the second time and it is replcaing an old version, please keep PSYNFT_CONTRACT as well.
2. Fill in the fields with your information. You can get RPC_URL's from providers such as Alchemy. You may retreive an ETHERSCAN_API_KEY from etherscan directly and your PRIVATE_KEY should be your secret (PLEASE MAKE SURE YOUR .ENV IS IN YOUR .GITIGNORE FILE). Fill in the PSYNFT_CONTRACT with the correct address on the chain you are deploying too.
3. Run the command ```source .env```
4. Run ```forge script script/TokenSale/DeployTokenSale.s.sol:DeployTokenSale --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvvv```. Note the above script command is only for Sepolia, change the RPC in the command for other networks.
5. The contract will have zero tokens, you need to transfer the amount of tokens you would like in the sale and call ```setSupply()```. This will set how many tokens are for sale in the contract. You can always send more tokens in and re-call ```setSupply()```