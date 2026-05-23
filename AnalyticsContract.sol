// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// Acts as a blueprint to allow direct interaction with external smart contracts.
interface ITradeContract {
    function getTradeCount(address _trader) external view returns (uint256);
    function getTradeResult(address _trader, uint256 _index) external view returns (int256); // Positive = Win, Negative = Loss
}

interface IUserContract {
    function isTraderActive(address _trader) external view returns (bool);
}

contract AnalyticsContract {
    // Stores the contract instances linked via their deployed addresses.
    ITradeContract public tradeContract;
    IUserContract public userContract;

    constructor(address _tradeContractAddress, address _userContractAddress) {
        require(_tradeContractAddress != address(0) && _userContractAddress != address(0), "Error: Invalid address");
        
        // Initializing external contract connections using their deployed addresses
        tradeContract = ITradeContract(_tradeContractAddress);
        userContract = IUserContract(_userContractAddress);
    }
    function calculateWinRate(address _trader) external view returns (uint256) {
        require(userContract.isTraderActive(_trader), "Error: Trader account is not active or not registered");
        uint256 totalTrades = tradeContract.getTradeCount(_trader);
        if (totalTrades == 0) return 0;
        uint256 wins = 0; 
        // Loops through the trade array hosted on the external TradeContract
        for (uint256 i = 0; i < totalTrades; i++) {
            int256 pl = tradeContract.getTradeResult(_trader, i);
            if (pl > 0) {
                wins++;
            }
        }
        // Returns an integer representing the percentage (e.g., 75 = 75% win rate)
        return (wins * 100) / totalTrades;
    }
    // Calculates total cumulative Net Profit & Loss on-chain for verification transparency.
    function calculateTotalPL(address _trader) external view returns (int256) {
        require(userContract.isTraderActive(_trader), "Error: Trader account is not active");

        uint256 totalTrades = tradeContract.getTradeCount(_trader);
        int256 totalPL = 0;

        for (uint256 i = 0; i < totalTrades; i++) {
            totalPL += tradeContract.getTradeResult(_trader, i);
        }

        return totalPL;
    }
}