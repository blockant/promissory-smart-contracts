const {expect}=require('chai')
const hre=require('hardhat')
const tokenName="Promissory Token"
const propertyTokenSymbol="XYZ"
describe("Promissory Contract", ()=>{
    let PromissoryContract, promissory 
    before(async ()=>{
        PromissoryContract = await hre.ethers.getContractFactory("Promissory");
        promissory =  await PromissoryContract.deploy("0x2F13629e03286fA8C1135AfBccaF7DF810299fC4", "0x40154F00f2a6c0Ef7b7A2589c55D7250b43861d6");
        await promissory.deployed();
        console.log(`Promissory Contract Deployed ${promissory.address}`)
    })
    describe("Add Property", ()=>{  
        it("It should Add Property with all valid details", async ()=>{
            await expect(promissory.addProperty(tokenName, propertyTokenSymbol, 100,725, 1 )).to.emit(promissory, "PropertyAdded") 
        })
        it("Add Property should Throw Error if token supply is negative", async ()=>{
            await expect(promissory.addProperty(tokenName, propertyTokenSymbol, -100,725, 1 )).to.Throw
        })
        it("Add Property should throw error if interest rate is negative", async ()=>{
            await expect(promissory.addProperty(tokenName, propertyTokenSymbol, 100,-725, 1 )).to.Throw
        })
        it("Add Property should throw error if locking period is negative", async ()=>{
            await expect(promissory.addProperty(tokenName, propertyTokenSymbol, 100,725, -1 )).to.Throw
        })
        it("Add Property should throw error if locking period is negative", async ()=>{
            await expect(promissory.addProperty(tokenName, propertyTokenSymbol, 100,725, -1 )).to.Throw
        })
        it('List of properties added should be 1', async()=>{
            const response=(await promissory.property(0))
            console.log('Response is', response)
            //expect(response).to
        })
    })
    describe("Update Interest Rate of Property", ()=>{  
        it("It should Throw Error if SM caller is not Owner", async ()=>{
            await expect((await promissory.updateInterestRate(1, 800))).to.Throw 
        })
        it("It should Update Interest Rate of property if SM caller is Owner", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(await promissory.updateInterestRate(1, 800).call({from: "0x2F13629e03286fA8C1135AfBccaF7DF810299fC4"})).to.emit(promissory, "InterestRateUpdated") 
        })
    })
    describe("Approve Property", ()=>{  
        it("It should Throw Error if SM caller is not Owner", async ()=>{
            await expect((await promissory.approveProperty(1, 800))).to.Throw 
        })
        it("It should Throw Error if SM caller is Owner, but property Id is invalid", async ()=>{
            await expect((await promissory.approveProperty(1, 800))).to.Throw 
        })
        it("It should Approve Property if SM caller is Owner", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(await promissory.updateInterestRate(1, 800).call({from: "0x2F13629e03286fA8C1135AfBccaF7DF810299fC4"})).to.emit(promissory, "InterestRateUpdated") 
        })
    })
    describe("Ban Property", ()=>{  
        it("It should Throw Error if SM caller is not Owner", async ()=>{
            await expect((await promissory.approveProperty(1, 800))).to.Throw 
        })
        it("It should Throw Error if SM caller is Owner, but property Id is invalid", async ()=>{
            await expect((await promissory.approveProperty(1, 800))).to.Throw 
        })
        it("It should Approve Property if SM caller is Owner", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(await promissory.updateInterestRate(1, 800).call({from: "0x2F13629e03286fA8C1135AfBccaF7DF810299fC4"})).to.emit(promissory, "InterestRateUpdated") 
        })
    })
    
})