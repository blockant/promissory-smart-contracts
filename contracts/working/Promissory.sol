// SPDX-License-Identifier: MIT
import "./ERC20Token.sol";
pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: Promissory/Promissory.sol


pragma solidity ^0.8.0;



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
    event PropertyApprovedAndTokenized(uint256 indexed PropertyId, address indexed PropertyOwner, string TokenName, string TokenSymbol, uint256 TokenSupply, address indexed PropertyTokenAddress,PropertyStatus Status, uint256 NumberOfLockedTokens);
    event InterestRateUpdated(uint256 indexed PropertyId, uint256 indexed InterestRate);
    event Invested(uint256 PropertyId, address Investor, uint256 InvestmentAmount, uint256 TokenSupply, uint256 InterestRate);
    event InvestmentClaimed(address indexed PropertyOwner, uint256 indexed PropertyId, uint256 indexed ClaimedAmount);
    event InvestmentReturned(address indexed PropertyOwner,address indexed Investor, uint256 indexed ReturnedAmount, uint256 InvestedAmount);
    event ReturnClaimed(address indexed Investor,uint256 indexed PropertyId,uint256 indexed ReturnedAmount);
    event PropertyTokensClaimed(address indexed PropertyOwner, uint256 indexed PropertyId, uint256 indexed ClaimedTokens);
    event TokenSupplyUpdated(address indexed Owner, uint256 indexed PropertyId, uint256 TokenSupply);
    event LockingPeriodUpdated(uint256 indexed PropertyId, uint256 indexed LockingPeriod);
    
    
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

    // / @notice Sets parameters
    // / @param _promissoryOwner address of owner of the platform
    // / @param _USDT address of USDT token
    constructor(
        // address _promissoryOwner,
        // address _USDT
    )
    {
        //confirming that no one can bypass using null
        //require(_promissoryOwner != address(0), "Zero(0x0) Promissory Owner address");
        //require(_USDT != address(0), "Zero(0x0) USDT address");

        //assigning params of constructor to declared addresses
        promissoryOwner = 0x78315cF7082dBb0174da3286D436BfE7577dF836;
        USDT = 0x2aC68A7Fa635972335d1d0880aa8861c5a46Bf88;
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
        userProperty.interestRate = _interestRate ; //enter input upto decimal places. 525 means 5.25
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

        // Property memory userProperty;
        // userProperty.status = PropertyStatus.BANNED;
        propertyIdToProperty[_propertyId].status = PropertyStatus.BANNED;

        emit PropertyBanned(_propertyId, propertyIdToProperty[_propertyId].owner);
    }

    /// @notice owner of the platform will approve a property and it'll be tokenized and the tokens will be locked in the smart contract
    function approveProperty(uint256 _propertyId) external checkPromissoryOwner() {

        require(propertyIdToProperty[_propertyId].status == PropertyStatus.ADDED, "Property do not exist!");
        //require(lockedTokens[_propertyId] + _numberOfTokensToLock <= propertyIdToProperty[_propertyId].tokenSupply, "Token release exceeds token supply");

        /// @notice deploy new ERC20 Token with these params
        ERC20Token t = new ERC20Token(
            propertyIdToProperty[_propertyId].tokenName,
            propertyIdToProperty[_propertyId].tokenSymbol,
            propertyIdToProperty[_propertyId].tokenSupply
        );

        propertyIdToTokenAddress[_propertyId] = address(t);

        // ERC20Token(propertyIdToTokenAddress[_propertyId]).approve(address(this), _numberOfTokensToLock);

        // ERC20Token(propertyIdToTokenAddress[_propertyId]).transfer(address(this), _numberOfTokensToLock);
        // lockedTokens[_propertyId] += _numberOfTokensToLock;

        ERC20Token(propertyIdToTokenAddress[_propertyId]).approve(address(this), propertyIdToProperty[_propertyId].tokenSupply);

        ERC20Token(propertyIdToTokenAddress[_propertyId]).transfer(address(this), propertyIdToProperty[_propertyId].tokenSupply);
        lockedTokens[_propertyId] += propertyIdToProperty[_propertyId].tokenSupply;
    
        propertyIdToProperty[_propertyId].status = PropertyStatus.APPROVED;

        Property storage propertyStatus = property[_propertyId];
        propertyStatus.status = PropertyStatus.APPROVED;


        // uint256 totalSupply = IERC20(USDT).totalSupply();
        // IERC20(USDT).approve(address(this), totalSupply);

        emit PropertyApprovedAndTokenized(
            _propertyId,
            propertyIdToProperty[_propertyId].owner,
            propertyIdToProperty[_propertyId].tokenName,
            propertyIdToProperty[_propertyId].tokenSymbol,
            propertyIdToProperty[_propertyId].tokenSupply,
            propertyIdToTokenAddress[_propertyId],
            propertyIdToProperty[_propertyId].status,
            // _numberOfTokensToLock
            propertyIdToProperty[_propertyId].tokenSupply
        );
    }

    /// @notice owner of the platform can update the interest rate of a property
    function updateInterestRate(uint _propertyId, uint256 _interestRate) external {
        
        require(propertyIdToProperty[_propertyId].status == PropertyStatus.ADDED, "Property has already been APPROVED or BANNED!");
        require(propertyIdToProperty[_propertyId].owner == msg.sender, "You are not the owner of this Property!");
        
        propertyIdToProperty[_propertyId].interestRate = _interestRate;

        Property storage propertyInterestRate = property[_propertyId];
        propertyInterestRate.interestRate = _interestRate;


        emit InterestRateUpdated(_propertyId, _interestRate);
    }

    /// @notice owner of the property can update the token supply of a property
    function updateTokenSupply(uint _propertyId, uint256 _tokenSupply) external {
        
        require(propertyIdToProperty[_propertyId].status == PropertyStatus.ADDED, "Property has already been APPROVED or BANNED!");
        require(propertyIdToProperty[_propertyId].owner == msg.sender, "You are not the owner of this Property!");
        
        propertyIdToProperty[_propertyId].tokenSupply = _tokenSupply;

        Property storage propertyTokenSupply = property[_propertyId];
        propertyTokenSupply.tokenSupply = _tokenSupply;

        emit TokenSupplyUpdated(msg.sender, _propertyId, _tokenSupply);
    }


    /// @notice owner of a property can update the locking period of it's respective property
    function updateLockingPeriod(uint _propertyId, uint256 _updateLockingPeriod) external {
        
        require(propertyIdToProperty[_propertyId].status == PropertyStatus.ADDED, "Property isn't approved yet!");
        require(propertyIdToProperty[_propertyId].owner == msg.sender, "You are not the owner of this Property!");

        propertyIdToProperty[_propertyId].lockingPeriod = _updateLockingPeriod;

        Property storage propertyLockingPeriod = property[_propertyId];
        propertyLockingPeriod.lockingPeriod = _updateLockingPeriod;

        emit LockingPeriodUpdated(_propertyId, _updateLockingPeriod);
    }

    /// @notice investors can invest in property now
    function investInProperty(uint256 _propertyId, uint256 _investmentAmount) external {

        require(propertyIdToProperty[_propertyId].status == PropertyStatus.APPROVED, "Property isn't approved yet!, Wait for platform to approve this property.");
        require(_investmentAmount <= lockedTokens[_propertyId], "Invested Amount exceeds the number of Property Tokens available");
        
        IERC20(USDT).approve(address(this), _investmentAmount);
        IERC20(USDT).transferFrom(msg.sender, address(this), _investmentAmount);
        totalInvestedAmount[_propertyId] += _investmentAmount;

        ERC20Token(propertyIdToTokenAddress[_propertyId]).approve(msg.sender, _investmentAmount);
        ERC20Token(propertyIdToTokenAddress[_propertyId]).transferFrom(address(this), msg.sender, _investmentAmount);
        lockedTokens[_propertyId] -= _investmentAmount;

        investments[_propertyId][msg.sender] = Investment({
            investor: msg.sender,
            investmentAmount: _investmentAmount,
            // timeStamp: block.timestamp.div(86400)
            timeStamp: block.timestamp
        });

        emit Invested(_propertyId, msg.sender, _investmentAmount, propertyIdToProperty[_propertyId].tokenSupply, propertyIdToProperty[_propertyId].interestRate);
    }

    /// @notice Property owners can claim the investment that has been invested in thier property up until now
    function claimInvestment(uint256 _propertyId, uint256 _numberOfTokensToClaim) external {

        require(msg.sender == propertyIdToProperty[_propertyId].owner, "You are not the onwer of this property!");
        require(_numberOfTokensToClaim <= totalInvestedAmount[_propertyId], "Amount exceeds than available!");

        IERC20(USDT).approve(propertyIdToProperty[_propertyId].owner, _numberOfTokensToClaim);
        IERC20(USDT).transferFrom(address(this), propertyIdToProperty[_propertyId].owner, _numberOfTokensToClaim);

        claimedInvestment[_propertyId] += _numberOfTokensToClaim;

        emit InvestmentClaimed(msg.sender, _propertyId, _numberOfTokensToClaim);
    }

    /// @notice Property owner have to return loan with interest to the smart contract
    function returnInvestment(uint256 _propertyId, address _investor) external {

        require(msg.sender == propertyIdToProperty[_propertyId].owner, "You are not the owner of this property!");

        uint256 _blockTimeStamp = block.timestamp;
        require((investments[_propertyId][_investor]).timeStamp + propertyIdToProperty[_propertyId].lockingPeriod < _blockTimeStamp, "Locking period isn't completed yet!");

        uint256 _investedAmount = (investments[_propertyId][_investor]).investmentAmount; //500 * 10 ** 18
        uint256 _interestRate = propertyIdToProperty[_propertyId].interestRate; //525
        uint256 _interestAmount = (_investedAmount*_interestRate).div(10000); //(525*500*(10**18) )/10000
    
        uint256 returnAmount = ((investments[_propertyId][_investor]).investmentAmount) + _interestAmount; //*(1 + propertyIdToProperty[_propertyId].interestRate);

        IERC20(USDT).approve(address(this), returnAmount);
        IERC20(USDT).transferFrom(msg.sender, address(this), returnAmount);

        emit InvestmentReturned(msg.sender, _investor, returnAmount, (investments[_propertyId][_investor]).investmentAmount);
    }

    /// @notice Investors can claim the returned investment amount and return the proeprty token to property owner
    function claimReturn(uint256 _propertyId, uint256 _returnAmount) external {

        require(msg.sender == (investments[_propertyId][msg.sender]).investor, "You have not invested in this property!");

        IERC20(USDT).approve(msg.sender, _returnAmount);
        IERC20(USDT).transferFrom(address(this), msg.sender, _returnAmount);
        totalInvestedAmount[_propertyId] -= (investments[_propertyId][msg.sender]).investmentAmount;

        ERC20Token(propertyIdToTokenAddress[_propertyId]).approve(address(this), (investments[_propertyId][msg.sender]).investmentAmount);
        ERC20Token(propertyIdToTokenAddress[_propertyId]).transferFrom(msg.sender, address(this), (investments[_propertyId][msg.sender]).investmentAmount);
        lockedTokens[_propertyId] += (investments[_propertyId][msg.sender]).investmentAmount;

        emit ReturnClaimed(msg.sender, _propertyId, _returnAmount);
    }

    /// @notice Property Onwers can claim the property tokens locked in the smart contract
    function claimPropertyTokens(uint256 _propertyId, uint256 _claimTokens) external {
        require(msg.sender == propertyIdToProperty[_propertyId].owner, "You are not the owner of this property!");
        require(_claimTokens <= lockedTokens[_propertyId], "You are claiming more tokens than locked!");

        ERC20Token(propertyIdToTokenAddress[_propertyId]).approve(msg.sender, _claimTokens);
        ERC20Token(propertyIdToTokenAddress[_propertyId]).transferFrom(address(this), msg.sender, _claimTokens);
        lockedTokens[_propertyId] -= _claimTokens;

        emit PropertyTokensClaimed(msg.sender, _propertyId, _claimTokens);
    }

    function getProperties() public view returns (Property[] memory) {
        return property;
    }

    // function getinvestments() public view returns (Investment[] memory) {
    //     return investmentList;
    // }

}