

# 🧩 Fungily NFT Swap – Developer Documentation

**Fungily NFT Swap** is a decentralized NFT trading mechanism powered by an **Automated Market Maker (AMM)** model. It enables users to buy and sell NFTs directly from a liquidity pool using a **constant product formula**, similar to token-based AMMs, ensuring real-time pricing, instant liquidity, and trustless trades.

---

## 🔄 Core Functionality

The Fungily NFT Swap allows users to:

- **Buy NFTs** from the pool by paying tokens.
- **Sell NFTs** into the pool in exchange for tokens.

Trades follow an AMM-based bonding curve, where **prices adjust dynamically** depending on the pool's NFT/token balance, ensuring supply/demand-driven price discovery.

---

## ⚙️ AMM Formula: Constant Product Market Maker

Fungily uses a **constant product formula** to drive NFT price mechanics:

\[
x \cdot y = k
\]

Where:

- `x` = Number of NFTs in the pool  
- `y` = Number of tokens in the pool  
- `k` = Constant product (remains invariant during swaps)

> This model guarantees that every trade shifts the balance of NFTs and tokens while preserving the product `k`, ensuring that prices adjust as the supply changes.

---

## 📦 Components

| Component      | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `NFTs (x)`     | Number of NFTs in the pool                                                  |
| `Tokens (y)`   | Number of fungible tokens (e.g., ETH, USDC) in the pool                     |
| `k`            | Invariant used to calculate price based on x and y                          |

---

## 🛒 NFT Buy Process

### 🔁 Buying 1 NFT

**Initial Pool State:**

- `x₁` NFTs  
- `y₁` tokens  
- `k = x₁ * y₁`

**After Buying 1 NFT:**

- New NFT balance: `x₂ = x₁ - 1`  
- New token balance required to maintain `k`:  
  \[
  y₂ = \frac{k}{x₂}
  \]

**Price Paid:**
\[
\text{Price} = y₂ - y₁ = \frac{k}{x₂} - y₁
\]

**Result:** As `x` decreases, price increases → classic bonding curve behavior.

---

## 📤 NFT Sell Process

### 🔁 Selling 1 NFT

**Initial Pool State:**

- `x₁` NFTs  
- `y₁` tokens  
- `k = x₁ * y₁`

**After Selling 1 NFT:**

- New NFT balance: `x₂ = x₁ + 1`  
- New token balance to preserve `k`:  
  \[
  y₂ = \frac{k}{x₂}
  \]

**Tokens Received:**
\[
\text{Payout} = y₁ - y₂ = y₁ - \frac{k}{x₂}
\]

**Result:** As `x` increases, price decreases, encouraging buying.

---

## 💰 Price Calculation

At any point, the **spot price** of an NFT in the pool is:

\[
\text{Price} = \frac{y}{x}
\]

This provides real-time price discovery based on current liquidity levels.

---

## 📉 Slippage

Slippage occurs when:

- Large volume trades affect the token/NFT balance significantly
- The price for each additional NFT in a batch buy/sell increases or decreases due to the bonding curve

**Mitigation:**

- Use slippage protection (min/max return values)
- Display pre-trade estimates in UI

---

## 💸 Fees & Royalties

Fungily integrates both platform fees and creator royalties into every swap.

| Fee Type         | Description                                                                   |
|------------------|-------------------------------------------------------------------------------|
| **Platform Fee** | % fee per trade, retained by the protocol (e.g., 2%)                          |
| **Creator Royalty** | Set by the NFT creator during minting (e.g., 5%), sent to creator wallet    |

### Example Calculation (Buy Trade):

- **NFT Price**: 100 tokens  
- **Platform Fee (2%)**: 2 tokens  
- **Creator Royalty (5%)**: 5 tokens  
- **Total Paid by Buyer**: 107 tokens  
- **Tokens added to pool**: 100 tokens  
- **Protocol & Creator receive**: 7 tokens split accordingly

---

## 🔁 Swap Workflow Summary

### ✅ Buying an NFT:

1. User selects NFT to buy.
2. Swap contract calculates current price using `x * y = k`.
3. User transfers tokens (`price + fees`).
4. NFT is transferred to the user.
5. Pool updates: `x--`, `y++`, `k` preserved.

### ✅ Selling an NFT:

1. User submits NFT to swap contract.
2. Swap calculates tokens to return: `y₁ - (k / x₂)`
3. Platform/creator fees deducted from payout.
4. Tokens transferred to seller.
5. Pool updates: `x++`, `y--`, `k` preserved.

---


### Optional Parameters:

- `minTokensIn / minTokensOut`: Protects against slippage
- `deadline`: Transaction must complete before this timestamp

---

## 📚 Integration Notes

- Fully compatible with ERC721/ERC1155 NFTs
- Can be paired with **Fungily Mintpad** to create liquidity-backed NFTs at launch
- Liquidity pools are initialized by creators post-mint or post-presale

---

## 🔐 Security Measures

- Swaps require pre-approval for token/NFT transfers
- Royalty logic handled at the smart contract level to ensure consistency
- Adminless, immutable pool contracts post-deployment

