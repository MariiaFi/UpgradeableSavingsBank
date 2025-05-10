# UpgradeableSavingsBank

An upgradeable Ethereum smart contract built with Solidity and the UUPS proxy pattern. It allows users to deposit ETH, tracks donations, and supports contract upgrades without losing stored data.

This project is part of my learning journey in the `#100DaysOfSolidity` challenge — it's my first hands-on implementation of proxy-based upgradeable contracts.

## Features

- ETH deposits
- Donation tracking with timestamp
- OnlyOwner withdrawals
- UUPS upgradeable logic (OpenZeppelin)
- View donation history and contract balance
- V2 Upgrade: 
  - Track total ETH donated
  - Emergency pause toggle (can disable deposits)

## Technologies Used

- Solidity ^0.8.20
- OpenZeppelin Upgradeable Contracts
- UUPS Proxy Pattern

## Version History

- **V1:** Basic savings bank with deposit, withdraw, donation tracking
- **V2:** Adds pause functionality and totalDonated counter

## Learning Goals

This contract helped me understand:
- How UUPS upgradeable proxies work
- Why `initializer()` and `reinitializer()` are necessary
- How to manage storage layout during upgrades
- The importance of `onlyOwner` and `access control`

## Try it on Remix

Paste either `SavingsBank.sol` or `SavingsBankV2.sol` into [Remix IDE](https://remix.ethereum.org/) and deploy to testnet with an injected wallet (e.g. MetaMask). Make sure to enable the "Solidity compiler" and "Deploy & Run Transactions" plugins.

## Files

- `SavingsBank.sol` — V1
- `SavingsBankV2.sol` — upgrade with pause and analytics

## 📸 Preview

You can find a demo of how this contract works with frontend integration in this LinkedIn post:  
 [My Solidity Day 6: Using UUPS Proxy Pattern](https://www.linkedin.com/posts/mariia-fialkovska-78857b234_100daysofsolidity-solidity-blockchain-activity-7324820319548882944-5cwB)

## Author

👩‍💻 Mariia Fialkovska  
Solidity beginner, building my developer portfolio step by step.  
Follow my progress on [LinkedIn](https://www.linkedin.com/in/mariia-fialkovska-78857b234/)

---

