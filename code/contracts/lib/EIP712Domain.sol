// SPDX-License-Identifier: MIT

pragma solidity 0.7.5;

import "./EIP712.sol";

abstract contract EIP712Domain {
    bytes32 public DOMAIN_SEPARATOR;

    function _setDomainSeparator(string memory name, string memory version)
    internal
    {
        DOMAIN_SEPARATOR = EIP712.makeDomainSeparator(name, version);
    }
}