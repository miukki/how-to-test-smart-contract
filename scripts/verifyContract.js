/**
 *  This script will calculate the constructor arguments for the `verify` function and call it.
 *  You can use this script to verify the contract on etherscan.io.
 */

 require('@nomiclabs/hardhat-etherscan')
 const hre = require('hardhat')
 
 
 async function main() {
   
   await hre.run('verify:verify', {
     address: '0x344C5918f9120f0Bc48Ee0e79D3cd0B205C9b4c5', // Deployed contract address
     constructorArguments: []
   })
 }
 
 // We recommend this pattern to be able to use async/await everywhere
 // and properly handle errors.
 main()
   .then(() => process.exit(0))
   .catch((error) => {
     console.error(error)
     process.exit(1)
   })
 