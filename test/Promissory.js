const {expect}=require('chai')
const hre=require('hardhat')
describe("Promissory Contract", ()=>{
    let PromissoryContract, promissory 
    beforeEach(async ()=>{
        PromissoryContract = await hre.ethers.getContractFactory("Promissory");
        promissory = await PromissoryContract.deploy("0x2F13629e03286fA8C1135AfBccaF7DF810299fC4", "0x40154F00f2a6c0Ef7b7A2589c55D7250b43861d6", "0xdEf69C61a516E2648ABeED821a25422e4D0E91F6", "0xdFDBc88Ca3A8D6E4D3e6db389BE1baAA88f2dfC3");
        await promissory.deployed();
        console.log(`Promissory Contract Deployed ${promissory.address}`)
    })
    it("It should Add Property with all valid details", async ()=>{
        const propertyDetails={
            propertyId: 1,
            owner: "0x03d7c3b4c055029D6428Eda63F16043a4DDCD39B",
            tokenSupply: 100,
            tokenName: "Promissory Token",
            tokenSymbol: "XYZ",
            interestRate: 7.25 * (10^18)
        }
        //const response=await promissory.addProperty(propertyDetails)
        await expect(promissory.addProperty(propertyDetails)).to.emit(promissory, "PropertyAdded") 

    })
})