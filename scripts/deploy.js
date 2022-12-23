const hre = require("hardhat");

async function main() {

  const PromissoryContract = await hre.ethers.getContractFactory("Promissory");
  const promissory = await PromissoryContract.deploy("0x2F13629e03286fA8C1135AfBccaF7DF810299fC4", "0x40154F00f2a6c0Ef7b7A2589c55D7250b43861d6", "0xdEf69C61a516E2648ABeED821a25422e4D0E91F6", "0xdFDBc88Ca3A8D6E4D3e6db389BE1baAA88f2dfC3");

  await promissory.deployed();

  console.log(`Promissory Contract Deployed ${promissory.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
