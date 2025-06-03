// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/SimpleAccount.sol";

contract SimpleAccountTest is Test {
    SimpleAccount public simpleAccount;

    function setUp() public {
        simpleAccount = new SimpleAccount();
    }

    function generateSignature(
        address token,
        address to,
        uint256 amount,
        uint256 fee,
        uint256 nonce,
        uint256 chainid,
        address signer,
        uint256 privateKey
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        // generate the signature of EIP712
        bytes32 typeHash =
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        bytes32 domainHash = keccak256(abi.encode(typeHash, "SimpleAccount", "1", chainid, signer));
        bytes32 hashStruct = keccak256(
            abi.encode(keccak256("Transfer(address,address,uint256,uint256,uint256)"), token, to, amount, fee, nonce)
        );
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", domainHash, hashStruct));
        (v, r, s) = vm.sign(privateKey, hash);
    }

    function test_generateSignature() public view {
        address token = vm.envAddress("TOKEN_ADDRESS");
        address to = vm.envAddress("BOB_ADDRESS");
        uint256 amount = vm.envUint("TRANSFER_AMOUNT");
        uint256 fee = vm.envUint("FEE_AMOUNT");
        uint256 nonce = 0;
        uint256 chainid = vm.envUint("CHAIN_ID");
        address signer = vm.envAddress("ALICE_ADDRESS");
        uint256 privateKey = vm.envUint("ALICE_PRIVATE_KEY");

        (bytes32 r, bytes32 s, uint8 v) = generateSignature(token, to, amount, fee, nonce, chainid, signer, privateKey);
        console2.logBytes32(r);
        console2.logBytes32(s);
        console2.log("v", v);
    }

    function test_getSlot() public pure {
        bytes32 slot = keccak256(abi.encode(uint256(keccak256("Rubick.SimpleAccount")) - 1));
        console2.logBytes32(slot);
    }
}
