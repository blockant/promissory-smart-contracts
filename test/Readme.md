Test Description File

- While creating smart contract passing decimal places in the `_interestRate` argument throws `underflow` error, despite multiplying the interest rate by 100.
- Each Time property is approved new ERC20 Token for property is minted, however if property is minted with tokenSupply less than max supply, it can not be approved again. Thus any residual token can not be re-minted.
- Approved Property Can Not be Banned
  - In case This is desired behaviour, error throw is same as inexistent property `Property do not exist!`  
- Only Property owner can claim investment, currently anyone can claim investment
- Similary only Propertty Investors can claim Returns
  - Probable Source of bug
  ```solidity
        require(msg.sender != propertyIdToProperty[_propertyId].owner, "You are not the onwer of this property!");
  ```
  - Should be? 
  ```solidity
        require(msg.sender == propertyIdToProperty[_propertyId].owner, "You are not the onwer of this property!");
  ``` 