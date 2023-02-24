This contract is designed to bypass the maximum transaction limit on Uniswap, which can prevent large token purchases. It allows users to purchase tokens on Uniswap by breaking up the transaction into smaller transactions, thus avoiding the maximum transaction limit.

Contract Details
The contract is written in Solidity, using version 0.8.0. It includes an interface for the Uniswap V2 Router, which is used to perform the token swaps. The contract has three main functions:

purchaseToken
This function allows users to purchase tokens on Uniswap. It takes the following parameters:

tokenAddress: the address of the token to be purchased
amount: the amount of tokens to be purchased
minAmountOut: the minimum amount of output tokens that must be received for the trade to be successful
maxSlippage: the maximum amount of slippage allowed in each trade
recipient: the address to which the purchased tokens will be sent
The function requires that the caller sends ether along with the transaction, and that the token amount is greater than zero. It then calculates the amount of WETH needed for the token swap, ensures that the sender has sent enough ether to perform the swap, and swaps ether for tokens in smaller transactions until the desired amount of tokens has been purchased. The purchased tokens are then transferred to the recipient, and any excess ether is returned to the sender.

withdraw
This function allows the owner of the contract to withdraw tokens from the contract. It takes the following parameters:

tokenAddress: the address of the token to be withdrawn
amount: the amount of tokens to be withdrawn
The function requires that the caller is the owner of the contract, and transfers the specified amount of tokens to the owner.

setOwner
This function allows the owner of the contract to change the owner address. It takes the following parameter:

owner: the new owner address
The function requires that the caller is the current owner of the contract, and changes the owner address to the specified address.

Deployment
To deploy this contract, you will need to provide the address of the Uniswap V2 Router as a constructor parameter. Once deployed, users can call the purchaseToken function to purchase tokens on Uniswap.

Security Considerations
This contract is intended to be used with caution, as breaking up transactions can increase the risk of front-running attacks. It is recommended that users set maxSlippage to a low value to minimize this risk. Additionally, it is important to ensure that the contract is deployed securely and that the owner address is kept secure to prevent unauthorized withdrawals.
