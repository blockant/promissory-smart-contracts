const chai=require('chai')
const expect=chai.expect
const hre=require('hardhat')

const tokenName="Promissory Token"
const PropertyInfo=[
    {
        //Added By Owner
        //Will Be Banned
        tokenName: 'Property Test Token 1',
        tokenSupply: 100,
        tokenSymbol: 'PTT1',
        interestRate: 725,
        lockingPeriod: 1,
        tokenAddress: null,
        updatedInterestRate: 3
    },
    {
        //By User 1
        tokenName: 'Property Test Token 2',
        tokenSupply: 100,
        tokenSymbol: 'PTT2',
        interestRate: 5025,
        lockingPeriod: 10,
        tokenAddress: null,
        updatedInterestRate: 3
    },
    {
        //By User 2
        tokenName: 'Property Test Token 3',
        tokenSupply: 300,
        tokenSymbol: 'PTT3',
        interestRate: 125,
        lockingPeriod: 2,
        tokenAddress: null,
        updatedInterestRate: 3
    },
    {
        //By User 2
        tokenName: 'Property Test Token 4',
        tokenSupply: 400,
        tokenSymbol: 'PTT4',
        interestRate: 125,
        lockingPeriod: 2,
        tokenAddress: null,
        updatedInterestRate: 3
    }
]
const propertyTokenSymbol="XYZ"
describe("Promissory Contract", ()=>{
    let PromissoryContract, promissory , owner, promissoryUser2, promissoryUser1,promissoryUser3, user1PropertyId, ownerPropertyId, contract, USDT_Token
    
    before(async ()=>{
        [owner, promissoryUser1,promissoryUser2, promissoryUser3] = await ethers.getSigners()
        console.log('Deployer/owner address is', owner.address)
        console.log('Promissory User 1 Address', promissoryUser1.address)
        console.log('Promissory User 2 Address', promissoryUser2.address)
        PromissoryContract = await hre.ethers.getContractFactory("Promissory");
        const someRandomERC20TokenContract=await hre.ethers.getContractFactory('ERC20Token')
        USDT_Token=await someRandomERC20TokenContract.deploy('Stable Coin USDT', 'USDT', 10000)
        await USDT_Token.deployed()
        console.log('USDT Token Address is', USDT_Token.address)
        //console.log('Amount of USDT Tokens Owner Has',(await USDT_Token.balanceOf(owner.address)) )

        promissory =  await PromissoryContract.deploy(owner.address, USDT_Token.address);
        await promissory.deployed();
        console.log(`Promissory Contract Deployed ${promissory.address}`)
    })
    describe("Deployment", function () {
        it("Should assign the total supply of USDT tokens to the owner", async ()=> {
          const ownerBalance = await USDT_Token.balanceOf(owner.address);
          expect(await USDT_Token.totalSupply()).to.equal(ownerBalance);
        });
    });
    describe("Transactions", function () {

        it("Should transfer 1000 USDT Tokens From Owner To Promissory User 1", async ()=> {
            await USDT_Token.transfer(promissoryUser1.address, 1000);
            const userBalance = await USDT_Token.balanceOf(promissoryUser1.address);
            expect(userBalance).to.equal(1000);
        });
        
        it("Should transfer 1000 USDT Tokens From Owner To Promissory User 2", async ()=> {
            await USDT_Token.transfer(promissoryUser2.address, 1000);
            const userBalance = await USDT_Token.balanceOf(promissoryUser2.address);
            expect(userBalance).to.equal(1000);
        });

        it("Should transfer 100 USDT Tokens From Owner To Promissory User 3", async ()=> {
            await USDT_Token.transfer(promissoryUser3.address, 100);
            const userBalance = await USDT_Token.balanceOf(promissoryUser3.address);
            expect(userBalance).to.equal(100);
        });

    })

    describe('Approvals', ()=>{
        
        it('Promissory User 1 Should give approval to smart contract to receive 500 USDT from his address', async()=>{
            await USDT_Token.connect(promissoryUser1).approve(promissory.address, 500)
            await expect(await USDT_Token.allowance(promissoryUser1.address, promissory.address)).equal(500)
        })
        it('Promissory User 2 Should give approval to smart contract to receive 500 USDT from his address', async()=>{
            await USDT_Token.connect(promissoryUser2).approve(promissory.address, 500)
            await expect(await USDT_Token.allowance(promissoryUser2.address, promissory.address)).equal(500)
        })
    })
    describe("Add Property By Owner", ()=>{  
        it("It should Add Property with all valid details", async ()=>{
            await expect(promissory.addProperty(PropertyInfo[0].tokenName, PropertyInfo[0].tokenSymbol, PropertyInfo[0].tokenSupply,PropertyInfo[0].interestRate, PropertyInfo[0].lockingPeriod ))
            .to.emit(promissory, "PropertyAdded") 
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
    })
    describe('Property with id 0 should have valid Properties', ()=>{
        it('Should Have Property Id as 0',async ()=>{
            const response=(await promissory.property(0))
            expect(response[0]).to.be.equal(0)
        })
        it('Should Have Owner Address as the platform owner address',async ()=>{
            const response=(await promissory.property(0))
            expect(response[1]).to.be.equal(owner.address)
        })
        it('Should Have Valid Token Name',async ()=>{
            const response=(await promissory.property(0))
            expect(response[2]).to.be.equal(PropertyInfo[0].tokenName)
        })
        it('Should Have Valid Token Symbol',async ()=>{
            const response=(await promissory.property(0))
            expect(response[3]).to.be.equal(PropertyInfo[0].tokenSymbol)
        })
        it('Should Have Valid Token Supply',async ()=>{
            const response=(await promissory.property(0))
            expect(response[4]).to.be.equal(PropertyInfo[0].tokenSupply)
        })
        it('Should Have Valid Interest Rate',async ()=>{
            const response=(await promissory.property(0))
            expect(response[5]).to.be.equal(PropertyInfo[0].interestRate)
        })
        it('Should Have Valid Locking Period',async ()=>{
            const response=(await promissory.property(0))
            expect(response[6]).to.be.equal(PropertyInfo[0].lockingPeriod)
        })
        it('Should Have Valid Status',async ()=>{
            const response=(await promissory.property(0))
            expect(response[7]).to.be.equal(1)
        })
    })
    describe("Add Property By External Promissory Users", ()=>{  
        it("It should Add Property with all valid details", async ()=>{
            await expect(promissory.connect(promissoryUser1).addProperty(PropertyInfo[1].tokenName, PropertyInfo[1].tokenSymbol, PropertyInfo[1].tokenSupply,PropertyInfo[1].interestRate, PropertyInfo[1].lockingPeriod  )).to.emit(promissory, "PropertyAdded") 
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
            await expect(promissory.connect(promissoryUser2).addProperty(PropertyInfo[2].tokenName, PropertyInfo[2].tokenSymbol, PropertyInfo[2].tokenSupply,PropertyInfo[2].interestRate, PropertyInfo[2].lockingPeriod  )).to.emit(promissory, "PropertyAdded") 
        })
        it("It should Add Property with  id 3 all valid details", async ()=>{
            await expect(promissory.connect(promissoryUser2).addProperty(PropertyInfo[3].tokenName, PropertyInfo[3].tokenSymbol, PropertyInfo[3].tokenSupply,PropertyInfo[3].interestRate, PropertyInfo[3].lockingPeriod  )).to.emit(promissory, "PropertyAdded") 
        })
        it(`Property with id 2 should have owner as promissory user 2`, async()=>{
            const response=(await promissory.property(2))
            expect(response[1]).to.be.equal(promissoryUser2.address)
        })
        it(`Property with id 3 should have owner as promissory user 2`, async()=>{
            const response=(await promissory.property(3))
            expect(response[1]).to.be.equal(promissoryUser2.address)
        })
    })
    describe("Approve Property (Complete Tokenization)", ()=>{  
        it("It should Throw Error if SM caller is not Owner", async ()=>{
            await expect((promissory.connect(promissoryUser1).approveProperty(1))).to.be.revertedWith("Caller is not the owner of the platform"); 
        })
        it("It should Throw Error if SM caller is Owner, but property Id is invalid", async ()=>{
            await expect((promissory.approveProperty(15))).to.be.revertedWith("Property do not exist!") 
        })
        it("It should Approve Property if SM caller is Owner , Property Id Is Valid", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.approveProperty(1)).to.emit(promissory, "PropertyApprovedAndTokenized").withArgs(
                1,
                promissoryUser1.address,
                PropertyInfo[1].tokenName,
                PropertyInfo[1].tokenSymbol,
                PropertyInfo[1].tokenSupply,
                (ERC20TokenAddress)=>{
                    console.log('ERC 20 Token Address For Property 1 is', ERC20TokenAddress)
                    PropertyInfo[1].tokenAddress=ERC20TokenAddress
                    return true
                },
                2,
                PropertyInfo[1].tokenSupply
            ) 
        })
        //TODO: Verify
        it("It should throw error, if approoving an already approved property", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.approveProperty(1)).to.be.revertedWith('Property do not exist!')
        })
        it('Approved property with 1 must have status of 2 in its state', async()=>{
            const response=(await promissory.property(1))
            expect(response[7]).to.be.equal(2)
        })
    })
    describe("Ban Property", ()=>{  
        it("If Property Banner is not promissory owner it should throw error", async ()=>{
            await expect((promissory.connect(promissoryUser1).banProperty(1))).to.be.revertedWith('Caller is not the owner of the platform') 
        })
        it("If Property Banner is promissory owner and Property Id is valid and property is not approved, it should be banned", async ()=>{
            const property=(await promissory.property(0))
            await expect((promissory.banProperty(0))).to.emit(promissory, "PropertyBanned").withArgs(
                0,
                property[1]
            )
        })
        it("It should Throw Error if property exists but is approved", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.banProperty(1)).to.be.revertedWith('Property do not exist!!')
        })
        it("It should Throw Error if property does not exist", async ()=>{
            await expect(promissory.banProperty(10)).to.be.revertedWith('Property do not exist!!')
        })
        it('Banned property with Id 0 must have status of 3 in its state', async()=>{
            const response=(await promissory.property(0))
            expect(response[7]).to.be.equal(3)
        })
    })
    describe("Update Interest Rate of Property", ()=>{  
        it("If Property Updater is not promissory owner it should throw error", async ()=>{
            await expect((promissory.connect(promissoryUser1).updateInterestRate(1, 2))).to.be.revertedWith('Caller is not the owner of the platform') 
        })
        it("It should Update Interest Rate of property if SM caller is Owner", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.updateInterestRate(1, PropertyInfo[1].updatedInterestRate)).to.emit(promissory, "InterestRateUpdated") .withArgs(
                1, PropertyInfo[1].updatedInterestRate
            )
        })
        it("Property which is not approved, shall not be updated", async ()=>{
            //console.log('Promisoory is', promissory)
            await expect(promissory.updateInterestRate(3, 3)).to.be.revertedWith('Property isn\'t approved yet!')
        })
    })
    describe("Invest In Property", ()=>{  
        it("User should Invest 10 (i.e < totalSupply) in Approved Property with id 1", async ()=>{
            //console.log('Promissory contract is?', promissory)
            await expect((promissory.connect(promissoryUser1).investInProperty(1, 10))).to.emit(promissory, 'Invested').withArgs(
                1, promissoryUser1.address, 10, PropertyInfo[1].tokenSupply, PropertyInfo[1].updatedInterestRate
            ) 
        })
        it("Limit should be changed from Token Supply to Token Supply -10 , thus investing tital Token Supply should throw error", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(1, PropertyInfo[1].tokenSupply))).to.be.revertedWith('Invested Amount exceeds the number of Property Tokens available') 
        })
        it("User should Invest 20 (another limit i.e < totalSupply) in Approved Property with id 1", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(1,20))).to.emit(promissory, 'Invested')
        })
        it("User other than property owner can too invest in the property id 1, 30 tokens", async ()=>{
            await expect((promissory.connect(promissoryUser2).investInProperty(1,30))).to.emit(promissory, 'Invested')
        })
        it("It should Throw Error if property is banned", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(0,20))).to.be.revertedWith('Property isn\'t approved yet!, Wait for platform to approve this property.')
        })
        it("It should Throw Error if property does not exist", async ()=>{
            await expect((promissory.connect(promissoryUser1).investInProperty(9,20))).to.be.revertedWith('Property isn\'t approved yet!, Wait for platform to approve this property.')
        })
        it('Residual Token Supply Should be Propert id 1 should be totalsupply - total invested',async ()=>{
            const response=await promissory.lockedTokens(1)
            //60 Is Invested Amount
            await expect(response).to.equal(PropertyInfo[1].tokenSupply-60)
        })
        it('Total Invested amount Should match the amount invested', async()=>{
            const response=await promissory.totalInvestedAmount(1)
            //60 Is Invested Amount
            await expect(response).to.equal(60)
        })
    })
    // // //TODO: Can a property be banned after investment?
    describe("Claim Investement, Property Owner Can Claim Invested USDT", ()=>{  
        it("Should throw an error, if user claiming investment is not property owner", async ()=>{
            await expect((promissory.connect(promissoryUser2).claimInvestment(1, 10))).to.be.revertedWith('You are not the onwer of this property!')
        })
        it("Should throw an error, if property owner claiming investment tries to claim more than available", async ()=>{
            await expect((promissory.connect(promissoryUser1).claimInvestment(1, 70))).to.be.revertedWith('Amount exceeds than available!')
        })
        it("Property Owner should be able to claim, the investment partially", async ()=>{
            await expect((promissory.connect(promissoryUser1).claimInvestment(1,10))).to.be.emit(promissory, 'InvestmentClaimed').withArgs(
                promissoryUser1.address,
                1,
                10
            )
        })
        it("Should throw an error, if property owner claiming investment tries to claim more than available, after any withdrawl", async ()=>{
            await expect((promissory.connect(promissoryUser1).claimInvestment(1,60))).to.be.revertedWith('Amount exceeds than available!')
        })
        it('Total Invested amount in property 1 match the total amount invested - any invested amount claimed', async()=>{
            const claimedInvestment=await promissory.claimedInvestment(1)
            const totalInvestedAmount=await promissory.totalInvestedAmount(1)
            //50 Is Invested Amount
            await expect(totalInvestedAmount-claimedInvestment).to.equal(50)
        })
        it("Property Owner should be able to claim, the investment made completely", async ()=>{
            await expect((promissory.connect(promissoryUser1).claimInvestment(1,50))).to.be.emit(promissory, 'InvestmentClaimed')
        })
    })
    describe("Claim Return", ()=>{  
        it("Should throw an error, if user claiming return is not an investor in the property", async ()=>{
            await expect((promissory.connect(promissoryUser3).claimReturn(1, 10))).to.be.revertedWith('You have not invested in this property!')
        })
        it("Should throw an error, investor is claiming more than expected", async ()=>{
            await expect((promissory.connect(promissoryUser2).claimReturn(1, 50))).to.be.revertedWith('Amount exceeds than available!')
        })
        it("Investor should be able to claim, the returns partially", async ()=>{
            await expect((promissory.connect(promissoryUser1).claimReturn(1,10))).to.be.emit(promissory, 'ClaimedReturn')
        })
        it("Investor should be able to claim the complete returns", async ()=>{
            await expect((promissory.connect(promissoryUser1).claimReturn(1,20))).to.be.emit(promissory, 'ClaimedInvestment')
        })
    })
    describe('Claim Property Token Locked in Smart Contract By Property Owner', ()=>{
        it("Should throw an error, if user claiming property Token Back is not property owner", async ()=>{
            await expect((promissory.connect(promissoryUser2).claimPropertyTokens(1, 10))).to.be.revertedWith('You are not the owner of this property!')
        })
        it('If Tokens are already invested in, user can not withdraw more than locked token', async ()=>{
            const response=await promissory.lockedTokens(1)
            console.log('Residual Locked Tokens are', response)
            await expect((promissory.connect(promissoryUser1).claimPropertyTokens(1, PropertyInfo[1].tokenSupply))).to.be.revertedWith('You are claiming more tokens than locked!')
        })
    })
    describe('Return Investment Made with interest by property owner', ()=>{
        it("Should throw an error, if user retuning investment made is not the owner of property", async ()=>{
            await expect((promissory.connect(promissoryUser2).returnInvestment(1, promissoryUser1.address))).to.be.revertedWith('You are not the owner of this property!')
        })
    })
})