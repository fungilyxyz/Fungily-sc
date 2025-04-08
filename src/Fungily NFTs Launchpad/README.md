
# 🧬 Fungily NFT Presale / Launchpad

Fungily’s NFT Presale system is a next-gen minting platform that bridges **NFT creation**, **on-chain liquidity**, and **instant trading** via an integrated **NFT Automated Market Maker (NFT-AMM)**.

Unlike traditional NFT mints that end in static collections, **Fungily mints are dynamic and liquidity-backed**, enabling real-time price discovery and trading post-mint—bringing a memecoin-style experience into NFT markets.

---

## 🚀 Key Benefits

- 🔁 **Tradeable NFTs Immediately After Mint**
- 📉 **Algorithmic Floor Price via Bonding Curves**
- 💧 **Built-in Liquidity Pools**
- 🧱 **Royalties & Protocol Fees Built-in**
- 🎯 **Whitelist & Public Mint Phases**
- 🆓 **Optional Free Mints with Manual Liquidity**

---

## ⚙️ How It Works

### 1. 🛠 NFT Collection Setup

Creators configure their NFT collection with the following:

- **Collection Name**
- **Symbol**
- **Description**
- **Image Assets or Generative Layers**

You can upload individual images or generate on-chain via metadata layers.

---

### 2. 🧾 Mint Configuration

Specify the mint structure with:

- **Mint Start & End Dates**
- **Mint Phases:**
  - `Whitelist Phase` (optional): Limited to pre-approved wallets.
  - `Public Phase`: Open access after whitelist ends.
- **Pricing & Supply:**
  - Fixed or tiered pricing per phase
  - Max supply cap
- **Royalties:**
  - Creator royalties on all secondary trades via the NFT-AMM or marketplace.

---

### 3. 💧 Liquidity Pool Setup (Pre-Mint)

Creators define how much of the collection and raised funds go into liquidity:

```yaml
Example:
  - 10% of total NFTs
  - 20% of raised tokens
```

These assets are committed to an **NFT Liquidity Pool**, enabling AMM-style trading.

---

### 4. 🔁 Post-Mint Transition

When the mint ends:

- Allocated NFTs + tokens are locked into the pool.
- Fungily’s **NFT-AMM (LiquidNFTs)** is activated.

Users can:

- **Buy NFTs** directly from the pool (bonding curve pricing).
- **Sell NFTs** back into the pool for tokens.

This enables:

- 🔄 Continuous Trading
- 📉 Live Price Discovery
- 📈 Liquidity-backed Floor Pricing

---

## ✨ Features Overview

| Feature               | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| **Phased Minting**    | Multiple mint stages (e.g. whitelist, public) with separate configs.        |
| **Instant Liquidity** | NFTs tradeable right after mint via Fungily’s AMM.                          |
| **Dynamic Floor**     | NFT floor price auto-set by bonding curve logic.                            |
| **Royalties**         | Creator royalties enforced via protocol on all AMM trades.                  |
| **Protocol Fees**     | Platform fees built into each AMM swap.                                     |
| **Optional Freemint** | Creators can skip mint pricing and add liquidity manually for free mints.   |

---

## 📚 Developer Integration Guide (Coming Soon)

Want to integrate your collection with Fungily? API, SDK, and smart contract templates will be available soon.

For early access or to get listed on the Mintpad, reach out to our team.

---



