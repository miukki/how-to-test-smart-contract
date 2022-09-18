// scripts/deploy.js
async function main() {
  const signers = await ethers.getSigners()
  const [deployer] = signers

  console.log('Deploying contracts with the account:', deployer.address)

  console.log('Account balance:', (await deployer.getBalance()).toString())

  // We get the contract to deploy
  const PRT = await ethers.getContractFactory('PRT')
  console.log('Deploying PRT...')
  const prt = await PRT.deploy()

  await prt.deployed()
  console.log('PRT deployed to address:', prt.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
