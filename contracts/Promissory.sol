// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "./IERC20.sol";
import "./ERC20Token.sol";

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

    /// @notice
    address public PROM; // remove & mint new token for every new property
    
    /// @notice The addressw which is owner of the platform
    address public promissoryOwner;

    /// @notice
    address public feesRegistry;


    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event PropertyAdded(uint256 propertyId, address owner, uint256 tokenSupply, string tokenName, string tokenSymbol,  uint256 interestRate);
    event PropertBanned(address promissoryOwner, uint256 propertyId, address owner);
    event PropertyApprovedAndTokenized(uint256 propertyId, address promissoryOwner, address propertyOwner, uint256 tokenSupply, address propertyTokenAddress);
    event PropertyTokensReleased(uint256 propertyId, address owner, uint256 tokenSupply);
    event TokensClaimed(address investor, uint256 propertyId, uint256 tokensToClaim);
    event Invested(uint256 propertyId, address investor, uint256 investmentAmount, uint256 tokenSupply, uint256 interestRate);
    event InvestmentReleased(address investor, uint256 propertyId, uint256 investmentAmount);
    event InvestmentClaimed(address owner, uint256 propertyId, uint256 investmentToClaim);
    event InterestRateUpdated(uint256 propertyId, uint256 interestRate);

    /*//////////////////////////////////////////////////////////////
                                MAPPING
    //////////////////////////////////////////////////////////////*/
    mapping (uint256 => bool) public approved;
    mapping (uint256 => uint256) public releasedTokens;
    mapping (uint256 => uint256) public claimedTokens;
    mapping (uint256 => uint256) public releasedInvestment;
    mapping (uint256 => uint256) public claimedInvestment;
    mapping (uint256 => address) public propertyTokens;

    /// @dev Property name array
    Property[] public properties;

    /// @dev Property struct contains variable that collectively defines a property
    struct Property{
        uint256 propertyId;
        address owner;
        uint256 tokenSupply;
        string tokenName;
        string tokenSymbol; 
        uint256 interestRate; //handle 2 decimal points (1000)
        //locking period
        bool isBanned;
    }

    /// @dev An enum for representing whether a property is
    /// listed or banned or a 
    enum PropertyState {
        ADDED,
        APPROVED,
        BANNED
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets parameters
    /// @param _promissoryOwner address of owner of the platform
    /// @param _USDT address of USDT token
    /// @param _PROM address of 
    /// @param _feesRegistry address of 
    constructor(address _promissoryOwner,address _USDT,address _PROM,address _feesRegistry){
        //confirming that no one can bypass using null
        require(_promissoryOwner != address(0), "Zero(0x0) Promissory Owner address");
        require(_USDT != address(0), "Zero(0x0) USDT address");
        require(_PROM != address(0), "Zero(0x0) Promissorty Token (PROM) address");
        require(_feesRegistry != address(0), "Zero(0x0) Fee Registry address");

        //settting params of constructor using declared addresses
        promissoryOwner = _promissoryOwner;
        USDT = _USDT;
        PROM = _PROM;
        feesRegistry = _feesRegistry;
    }

    /// @dev adds a modifier which will be used later for checks 
    modifier checkPromissoryOwner(){    
        if(msg.sender != promissoryOwner) revert("Caller is not the owner of the platform");
        _;
    }

    /// @notice creates a new property
    function addProperty(Property memory propertyDetails) external

    { //checkJobCreator(jobCreation.jobId)

        require(propertyDetails.owner != address(0), "Owner address can't be empty or zero(0x0) address");

        // Create Property and add property details
        uint256 propertyId = properties.length;
        properties.push();
        properties[propertyId].owner = propertyDetails.owner;
        properties[propertyId].tokenSupply = propertyDetails.tokenSupply;
        properties[propertyId].tokenName = propertyDetails.tokenName;
        properties[propertyId].tokenSymbol = propertyDetails.tokenSymbol;
        properties[propertyId].interestRate = propertyDetails.interestRate;
        properties[propertyId].isBanned = false;

        emit PropertyAdded(propertyId, propertyDetails.owner, propertyDetails.tokenSupply, propertyDetails.tokenName, propertyDetails.tokenSymbol, propertyDetails.interestRate);
    }

    function banProperty(uint256 propertyId) external checkPromissoryOwner() {
        // ban Property
        properties[propertyId].isBanned = true;

        emit PropertBanned(msg.sender, propertyId, properties[propertyId].owner);
    }


    function approveProperty(uint256 propertyId) external checkPromissoryOwner() {
        //change this function and mint new ERC20 for every new property

        require(!properties[propertyId].isBanned, "Property already banned");

        // Pay SPay
        ERC20Token t = new ERC20Token(
            properties[propertyId].tokenName,
            properties[propertyId].tokenSymbol,
            properties[propertyId].tokenSupply
        );
        //ERC20Token().mintPropertyTokens(properties[propertyId].owner, properties[propertyId].tokenSupply);

        emit PropertyApprovedAndTokenized(propertyId, msg.sender, properties[propertyId].owner, properties[propertyId].tokenSupply, address(t));
    }

    function setInterestRate(uint propertyId, uint256 interestRate) external checkPromissoryOwner(){
        
        //require(!interestRate, "Interest rate already set");

        properties[propertyId].interestRate = interestRate;

        emit InterestRateUpdated(propertyId, interestRate);
    }

    function releasePropertyTokens(uint256 propertyId, uint256 tokenSupply) external checkPromissoryOwner() { 

// Handle transfer of specific property ERC20 transfer from property owner to contract
        require(releasedTokens[propertyId] + tokenSupply <= properties[propertyId].tokenSupply, "Token release exceeds token supply");
        releasedTokens[propertyId] += tokenSupply;

        emit PropertyTokensReleased(propertyId, properties[propertyId].owner, tokenSupply);
    }

    function claimTokens(uint propertyId) external {
        require(claimedTokens[propertyId] < releasedTokens[propertyId] , "Nothing left to claim");

        uint256 tokensToClaim = releasedTokens[propertyId] - claimedTokens[propertyId];
        claimedTokens[propertyId] = releasedTokens[propertyId];

        // Get paid
        IERC20(PROM).transfer(msg.sender, tokensToClaim);

        emit TokensClaimed(msg.sender, propertyId, tokensToClaim);
    }

    function investInProperty(uint256 propertyId, uint256 investmentAmount) external {

        require(!properties[propertyId].isBanned, "Property already banned");

        
        IERC20(USDT).transferFrom(msg.sender, address(this), investmentAmount);

        emit Invested(propertyId, msg.sender, investmentAmount, properties[propertyId].tokenSupply, properties[propertyId].interestRate);
    }

    function releaseInvestment(uint256 propertyId, uint256 investmentAmount) external { 

        require(releasedInvestment[propertyId] + investmentAmount <= properties[propertyId].tokenSupply, "Investment exceeds limit");
        releasedInvestment[propertyId] += investmentAmount;

        emit InvestmentReleased(msg.sender, propertyId, investmentAmount);
    }

    function claimInvestment(uint propertyId) external {
        require(claimedInvestment[propertyId] < releasedInvestment[propertyId] , "Nothing left to claim out of investment");
        require(msg.sender != properties[propertyId].owner, "Incorrect Owner");

        uint256 investmentToClaim = releasedInvestment[propertyId] - claimedInvestment[propertyId];
        claimedInvestment[propertyId] = releasedInvestment[propertyId];

        // Get paid
        IERC20(USDT).transferFrom(address(this), properties[propertyId].owner, investmentToClaim);

        emit InvestmentClaimed(msg.sender, propertyId, investmentToClaim);
    }

}