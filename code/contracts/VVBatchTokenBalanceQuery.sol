// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma abicoder v2;

import "./lib/SafeMath.sol";
import "./lib/IERC20.sol";

contract VVBatchTokenBalanceQuery {
    using SafeMath for uint256;

    function batchBalanceQuery(address[] memory tokenAddresses, address user) public returns (uint256[] memory) {
        require(tokenAddresses.length > 0, "empty token list");
        require(user != address(0), "empty query address");

        uint256[] memory balances = new uint256[](tokenAddresses.length);
        for (uint256 i = 0;i < tokenAddresses.length;i++) {
            if (tokenAddresses[i] == address (0)) {
                balances[i] = user.balance;
            } else {
                balances[i] = IERC20(tokenAddresses[i]).balanceOf(user);
            }
        }
        return balances;
    }



    function batchBalanceQuery(address[] memory tokenAddresses, address[] memory users) public returns (uint256[] memory) {
        require(tokenAddresses.length > 0, "empty token list");
        require(users.length > 0, "empty user list");

        uint256[] memory balances = new uint256[](tokenAddresses.length * users.length);
        for (uint256 i = 0;i < users.length;i++) {
            require(users[i] != address(0), "empty query address");
            for (uint256 j = 0;j < tokenAddresses.length;j++) {
                if (tokenAddresses[j] == address (0)) {
                    balances[i * tokenAddresses.length + j] = users[i].balance;
                } else {
                    balances[i * tokenAddresses.length + j] = IERC20(tokenAddresses[j]).balanceOf(users[i]);
                }
            }
        }
        return balances;
    }
}