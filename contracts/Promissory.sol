// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC20Token.sol";

contract Promissory {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    address public USDT;
    address public promissoryOwner;

    event PropertyAdded(uint256 indexed PropertyId, address indexed PropertyOwner, string indexed PropertyTokenName, string PropertyTokenSymbol, uint256 PropertyTokenSupply, uint256 PropertyInterestRate, uint256 PropertyLockingPeriod);
    event PropertyApprovedAndTokenized(uint256 indexed PropertyId, address indexed PropertyOwner, string TokenName, string TokenSymbol, uint256 TokenSupply, address indexed PropertyTokenAddress,PropertyStatus Status, uint256 NumberOfLockedTokens);
    event PropertyBanned(uint256 indexed PropertyId, address indexed PropertyOwner);
    event Invested(uint256 indexed PropertyId, address indexed Investor, uint256 indexed InvestmentAmount, uint256 TokenSupply, uint256 InterestRate);
    event InvestmentClaimed(address indexed PropertyOwner, uint256 indexed PropertyId, uint256 indexed ClaimedAmount);
    event InvestmentReturned(address indexed PropertyOwner, uint256 indexed ReturnedAmount, uint256 InvestedAmount);
    event ReturnClaimed(address indexed Investor,uint256 indexed PropertyId,uint256 indexed ReturnedAmount);
    event PropertyTokensClaimed(address indexed PropertyOwner, uint256 indexed PropertyId, uint256 indexed ClaimedTokens);
    event InterestRateUpdated(uint256 indexed PropertyId, uint256 indexed InterestRate);
    event TokenSupplyUpdated(address indexed Owner, uint256 indexed PropertyId, uint256 TokenSupply);
    event LockingPeriodUpdated(uint256 indexed PropertyId, uint256 indexed LockingPeriod);

    enum PropertyStatus {
        PENDING,
        ADDED,
        APPROVED,
        BANNED
    }

    struct Property{
        uint256 propertyId;
        address owner;
        string tokenName;
        string tokenSymbol;
        uint256 tokenSupply;
        uint256 interestRate;
        uint256 lockingPeriod;
        PropertyStatus status;
    }

    struct Investment {
        uint256 investmentId;
        address investor;
        uint256 investmentAmount;
        uint256 timeStamp;
    }
    
    Counters.Counter public _propertyIdCount;
    Counters.Counter public _investmentIdCount;

    mapping (uint256 => address) public propertyIdToTokenAddress;
    mapping (uint256 => uint256) public lockedTokens;
    mapping (uint256 => Property) public properties;
    mapping (uint256 => uint256) public totalInvestedAmount;
    mapping (uint256 => mapping (uint256 => Investment)) public investments;
    mapping (uint256 => uint256) public claimedInvestment;
    mapping (uint256 => uint256) public returnedInvestment;

    constructor(
        address _promissoryOwner,
        address _USDT
    )
    {
        require(_promissoryOwner != address(0), "Zero(0x0) Promissory Owner address");
        require(_USDT != address(0), "Zero(0x0) USDT address");

        promissoryOwner=_promissoryOwner;
        USDT=_USDT;
    }

    function addProperty(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenSupply,
        uint256 _interestRate,
        uint256 _lockingPeriod
    ) public {
        uint256 propertyId = _propertyIdCount.current();
        _propertyIdCount.increment();
        properties[propertyId] = Property(
            propertyId,
            msg.sender,
            _tokenName,
            _tokenSymbol,
            _tokenSupply,
            _interestRate,
            _lockingPeriod,
            PropertyStatus.ADDED
        );

        emit PropertyAdded(
            propertyId,
            msg.sender,
            _tokenName,
            _tokenSymbol,
            _tokenSupply,
            _interestRate,
            _lockingPeriod
        );
    }

    function getProperties() public view returns (Property[] memory) {
        Property[] memory result = new Property[](_propertyIdCount.current());
        uint256 i = 0;
        for (uint256 propertyId = 0; propertyId <= _propertyIdCount.current(); propertyId++) {
            if (properties[propertyId].propertyId > 0) {
                result[i] = properties[propertyId];
                i = i.add(1);
            }
        }
        return result;
    }

    modifier checkPromissoryOwner(){    
        if(msg.sender != promissoryOwner) revert("Caller is not the owner of the platform");
        _;
    }

    function approveProperty(uint256 _propertyId) external checkPromissoryOwner() {
        require(properties[_propertyId].status == PropertyStatus.ADDED, "Property do not exist!");
        ERC20Token t = new ERC20Token(
            properties[_propertyId].tokenName,
            properties[_propertyId].tokenSymbol,
            properties[_propertyId].tokenSupply
        );

        propertyIdToTokenAddress[_propertyId] = address(t);

        ERC20Token(propertyIdToTokenAddress[_propertyId]).transfer(address(this), properties[_propertyId].tokenSupply);
        lockedTokens[_propertyId] += properties[_propertyId].tokenSupply;
    
        properties[_propertyId].status = PropertyStatus.APPROVED;

        emit PropertyApprovedAndTokenized(
            _propertyId,
            properties[_propertyId].owner,
            properties[_propertyId].tokenName,
            properties[_propertyId].tokenSymbol,
            properties[_propertyId].tokenSupply,
            propertyIdToTokenAddress[_propertyId],
            properties[_propertyId].status,
            properties[_propertyId].tokenSupply
        );
    }

    function banProperty(uint256 _propertyId) external checkPromissoryOwner() {

        require(properties[_propertyId].status == PropertyStatus.ADDED, "Property do not exist!!");
        properties[_propertyId].status = PropertyStatus.BANNED;

        emit PropertyBanned(_propertyId, properties[_propertyId].owner);
    }

    function investInProperty(uint256 _propertyId, uint256 _investmentAmount) public {
        require(properties[_propertyId].status == PropertyStatus.APPROVED, "Property is not approved for investment.");
        require(_investmentAmount > 0 && _investmentAmount <= lockedTokens[_propertyId], "Investment amount must be >0 and <= locked property tokens!");
        IERC20(USDT).approve(address(this), _investmentAmount);
        IERC20(USDT).transferFrom(msg.sender, address(this), _investmentAmount);
        totalInvestedAmount[_propertyId] += _investmentAmount;

        ERC20 propertyToken = ERC20(propertyIdToTokenAddress[_propertyId]);
        propertyToken.transferFrom(address(this), msg.sender, _investmentAmount);
        lockedTokens[_propertyId] -= _investmentAmount;

        uint256 _investmentId = _investmentIdCount.current();
        _investmentIdCount.increment();

        investments[_propertyId][_investmentId] = Investment({
            investmentId: _investmentId,
            investor: msg.sender,
            investmentAmount: _investmentAmount,
            timeStamp: block.timestamp
        });

        emit Invested(_propertyId, msg.sender, _investmentAmount, properties[_propertyId].tokenSupply, properties[_propertyId].interestRate);
    }

    function getAllInvestments() public view returns (Investment[] memory) {
        Investment[] memory investmentsArr = new Investment[](_investmentIdCount.current());
        uint256 counter = 0;
        for (uint256 propertyId = 0; propertyId <= _propertyIdCount.current() ; propertyId++) {
            for (uint256 investmentId = 0; investmentId < _investmentIdCount.current(); investmentId++) {
                investmentsArr[counter++] = investments[propertyId][investmentId];
            }
        }
        return investmentsArr;
    }

    function claimInvestment(uint256 _propertyId, uint256 _numberOfTokensToClaim) external {

        require(msg.sender == properties[_propertyId].owner, "You are not the onwer of this property!");
        uint256 remainingInvestment = totalInvestedAmount[_propertyId] - claimedInvestment[_propertyId];
        require(_numberOfTokensToClaim <= remainingInvestment, "Amount exceeds than available!");

        IERC20(USDT).transferFrom(address(this), properties[_propertyId].owner, _numberOfTokensToClaim);
        claimedInvestment[_propertyId] += _numberOfTokensToClaim;

        emit InvestmentClaimed(msg.sender, _propertyId, _numberOfTokensToClaim);
    }

    function returnInvestment(uint256 _propertyId, uint256 _investmentId) external {
        require(msg.sender == properties[_propertyId].owner, "You are not the owner of this property!");

        uint256 blockTimestamp = block.timestamp;
        uint256 lockingPeriod = properties[_propertyId].lockingPeriod;
        require(investments[_propertyId][_investmentId].timeStamp + lockingPeriod < blockTimestamp, "Locking period isn't completed yet!");

        Investment storage investment = investments[_propertyId][_investmentId];
        uint256 investedAmount = investment.investmentAmount;
        uint256 interestRate = properties[_propertyId].interestRate;
        uint256 interestAmount = (investedAmount * interestRate).div(10000);

        uint256 returnAmount = investedAmount + interestAmount;
        IERC20(USDT).transferFrom(msg.sender, address(this), returnAmount);

        returnedInvestment[_investmentId] = returnAmount;

        emit InvestmentReturned(msg.sender, returnAmount, investedAmount);
    }

    function claimReturn(uint256 _propertyId, uint256 _investmentId) external {
        require(msg.sender == (investments[_propertyId][_investmentId]).investor, "You have not invested in this property!");

        IERC20(USDT).transferFrom(address(this), msg.sender, returnedInvestment[_investmentId]);
        totalInvestedAmount[_propertyId] -= (investments[_propertyId][_investmentId]).investmentAmount;

        ERC20Token(propertyIdToTokenAddress[_propertyId]).transferFrom(msg.sender, address(this), (investments[_propertyId][_investmentId]).investmentAmount);
        lockedTokens[_propertyId] += (investments[_propertyId][_investmentId]).investmentAmount;

        emit ReturnClaimed(msg.sender, _propertyId, returnedInvestment[_investmentId]);
    }

    function claimPropertyTokens(uint256 _propertyId, uint256 _claimTokens) external {
        require(msg.sender == properties[_propertyId].owner, "You are not the owner of this property!");
        require(_claimTokens <= lockedTokens[_propertyId], "You are claiming more tokens than locked!");

        ERC20Token(propertyIdToTokenAddress[_propertyId]).transferFrom(address(this), msg.sender, _claimTokens);
        lockedTokens[_propertyId] -= _claimTokens;

        emit PropertyTokensClaimed(msg.sender, _propertyId, _claimTokens);
    }

    function updateInterestRate(uint _propertyId, uint256 _interestRate) external {
        require(properties[_propertyId].status == PropertyStatus.ADDED, "Property has already been APPROVED or BANNED!");
        require(properties[_propertyId].owner == msg.sender, "You are not the owner of this Property!");
        
        properties[_propertyId].interestRate = _interestRate;
        emit InterestRateUpdated(_propertyId, _interestRate);
    }

    function updateTokenSupply(uint _propertyId, uint256 _tokenSupply) external {
        require(properties[_propertyId].status == PropertyStatus.ADDED, "Property has already been APPROVED or BANNED!");
        require(properties[_propertyId].owner == msg.sender, "You are not the owner of this Property!");
        
        properties[_propertyId].tokenSupply = _tokenSupply;
        emit TokenSupplyUpdated(msg.sender, _propertyId, _tokenSupply);
    }

    function updateLockingPeriod(uint _propertyId, uint256 _updateLockingPeriod) external {
        require(properties[_propertyId].status == PropertyStatus.ADDED, "Property has already been APPROVED or BANNED!");
        require(properties[_propertyId].owner == msg.sender, "You are not the owner of this Property!");

        properties[_propertyId].lockingPeriod = _updateLockingPeriod;
        emit LockingPeriodUpdated(_propertyId, _updateLockingPeriod);
    }
}
