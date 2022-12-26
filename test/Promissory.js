const {expect}=require('chai')
const hre=require('hardhat')
describe("Promissory Contract", ()=>{
    let PromissoryContract, promissory 
    beforeEach(async ()=>{
        PromissoryContract = await hre.ethers.getContractFactory("Promissory");
        promissory =  await PromissoryContract.deploy("0x2F13629e03286fA8C1135AfBccaF7DF810299fC4", "0x40154F00f2a6c0Ef7b7A2589c55D7250b43861d6");
        await promissory.deployed();
        console.log(`Promissory Contract Deployed ${promissory.address}`)
    })

    describe("Add Property", ()=>{
        it("It should Add Property with all valid details", async ()=>{
            await expect(promissory.addProperty("Promissory Token", "XYZ", 100,725, 1 )).to.emit(promissory, "PropertyAdded") 
        })
        it("Add Property should Throw Error if token supply is negative", async ()=>{
            await expect(promissory.addProperty("Promissory Token", "XYZ", 100,-725, 1 )).to.be.reverted
        })
        // it("Add Property should throw error if interest rate is negative", async ()=>{
        //     await expect(promissory.addProperty("Promissory Token", "XYZ", 100,7.25, 1 )).to.be.reverted
        // })
        // it("Add Property should throw error if locking period is negative", async ()=>{
        //     await expect(promissory.addProperty("Promissory Token", "XYZ", 100,7.25, 1 )).to.be.reverted
        // })
    })
    
})