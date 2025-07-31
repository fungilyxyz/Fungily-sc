# 🌱 Fungily Protocol

**Fungily** is a next-generation platform for launching, minting, swapping, and trading NFTs and tokens with built-in liquidity. It combines familiar tools like NFT marketplaces and presales with powerful DeFi mechanics like Automated Market Makers (AMMs), enabling dynamic pricing, instant tradability, and liquidity-backed floor prices.

Whether you're a creator, collector, or developer, Fungily offers the infrastructure to build, launch, and interact with NFTs and tokens in a seamless, decentralized way — no code required.

---

## 🔧 What’s Inside

Fungily is composed of modular products that work together to provide a full-stack decentralized asset platform:

### 📦 Core Modules

| Module | Description |
|--------|-------------|
| [**Fungily NFTs Launchpad**](src/Fungily%20NFTs%20Launchpad/README.md) | Create, configure, and mint NFTs with liquidity-backed presales. |
| [**Fungily Token Presale**](src/Token%20Presale/README.md) | Launch tokens with fair and gated presale options, and bootstrap liquidity. |
| [**Fungily Token Swap**](src/Token%20Swap/README.md) | Swap tokens via AMM similar to Uniswap V3 with efficient pricing. |
| [**Fungily NFT Swap**](src/NFT%20Swap/README.md) | Buy/sell NFTs using an AMM model based on bonding curves. |
| [**Fungily Marketplace**](src/Marketplace/README.md) | A liquidity-integrated NFT marketplace for buying, selling, and discovering NFTs. |

---

## ⚙️ Technologies Used

- Solidity Smart Contracts
- Automated Market Makers (AMMs)
- Bonding Curves (Constant Product Formulas)
- EVM-compatible Chains
- Frontend: React + Ethers.js + TailwindCSS

---

## 📂 Developer Docs

Each product module contains its own technical documentation and implementation details. Browse them here:

- [`Fungily NFTs Launchpad`](https://fungily.gitbook.io/fungily/fungily-nft/launchpad-presale)
- [`Token Presale`](https://fungily.gitbook.io/fungily/fungily-token/token-presale)
- [`Token Swap`](https://fungily.gitbook.io/fungily/fungily-token/token-swap)
- [`NFT Swap`](https://fungily.gitbook.io/fungily/fungily-nft/liquidnfts)
- [`Marketplace`](https://fungily.gitbook.io/fungily/fungily-nft/marketplace)

---


```bash
# Clone the repo
git clone https://github.com/fungilyxyz/Fungily-sc.git

# Navigate and start building
cd Fungily-sc

# Installation


forge install

# Compile contracts

forge build


# Forge test

forge test

```