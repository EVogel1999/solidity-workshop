# Steps

The following contains the pre-requisites, terminal/command prompt commands, steps, and code for understanding crucial parts of the workshop.

## Pre-Requisites

You will need the following installed to successfully use this repository:

- [Node](https://nodejs.org/en/download/)
- [Git](https://git-scm.com/downloads)
- A text editor
  - [Visual Studio Code](https://code.visualstudio.com/Download)
  - [Atom](https://atom.io/)
  - Any other text editor you prefer

To fully understand this workshop, its assumed you know how to use node and code in ```javascript``` and/or ```typescript```, especially with async functions.  It also assumes you know how to use your computer's terminal or command prompt.

## Install Dependencies and Init Project

Run the following commands in an empty project directory in your terminal/command prompt:

```
$ npm init -y
$ npm install chai ethereum-waffle ethers @nomiclabs/hardhat-ethers @nomiclabs/hardhat-waffle @nomicfoundation/hardhat-toolbox @openzeppelin/contracts ts-node
$ npx hardhat
```

Alternatively you can clone this repository using ```git``` so you don't have to manually perform the setup steps.

## Create Smart Contract

Smart contract code is written in ```solidity``` which is a c-like programming language.  Let's start by creating a ```Job.sol``` file in the contracts folder with the following code:

```solidity
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Job {
    // TODO: Write code
}
```

For the actual code in the contract refer to [contracts/Job.sol](./contracts/Job.sol).

## Create Run Script

To run, test, and deploy solidity contracts you need to use ```javascript``` or ```typescript```.  After you create a ```run.js``` file in the scripts folder, you need to "deploy" your smart contract to a local ethereum node on your computer.  Running a local ethereum node means that it isn't connected to the ethereum blockchain (mainnet or testnet).  To do this, you have to add the following lines of code to a function:

```typescript
// 1. Get random wallets from your local ethereum node
const [client, addr1, addr2] = await hre.ethers.getSigners();

// 2. Get the contract's factory and deploy it
const JobFactory = await hre.ethers.getContractFactory('Job');
let jobContract = await JobFactory.deploy();

// 3. Wait for the deployment transaction to complete
await jobContract.deployed();

// 4. Record the contract's address (important when deploying to mainnet/testnet)
console.log('Contract deployed to:', jobContract.address);
```

To call a function from the script, all you have to do is reference the ```jobContract``` variable:

```typescript
const payout = await jobContract.getPayout();
await jobContract.acceptJob([addr1.address, addr2.address], [75, 25]);
```

To change who is calling the contract (default is ```owner```), you use the ```connect``` function on ```jobContract```:

```typescript
jobContract = jobContract.connect(addr1);
```

To deposit ETH to the contract, you call the ```deposit``` function with a specified value:

```typescript
await jobContract.deposit({value: ethers.utils.parseEther('1.3')});
```

Refer to [scripts/run.js](./scripts/run.js) for a complete example of interacting with the ```Job.sol``` contract using a javascript script.

## Running the Script

To run the script you have to invoke hardhat using the following command:

```
$ npx hardhat run .\scripts\run.js
```

When this runs, hardhat will create an artifacts folder.  This folder contains the contract's ABI file.  We don't cover it in this workshop, however you use ABI files for integrating smart contracts functions with frontend clients.
