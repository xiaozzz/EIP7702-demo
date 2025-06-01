// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title SimpleAccount. EOA account can delegate to this contract with EIP7702
/// @author @Rubick
/// @notice A simple account that support sending erc20 tokens by paymaster.
contract SimpleAccount {
    /// transfer erc20 token, the account should sign the transfer intent with EIP712 signature
    /// @param token erc20 token address
    /// @param from from address
    /// @param to to address
    /// @param amount transfer amount
    /// @param fee transfer fee, will be sent to the paymaster
    /// @param v signature of transfer intent
    /// @param r signature of transfer intent
    /// @param s signature of transfer intent
    function transfer(
        address token,
        address from,
        address to,
        uint256 amount,
        uint256 fee,
        bytes32 v,
        bytes32 r,
        bytes32 s
    ) external {}
}
