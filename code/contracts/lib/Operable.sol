// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./Ownable.sol";

contract Operable is Ownable {
    // 操作者，web2 server更新操作者
    mapping (address=>bool) public operator;

    event OperatorRemoved(address operator);

    event OperatorAdded(address operator);

    function addOperator(address newOperator) external onlyOwner {
        require(newOperator != address(0), "Operable: new operator is the zero address");
        require(!operator[newOperator], "Operable: operator already exist");
        emit OperatorAdded(newOperator);
        operator[newOperator] = true;
    }

    function removeOperator(address oldOperator) external onlyOwner {
        require(oldOperator != address(0), "Operable: operator to remove is the zero address");
        require(operator[oldOperator], "Operable: operator to remove is not privileged");
        emit OperatorRemoved(oldOperator);
        operator[oldOperator] = false;
    }

    modifier isOperator() {
        require(operator[msg.sender], "only operator address allowed");
        _;
    }
}
