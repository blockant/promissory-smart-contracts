// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "./IERC20.sol";
import "./ERC20Token.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// @dev Followed Promissory Product Summary.pdf

/// @title Promissory: 4 different stakeholders named super admin, property owners, promissory platform and the investors. 
/*

@Super Admin
Will manage all other stakeholders and will do the KYC ofproperty owners and investors.

@Property Owner
Can list their properties to get some loan or investment from other stakeholders,
along with the total amount required with the return interest rate for the investors.
Property owners then can payback to investors.

@Promissory Platform
Will approve the properties to be listed on the marketplace,
So that investors can discover them and invest their money in the properties.
After approval, it will transfer crypto tokens to property owners so
that they can send these tokens to investors in exchange for the investment.

@Investors
Will view all the listed properties on the platform and,
Will invest their money to earn the interest on their investment.
In return, they will get crypto tokens from property owners.

*/

contract Promissory{
    //using the SafeMath library
    using SafeMath for uint256;

    /*//////////////////////////////////////////////////////////////
                                ADDRESSES
    //////////////////////////////////////////////////////////////*/

    /// @notice The USDT token address, will be used as loan or investment
    address public USDT;
    
    /// @notice The addressw which is owner of the platform
    address public promissoryOwner;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event PropertyAdded(uint256 indexed PropertyId, address indexed PropertyOwner, string PropertyTokenName, string PropertyTokenSymbol, uint256 PropertyTokenSupply, uint256 PropertyInterestRate, uint256 PropertyLockingPeriod);
    event PropertyBanned(uint256 indexed PropertyId, address indexed PropertyOwner);
    event PropertyApprovedAndTokenized(uint256 indexed PropertyId, address indexed PropertyOwner, string TokenName, string TokenSymbol, uint256 TokenSupply, address indexed PropertyTokenAddress, uint256 NumberOfLockedTokens);
    event InterestRateUpdated(uint256 indexed PropertyId, uint256 indexed InterestRate);
    event Invested(uint256 PropertyId, address Investor, uint256 InvestmentAmount, uint256 TokenSupply, uint256 InterestRate);
    event ClaimedInvestment(address indexed PropertyOwner, uint256 indexed PropertyId, uint256 indexed ClaimedAmount);
    event ReturnedInvestment(address indexed PropertyOwner,address indexed Investor, uint256 indexed ReturnedAmount, uint256 InvestedAmount);
    event ClaimedReturn(address indexed Investor,uint256 indexed PropertyId,uint256 indexed ReturnedAmount);
    event ClaimedPropertyTokens(address indexed PropertyOwner, uint256 indexed PropertyId, uint256 indexed ClaimedTokens);

    /// @dev An enum for representing whether a property is
    /// @param Pending when nothing happend
    /// @param Added when property is added
    /// @param Approved when property is approved and tokenized
    /// @param Banned when property is banned
    enum PropertyStatus {
        PENDING,
        ADDED,
        APPROVED,
        BANNED
    }

    /// @dev is using enum as a state variable
    //PropertyStatus public status;
    // Returns uint
    // Pending  - 0
    // Added  - 1
    // Approved - 2
    // Banned - 3

    /// @dev Property struct contains variable that collectively defines a property
    /// @param propertyId is Id of property assigned by owner of the property
    /// @param owner is owner of the property i.e msg.sender
    /// @param tokenSupply is the number of property token created by owner
    /// @param tokenName is the name of property token created by owner
    /// @param tokenSymbol is symbol of property token created by owner
    /// @param interestRate is the interest on the property decided by owner
    /// @param lockingPeriod is the duration of Property to be locked by owner 
    /// @param tokenAddress is the address of Property token when property gets approved and tokenized
    /// @param PropertyStatus is the status of a property with the help of enum
    struct Property{
        uint256 propertyId;
        address owner;
        string tokenName;
        string tokenSymbol;
        uint256 tokenSupply; 
        uint256 interestRate; //handle 2 decimal points (1000)
        uint256 lockingPeriod;
        PropertyStatus status;
    }

    //An array of 'Property' struct
    Property[] public property;

    /// @dev Counters for assigning and updating propertyId
    using Counters for Counters.Counter;
    Counters.Counter public _propertyIdCount;

    // Struct for storing investment information
    struct Investment {
        address investor;
        uint256 investmentAmount;
        uint256 timeStamp;
    }

    /*//////////////////////////////////////////////////////////////
                                MAPPING
    //////////////////////////////////////////////////////////////*/
    
    mapping (uint256 => Property) public propertyIdToProperty;// Mapping for storing property details with propertyId
    mapping (uint256 => address) public propertyIdToTokenAddress;// propertyId to property token address
    mapping (uint256 => uint256) public lockedTokens;// propertyId to numberOfTokens that has been locked in the smart contract of that propertyId
    mapping (uint256 => uint256) public totalInvestedAmount;// invested amount in a property
    mapping (uint256 => uint256) public claimedInvestment;// claimed loan amount by owner of property
    mapping (uint256 => mapping (address => Investment)) public investments;// Mapping for storing investment information with tokenID and invetsor address
    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets parameters
    /// @param _promissoryOwner address of owner of the platform
    /// @param _USDT address of USDT token
    constructor(
        address _promissoryOwner,
        address _USDT
    )
    {
        //confirming that no one can bypass using null
        require(_promissoryOwner != address(0), "Zero(0x0) Promissory Owner address");
        require(_USDT != address(0), "Zero(0x0) USDT address");

        //assigning params of constructor to declared addresses
        promissoryOwner = _promissoryOwner;
        USDT = _USDT;
    }

    /// @dev creating a modifier which will be used later for checks 
    modifier checkPromissoryOwner(){    
        if(msg.sender != promissoryOwner) revert("Caller is not the owner of the platform");
        _;
    }

    /// @notice creates a new property
    function addProperty(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenSupply,
        uint256 _interestRate,
        uint256 _lockingPeriod
    ) external

    {   
        Property memory userProperty;
        userProperty.propertyId = _propertyIdCount.current();
        _propertyIdCount.increment();
        userProperty.owner = msg.sender;
        userProperty.tokenName = _tokenName;
        userProperty.tokenSymbol = _tokenSymbol;
        userProperty.tokenSupply = _tokenSupply;
        userProperty.interestRate = _interestRate * 100;//handling two decimal points
        userProperty.lockingPeriod = _lockingPeriod;

        userProperty.status = PropertyStatus.ADDED;
        propertyIdToProperty[userProperty.propertyId] = userProperty;

        property.push(Property(
            userProperty.propertyId,
            userProperty.owner,
            userProperty.tokenName,
            userProperty.tokenSymbol,
            userProperty.tokenSupply,
            userProperty.interestRate,
            userProperty.lockingPeriod,
            userProperty.status
        ));

        emit PropertyAdded(
            userProperty.propertyId,
            msg.sender,
            userProperty.tokenName,
            userProperty.tokenSymbol,
            userProperty.tokenSupply,
            userProperty.interestRate,
            userProperty.lockingPeriod
        );

    }

    /// @notice owner of the platform can ban a property
    function banProperty(uint256 _propertyId) external checkPromissoryOwner() {

        require(propertyIdToProperty[_propertyId].status == PropertyStatus.ADDED, "Property do not exist!!");

        propertyIdToProperty[_propertyId].status = PropertyStatus.BANNED;

        emit PropertyBanned(_propertyId, propertyIdToProperty[_propertyId].owner);
    }

    /// @notice owner of the platform will approve a property and it'll be tokenized and the tokens will be locked in the smart contract
    function approveProperty(uint256 _propertyId, uint256 _numberOfTokensToLock) external checkPromissoryOwner() {

        require(propertyIdToProperty[_propertyId].status == PropertyStatus.ADDED, "Property do not exist!");
        require(lockedTokens[_propertyId] + _numberOfTokensToLock <= propertyIdToProperty[_propertyId].tokenSupply, "Token release exceeds token supply");

        ERC20Token t = new ERC20Token(
            propertyIdToProperty[_propertyId].tokenName,
            propertyIdToProperty[_propertyId].tokenSymbol,
            propertyIdToProperty[_propertyId].tokenSupply
        );

        propertyIdToTokenAddress[_propertyId] = address(t);

        propertyIdToProperty[_propertyId].status = PropertyStatus.APPROVED;

        ERC20Token(propertyIdToTokenAddress[_propertyId]).transfer(address(this), _numberOfTokensToLock);
        lockedTokens[_propertyId] += _numberOfTokensToLock;

        emit PropertyApprovedAndTokenized(
            _propertyId,
            propertyIdToProperty[_propertyId].owner,
            propertyIdToProperty[_propertyId].tokenName,
            propertyIdToProperty[_propertyId].tokenSymbol,
            propertyIdToProperty[_propertyId].tokenSupply,
            propertyIdToTokenAddress[_propertyId],
            _numberOfTokensToLock
        );
    }

    /// @notice owner of the platform can update the interest rate of a property
    function updateInterestRate(uint _propertyId, uint256 _interestRate) external checkPromissoryOwner(){
        
        require(propertyIdToProperty[_propertyId].status == PropertyStatus.APPROVED, "Property isn't approved yet!");

        propertyIdToProperty[_propertyId].interestRate = _interestRate;

        emit InterestRateUpdated(_propertyId, _interestRate);
    }

    /// @notice investors can invest in property now
    function investInProperty(uint256 _propertyId, uint256 _investmentAmount) external {

        require(propertyIdToProperty[_propertyId].status == PropertyStatus.APPROVED, "Property isn't approved yet!, Wait for platform to approve this property.");
        require(_investmentAmount <= lockedTokens[_propertyId], "Invested Amount exceeds the number of Property Tokens available");
        
        IERC20(USDT).transferFrom(msg.sender, address(this), _investmentAmount);
        totalInvestedAmount[_propertyId] += _investmentAmount;

        ERC20Token(propertyIdToTokenAddress[_propertyId]).transfer(msg.sender, _investmentAmount);
        lockedTokens[_propertyId] -= _investmentAmount;

        investments[_propertyId][msg.sender] = Investment({
            investor: msg.sender,
            investmentAmount: _investmentAmount,
            timeStamp: block.timestamp.div(86400)
        });

        emit Invested(_propertyId, msg.sender, _investmentAmount, propertyIdToProperty[_propertyId].tokenSupply, propertyIdToProperty[_propertyId].interestRate);
    }

    /// @notice Property owners can claim the investment that has been invested in thier property up until now
    function claimInvestment(uint256 _propertyId, uint256 _numberOfTokensToClaim) external {

        require(msg.sender != propertyIdToProperty[_propertyId].owner, "You are not the onwer of this property!");
        require(_numberOfTokensToClaim <= totalInvestedAmount[_propertyId], "Amount exceeds than available!");

        IERC20(USDT).transferFrom(address(this), propertyIdToProperty[_propertyId].owner, _numberOfTokensToClaim);

        claimedInvestment[_propertyId] += _numberOfTokensToClaim;

        emit ClaimedInvestment(msg.sender, _propertyId, _numberOfTokensToClaim);
    }

    /// @notice Property owner have to return loan with interest to the smart contract
    function returnInvestment(uint256 _propertyId, address _investor) external {

        require(msg.sender != propertyIdToProperty[_propertyId].owner, "You are not the owner of this property!");
        require((investments[_propertyId][_investor]).timeStamp - (block.timestamp).div(86400) >= propertyIdToProperty[_propertyId].lockingPeriod, "Locking period isn't completed yet!");

        uint256 returnAmount = ((investments[_propertyId][_investor]).investmentAmount)*(1 + propertyIdToProperty[_propertyId].interestRate);

        IERC20(USDT).transferFrom(msg.sender, address(this), returnAmount);

        //ask about how to update investment detail now

        emit ReturnedInvestment(msg.sender, _investor, returnAmount, (investments[_propertyId][_investor]).investmentAmount);
    }

    /// @notice Investors can claim the returned investment amount and return the proeprty token to property owner
    function claimReturn(uint256 _propertyId, uint256 _returnAmount) external {

        require(msg.sender != (investments[_propertyId][msg.sender]).investor, "You have not invested in this property!");

        IERC20(USDT).transferFrom(address(this), msg.sender, _returnAmount);
        totalInvestedAmount[_propertyId] -= (investments[_propertyId][msg.sender]).investmentAmount;

        ERC20Token(propertyIdToTokenAddress[_propertyId]).transfer(address(this), (investments[_propertyId][msg.sender]).investmentAmount);
        lockedTokens[_propertyId] += (investments[_propertyId][msg.sender]).investmentAmount;

        emit ClaimedReturn(msg.sender, _propertyId, _returnAmount);
    }

    /// @notice Property Onwers can claim the property tokens locked in the smart contract
    function claimPropertyTokens(uint256 _propertyId, uint256 _claimTokens) external {
        require(msg.sender != propertyIdToProperty[_propertyId].owner, "You are not the owner of this property!");
        require(_claimTokens <= lockedTokens[_propertyId], "You are claiming more tokens than locked!");

        ERC20Token(propertyIdToTokenAddress[_propertyId]).transfer(msg.sender, _claimTokens);
        lockedTokens[_propertyId] -= _claimTokens;

        emit ClaimedPropertyTokens(msg.sender, _propertyId, _claimTokens);
    }
}