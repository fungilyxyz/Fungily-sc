# 🛍️ Fungily Marketplace — Technical Documentation

**Fungily Marketplace** is a next-generation NFT platform designed for creators, collectors, and traders. It combines the familiar NFT marketplace experience with **liquidity-backed pricing and on-chain automated market making (AMM)** to offer a secure, fair, and sustainable trading environment.

---

## Core Marketplace Features

Fungily provides the standard functionality expected from an NFT marketplace, with enhanced trading logic:

- ✅ **Collection Browsing**  
  View and explore curated NFT collections.
  
- ✅ **NFT Listings**  
  List NFTs via fixed-price, offers, or auction formats.
  
- ✅ **NFT Buying and Bidding**  
  Purchase NFTs at market price or place competitive bids.
  
- ✅ **Creator Royalties**  
  Enforce on-chain royalties with every secondary sale.
  
- ✅ **Activity & Rarity Tracking**  
  Monitor floor price, holder count, trading volume, and NFT rarity.

---

## 💡 Key Differentiators

What sets Fungily apart is its **on-chain liquidity integration**. Every collection is paired with a **smart liquidity pool**, allowing for:

- 🔒 **Liquidity-Backed Floor Prices**  
  NFTs cannot be listed below the value secured in the collection's liquidity pool. This creates a minimum price threshold based on AMM logic (constant product model), ensuring pricing integrity and protecting holders from undercutting.

- ⚖️ **Price Protection**  
  AMM-derived price curves determine the floor, dynamically adjusting based on the pool’s NFT and token reserves.

- 💰 **Value-Backed Listings**  
  Every listed NFT represents an asset with actual on-chain liquidity, reducing speculation and price volatility.

---

## 🔁 NFT Listing Mechanics

Fungily supports the following listing types:

| Listing Type       | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| **Fixed Price**     | List at a specific token amount. Enforced by minimum floor from the pool.   |
| **Offer System**    | Bidders can place custom offers on listed or unlisted NFTs.                 |
| **Timed Auctions**  | Users set a duration and reserve price; highest bidder wins post-expiry.    |

> 🛡️ Note: Listings are validated against the **liquidity-backed floor price** derived from the associated pool. Listings below this floor are automatically rejected.

---

## 🧮 Floor Price Calculation

Each collection is paired with an AMM pool governed by the constant product formula:

\[
x \cdot y = k
\]

Where:

- `x` = Number of NFTs in pool  
- `y` = Number of tokens in pool (e.g., ETH/USDC)  
- `k` = Constant product

The **floor price** is derived using:

\[
\text{Floor Price} = \frac{y}{x}
\]

This ensures that the value of NFTs is tied to real token reserves.

---

## 🎨 Creator-Centric Features

Fungily empowers creators with tools to manage and grow their collections:

| Feature             | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| **Royalties**       | Set and enforce on-chain royalty % on secondary sales                       |
| **Verified Collections** | Submit for verification to gain trust and visibility                        |
| **Drop Management** | Tools to launch generative or 1/1 collections with liquidity pool pairing   |
| **Sales Dashboard** | Track sales history, royalties earned, and price trends                     |

---

## 📈 Market Insights

The platform provides robust analytics for collections and individual NFTs:

- 📊 Floor price trends
- 👥 Number of holders
- 🔄 Swap activity via liquidity pools
- 📦 Real-time volume
- ⭐ Rarity scores and rankings

These stats are derived directly from on-chain data and swap contracts.

---

## 🤝 Community & Discovery

To aid discoverability and trust:

- ✅ **Verified Collections**: Curated and reviewed by Fungily to reduce scams  
- ✅ **Community Voting**: Integrate DAOs for collection promotion  
- ✅ **Featured Drops**: Highlight trending or high-quality NFT projects

---

## 💼 Wallet & Portfolio View

Each user has a **dashboard** to:

- 📁 View owned NFTs
- 💵 Monitor current market value (based on AMM pricing)
- 🧾 Access trade history
- 📉 View historical valuations and liquidity position

---

## 🔄 Marketplace vs Traditional Platforms

| Feature                             | Traditional Marketplaces | Fungily Marketplace |
|-------------------------------------|---------------------------|---------------------|
| Standard Listings                   | ✅ Yes                    | ✅ Yes              |
| Bids & Auctions                     | ✅ Yes                    | ✅ Yes              |
| On-Chain Creator Royalties          | ✅ Yes                    | ✅ Yes              |
| Verified Collections                | ✅ Yes                    | ✅ Yes              |
| **Liquidity-Backed Floor Prices**   | ❌ No                     | ✅ Yes              |
| **Enforced Price Minimums**         | ❌ No                     | ✅ Yes              |
| **AMM-Based Pricing Logic**         | ❌ No                     | ✅ Yes              |
| **Prevents Listing Below Pool Value** | ❌ No                     | ✅ Yes              |

---

## 🧠 How It Works (Simplified Workflow)

1. **Creator Deploys Collection**  
   -> Initializes a liquidity pool (NFTs + base token)  
   -> Sets royalty %  

2. **Buyer Visits Marketplace**  
   -> Sees available listings & pool-determined floor price  
   -> Chooses fixed-price NFT or participates in auction

3. **Trade Occurs**  
   -> Fungily contract checks listing price ≥ floor price  
   -> Trade executes, fees + royalties are distributed  
   -> Pool state updates (`x`, `y`, `k`)


---

## 📎 Resources

- 🌐 Website: [https://fungily.xyz](https://fungily.xyz)  
- 📚 Docs: [https://docs.fungily.xyz](https://docs.fungily.xyz)  
- 🛠 SDK Access: dev@fungily.xyz  
- 🐦 Twitter: [@FungilyXYZ](https://twitter.com/FungilyXYZ)
