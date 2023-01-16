const hre = require("hardhat");

async function main() {
  const Promissory = await hre.ethers.getContractFactory("Promissory");
  const promissory = await Promissory.deploy();

  await promissory.deployed();

  console.log(`Promissory deployed on polygon mumbai to ${promissory.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
