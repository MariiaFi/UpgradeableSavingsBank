# UpgradeableSavingsBank

An upgradeable Ethereum smart contract built in Solidity using the **UUPS Proxy Pattern**.  
This contract lets users deposit ETH, tracks donations with timestamps, and allows the contract logic to be upgraded without losing data.

This is part of my `#100DaysOfSolidity` journey.  
It's my first real attempt at writing upgradeable contracts - I followed the proxy pattern from OpenZeppelin and extended it step by step.

---

## Features

### V1 - Base version
- Deposit ETH into the contract
- Track donations (address, amount, timestamp)
- Only the contract owner can withdraw
- View donation count and current balance
- Upgradeable via UUPS

### V2 - Upgrade
- Track total ETH donated
- Add emergency `pause()` to disable deposits
- Maintain full compatibility with V1 storage

---

## Tech Stack

- Solidity `^0.8.20`
- [OpenZeppelin Upgradeable Contracts](https://docs.openzeppelin.com/contracts/4.x/upgradeable)
- UUPS Proxy upgrade mechanism

---

## What I Learned

- How upgradeable proxies (UUPS) work in practice  
- Why `initializer()` and `reinitializer()` are needed  
- Managing storage layout across upgrades  
- Using `onlyOwner` for upgrade access control  
- Deploying + testing in Remix + MetaMask

---

## Try It on Remix

1. Open [Remix IDE](https://remix.ethereum.org/)
2. Paste `SavingsBank.sol` and deploy V1
3. Upgrade to `SavingsBankV2.sol` using the UUPS upgrade method
4. Test deposits, pause/unpause, donation history
5. Remove my comments from the first document beforehand so Remix doesn't complain
---

## Files

- `SavingsBank.sol` - Initial version
- `SavingsBankV2.sol` - Upgrade with pause + analytics

---

## Related Post

This repo was inspired by [my Day 6 post on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7325624218895745024/),  
where I realized that smart contracts can be upgraded - and how the UUPS proxy pattern actually works.

---

## About Me

Mariia Fialkovska  
Solidity learner & junior web3 enthusiast, sharing my progress publicly.  
You can follow my journey here: [LinkedIn](https://www.linkedin.com/in/mariia-fialkovska-78857b234/)

---

> Feedback, ideas or collab offers are always welcome
> Just drop me a message - I’m building in public and learning every day!
