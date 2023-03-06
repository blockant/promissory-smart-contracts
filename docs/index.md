# Solidity API

## ERC20Token

### constructor

```solidity
constructor(string name, string symbol, uint256 initialSupply) public
```

## Promissory

### USDT

```solidity
address USDT
```

The USDT token address, will be used as loan or investment

### promissoryOwner

```solidity
address promissoryOwner
```

The addressw which is owner of the platform

### PropertyAdded

```solidity
event PropertyAdded(uint256 PropertyId, address PropertyOwner, string PropertyTokenName, string PropertyTokenSymbol, uint256 PropertyTokenSupply, uint256 PropertyInterestRate, uint256 PropertyLockingPeriod)
```

### PropertyBanned

```solidity
event PropertyBanned(uint256 PropertyId, address PropertyOwner)
```

### PropertyApprovedAndTokenized

```solidity
event PropertyApprovedAndTokenized(uint256 PropertyId, address PropertyOwner, string TokenName, string TokenSymbol, uint256 TokenSupply, address PropertyTokenAddress, enum Promissory.PropertyStatus Status, uint256 NumberOfLockedTokens)
```

### InterestRateUpdated

```solidity
event InterestRateUpdated(uint256 PropertyId, uint256 InterestRate)
```

### Invested

```solidity
event Invested(uint256 PropertyId, address Investor, uint256 InvestmentAmount, uint256 TokenSupply, uint256 InterestRate)
```

### InvestmentClaimed

```solidity
event InvestmentClaimed(address PropertyOwner, uint256 PropertyId, uint256 ClaimedAmount)
```

### InvestmentReturned

```solidity
event InvestmentReturned(address PropertyOwner, address Investor, uint256 ReturnedAmount, uint256 InvestedAmount)
```

### ReturnClaimed

```solidity
event ReturnClaimed(address Investor, uint256 PropertyId, uint256 ReturnedAmount)
```

### PropertyTokensClaimed

```solidity
event PropertyTokensClaimed(address PropertyOwner, uint256 PropertyId, uint256 ClaimedTokens)
```

### TokenSupplyUpdated

```solidity
event TokenSupplyUpdated(address Owner, uint256 PropertyId, uint256 TokenSupply)
```

### LockingPeriodUpdated

```solidity
event LockingPeriodUpdated(uint256 PropertyId, uint256 LockingPeriod)
```

### PropertyStatus

```solidity
enum PropertyStatus {
  PENDING,
  ADDED,
  APPROVED,
  BANNED
}
```

### Property

```solidity
struct Property {
  uint256 propertyId;
  address owner;
  string tokenName;
  string tokenSymbol;
  uint256 tokenSupply;
  uint256 interestRate;
  uint256 lockingPeriod;
  enum Promissory.PropertyStatus status;
}
```

### property

```solidity
struct Promissory.Property[] property
```

### _propertyIdCount

```solidity
struct Counters.Counter _propertyIdCount
```

### Investment

```solidity
struct Investment {
  address investor;
  uint256 investmentAmount;
  uint256 timeStamp;
}
```

### propertyIdToProperty

```solidity
mapping(uint256 => struct Promissory.Property) propertyIdToProperty
```

### propertyIdToTokenAddress

```solidity
mapping(uint256 => address) propertyIdToTokenAddress
```

### lockedTokens

```solidity
mapping(uint256 => uint256) lockedTokens
```

### totalInvestedAmount

```solidity
mapping(uint256 => uint256) totalInvestedAmount
```

### claimedInvestment

```solidity
mapping(uint256 => uint256) claimedInvestment
```

### investments

```solidity
mapping(uint256 => mapping(address => struct Promissory.Investment)) investments
```

### propertyIdToInvestment

```solidity
mapping(uint256 => struct Promissory.Investment[]) propertyIdToInvestment
```

### constructor

```solidity
constructor() public
```

### checkPromissoryOwner

```solidity
modifier checkPromissoryOwner()
```

_creating a modifier which will be used later for checks_

### getAllProperties

```solidity
function getAllProperties() public view returns (struct Promissory.Property[])
```

### getAllInvestments

```solidity
function getAllInvestments(uint256 _propertyId) public view returns (struct Promissory.Investment[])
```

### addProperty

```solidity
function addProperty(string _tokenName, string _tokenSymbol, uint256 _tokenSupply, uint256 _interestRate, uint256 _lockingPeriod) external
```

creates a new property

### banProperty

```solidity
function banProperty(uint256 _propertyId) external
```

owner of the platform can ban a property

### approveProperty

```solidity
function approveProperty(uint256 _propertyId) external
```

owner of the platform will approve a property and it'll be tokenized and the tokens will be locked in the smart contract

### updateInterestRate

```solidity
function updateInterestRate(uint256 _propertyId, uint256 _interestRate) external
```

owner of the platform can update the interest rate of a property

### updateTokenSupply

```solidity
function updateTokenSupply(uint256 _propertyId, uint256 _tokenSupply) external
```

owner of the property can update the token supply of a property

### updateLockingPeriod

```solidity
function updateLockingPeriod(uint256 _propertyId, uint256 _updateLockingPeriod) external
```

owner of a property can update the locking period of it's respective property

### investInProperty

```solidity
function investInProperty(uint256 _propertyId, uint256 _investmentAmount) external
```

investors can invest in property now

### claimInvestment

```solidity
function claimInvestment(uint256 _propertyId, uint256 _numberOfTokensToClaim) external
```

Property owners can claim the investment that has been invested in thier property up until now

### returnInvestment

```solidity
function returnInvestment(uint256 _propertyId, address _investor) external
```

Property owner have to return loan with interest to the smart contract

### claimReturn

```solidity
function claimReturn(uint256 _propertyId, uint256 _returnAmount) external
```

Investors can claim the returned investment amount and return the proeprty token to property owner

### claimPropertyTokens

```solidity
function claimPropertyTokens(uint256 _propertyId, uint256 _claimTokens) external
```

Property Onwers can claim the property tokens locked in the smart contract

### getProperties

```solidity
function getProperties() public view returns (struct Promissory.Property[])
```

