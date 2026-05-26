// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UserContract { 
    // Variables stored permanently on the blockchain storage.
    address public adminBroker; 
    uint256 public accountActivationFee = 0.01 ether; 
    // Defines fixed states for trader account management.
    enum AccountStatus { Unregistered, Active, Suspended }
    // Groups related user profile details into a single data type.
    struct UserProfile {
        string username;
        AccountStatus status;
        uint256 registrationTimestamp;
    }
    // Hash table for O(1) lookup efficiency. Links a wallet address to a UserProfile.
    mapping(address => UserProfile) public users;
    mapping(address => bool) public authorisedBrokers;
    event BrokerAuthorised(address indexed brokerAddress, bool isAuthorised);
    // Logs important activities on-chain. Used by the UI to update the interface.
    event UserRegistered(address indexed userAddress, string username, uint256 timestamp);
    event UserStatusUpdated(address indexed userAddress, AccountStatus newStatus);
    // Restricts function execution to authorized addresses using msg.sender.
    modifier onlyAdmin() {
        require(msg.sender == adminBroker, "Error: Only Admin Broker can call this function");
        _;
    }

    constructor() {
        adminBroker = msg.sender; 
    }
    // Accepts ETH deposit and uses msg.value to verify the correct payment amount.
    function registerTrader(string memory _username) external payable {
        require(users[msg.sender].status == AccountStatus.Unregistered, "Error: User already registered");
        require(msg.value >= accountActivationFee, "Error: Insufficient ETH sent for activation");

        users[msg.sender] = UserProfile({
            username: _username,
            status: AccountStatus.Active,
            registrationTimestamp: block.timestamp 
        });
        emit UserRegistered(msg.sender, _username, block.timestamp);
        if (msg.value > accountActivationFee) {
            uint256 refundAmount = msg.value - accountActivationFee;
            (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
            require(success, "Error: Refund failed");
        }
    }
    // MULTI-STAKEHOLDER BUSINESS LOGIC 
    // Allows the Broker to suspend an account if malicious activity is detected off-chain.
    function suspendTrader(address _trader) external onlyAdmin {
        require(users[_trader].status == AccountStatus.Active, "Error: Trader account is not active");
        users[_trader].status = AccountStatus.Suspended;
        emit UserStatusUpdated(_trader, AccountStatus.Suspended);
    }
    // Provides a helper function for external contract interactions.
    function isTraderActive(address _trader) external view returns (bool) {
        return users[_trader].status == AccountStatus.Active;
    }
    // Allows the admin to grant or revoke broker permissions.
    function setBrokerPermission(address _broker, bool _status) external onlyAdmin {
        require(_broker != address(0), "Error: Invalid broker address");
        authorisedBrokers[_broker] = _status;
        emit BrokerAuthorised(_broker, _status);
    }

// Need this function for linking trade contract
    function isBrokerAuthorised(address _broker) external view returns (bool) {
        return authorisedBrokers[_broker];
    }
receive() external payable {
}

fallback() external payable {
}
}
