pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract IfChainlinkClient is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    struct Staking {
        uint256 count;
        string track;
        uint256 updatedat;
    }

    struct Snapshot {
        uint256 dao;
        uint256 updatedat;
    }

    struct Swapping {
        uint256 count;
        uint256 updatedat;
    }

    struct SwapStaker {
        uint256 count;
        uint256 updatedat;
    }

    struct IfData {
        Staking staking;
        Snapshot snapshot;
        Swapping swapping;
        SwapStaker swapStaker;
        uint256 updatedat;
    }

    mapping(address => IfData) public users;
    mapping(address => Staking) public StakingData;
    mapping(address => Snapshot) public SnapshotData;
    mapping(address => Swapping) public SwappingData;
    mapping(address => SwapStaker) public SwapStakerData;
    address linkTokenAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    uint256 private constant ORACLE_PAYMENT = 1 * 10**1;

    event RequestStakingFulfilled(
        bytes32 indexed requestId,
        address[] user,
        uint256[] indexed count,
        string[] indexed track
    );
    event RequestSnapshotFulfilled(
        bytes32 indexed requestId,
        address[] user,
        uint256[] indexed dao
    );
    event RequestSwappingFulfilled(
        bytes32 indexed requestId,
        address[] user,
        uint256[] indexed count
    );
    event RequestSwapStakerFulfilled(
        bytes32 indexed requestId,
        address[] user,
        uint256[] indexed count
    );

    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(linkTokenAddress);
    }

    function requestStaking(address _oracle, string memory _jobId) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillStaking.selector
        );
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function requestSnapshot(address _oracle, string memory _jobId) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillSnapshot.selector
        );
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function requestSwapping(address _oracle, string memory _jobId) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillSwapping.selector
        );
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function requestSwapStaker(address _oracle, string memory _jobId) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillSwapStaker.selector
        );
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function fulfillStaking(
        bytes32 _requestId,
        address[] memory user,
        uint256[] memory count,
        string[] memory track
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestStakingFulfilled(_requestId, user, count, track);
        for (uint256 i; i < user.length; i++) {
            StakingData[user[i]] = Staking(count[i], track[i], block.timestamp);
            users[user[i]].staking = StakingData[user[i]];
            users[user[i]].updatedat = block.timestamp;
        }
    }

    function fulfillSnapshot(
        bytes32 _requestId,
        address[] memory user,
        uint256[] memory dao
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestSnapshotFulfilled(_requestId, user, dao);
        for (uint256 i; i < user.length; i++) {
            SnapshotData[user[i]] = Snapshot(dao[i], block.timestamp);
            users[user[i]].snapshot = SnapshotData[user[i]];
            users[user[i]].updatedat = block.timestamp;
        }
    }

    function fulfillSwapping(
        bytes32 _requestId,
        address[] memory user,
        uint256[] memory count
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestSwappingFulfilled(_requestId, user, count);
        for (uint256 i; i < user.length; i++) {
            SwappingData[user[i]] = Swapping(count[i], block.timestamp);
            users[user[i]].swapping = SwappingData[user[i]];
            users[user[i]].updatedat = block.timestamp;
        }
    }

    function fulfillSwapStaker(
        bytes32 _requestId,
        address[] memory user,
        uint256[] memory count
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestSwapStakerFulfilled(_requestId, user, count);
        for (uint256 i; i < user.length; i++) {
            SwapStakerData[user[i]] = SwapStaker(count[i], block.timestamp);
            users[user[i]].swapStaker = SwapStakerData[user[i]];
            users[user[i]].updatedat = block.timestamp;
        }
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}
