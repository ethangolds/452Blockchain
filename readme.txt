IFB452 Blockchain - Group101

Proof of Profit Trading Blockchain

Project outline
---------------

Proof of Profit Blockchain application build through solidity smart contract
Via Remix to demonstrate the process with potential for implementation on UI websites for Trading companies or investment firms

The purpose of the project is to create a transparent and reliable profit and loss contract confirmation that verifies a agents trades and the reliability of their proof of profit/loss.

Using three smart contracts

---------

User Contract

Manages trader registration and account status on the blockchain

with functions of 
-Registering traders
-Managing account status
-Authorising brokers


--------

Trade Contract

Stores trade records submitted by traders

with functions of
-Submitting trades
-verifying trades
-rejecting trades
-receiving and storing all trade info

--------

Analytics Contract

Calculate performance metrics from verified trades

with functions of 
-calculating profit and loss
-viewing verified trading performance

-----
Stakeholders include, Trader(registers an account and submits trade) Broker/Orace (verifies or rejects submitted trades, Prop firm/ investors/banks (views verified trades and performance)



Instructions for blockchain deployment through Remix IDE

1: Open remix with the 3 files open

2: Compile all contracts using Solidity

3: Deploy UserContract - then copy deployed contract address

4: Deploy TradeContract - then pass the UserContract address into the contructor. Then copy the deployed TradeContract address

5: Deploy AnalyticsContract - then pass TradeContract and UserContract address into the contructor


----- Through these steps

Register a trader and call registerTrader()
Account will register

Using the admin account call setAuthorisedBroker()
Broker account will be set to true

Using Trader account call submitTrade()

Enter Asset, price of trades and other details which can be added at any time for future development
Trade will be sotres

Switch batck to broker account and call verifyTrade()
provide trader address, number, profit or loss
This will confirm the trade status as verified

Call analytics function eg calculateTotalPL()
Will confirm analytics from the chosen verified trader


-------

Our project design and future potential

The Project separates functionality into three separate contracts

Through REMIX the entire backend and data can be run for anyone. However a UI can be made or implemented for bank/broker companies ect to run a quick and clean analysis on potential trader clients




