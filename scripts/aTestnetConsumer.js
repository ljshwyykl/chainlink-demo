const { ethers } = require("hardhat")

async function main() {
    const ATestnetConsumer = await ethers.getContractFactory("ATestnetConsumer")
    console.log("deploy to ATestnetConsumer...")
    const aTestnetConsumer = await ATestnetConsumer.deploy()
    console.log(aTestnetConsumer.address)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
