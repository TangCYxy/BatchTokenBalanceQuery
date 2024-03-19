// SPDX-License-Identifier: MIT

pragma solidity 0.7.5;

interface NativeMetaTransactionApi {
    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) external payable returns (bytes memory);
}