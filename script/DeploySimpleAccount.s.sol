// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {SimpleAccount} from "../src/SimpleAccount.sol";

contract SimpleAccountScript is Script {
    SimpleAccount public simpleAccount;

    function setUp() public {}

    function run() public {
        uint256 paymasterPrivateKey = vm.envUint("PAYMASTER_PRIVATE_KEY");
        vm.startBroadcast(paymasterPrivateKey);
        simpleAccount = new SimpleAccount();
        vm.stopBroadcast();
    }
}
