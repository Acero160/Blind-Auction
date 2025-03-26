
# 🎯 Blind Auction Smart Contract

**Blind Auction** project, designed to facilitate secure and transparent auctions where bids are hidden until the auction ends. The project includes comprehensive testing, including **unit tests** and **fuzz testing**, to ensure robustness and reliability.



---

## 🚀 Features

- **Auction Creation**: Anyone can start an auction by specifying an **item name, duration** (in hours), and **starting price**.
- **Blind Bidding**: Bidders submit their bids, and the highest bid is tracked **without revealing amounts** until the auction ends.
- **Automatic Refunds**: When the auction ends, the **creator receives the highest bid**, and losing bidders are **refunded** their amounts.
- **Security:**
  - Protected against **reentrancy attacks** using `ReentrancyGuard`.
  - **Input validation** and **custom errors** for robust error handling.
- ** Transparency**: Events (`HighestBidIncreased`, `AuctionEnded`) are emitted for **tracking bid updates** and **auction results**.
- ** View Functions**: Retrieve auction details (`creator, item name, highest bidder, etc.`) via `getAuctionDetails`.

---

## 📌 Smart Contract Overview

### 📦 Structs
- **`ItemToAuction`**: Stores auction details (**creator, item name, ID, highest bidder, bid amount, etc.**).

### 📚 Mappings
- Tracks **bidders, their bid amounts, and participation status** per auction.

### 🛑 Modifiers
- **`onlyCreator`**: Restricts certain actions (e.g., ending an auction) to the **auction creator**.

### 🔔 Events
- **`HighestBidIncreased`**: Emitted when a new highest bid is placed.
- **`AuctionEnded`**: Emitted when the auction concludes, **announcing the winner and final amount**.

### 🏗️ Functions
- **`startAuction`**: Initiates a new auction.
- **`bid`**: Allows users to **place bids** (payable).
- **`endAuction`**: Finalizes the auction, **transferring funds** to the creator and **refunding losers**.
- **`getAuctionDetails`**: Returns auction information.

---

## ⚙️ Prerequisites

- **Node.js and npm**: For managing dependencies.
- **Foundry**: For compiling, deploying, and testing the smart contract.
- **Solidity**: Version **^0.8.13**.
- **OpenZeppelin Contracts**: Used for **ReentrancyGuard**.

---

## 🔧 Installation

### 1️⃣ Clone the Repository:
```bash
git clone https://github.com/your-username/blind-auction.git
cd blind-auction
```

### 2️⃣ Install Dependencies:
Ensure **Foundry** is installed. If not, install it:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```
Then install project dependencies:
```bash
forge install
```

### 3️⃣ Compile the Contract:
```bash
forge build
```

---

## 🚀 Usage

### ✅ Deploy the Contract
Deploy the **BlindAuction** contract to your preferred Ethereum network (e.g., local, testnet, or mainnet) using Foundry:
```bash
forge create --rpc-url <your-rpc-url> --private-key <your-private-key> src/BlindAuction.sol:BlindAuction
```

### 🔄 Interact with the Contract
- Call **`startAuction`** to **create an auction**.
- Use **`bid`** to **place bids** with Ether.
- Call **`endAuction`** (as the creator) after the auction duration **to finalize it**.

---

## 🧪 Testing

The project includes a **comprehensive test suite** written using Foundry's testing framework. Tests cover both **standard unit tests** and **fuzz testing** to ensure the contract behaves correctly under various conditions.

### 🏗️ Test Setup
- **File**: `test/BlindAuctionTest.sol`
- **Dependencies**: Forge Standard Library (`forge-std`).
- **Test Contract**: `BlindAuctionTest` deploys the **BlindAuction** contract and simulates interactions with multiple accounts (**creator, bidder1, bidder2, bidder3**).

### ▶️ Running Tests
Run the full test suite:
```bash
forge test
```
For verbose output:
```bash
forge test -vvv
```

### 🔍 Test Cases
- **`testFuzzStartAuction`**:
  - Fuzzes auction creation with **random item names, durations, and starting prices**.
  - Verifies auction details are correctly set.
- **`testFuzzBid`**:
  - Tests bidding with **random bid amounts**.
  - Ensures the highest bidder and bid are updated correctly.
- **`testFuzzEndAuction`**:
  - Simulates multiple bids and **auction finalization**.
  - Verifies the **creator receives the highest bid** and **losers are refunded**.
- **`testFuzzConcurrentBids`**:
  - Tests **concurrent bidding** from multiple accounts.
  - Confirms the highest bidder wins and the number of bidders is tracked accurately.

### 🎲 Fuzz Testing
Fuzz tests use **Foundry's fuzzing capabilities** to input **random values** within specified bounds (e.g., bid amounts between **1 and 20 Ether**). This ensures the contract handles **edge cases** and **unexpected inputs gracefully**.

---

## 🔐 Security Considerations

- ** Reentrancy Protection**: The `nonReentrant` modifier **prevents reentrancy attacks** during fund transfers.
- ** Input Validation**: Custom errors (`InvalidStartPrice`, `InvalidBid`, etc.) **enforce valid inputs**.
- ** Time Management**: Auctions are **time-bound**, and **bids are rejected after the end time**.

---

## 🔮 Future Improvements

- **Add support for bid withdrawal** before the auction ends.
- **Implement a frontend interface** for easier interaction.
- **Extend testing** with formal verification tools (e.g., **Certora**).

---

