pragma solidity ^0.8.0;

interface IUniswapV2Router {
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

contract UniswapMaxTxnBypass {
    address private constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private _owner;
    IUniswapV2Router private _uniswapRouter;

    constructor() {
        _owner = msg.sender;
        _uniswapRouter = IUniswapV2Router(UNISWAP_ROUTER_ADDRESS);
    }

    function purchaseToken(
        address tokenAddress,
        uint256 amount,
        uint256 minAmountOut,
        uint256 maxSlippage,
        address payable recipient
    ) external payable {
        require(msg.value > 0, "No ether sent");
        require(amount > 0, "Token amount must be greater than zero");

        // Get the token and WETH addresses for the token swap
        address[] memory path = new address[](2);
        path[0] = _uniswapRouter.WETH();
        path[1] = tokenAddress;

        // Calculate the amount of WETH needed for the token swap
        uint256[] memory amountsOut = _uniswapRouter.getAmountsOut(amount, path);
        uint256 wethAmount = amountsOut[0];

        // Ensure that we have enough ether to perform the swap
        require(msg.value >= wethAmount, "Not enough ether sent");

        // Swap the ether for the token, breaking up the transaction if necessary to bypass MaxTransaction
        uint256 remainingAmount = amount;
        while (remainingAmount > 0) {
            uint256 amountToSend = remainingAmount > maxSlippage ? maxSlippage : remainingAmount;
            uint256[] memory amounts = _uniswapRouter.swapExactTokensForTokens(
                amountToSend,
                minAmountOut,
                path,
                address(this),
                block.timestamp + 1800
            );
            remainingAmount -= amounts[1];
        }

        // Transfer the purchased tokens to the recipient
        require(IERC20(tokenAddress).transfer(recipient, amount), "Transfer failed");

        // Return any excess ether to the sender
        if (msg.value > wethAmount) {
            payable(msg.sender).transfer(msg.value - wethAmount);
        }
    }

    function withdraw(address tokenAddress, uint256 amount) external {
        require(msg.sender == _owner, "Not authorized");
        require(IERC20(tokenAddress).transfer(_owner, amount), "Transfer failed");
    }

    function setOwner(address owner) external {
        require(msg.sender == _owner, "Not authorized");
        _owner = owner;
    }

    receive() external payable {}
}
