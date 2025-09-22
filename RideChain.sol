// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//!-Safeguard against reentrancy attacks throughout the whole contract.
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract RideChain{
    using ECDSA for bytes32;
    IERC20 public immutable RIDE;
    address public immutable publicGoodFund;

    struct Ride {
        address rider;
        address driver;
        uint64 startTime;
        uint64 endTime;
        uint120 amount;
        uint8 status; // 0 = pending, 1 = completed, 2 = reversed
    }

    mapping(bytes32 => Ride) public rides;
    mapping(address => uint8) public failedReversals;
    mapping(bytes32 => bool) public commitments;

    event RideStarted(bytes32 indexed rideId, address rider, address driver, uint120 amount);
    event RideFinalized(bytes32 indexed rideId, address driver, uint120 payout);
    event RideReversed(bytes32 indexed rideId, address rider, uint120 refund, uint120 penalty);
    event EmergencyRelease(bytes32 indexed rideId, uint120 penalty);

    //!-Give _rideToken and _publicGoodFund addresses. We must be able to see the transfer of tokens between rider and driver accounts.
    constructor(address _rideToken, address _publicGoodFund) {
        RIDE = IERC20(_rideToken);
        publicGoodFund = _publicGoodFund;
    }

    function startRide(
        address _driver,
        uint120 _amount,
        bytes32 _commitment 
    ) external{
        require(_driver != address(0), "Invalid driver");
        require(commitments[_commitment], "Commitment not registered");
        uint64 _startTime = uint64(block.timestamp); // take current block time
        bytes32 rideId = keccak256(abi.encodePacked(msg.sender, _driver, _startTime));
        require(rides[rideId].rider == address(0), "Ride already exists");
        rides[rideId] = Ride(msg.sender, _driver, _startTime, 0, _amount, 0);//amount is pre-determined
        RIDE.transferFrom(msg.sender, address(this), _amount);
        emit RideStarted(rideId, msg.sender, _driver, _amount);
    }

    function finalizeRide(bytes32 rideId) external{
        Ride storage ride = rides[rideId];
        require(ride.status == 0, "Ride already finalized/reversed");
        require(msg.sender == ride.driver, "Only driver can finalize");
        ride.endTime = uint64(block.timestamp);
        ride.status = 1;
        RIDE.transfer(ride.driver, ride.amount);
        emit RideFinalized(rideId, ride.driver, ride.amount);
    }

    function reverseRide(bytes32 rideId) external{
        Ride storage ride = rides[rideId];
        require(ride.status == 0, "Ride already finalized/reversed");
        require(msg.sender == ride.rider, "Only rider can reverse");
        require(block.timestamp <= ride.startTime + 12 minutes, "Reversal time expired");
        uint120 penalty = ride.amount / 10; // 10% penalty
        uint120 refund = ride.amount - penalty;
        ride.status = 2;
        RIDE.transfer(ride.rider, refund);
        RIDE.transfer(publicGoodFund, penalty);
         
        //!-This 24 hour lockout feature is incomplete. Implement the feature properly. 
        failedReversals[msg.sender]++;
        if (failedReversals[msg.sender] >= 3) {
            revert("Too many failed reversals, 24-hour lockout");
        }
        emit RideReversed(rideId, ride.rider, refund, penalty);
    }

    function emergencyRelease(bytes32 rideId) external {
        Ride storage ride = rides[rideId];
        require(msg.sender==ride.rider,"Driver can't call this function");
        require(ride.status == 0, "Ride already finalized/reversed");
        uint120 penalty = ride.amount;
        ride.status = 2;
        RIDE.transfer(publicGoodFund, penalty);
        emit EmergencyRelease(rideId, penalty);
    }

    function registerCommitment(bytes32 commitment) external {
        commitments[commitment] = true;
    }
}

//!-Go through 1 entire workflow. (Use the GUI and then just comment the logs you got. Mention the functions called, and a general overview of your workflow.)
//!-(Try including all functions in your process.)
