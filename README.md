## EIP7702 demo

Alice is an EOA address, received 1000 USDC from others.
Alice want to send to Bob 100 USDC, without ETH involved.
This example should how to use EIP7712 and SimpleAccount contract to do this.

1. deploy contact

```
# deploy
forge create SimpleAccount  -r $CHAIN_URL --account metamaskTestnet --broadcast
# result
Deployer: 0x6d4d23200962135C90e2Ad737E8c70644738d57a
Deployed to: 0xD93B8A0d04bB1fcFcd278A33F788733cfF43287b
Transaction hash: 0x54dc9386fe9df61ee5d372113a8d9f64e431c489d6a1d449a1162dfce752fc49

# verify after deploy
forge v 0xD93B8A0d04bB1fcFcd278A33F788733cfF43287b ./src/SimpleAccount.sol:SimpleAccount -r $CHAIN_URL --etherscan-api-key $API_KEY
# or using standard-json-input for mannual verify
forge v 0xD93B8A0d04bB1fcFcd278A33F788733cfF43287b ./src/SimpleAccount.sol:SimpleAccount -r $CHAIN_URL --show-standard-json-input > SimpleAccount.json
```

2. sign & delegate

```
# sign
cast w sa 0xD93B8A0d04bB1fcFcd278A33F788733cfF43287b --chain $CHAIN_ID --nonce $(cast n $ALICE_ADDRESS -r $CHAIN_URL) --private-key $ALICE_PRIVATE_KEY
# result
0xf85d83aa36a794d93b8a0d04bb1fcfcd278a33f788733cff43287b0180a02ae79838992a80cbae5058cd89cc256ec072972dc6dbd735ff5222d2ef16347ea06671e4bf93a784176786fd290edc8a0d8c0f9b70abfe2186c72f42f9083a1161
# delegate
cast s $PAYMASTER_ADDRESS 0x \
-r $CHAIN_URL \
--auth 0xf85d83aa36a794d93b8a0d04bb1fcfcd278a33f788733cff43287b0180a02ae79838992a80cbae5058cd89cc256ec072972dc6dbd735ff5222d2ef16347ea06671e4bf93a784176786fd290edc8a0d8c0f9b70abfe2186c72f42f9083a1161 \
--account metamaskTestnet
```

3. faucet usdc to Alice

```
cast s $TOKEN_ADDRESS "transfer(address,uint256)" $ALICE_ADDRESS 1000000000 -r $CHAIN_URL --account metamaskTestnet
```

4. Alice transfer usdc to Bob

```
# run this test to get signature r,s,v
forge test --match-test test_generateSignature -vv
# replace r,s,v
cast s $ALICE_ADDRESS "transferWithSignature(address,address,uint256,uint256,uint256,bytes32,bytes32,uint8)" $TOKEN_ADDRESS $BOB_ADDRESS $TRANSFER_AMOUNT $FEE_AMOUNT 0 0x3eae47e86ac2dff6a593d4278a8484462fb3746d44fe228ec20a7537afde1dfe 0x581142a11d28fa2d6e1bde0eb7c57211fee89b6401375904e5ed98dde948a4a9 28 -r $CHAIN_URL --account metamaskTestnet
```
