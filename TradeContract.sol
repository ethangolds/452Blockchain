// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUserContract {
    function isTraderActive(address _trader) external view returns (bool);
    function isBrokerAuthorised(address _broker) external view returns (bool);
}

contract TradeContract {
    address public adminBroker;
    IUserContract public userContract;


// Trade states 
    enum TradeStatus {
        Submitted,
        BrokerVerified,
        Rejected
    }
// stores trade information submitted by trader
    struct Trade {
        string assetType; 
        uint256 entryPrice;
        uint256 exitPrice;
        uint256 submitTime;
        uint256 verifyTime;
        int256 profitOrLoss; 
        TradeStatus status; 
    }
// Mpas each traers wallet to their list of submitted trades

    mapping(address => Trade[]) private traderTrades;

    event TradeSubmitted(
        address indexed trader,
        uint256 indexed tradeIndex,
        string assetType,
        uint256 entryPrice,
        uint256 exitPrice,
        uint256 submitTime
    );

    event TradeVerified(
        address indexed trader,
        uint256 indexed tradeIndex,
        address indexed brokerOracle,
        int256 profitOrLoss, 
        uint256 verifyTime
    );

    event TradeRejected(
        address indexed trader,
        uint256 indexed tradeIndex,
        address indexed brokerOracle,
        uint256 verifyTime
    );


// Access control modifiers used to restrict contract functions

    modifier onlyAdmin() {
        require(msg.sender == adminBroker, "Only Broker can call this");
        _;
    }

    // Set only registerd and active traders can submit trades
    modifier onlyActiveTrader() {
        require(userContract.isTraderActive(msg.sender), "Trader is not active");
        _;
    }
    // Only authorised broker can verify or reject trades
    modifier onlyAuthorisedBroker() {
        require(userContract.isBrokerAuthorised(msg.sender), "Broker/Oracle is not authrised");
        _;
    }
    modifier validTrade(address _trader, uint256 _tradeIndex) {
        require(_tradeIndex < traderTrades[_trader].length, "Trade does not exist");
        _;
    }

    constructor(address _userContractAddress) {
        require(_userContractAddress != address(0), "invalid UserContract Address");
        adminBroker = msg.sender;
        userContract = IUserContract(_userContractAddress);
    }

    /* Trader Submit completed trades.
    The trade remains in submitted status until approved by an authorised broker */

    function submitTrade(
        string memory _assetType,
        uint256 _entryPrice,
        uint256 _exitPrice
    ) external onlyActiveTrader {
        require(bytes(_assetType).length > 0, "asset type is required");
        require(_entryPrice > 0, "Entry price must be greater than zero");
        require(_exitPrice > 0, "Exit Price must be greater than zero");

        traderTrades[msg.sender].push(
            Trade({
                assetType: _assetType,
                entryPrice: _entryPrice,
                exitPrice: _exitPrice,
                submitTime: block.timestamp,
                verifyTime: 0,
                profitOrLoss: 0,
                status: TradeStatus.Submitted
            })
        );

        uint256 tradeIndex = traderTrades[msg.sender].length - 1;

        emit TradeSubmitted(
            msg.sender,
            tradeIndex,
            _assetType,
            _entryPrice,
            _exitPrice,
            block.timestamp
        );
    }

    // Broker berifies or rejects submitted trades. Verifies stores a confirmed profit or loss value. Rejects excludes

    function brokerVerifyTrade(
        address _trader, 
        uint256 _tradeIndex, 
        int256 _profitOrLoss, 
        TradeStatus _status
    ) external onlyAuthorisedBroker validTrade(_trader, _tradeIndex) {
        require(_status == TradeStatus.BrokerVerified || _status == TradeStatus.Rejected, "Invalid status update");
        
        Trade storage trade = traderTrades[_trader][_tradeIndex];
        require(trade.status == TradeStatus.Submitted, "Trade is already processed");

        trade.status = _status;
        trade.verifyTime = block.timestamp;
        
        if (_status == TradeStatus.BrokerVerified) {
            trade.profitOrLoss = _profitOrLoss;
            emit TradeVerified(_trader, _tradeIndex, msg.sender, _profitOrLoss, block.timestamp);
        } else {
            emit TradeRejected(_trader, _tradeIndex, msg.sender, block.timestamp);
        }
    }

    function getTradeCount(address _trader) external view returns (uint256) {
        return traderTrades[_trader].length;
    }
// Return result of profit or loss for verifies trader only
    function getTradeResult(address _trader, uint256 _tradeIndex)
        external
        view
        validTrade(_trader, _tradeIndex)
        returns (int256)
    {
        require(traderTrades[_trader][_tradeIndex].status == TradeStatus.BrokerVerified, "Trade is not verified");
        return traderTrades[_trader][_tradeIndex].profitOrLoss;
    }

    function isTradeVerified(address _trader, uint256 _tradeIndex)
        external
        view 
        validTrade(_trader, _tradeIndex)
        returns (bool)
    {
        return traderTrades[_trader][_tradeIndex].status == TradeStatus.BrokerVerified;
    }

    function getTradeDetails(address _trader, uint256 _tradeIndex)
        external 
        view
        validTrade(_trader, _tradeIndex)
        returns (
            string memory assetType,
            uint256 entryPrice,
            uint256 exitPrice,
            uint256 submitTime,
            uint256 verifyTime,
            int256 profitOrLoss,
            TradeStatus status
        )
    {
        Trade storage trade = traderTrades[_trader][_tradeIndex];

        return (
            trade.assetType,
            trade.entryPrice,
            trade.exitPrice,
            trade.submitTime,
            trade.verifyTime,
            trade.profitOrLoss,
            trade.status
        );
    }

    function updateUserContract(address _newUserContractAddress) external onlyAdmin {
        require(_newUserContractAddress != address(0), "Invalid UserContract address");
        userContract = IUserContract(_newUserContractAddress);
    }
}
