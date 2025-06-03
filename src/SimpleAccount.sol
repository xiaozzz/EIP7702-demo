// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title SimpleAccount. EOA account can delegate to this contract with EIP7702
/// @author @Rubick
/// @notice A simple account that support sending erc20 tokens by paymaster.
contract SimpleAccount {
    function version() public pure returns (string memory) {
        return "0.1.2";
    }

    struct SimpleAccountStorage {
        uint256 nonce;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("Rubick.SimpleAccount")) - 1))
    bytes32 private constant SimpleAccountStorageLocation =
        0x6a771a47559178fded0c5ccd3282e6d7c9e7982c3a74172c487460df3d8ef792;

    function _getSimpleAccountStorageLocation() private pure returns (SimpleAccountStorage storage $) {
        assembly {
            $.slot := SimpleAccountStorageLocation
        }
    }

    function getNonce() external view returns (uint256) {
        return _getSimpleAccountStorageLocation().nonce;
    }

    /// transfer erc20 token, the account should sign the transfer intent with EIP712 signature
    /// @param token erc20 token address
    /// @param to to address
    /// @param amount transfer amount
    /// @param fee transfer fee, will be sent to the paymaster
    /// @param nonce wallet nonce
    /// @param r signature of transfer intent
    /// @param s signature of transfer intent
    /// @param v signature of transfer intent
    /// @notice the signature can be replayed, a nonce should be added to the signature
    function transferWithSignature(
        address token,
        address to,
        uint256 amount,
        uint256 fee,
        uint256 nonce,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external {
        // nonce check
        require(nonce == this.getNonce(), "Invalid nonce");
        // Verify the signature of EIP712
        // Users can sign the transfer intent with EIP712 signature
        bytes32 typeHash =
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        bytes32 domainHash = keccak256(abi.encode(typeHash, "SimpleAccount", "1", block.chainid, address(this)));
        bytes32 hashStruct = keccak256(
            abi.encode(keccak256("Transfer(address,address,uint256,uint256,uint256)"), token, to, amount, fee, nonce)
        );
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", domainHash, hashStruct));
        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == address(this), "Invalid signature");

        // Transfer tokens
        IERC20(token).transfer(to, amount);

        // Transfer fee to paymaster
        if (fee > 0) {
            IERC20(token).transfer(msg.sender, fee);
        }
    }
}
