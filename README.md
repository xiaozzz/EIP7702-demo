## EIP7702 demo

Alice is an EOA address, received 1000 USDC from others.

Alice want to send to Bob 100 USDC, without ETH involved.

This example should how to use EIP7712 and SimpleAccount contract to do this.

Alice account example: https://sepolia.etherscan.io/address/0xc0fd58577FC1879114a718B5985fc5882C8c9d11#tokentxns

SimpleWallet example: https://sepolia.etherscan.io/address/0x24594819391ee59ff7232c5b1c1fa39b6fcef4aa#code

## step by step

1. prepare config

```
# prepare env
source .env
# prepare payment wallet
cast w i metamaskTestnet --private-key $PAYMASTER_PRIVATE_KEY
```

2. deploy contact

```
# deploy
forge create SimpleAccount  -r $CHAIN_URL --account metamaskTestnet --broadcast
# result
Deployed to: 0x24594819391EE59ff7232c5B1c1Fa39B6fcEF4aA

# verify after deploy
forge v 0x24594819391EE59ff7232c5B1c1Fa39B6fcEF4aA ./src/SimpleAccount.sol:SimpleAccount -r $CHAIN_URL --etherscan-api-key $API_KEY
# or using standard-json-input for mannual verify
forge v 0x24594819391EE59ff7232c5B1c1Fa39B6fcEF4aA ./src/SimpleAccount.sol:SimpleAccount -r $CHAIN_URL --show-standard-json-input > SimpleAccount.json
```

3. sign & delegate

```
# sign
cast w sa 0x24594819391EE59ff7232c5B1c1Fa39B6fcEF4aA --chain $CHAIN_ID --nonce $(cast n $ALICE_ADDRESS -r $CHAIN_URL) --private-key $ALICE_PRIVATE_KEY
# result
0xf85d83aa36a79424594819391ee59ff7232c5b1c1fa39b6fcef4aa0280a0b462d260bdc6f6287ce63d35f1c1ade1936def509319d8fae0a6da5c54011b82a021f8a1139130aac8ef7ccf926a4535815d032c7f7f8ea3c973ba5f8eafd33e8c
# delegate using signature
cast s $PAYMASTER_ADDRESS 0x \
-r $CHAIN_URL \
--auth 0xf85d83aa36a79424594819391ee59ff7232c5b1c1fa39b6fcef4aa0280a0b462d260bdc6f6287ce63d35f1c1ade1936def509319d8fae0a6da5c54011b82a021f8a1139130aac8ef7ccf926a4535815d032c7f7f8ea3c973ba5f8eafd33e8c \
--account metamaskTestnet
```

4. faucet usdc to Alice

```
cast s $TOKEN_ADDRESS "transfer(address,uint256)" $ALICE_ADDRESS 1000000000 -r $CHAIN_URL --account metamaskTestnet
```

5. Alice transfer usdc to Bob

```
# check nonce (optional)
cast c -r $CHAIN_URL $ALICE_ADDRESS "getNonce()"
# run this test to get signature r, s, v
forge test --match-test test_generateSignature -vv
# replace nonce, r, s, v
cast s $ALICE_ADDRESS "transferWithSignature(address,address,uint256,uint256,uint256,bytes32,bytes32,uint8)" $TOKEN_ADDRESS $BOB_ADDRESS $TRANSFER_AMOUNT $FEE_AMOUNT 0 0x3eae47e86ac2dff6a593d4278a8484462fb3746d44fe228ec20a7537afde1dfe 0x581142a11d28fa2d6e1bde0eb7c57211fee89b6401375904e5ed98dde948a4a9 28 -r $CHAIN_URL --account metamaskTestnet
```
