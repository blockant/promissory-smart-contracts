const {expect}=require('chai')
const hre=require('hardhat')
const tokenName="Promissory Token"
const propertyTokenSymbol="XYZ"
describe("Promissory Contract", ()=>{
    let PromissoryContract, promissory , owner, promissoryUser2, promissoryUser1,promissoryUser3, user1PropertyId, ownerPropertyId, contract
    
    before(async ()=>{
        [owner, promissoryUser1,promissoryUser2, promissoryUser3] = await ethers.getSigners()
        console.log('Deployer/owner address is', owner.address)
        console.log('Promissory User 1 Address', promissoryUser1.address)
        console.log('Promissory User 2 Address', promissoryUser2.address)
        PromissoryContract = await hre.ethers.getContractFactory("Promissory");
        promissory =  await PromissoryContract.deploy(owner.address, "0x40154F00f2a6c0Ef7b7A2589c55D7250b43861d6");
        await promissory.deployed();
        console.log(`Promissory Contract Deployed ${promissory.address}`)
    })
    describe("Add Property By Owner", ()=>{  
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
        it('Property 0 should have owner as promissory owner', async()=>{
            const response=(await promissory.property(0))
            //console.log('Response is', response)
            expect(response[1]).to.be.equal(owner.address)
            //expect(response).to
        })
    })
    describe("Add Property By External Promissory Users", ()=>{  
        it("It should Add Property with all valid details", async ()=>{
            await expect(promissory.connect(promissoryUser1).addProperty(tokenName, propertyTokenSymbol+`1`, 100,725, 1 )).to.emit(promissory, "PropertyAdded") 
        })
        it("Add Property should Throw Error if token supply is negative", async ()=>{
            await expect(promissory.connect(promissoryUser1).addProperty(tokenName, propertyTokenSymbol, -100,725, 1 )).to.Throw
        })
        it("Add Property should throw error if interest rate is negative", async ()=>{
            await expect(promissory.connect(promissoryUser1).addProperty(tokenName, propertyTokenSymbol, 100,-725, 1 )).to.Throw
        })
        it("Add Property should throw error if locking period is negative", async ()=>{
            await expect(promissory.connect(promissoryUser1).addProperty(tokenName, propertyTokenSymbol, 100,725, -1 )).to.Throw
        })
        it("Add Property should throw error if locking period is negative", async ()=>{
            await expect(promissory.connect(promissoryUser1).addProperty(tokenName, propertyTokenSymbol, 100,725, -1 )).to.Throw
        })
        it(`Property with id 1 should have owner as promissory user 1`, async()=>{
            const response=(await promissory.property(1))
            expect(response[1]).to.be.equal(promissoryUser1.address)
        })
        it("It should Add Property with  id 2 all valid details", async ()=>{
            await expect(promissory.connect(promissoryUser1).addProperty(tokenName, propertyTokenSymbol, 1000,7250, 10 )).to.emit(promissory, "PropertyAdded") 
        })
        it(`Property with id 1 should have owner as promissory user 1`, async()=>{
            const response=(await promissory.property(2))
            expect(response[1]).to.be.equal(promissoryUser1.address)
        })
    })
    describe("Approve Property", ()=>{  
        it("It should Throw Error if SM caller is not Owner", async ()=>{
            await expect((promissory.connect(promissoryUser1).approveProperty(1, 100))).to.be.revertedWith("Caller is not the owner of the platform"); 
        })
        it("It should Throw Error if SM caller is Owner, but property Id is invalid", async ()=>{
            await expect((promissory.approveProperty(15, 100))).to.be.reverted 
        })
        it("It revert Approve Property if SM caller is Owner, and number of tokens to lock in not in limit", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.approveProperty(1, 1000)).to.be.revertedWith('Token release exceeds token supply') 
        })
        it("It should Approve Property if SM caller is Owner, and number of tokens to lock in limit", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.approveProperty(1, 100)).to.emit(promissory, "PropertyApprovedAndTokenized") 
        })
        it("It should throw error, if approoving an already approved property", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.approveProperty(1, 100)).to.be.reverted
        })
    })
    describe("Update Interest Rate of Property", ()=>{  
        it("If Property Updater is not promissory owner it should throw error", async ()=>{
            await expect((promissory.connect(promissoryUser1).updateInterestRate(1, 2))).to.be.revertedWith('Caller is not the owner of the platform') 
        })
        it("It should Update Interest Rate of property if SM caller is Owner", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.updateInterestRate(1, 3)).to.emit(promissory, "InterestRateUpdated") 
        })
        it("Property which is not approved, shall not be updated", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.updateInterestRate(2, 3)).to.be.revertedWith('Property isn\'t approved yet!')
        })
    })
    describe("Ban Property", ()=>{  
        it("If Property Banner is not promissory owner it should throw error", async ()=>{
            await expect((promissory.connect(promissoryUser1).banProperty(1))).to.be.revertedWith('Caller is not the owner of the platform') 
        })
        it("If Property Banner is promissory owner and Property Id is valid, should be success", async ()=>{
            await expect((promissory.banProperty(2))).to.emit(promissory, "PropertyBanned")
        })
        it("It should Throw Error if property does not exist", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.banProperty(10)).to.be.revertedWith('Property do not exist!!')
        })
    })
    describe("Invest In Property", ()=>{  
        it("User should Invest in Approved Property", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(1, 10))).to.emit(promissory, 'Invested') 
        })
        it("Limit should be changed from 100 to 90, thus betting 100 should throw error", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(1, 100))).to.be.revertedWith('Invested Amount exceeds the number of Property Tokens available') 
        })
        it("It should Invest In Property with another Limit", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(1,20))).to.be.emit(promissory, 'Invested')
        })
        it("User other than property owner can too invest in the property", async ()=>{
            await expect((promissory.connect(promissoryUser2).investInProperty(1,30))).to.be.emit(promissory, 'Invested')
        })
        it("It should Throw Error if property is banned", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(1,20))).to.be.revertedWith('Property isn\'t approved yet!, Wait for platform to approve this property.')
        })
    })
    //TODO: Can a property be banned after investment?
    describe("Claim Investement", ()=>{  
        it("Should throw an error, if user claiming investment is not property owner", async ()=>{
            await expect((promissory.connect(promissoryUser2).claimInvestment(1, 10))).to.be.revertedWith('You are not the onwer of this property!')
        })
        it("Should throw an error, if property owner claiming investment tries to claim more than available", async ()=>{
            await expect((promissory.connect(promissoryUser1).claimInvestment(1, 50))).to.be.revertedWith('Amount exceeds than available!')
        })
        it("User should be able to claim, the investment partially", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(1,10))).to.be.emit(promissory, 'ClaimedInvestment')
        })
        it("User should be able to claim, the investment completely", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(1,20))).to.be.emit(promissory, 'ClaimedInvestment')
        })
    })
    describe("Claim Return", ()=>{  
        it("Should throw an error, if user claiming return is not an investor in the property", async ()=>{
            await expect((promissory.connect(promissoryUser3).claimReturn(1, 10))).to.be.revertedWith('You have not invested in this property!')
        })
        it("Should throw an error, investor is claiming more than expected", async ()=>{
            await expect((promissory.connect(promissoryUser2).claimReturn(1, 50))).to.be.revertedWith('Amount exceeds than available!')
        })
        it("User should be able to claim, the investment partially", async ()=>{
            await expect((promissory.connect(promissoryUser1).claimReturn(1,10))).to.be.emit(promissory, 'ClaimedReturn')
        })
        it("Investor should be able to claim investment successfully", async ()=>{
            await expect((promissory.connect(promissoryUser1).claimReturn(1,20))).to.be.emit(promissory, 'ClaimedInvestment')
        })
    })
})