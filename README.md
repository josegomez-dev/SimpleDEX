# 🦄 SimpleDEX – Decentralized Token Exchange on Scroll Sepolia

**SimpleDEX** is a **Decentralized Exchange (DEX)** built in Solidity and deployed on the **Scroll Sepolia** testnet. It allows users to swap between two ERC-20 tokens (`TokenA` and `TokenB`) using the **constant product formula** (Uniswap V1-style), manage liquidity pools, and query real-time token prices.

---

## 🔄 Smart Contract Interaction Flow

Your system consists of three smart contracts:

| Contract | Description | Address |
|----------|-------------|---------|
| `TokenA.sol` | Basic ERC-20 token (name: `TokenA`, symbol: `TKA`) | `0xC066d2392bFa34D857E5b045dc0FCEDb37a08C0f` |
| `TokenB.sol` | Basic ERC-20 token (name: `TokenB`, symbol: `TKB`) | `0x0C0eC0f59cAc9C0fdC183fdcc42E94878Ff21744` |
| `SimpleDEX.sol` | DEX contract to swap TKA ↔ TKB via liquidity pool | `0xFA8b5006a9e1D4B3C03A07BffbBF1C2188961972` |

---

## 🛠 Features

- 💧 Add liquidity to the token pool (TokenA & TokenB)
- 🔁 Swap tokens in both directions (TKA ↔ TKB)
- 🧮 Constant product formula: `(x + dx)(y - dy) = xy`
- 🔐 Liquidity management restricted to the contract owner
- 📊 Real-time price querying for both tokens
- 🧪 Fully compatible with **Remix IDE** for deployment & testing

---

## 📦 Contract Files

| File | Description |
|------|-------------|
| `TokenA.sol` | Basic ERC-20 token with symbol `TKA` |
| `TokenB.sol` | Basic ERC-20 token with symbol `TKB` |
| `SimpleDEX.sol` | Main DEX contract for swaps, liquidity, and prices |

---

## 📚 Method Overview

| Function | Description |
|----------|-------------|
| `constructor(address _tokenA, address _tokenB)` | Initializes DEX with token addresses |
| `addLiquidity(uint256 amountA, uint256 amountB)` | Adds liquidity to the pool *(owner only)* |
| `removeLiquidity(uint256 amountA, uint256 amountB)` | Removes liquidity from the pool *(owner only)* |
| `swapAforB(uint256 amountAIn)` | Swap TokenA → TokenB |
| `swapBforA(uint256 amountBIn)` | Swap TokenB → TokenA |
| `getPrice(address _token)` | Get the price of the input token vs the other |

---

## 🚀 Deployment & Testing Guide (Remix + MetaMask)

### ✅ Step-by-Step

1. **Deploy `TokenA.sol` & `TokenB.sol`**  
   Use `1000000000000000000000000` as initial supply (1M tokens with 18 decimals)

2. **Deploy `SimpleDEX.sol`**  
   Pass the deployed addresses of TokenA & TokenB to the constructor

3. **Approve the DEX contract**  
   From the TokenA and TokenB contracts, approve the DEX contract to spend tokens

4. **Add Liquidity**  
   Call `addLiquidity(10000000000000000, 10000000000000000)` as the contract owner

5. **Swap Tokens**  
   Use `swapAforB()` or `swapBforA()` to test token exchanges

6. **Query Prices**  
   Call `getPrice()` with either token address to retrieve real-time exchange rate

---

## 🧪 Remix Testing Tips

- Compile all contracts using **Solidity v0.8.x**
- Use **Injected Provider - MetaMask** in Remix for real Scroll Sepolia deployment
- Set gas limit manually if needed (`500000+`)
- Use decimals correctly when entering token amounts (18 decimals)

---

## 🧠 Additional Notes

- Based on **Uniswap V1's constant product formula**, no price slippage protection is included
- The `owner` (deployer) is the only one allowed to manage liquidity
- Swap logic deducts tokens and transfers output instantly, no LP tokens are issued

---

## 👨‍💻 Author

Built by **[Jose Alejandro Gomez Castro](https://github.com/josegomez-dev)** for a final Solidity module project.  
Feel free to fork, test, and contribute!

---

## 📝 License

MIT License
