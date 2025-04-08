
# 🔁 Fungily Token Swap – Developer Documentation

**Fungily Token Swap** is an on-chain token exchange protocol built on an **Automated Market Maker (AMM)** model, inspired by the innovations of **Uniswap V3**. It enables seamless, secure, and gas-optimized token swaps with real-time price discovery and capital-efficient liquidity provisioning.

---

## 🧠 What Is Fungily Token Swap?

Fungily Token Swap is the core infrastructure for swapping:

- Fungily-native tokens (from presales or mintpads)
- Any ERC-20 compatible tokens supported by the protocol

It is **non-custodial**, **permissionless**, and supports high-efficiency trading by relying on an AMM-powered liquidity pool—removing the need for centralized order books or third-party intermediaries.

---

## ⚙️ How It Works

At the heart of Fungily Token Swap is a **concentrated liquidity AMM** mechanism, similar to **Uniswap V3**.

Instead of distributing liquidity across the entire price curve, **liquidity providers (LPs)** can allocate capital within specific price ranges. This creates:

- Lower slippage for trades
- Higher capital efficiency
- Customizable liquidity provisioning for LPs

---

## 📈 The AMM Formula (Uniswap V3 Style)

Uniswap V3 modifies the traditional constant product formula from:

```math
x * y = k
```

to a more granular, price-driven mechanism using **square root price ticks**.

### ✅ Key Formulas

- **Price definition (P):**  
  The price of token1 in terms of token0:
  \[
  P = \frac{token1}{token0}
  \]

- **Square root price (√P):**  
  Stored internally in the pool contract as:
  \[
  \sqrt{P} = \sqrt{\frac{token1}{token0}}
  \]

- **Liquidity constant across ticks (L):**  
  The amount of liquidity provided between two price ticks is kept constant:
  \[
  \Delta x = \frac{L \cdot (\sqrt{P_{upper}} - \sqrt{P_{lower}})}{\sqrt{P_{upper}} \cdot \sqrt{P_{lower}}}
  \]
  \[
  \Delta y = L \cdot (\sqrt{P_{upper}} - \sqrt{P_{lower}})
  \]

This allows the protocol to simulate a **concentrated order book**, while still functioning as a decentralized AMM.

---

## 💡 Key Features

| Feature                    | Description                                                                 |
|----------------------------|-----------------------------------------------------------------------------|
| **Concentrated Liquidity** | LPs can choose price ranges to allocate capital more efficiently            |
| **On-Chain Pricing**       | No external price feeds—prices adjust according to trades and liquidity     |
| **Range Orders**           | LPs can simulate limit orders by providing liquidity at specific ranges     |
| **Fee Tiers**              | Support for multiple swap fee tiers (e.g., 0.05%, 0.3%, 1%) per pool         |
| **Gas Optimization**       | Efficient tick-based design improves gas usage per trade                    |

---

## 🧮 Price Execution & Slippage

- All swaps follow **bonding curve mechanics**
- Swaps that consume liquidity across multiple price ticks experience **progressive slippage**
- The pool enforces price protection and validates minimum output constraints (`amountOutMin`)

---

## 🔐 Security and Integrity

- **Immutable pool contracts** prevent malicious upgrades
- **Permissionless architecture**: anyone can add liquidity or initiate swaps
- **Slippage tolerance** and **deadline** options protect users from MEV and frontrunning

---

## 📈 Example Use Case

Swapping 100 USDC to FGLY (Fungily token):

1. Call `swapExactTokensForTokens` with:
   - `amountIn = 100e6`
   - `path = [USDC, FGLY]`
   - `amountOutMin = estimated - slippage`
2. Contract calculates output based on current tick, liquidity range, and fee tier
3. Output tokens are transferred to `msg.sender`

---

## 🔗 Integration & Extensibility

- Compatible with wallet dApps, dashboards, and on-chain trading bots
- Can be combined with **Fungily Presale** and **Mintpad** to bootstrap post-launch liquidity
- Future support for:
  - Multi-hop routing
  - Limit orders
  - Liquidity mining programs

---

