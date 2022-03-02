const hre = require("hardhat");

async function main() {

    const [deployer] = await ethers.getSigners();
    
    console.log(`Deploying contracts with the account: ${deployer.address}`);
    console.log(`Account balance: ${(await deployer.getBalance()).toString()}`);
    const nftContractFactory = await hre.ethers.getContractFactory(
        "BPSC"
    );
    const nft = await nftContractFactory.deploy("Test BPSC", "BPSC", "https://safelips.online/assets/meta/contract.json", "https://bafkreiba26n47tgsl4wsy7f3vyj5at7iytp2slssdp2rybjsf4iz7k4kfm.ipfs.dweb.link");
    console.log(`Contract deployed to address: ${nft.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });