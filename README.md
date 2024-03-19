# description
query multi token balance in one single request(native currency included) 
## core functions 
- token balance query
## usage
- `batchBalanceQuery(address[] tokenAddresses, address user) returns (uint256[])`
- `address(0) indicates native currency balance query` 
## installation
- nvm use 16.14.0
- npm install
- truffle compile
- truffle migrate
- truffle run verify
## configuration
- rename config.js.example into config.js
- update item needed in config.js