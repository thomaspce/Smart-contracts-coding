// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
 
// Importing the necessary interfaces and libraries
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 
contract SimpleTokenSwap {
    ISwapRouter public swapRouter;
    address public WETH;

    error InvalidAddressGiven();
 
    // Setting the Uniswap Router address and WETH address in the constructor
    constructor(address _swapRouter, address _WETH) {
        swapRouter = ISwapRouter(_swapRouter);
        if(_WETH == address(0)) revert InvalidAddressGiven();
        WETH = _WETH;
    }
 
    // Create a swap function that takes input and output token addresses,
    // the input amount, the minimum output amount, and the recipient's address
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMinimum,
        address recipient
    ) external {
        // Transfer the input tokens from the sender to the contract
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "Transfer failed");
 
        // Approve the Uniswap router to spend the input tokens
        require(IERC20(tokenIn).approve(address(swapRouter), amountIn), "Approval failed");
 
        // Create the swap parameters
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: 3000, // Using a 0.3% fee tier
            recipient: recipient,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0
        });
 
        // Call the Uniswap router's exactInputSingle function to execute the swap
        uint256 amountOut = swapRouter.exactInputSingle(params);
 
        require(amountOut >= amountOutMinimum, "Insufficient output amount");
    }
}
