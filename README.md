
# Docus
https://hardhat.org/hardhat-runner/docs/guides/compile-contracts

# Deploy
npx hardhat run --network rinkeby ./scripts/deploy.js

# Console Debug
npx hardhat console --network rinkeby 

```

https://github.com/NomicFoundation/hardhat/issues/851
https://hardhat.org/hardhat-runner/docs/advanced/hardhat-runtime-environment
https://docs.ethers.io/v5/
```

# Verify
npx hardhat run  ./scripts/verifyContract.js --network rinkeby 
https://hardhat.org/hardhat-runner/docs/guides/verifying

# Hadrhad
```
###Try running some of the following tasks:
npx hardhat accounts
npx hardhat compile
npx hardhat test
npx hardhat node
npx hardhat help

```

# Coverage
```
yarn
npx hardhat coverage --network hardhat     
open coverage/index.html 
```

# Faucet
## Metamask Rinkeby how to faucet
https://faucets.chain.link/rinkeby

## Metamask Goerli how to faucet
https://goerlifaucet.com/


# Remix demon to connect to remix
https://www.npmjs.com/package/@remix-project/remixd


# How to use it.each with hardhat provided in example
```
   forEach([
            [1, 0, 999 ],
            [2, 1000, 1999 ],
            [3, 2000, 2999 ],
            [4, 3000, 3999 ],
            [5, 4000, 4999 ],
            [6, 5000, 5999 ],
            [7, 6000, 6999 ],
            [8, 7000, 7999 ],
            [9, 8000, 8999 ],
            [10, 9000, 9999 ]
          ]).it(`expected: %d, %d, %d`, async (expectedCnt, expectedF, expectedL) => {

```