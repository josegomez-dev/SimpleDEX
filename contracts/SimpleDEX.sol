// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleDEX
 * @dev Exchange descentralizado básico con pool de liquidez para dos tokens ERC-20
 */
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

    // Eventos para monitorear operaciones
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    event Swapped(address indexed trader, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el owner puede realizar esta accion");
        _;
    }

    /**
     * @notice Inicializa el contrato con las direcciones de los tokens
     */
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    /**
     * @notice Agrega liquidez al pool
     */
  function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transferencia de TokenA fallida");
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Transferencia de TokenB fallida");

        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /**
     * @notice Retira liquidez del pool
     */
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA <= reserveA && amountB <= reserveB, "Reservas insuficientes");

        require(tokenA.transfer(msg.sender, amountA), "Transferencia de TokenA fallida");
        require(tokenB.transfer(msg.sender, amountB), "Transferencia de TokenB fallida");

        reserveA -= amountA;
        reserveB -= amountB;

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /**
     * @notice Intercambia TokenA por TokenB
     */
    function swapAforB(uint256 amountAIn) external {
        require(tokenA.transferFrom(msg.sender, address(this), amountAIn), "Transferencia A fallida");

        uint256 amountBOut = getAmountOut(amountAIn, reserveA, reserveB);
        require(tokenB.transfer(msg.sender, amountBOut), "Transferencia B fallida");

        reserveA += amountAIn;
        reserveB -= amountBOut;

        emit Swapped(msg.sender, address(tokenA), address(tokenB), amountAIn, amountBOut);
    }

    /**
     * @notice Intercambia TokenB por TokenA
     */
    function swapBforA(uint256 amountBIn) external {
        require(tokenB.transferFrom(msg.sender, address(this), amountBIn), "Transferencia B fallida");

        uint256 amountAOut = getAmountOut(amountBIn, reserveB, reserveA);
        require(tokenA.transfer(msg.sender, amountAOut), "Transferencia A fallida");

        reserveB += amountBIn;
        reserveA -= amountAOut;

        emit Swapped(msg.sender, address(tokenB), address(tokenA), amountBIn, amountAOut);
    }

    /**
     * @dev Calcula la cantidad de salida usando la fórmula del producto constante
     * (x + dx)(y - dy) = xy => dy = (dx * y) / (x + dx)
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        require(amountIn > 0, "Entrada invalida");
        require(reserveIn > 0 && reserveOut > 0, "Reservas invalidas");

        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    /**
     * @notice Devuelve el precio estimado del token dado
     */
    function getPrice(address _token) external view returns (uint256) {
        if (_token == address(tokenA)) {
            return (reserveB * 1e18) / reserveA; // Precio de 1 TokenA en términos de TokenB
        } else if (_token == address(tokenB)) {
            return (reserveA * 1e18) / reserveB; // Precio de 1 TokenB en términos de TokenA
        } else {
            revert("Token no soportado");
        }
    }

}