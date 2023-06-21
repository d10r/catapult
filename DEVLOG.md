Connext deployments: https://docs.connext.network/resources/deployments#mumbai
Multicall deployments: https://github.com/mds1/multicall/blob/main/deployments.json (default: 0xcA11bde05977b3631167028862bE2a173976CA11)

## forge testing

### Goerli

Simulate receiving a bridge call from mumbai:

RPC=https://eth-goerli.rpc HOST=0x22ff293e14F1EC3A09B137e9e06084AFd63adDF9 ERC20=0x88271d333C72e51516B67f5567c728E702b3eeE8 SUPERTOKEN=0xF2d68898557cCb2Cf4C10c3Ef2B034b2a69DAD00 MULTICALL=0xcA11bde05977b3631167028862bE2a173976CA11 CONNEXT=0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649 SAFE=0x18A6dBAA09317C352CAd15F03A13F1f38862d124 MODULE=0x777EB1f42f933Bd3887A5C440634e01a37D0649F ORIGIN=9991 ORIGINSENDER=0x30B125d5Fc58c1b8E3cCB2F1C71a1Cc847f024eE forge test -vvv

Connext contract: 0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649
Connext domainId: 1735353714

Safe: 0x18A6dBAA09317C352CAd15F03A13F1f38862d124
Zodiac Connext Module: 0x777EB1f42f933Bd3887A5C440634e01a37D0649F

### Mumbai

Connext contract: 0x2334937846Ab2A3FCE747b32587e1A1A2f6EEC5a
Connext domainId: 9991

### Connext Module

Set up https://github.com/d10r/zodiac-module-connext (fork with minimal changes)

deploy to goerli:
```
ANY_PROVIDER_URL=https://eth-goerli.rpc npx hardhat --network any setup --avatar 0x18A6dBAA09317C352CAd15F03A13F1f38862d124 --connext 0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649 --origin 9991 --owner 0x30B125d5Fc58c1b8E3cCB2F1C71a1Cc847f024eE --sender 0x30B125d5Fc58c1b8E3cCB2F1C71a1Cc847f024eE --target 0x18A6dBAA09317C352CAd15F03A13F1f38862d124
```

deploy to polygon:
```
$ ANY_PROVIDER_URL=https://polygon-mainnet.rpc npx hardhat --network any setup --avatar 0x9fe708c342D53bE829Da8b26ff99b460e08F96e9 --connext 0x11984dc4465481512eb5b777E44061C158CF2259 --origin 6778479 --owner 0xCcA090FD60d405a10b786559933daEEc4e2053Af --sender 0xCcA090FD60d405a10b786559933daEEc4e2053Af --target 0x9fe708c342D53bE829Da8b26ff99b460e08F96e9
Deploying Connext Module
Connext Module deployed to: 0xa4DD3F3b68647206E996E1c756f9c36096e65528
```

deploy to gnosis (to a Safe owned by 0x30...):
```
$ ANY_PROVIDER_URL=https://xdai-mainnet.rpc npx hardhat --network any setup --avatar 0x8b72430DEBD7994B269eB401230799eC9A1F24bc --connext 0x5bB83e95f63217CDa6aE3D181BA580Ef377D2109 --origin 1886350457 --owner 0xCcA090FD60d405a10b786559933daEEc4e2053Af --sender 0xCcA090FD60d405a10b786559933daEEc4e2053Af --target 0x8b72430DEBD7994B269eB401230799eC9A1F24bc
Deploying Connext Module
Connext Module deployed to: 0xee07D9fce4Cf2a891BC979E9d365929506C2982f
```

Polygon
Safe: 0x9fe708c342D53bE829Da8b26ff99b460e08F96e9
Module: 0xa4DD3F3b68647206E996E1c756f9c36096e65528

Gnosis
Safe: 0x8b72430DEBD7994B269eB401230799eC9A1F24bc
Module: 0xee07D9fce4Cf2a891BC979E9d365929506C2982f

verify:
```
ANY_PROVIDER_URL=https://xdai-mainnet.rpc npx hardhat verify --network any 0xFCD84210f5d51Cd40a30443d44d6A5500d5D10dF "0x8b72430DEBD7994B269eB401230799eC9A1F24bc" "0x8b72430DEBD7994B269eB401230799eC9A1F24bc" "0x8b72430DEBD7994B269eB401230799eC9A1F24bc" "0xCcA090FD60d405a10b786559933daEEc4e2053Af" 1886350457 "0x5bB83e95f63217CDa6aE3D181BA580Ef377D2109"
```
(args: address _owner, address _avatar, address _target, address _originSender, uint32 _origin, address _connext)

## nodejs scripts

### Mumbai

