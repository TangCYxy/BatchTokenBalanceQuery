// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./Ownable.sol";

contract FeeReceiver is Ownable {
    // feeReceiverAddress
    address public feeReceiverAddress;

    event FeeReceiverUpdated(address receiver);

    function updateFeeReceiver(address newReceiver) external onlyOwner {
        require(newReceiver != address(0), "FeeReceiver: new fee receiver is the zero address");
        _updateFeeReceiver(newReceiver);
    }

    function _updateFeeReceiver(address newReceiver) internal {
        emit FeeReceiverUpdated(newReceiver);
        feeReceiverAddress = newReceiver;
    }
}
