// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "./IERC20.sol";
import "./ERC20Token.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

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
    event PropertyApprovedAndTokenized(uint256 indexed PropertyId, address indexed PropertyOwner, string TokenName, string TokenSymbol, uint256 TokenSupply, address indexed PropertyTokenAddress);
    // event PropertyTokensReleased(uint256 propertyId, address owner, uint256 tokenSupply);
    // event TokensClaimed(address investor, uint256 propertyId, uint256 tokensToClaim);
    // event Invested(uint256 propertyId, address investor, uint256 investmentAmount, uint256 tokenSupply, uint256 interestRate);
    // event InvestmentReleased(address investor, uint256 propertyId, uint256 investmentAmount);
    // event InvestmentClaimed(address owner, uint256 propertyId, uint256 investmentToClaim);
    event InterestRateUpdated(uint256 propertyId, uint256 interestRate);

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
        string tokenName;
        string tokenSymbol;
        uint256 tokenSupply; 
        uint256 interestRate; //handle 2 decimal points (1000)
        uint256 lockingPeriod;//locking period
        PropertyStatus status;
    }

    //An array of 'Property' struct
    Property[] public property;

    /// @dev Counters for assigning and updating propertyId
    using Counters for Counters.Counter;
    Counters.Counter private _propertyId;

    /*//////////////////////////////////////////////////////////////
                                MAPPING
    //////////////////////////////////////////////////////////////*/
    
    mapping (uint256 => address) public propertyIdToOwner;//propertyId to owner mapping
    mapping (uint256 => Property) public propertyIdToProperty;//propertyId to struct Property mapping
    mapping (uint256 => address) public propertyIdToTokenAddress;//propertyId to property token address

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
        userProperty.propertyId = _propertyId.current();
        _propertyId.increment();
        propertyIdToOwner[userProperty.propertyId] = msg.sender;
        userProperty.tokenName = _tokenName;
        userProperty.tokenSymbol = _tokenSymbol;
        userProperty.tokenSupply = _tokenSupply;
        userProperty.interestRate = _interestRate;
        userProperty.lockingPeriod = _lockingPeriod;

        userProperty.status = PropertyStatus.ADDED;
        propertyIdToProperty[userProperty.propertyId] = userProperty;

        property.push(Property(
            userProperty.propertyId,
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

    // getter function to get properties by index
    //solidity automatically creates a getter for 'property' so
    //we don't actually need this function
    // function getProperties(uint _index) public view returns (
    //     uint256 propertyId,
    //     string calldata tokenName,
    //     string calldata tokenSymbol,
    //     uint256 tokenSupply,
    //     uint256 interestRate,
    //     uint256 lockingPeriod,
    //     uint status) {
    //     Property storage propertiesDetails = property[_index];
    //     return (
    //     propertiesDetails.propertyId,
    //     propertiesDetails.tokenName,
    //     propertiesDetails.tokenSymbol,
    //     propertiesDetails.tokenSupply,
    //     propertiesDetails.interestRate,
    //     propertiesDetails.lockingPeriod,
    //     propertiesDetails.status
    //     );
    // }

    /// @notice owner of the platform can ban a property
    function banProperty(uint256 propertyId) external checkPromissoryOwner() {

        propertyIdToProperty[propertyId].status = PropertyStatus.BANNED;

        emit PropertyBanned(propertyId, propertyIdToOwner[propertyId]);
    }

    /// @notice owner of the platform will approve a property and it'll be tokenized
    function approveProperty(uint256 propertyId) external checkPromissoryOwner() {

        require(propertyIdToProperty[propertyId].status == PropertyStatus.BANNED, "Property already banned");

        ERC20Token t = new ERC20Token(
            propertyIdToProperty[propertyId].tokenName,
            propertyIdToProperty[propertyId].tokenSymbol,
            propertyIdToProperty[propertyId].tokenSupply
        );

        propertyIdToTokenAddress[propertyId] = address(t);

        propertyIdToProperty[propertyId].status = PropertyStatus.APPROVED;

        emit PropertyApprovedAndTokenized(propertyId, propertyIdToOwner[propertyId], propertyIdToProperty[propertyId].tokenName, propertyIdToProperty[propertyId].tokenSymbol, propertyIdToProperty[propertyId].tokenSupply, address(t));
    }

    /// @notice owner of the platform can update the interest rate of a property
    function updateInterestRate(uint propertyId, uint256 _interestRate) external checkPromissoryOwner(){
        
        require(propertyIdToProperty[propertyId].status == PropertyStatus.APPROVED, "Property isn't approved yet!");

        propertyIdToProperty[propertyId].interestRate = _interestRate;

        emit InterestRateUpdated(propertyId, _interestRate);
    }
}