xcall-contract.js:
```
$ RPC=https://polygon-mumbai.rpc HOST=0x22ff293e14F1EC3A09B137e9e06084AFd63adDF9 ERC20=0x88271d333C72e51516B67f5567c728E702b3eeE8 SUPERTOKEN=0xF2d68898557cCb2Cf4C10c3Ef2B034b2a69DAD00 MULTICALL=0xcA11bde05977b3631167028862bE2a173976CA11 CONNEXT=0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649 SAFE=0x18A6dBAA09317C352CAd15F03A13F1f38862d124 MODULE=0x777EB1f42f933Bd3887A5C440634e01a37D0649F ORIGIN=9991 ORIGINSENDER=0x30B125d5Fc58c1b8E3cCB2F1C71a1Cc847f024eE DEST=1735353714 CONNEXTSRC=0x2334937846Ab2A3FCE747b32587e1A1A2f6EEC5a npx hardhat --network any run scripts/xcall-contract.js 
xcall executed in transaction 0xb52b8f9a6461320f1b316a03db346ee0e22cf2894c2b03a971b8cb5e1163296d
Transaction was mined in block 36325934
```

xcall-standalone.js - Goerli to Mumbai:
```
RPC=https://eth-goerli.rpc HOST=0xEB796bdb90fFA0f28255275e16936D25d3418603 L2ERC20=0xeDb95D8037f769B72AAab41deeC92903A98C9E16 SUPERTOKEN=0x1f8af2e863d58698cf4ae91ae1f0f5e2ec260d54 MULTICALL=0xcA11bde05977b3631167028862bE2a173976CA11 L2DOMAIN=9991 L1CONNEXT=0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649 L2TARGET=0xFF8Bf7F667B65e8139267345CDE2d60522f939e8 RELAYER_FEE=0.01 npx hardhat --network any run scripts/xcall-standalone.js
```

### Polygon to Gnosis

Deploy Module to Gnosis:
```
$ ANY_PROVIDER_URL=https://xdai-mainnet.rpc npx hardhat --network any setup --avatar 0x8b72430DEBD7994B269eB401230799eC9A1F24bc --connext 0x5bB83e95f63217CDa6aE3D181BA580Ef377D2109 --origin 1886350457 --owner 0xCcA090FD60d405a10b786559933daEEc4e2053Af --sender 0xCcA090FD60d405a10b786559933daEEc4e2053Af --target 0x8b72430DEBD7994B269eB401230799eC9A1F24bc
Deploying Connext Module
Connext Module deployed to: 0xee07D9fce4Cf2a891BC979E9d365929506C2982f
```

Catapult from Polygon:
```
RPC=https://polygon-mainnet.rpc HOST=0xEB796bdb90fFA0f28255275e16936D25d3418603 L1ERC20=0x2791bca1f2de4661ed88a30c99a7a9449aa84174 L2ERC20=0xddafbb505ad214d7b80b1f830fccc89b60fb7a83 SUPERTOKEN=0x1234756ccf0660e866305289267211823ae86eec MULTICALL=0xcA11bde05977b3631167028862bE2a173976CA11 L2DOMAIN=6778479 L1CONNEXT=0x11984dc4465481512eb5b777E44061C158CF2259 L2TARGET=0xee07D9fce4Cf2a891BC979E9d365929506C2982f RELAYER_FEE=0.1 AMOUNT=0.1 DECIMALS=6 FLOWRATE=111 npx hardhat --network any run scripts/xcall-standalone.js
...
xcall tx pending: 0x311eaa8b0d9ba3feb9f679496e8b2959038a54c56efcf1d364e8681de3d4a9e1
tx mined in block 43952875
https://connextscan.io/tx/0x311eaa8b0d9ba3feb9f679496e8b2959038a54c56efcf1d364e8681de3d4a9e1
```

## Dapps

run a webserver with `python -m SimpleHTTPServer 1337`

Deploy Module to Gnosis:
```
http://localhost:1337/zodiac-module-deployer.html?l1Sender=0xCcA090FD60d405a10b786559933daEEc4e2053Af&l1ChainId=137&l2Safe=0x8b72430DEBD7994B269eB401230799eC9A1F24bc
```

Catapult form Polygon:
```
http://localhost:1337/catapult.html?l1ChainId=137&l1Erc20=0x2791bca1f2de4661ed88a30c99a7a9449aa84174&l1Amount=0.42&l2ChainId=100&l2Erc20=0xddafbb505ad214d7b80b1f830fccc89b60fb7a83&l2SuperToken=0x1234756ccf0660e866305289267211823ae86eec&l2ConnextModule=0xFCD84210f5d51Cd40a30443d44d6A5500d5D10dF&l2Receiver=0x209b6ff4616152187d752eca6efafdc6e873c48a&l2FlowratePerDay=0.02
```