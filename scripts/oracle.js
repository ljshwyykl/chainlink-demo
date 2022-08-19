const { ethers } = require("hardhat")

async function main() {
    const Oracle = await ethers.getContractFactory("Operator")
    console.log("deploy to Operator...")
    const oracle = await Oracle.deploy(
        "0x326C977E6efc84E512bB9C30f76E30c160eD06FB",
        "0xD3420A3be0a1EFc0FBD13e87141c97B2C9AC9dD3"
    )
    console.log(oracle.address)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
