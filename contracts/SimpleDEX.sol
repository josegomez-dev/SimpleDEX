// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title SimpleDEX – Minimal Decentralized Exchange Contract
/// @author Jose Alejandro Gomez Castro
/// @notice Enables swapping between two ERC-20 tokens using a constant product formula (Uniswap V1-style)
/// @dev This contract does not issue LP tokens and assumes a single-owner liquidity pool

/// @dev Minimal ERC-20 interface required by the DEX
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract SimpleDEX {
    IERC20 public tokenA;
    IERC20 public tokenB;
    address public owner;

    uint256 public reserveA;
    uint256 public reserveB;

    /// @notice Emitted when liquidity is added to the pool
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);

    /// @notice Emitted when liquidity is removed from the pool
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);

    /// @notice Emitted when a token swap is performed
    event Swapped(address indexed trader, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    /// @dev Restricts function access to the contract owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /// @notice Initializes the DEX with two token addresses
    /// @param _tokenA The address of ERC-20 TokenA
    /// @param _tokenB The address of ERC-20 TokenB
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    /// @notice Adds liquidity to the token pool (only owner)
    /// @param amountA Amount of TokenA to deposit
    /// @param amountB Amount of TokenB to deposit
    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "TokenA transfer failed");
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "TokenB transfer failed");

        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /// @notice Removes liquidity from the token pool (only owner)
    /// @param amountA Amount of TokenA to withdraw
    /// @param amountB Amount of TokenB to withdraw
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA <= reserveA && amountB <= reserveB, "Insufficient reserves");

        require(tokenA.transfer(msg.sender, amountA), "TokenA transfer failed");
        require(tokenB.transfer(msg.sender, amountB), "TokenB transfer failed");

        reserveA -= amountA;
        reserveB -= amountB;

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /// @notice Swaps TokenA for TokenB using the constant product formula
    /// @param amountAIn Amount of TokenA sent in
    function swapAforB(uint256 amountAIn) external {
        require(tokenA.transferFrom(msg.sender, address(this), amountAIn), "TokenA transfer failed");

        uint256 amountBOut = getAmountOut(amountAIn, reserveA, reserveB);
        require(tokenB.transfer(msg.sender, amountBOut), "TokenB transfer failed");

        reserveA += amountAIn;
        reserveB -= amountBOut;

        emit Swapped(msg.sender, address(tokenA), address(tokenB), amountAIn, amountBOut);
    }

    /// @notice Swaps TokenB for TokenA using the constant product formula
    /// @param amountBIn Amount of TokenB sent in
    function swapBforA(uint256 amountBIn) external {
        require(tokenB.transferFrom(msg.sender, address(this), amountBIn), "TokenB transfer failed");

        uint256 amountAOut = getAmountOut(amountBIn, reserveB, reserveA);
        require(tokenA.transfer(msg.sender, amountAOut), "TokenA transfer failed");

        reserveB += amountBIn;
        reserveA -= amountAOut;

        emit Swapped(msg.sender, address(tokenB), address(tokenA), amountBIn, amountAOut);
    }

    /// @dev Calculates output amount using the constant product formula: (x + dx)(y - dy) = xy
    /// @param amountIn Amount of token being swapped in
    /// @param reserveIn Current reserve of the input token
    /// @param reserveOut Current reserve of the output token
    /// @return amountOut The amount of output token that can be received
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "Invalid input amount");
        require(reserveIn > 0 && reserveOut > 0, "Invalid reserves");

        amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    /// @notice Returns the current price of the given token in terms of the other
    /// @param _token The address of TokenA or TokenB
    /// @return price Estimated price using reserves (18 decimals)
    function getPrice(address _token) external view returns (uint256 price) {
        if (_token == address(tokenA)) {
            require(reserveA > 0, "TokenA reserve is zero");
            price = (reserveB * 1e18) / reserveA; // 1 TokenA in terms of TokenB
        } else if (_token == address(tokenB)) {
            require(reserveB > 0, "TokenB reserve is zero");
            price = (reserveA * 1e18) / reserveB; // 1 TokenB in terms of TokenA
        } else {
            revert("Unsupported token address");
        }
    }
}
