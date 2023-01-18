# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```

Latest Deployment(19/01/2023 12:44 AM): https://mumbai.polygonscan.com/address/0x039032fe5d989037e3ef6315475228c1dd5ee485

For function input reference, use: https://mumbai.polygonscan.com/address/0x40cc438c7294918a889186b979382232003f526e


# Promissory

- [x] Compiled  
       Compiled 2 Solidity file successfully

- [x] Deployed  
       Promissory Test USDT depoyed on polygon mumbai to 0x5445048b9172c132ca5e85213859d3bffcc5231a
      Promissory deployed on polygon mumbai to 0xAcCcA6bA1c86a2CD9F527c682C535c79E51b6203

- [x] Verified using remix and polygonscan  
       [Promissory Test USDT](https://mumbai.polygonscan.com/address/0x5445048b9172c132ca5e85213859d3bffcc5231a#writeContract)  
       [Promissory](https://mumbai.polygonscan.com/address/0xaccca6ba1c86a2cd9f527c682c535c79e51b6203#writeContract)

# Smart Contract:

### 1. Property Owners:

Property Owners can add a property  
 by calling `addProperty` with params:  
string tokenName, name of property token
string tokenSymbol, symbol of property token
uint256 tokenSupply, total supply of property token
uint256 interestRate, interest rate for investments
uint256 lockingPeriod, locking period for investments - in seconds for testing

- A property with all these details will be added along with a propertyId, it's owner address and status \*

### 2. Promissory Owner:

Promissory Owners will then approve a property by verifying it's details  
 by calling `approveProperty` with param:  
uint256 propertyId, propertyId of the property to approve and tokenize

- The property of input propertyId will be tokenized and it's status will change to APPROVED \*

#### NOTICE : Promissory Onwer can band any property any time!

### 3. TestUSDT Deployer: To get TestUSDT Token to invest

TestUSDT Deployer will transfer testUSDT to investors account  
 by calling `transfer` of TestUSDT with params:  
address to, investors address  
uint256 amount, tokens amount

### 4. Investor:

Now for investors to invest:

- [a] give approval to Promissory Contract to access investor's testUSDT  
   by calling `approve` of TestUSDT with params:
  address to, promissory contract address  
  uint256 amount, tokens amount
- [b] now proceed to invest in a property  
   by calling `investInProperty` with params:  
  uint256 propertyId, propertyId of the property to invest  
  uint256 investmentAmount, amount of testUSDT tokens to invest

* Now, here when the investment is done, TeastUSDT tokens will transfer to Promissory Contract and Property Tokens will be transfered to investors address \*
* It also stores the time of investment for gains \*

### 5. Property Owner:

Property Onwers can claim the investment that has been made to it's property  
 by calling `claimInvestment` with params:  
uint256 propertyId, property of the property to claim investment  
uint256 numberOfTokensToClaim, amount of number of tokens to claim

### 6. TestUSDT Deployer:To get TestUSDT Token to return investment

TestUSDT Deployer will transfer testUSDT to propertyOwners account  
 by calling `transfer` of TestUSDT with params:  
address to, investors address  
uint256 amount, tokens amount

### 7. Property Owner:

Now for property onwers to return investment:

- [a] give approval to Promissory Contract to access property onwers's testUSDT  
   by calling `approve` of TestUSDT with params:
  address to, promissory contract address  
  uint256 amount, tokens amount
- [b] now proceed to return investment with interest to a investor  
   by calling `returnInvestment` with params:  
  uint256 propertyId, propertyId of the property to retrunInvestment  
  address investor, address of investor

* It only allows to return investment with interest if the locking period is finished! \*
* Transfers TestUSDT to Promissory Contract \*
