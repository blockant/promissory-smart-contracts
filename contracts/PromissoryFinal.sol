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

    event PropertyAdded(uint256 PropertyId, address PropertyOwner, uint256 PropertyTokenSupply, string PropertyTokenName, string PropertyTokenSymbol,  uint256 PropertyInterestRate, uint256 PropertyLockingPeriod);
    event PropertyBanned(address promissoryOwner, uint256 propertyId, address owner);
    event PropertyApprovedAndTokenized(uint256 propertyId, address promissoryOwner, address propertyOwner, uint256 tokenSupply, address propertyTokenAddress);
    // event PropertyTokensReleased(uint256 propertyId, address owner, uint256 tokenSupply);
    // event TokensClaimed(address investor, uint256 propertyId, uint256 tokensToClaim);
    // event Invested(uint256 propertyId, address investor, uint256 investmentAmount, uint256 tokenSupply, uint256 interestRate);
    // event InvestmentReleased(address investor, uint256 propertyId, uint256 investmentAmount);
    // event InvestmentClaimed(address owner, uint256 propertyId, uint256 investmentToClaim);
    // event InterestRateUpdated(uint256 propertyId, uint256 interestRate);

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
        uint256 tokenSupply;
        string tokenName;
        string tokenSymbol; 
        uint256 interestRate; //handle 2 decimal points (1000)
        uint256 lockingPeriod;//locking period
        bool isBanned;
        // address propertyTokenAddress;
        PropertyStatus status;
    }

    /// @dev Property name array
    Property[] public properties;

    //Counters for assigning and updating propertyId
    using Counters for Counters.Counter;
    Counters.Counter private _propertyId;

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
    function addProperty(Property memory propertyDetails) external

    {
        require(propertyDetails.owner != address(0), "Owner address can't be empty or zero(0x0) address");

        uint256 propertyId = _propertyId.current();
        _propertyId.increment();
        // Create Property and add property details
        //uint256 propertyId = properties.length;
        properties.push();
        properties[propertyId].owner = propertyDetails.owner;
        properties[propertyId].tokenSupply = propertyDetails.tokenSupply;
        properties[propertyId].tokenName = propertyDetails.tokenName;
        properties[propertyId].tokenSymbol = propertyDetails.tokenSymbol;
        properties[propertyId].interestRate = propertyDetails.interestRate;
        properties[propertyId].lockingPeriod = propertyDetails.lockingPeriod;

        properties[propertyId].status = PropertyStatus.ADDED;

        emit PropertyAdded(
            propertyId,
            propertyDetails.owner,
            propertyDetails.tokenSupply,
            propertyDetails.tokenName,
            propertyDetails.tokenSymbol,
            propertyDetails.interestRate,
            propertyDetails.lockingPeriod
        );

    }

    /// @notice owner of the platform can ban a property
    function banProperty(uint256 propertyId) external checkPromissoryOwner() {
        // ban Property
        properties[propertyId].isBanned = true;
        properties[propertyId].status = PropertyStatus.BANNED;

        emit PropertyBanned(msg.sender, propertyId, properties[propertyId].owner);
    }

    /// @notice getter function for the status of a property
    function getPropertyStatus(uint256 propertyId) public view returns (PropertyStatus) {
        return properties[propertyId].status;
    }

    /// @notice owner of the platform will approve a property and it'll be tokenized
    function approveProperty(uint256 propertyId) external checkPromissoryOwner() {

        require(!properties[propertyId].isBanned, "Property already banned");

        ERC20Token t = new ERC20Token(
            properties[propertyId].tokenName,
            properties[propertyId].tokenSymbol,
            properties[propertyId].tokenSupply
        );

        // properties[propertyId].propertyTokenAddress = address(t);

        emit PropertyApprovedAndTokenized(propertyId, msg.sender, properties[propertyId].owner, properties[propertyId].tokenSupply, address(t));
    }
}