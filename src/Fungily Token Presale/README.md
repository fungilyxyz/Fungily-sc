# 🧪 Fungily Presale Protocol

**Fungily Presale** is a trustless token launchpad enabling creators to raise capital transparently and securely—without writing smart contracts. Whether the token is created via Fungily's no-code generator or imported, the presale system supports both **Gated (Whitelisted)** and **Fair Launch** models.

---

## 🔩 System Overview

### ✅ Token Onboarding

Fungily supports onboarding both new and pre-existing ERC-20 tokens.

- **Token Creation (Optional):** Use Fungily's no-code generator to deploy an ERC-20 token.
- **Token Import:** Import any ERC-20 token deployed on supported networks.
- **Ownership Verification:**  
  Fungily validates ownership via smart contract call to `Ownable.owner()` or similar pattern. This ensures only the rightful token deployer can initiate the presale.

---

## 🛠️ Presale Setup

Token creators configure key parameters through the frontend or SDK:

| Parameter        | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `softCap`        | Minimum fundraising target (in base asset like ETH/USDC)                    |
| `hardCap`        | Maximum fundraising limit                                                   |
| `tokenPrice`     | Fixed token price per base unit (e.g. 1 ETH = X Tokens)                     |
| `totalForSale`   | Total token amount allocated for presale                                    |
| `presaleStart`   | Timestamp when presale becomes active                                       |
| `presaleEnd`     | Timestamp when presale ends                                                 |
| `presaleType`    | `"whitelist"` (Gated) or `"public"` (Fair Launch)                           |
| `acceptedToken`  | Token accepted for contributions (e.g. ETH, USDC)                           |

---

## 🔓 Presale Types

### 1. **Gated Presale (Whitelisted)**  
Only wallet addresses explicitly added to the whitelist can contribute.

- Whitelist managed on-chain or via Merkle Root
- Creator can modify the whitelist pre-launch

### 2. **Fair Launch**  
Fully open to all wallets, no restrictions.

---

## 🚀 Presale Launch & Participation

Once live, the presale smart contract accepts user contributions.

- Contributions must be made in the `acceptedToken`
- Token allocation is based on the fixed `tokenPrice`
- Purchased tokens are **locked** until presale ends

> ℹ️ A real-time frontend displays live stats:
> - Total raised
> - Progress toward cap
> - Countdown timer

---

## 🔄 Post-Presale: Liquidity Bootstrapping

After hitting the soft or hard cap:

1. Creator pairs the **raised funds** with **remaining tokens**
2. A liquidity pool is initialized on **Fungily Token Swap**
3. Token becomes tradable instantly, ensuring zero downtime between mint and utility

> Liquidity parameters (e.g., % of raised funds for pool) are configurable by the creator.

---

## 💸 Fees & Economics

| Type                          | Details                                                                 |
|-------------------------------|-------------------------------------------------------------------------|
| **Presale Creation Fee**      | Flat fee (e.g., $100 in ETH/USDC) for contract deployment               |
| **Protocol Fee (Raise Cut)**  | Percentage of raised funds deducted before creator withdrawal (e.g., 2%)|
| **Buyer Transaction Fee**     | Fixed fiat-equivalent per transaction (e.g., $3 USD in ETH/USDC)        |
| **Chargeback Fee**            | 5% deducted if buyer exits before presale ends                          |

---

## 🔐 Presale Withdrawal (Optional Exit)

- Buyers can withdraw contributions **before presale ends**
- A **5% fee** is applied to discourage exit abuse and maintain integrity
- Withdrawals are disabled after the presale closes

---

## 📜 Smart Contract Security

- Fully non-custodial: Funds are locked in smart contracts until conditions are met
- Verified ownership to prevent malicious token listings
- Locking mechanisms prevent premature access to purchased tokens

---

## 🧰 Developer Toolkit

Fungily will provide:

- ✅ Smart contract ABIs
- ✅ SDKs (TypeScript/React)
- ✅ Frontend widgets
- ✅ Webhooks for presale events

---

- **Ownership Verification:**  
  Fungily validates ownership via smart contract call to `Ownable.owner()` or similar pattern. This ensures only the rightful token deployer can initiate the presale.

---

## 🛠️ Presale Setup

Token creators configure key parameters through the frontend or SDK:

| Parameter        | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| `softCap`        | Minimum fundraising target (in base asset like ETH/USDC)                    |
| `hardCap`        | Maximum fundraising limit                                                   |
| `tokenPrice`     | Fixed token price per base unit (e.g. 1 ETH = X Tokens)                     |
| `totalForSale`   | Total token amount allocated for presale                                    |
| `presaleStart`   | Timestamp when presale becomes active                                       |
| `presaleEnd`     | Timestamp when presale ends                                                 |
| `presaleType`    | `"whitelist"` (Gated) or `"public"` (Fair Launch)                           |
| `acceptedToken`  | Token accepted for contributions (e.g. ETH, USDC)                           |

---

## 🔓 Presale Types

### 1. **Gated Presale (Whitelisted)**  
Only wallet addresses explicitly added to the whitelist can contribute.

- Whitelist managed on-chain or via Merkle Root
- Creator can modify the whitelist pre-launch

### 2. **Fair Launch**  
Fully open to all wallets, no restrictions.

---

## 🚀 Presale Launch & Participation

Once live, the presale smart contract accepts user contributions.

- Contributions must be made in the `acceptedToken`
- Token allocation is based on the fixed `tokenPrice`
- Purchased tokens are **locked** until presale ends

> ℹ️ A real-time frontend displays live stats:
> - Total raised
> - Progress toward cap
> - Countdown timer



## 🔄 Post-Presale: Liquidity Bootstrapping

After hitting the soft or hard cap:

1. Creator pairs the **raised funds** with **remaining tokens**
2. A liquidity pool is initialized on **Fungily Token Swap**
3. Token becomes tradable instantly, ensuring zero downtime between mint and utility

> Liquidity parameters (e.g., % of raised funds for pool) are configurable by the creator.

---

## 💸 Fees & Economics

| Type                          | Details                                                                 |
|-------------------------------|-------------------------------------------------------------------------|
| **Presale Creation Fee**      | Flat fee (e.g., $100 in ETH/USDC) for contract deployment               |
| **Protocol Fee (Raise Cut)**  | Percentage of raised funds deducted before creator withdrawal (e.g., 2%)|
| **Buyer Transaction Fee**     | Fixed fiat-equivalent per transaction (e.g., $3 USD in ETH/USDC)        |
| **Chargeback Fee**            | 5% deducted if buyer exits before presale ends                          |

---

## 🔐 Presale Withdrawal (Optional Exit)

- Buyers can withdraw contributions **before presale ends**
- A **5% fee** is applied to discourage exit abuse and maintain integrity
- Withdrawals are disabled after the presale closes

---

## 📜 Smart Contract Security

- Fully non-custodial: Funds are locked in smart contracts until conditions are met
- Verified ownership to prevent malicious token listings
- Locking mechanisms prevent premature access to purchased tokens

