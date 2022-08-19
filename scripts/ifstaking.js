const { ethers } = require("hardhat")

async function main() {
    const IfChainlinkClient = await ethers.getContractFactory("IfChainlinkClient")
    console.log("deploy to IfChainlinkClient...")
    const ifChainlinkClient = await IfChainlinkClient.deploy()
    console.log(ifChainlinkClient.address)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
