Connext deployments: https://docs.connext.network/resources/deployments#mumbai
Multicall deployments: https://github.com/mds1/multicall/blob/main/deployments.json (default: 0xcA11bde05977b3631167028862bE2a173976CA11)

### Mumbai

RPC=https://polygon-mumbai.rpc.x.superfluid.dev HOST=0xEB796bdb90fFA0f28255275e16936D25d3418603 ERC20=0x15F0Ca26781C3852f8166eD2ebce5D18265cceb7 SUPERTOKEN=0x5D8B4C2554aeB7e86F387B4d6c00Ac33499Ed01f MULTICALL=0xcA11bde05977b3631167028862bE2a173976CA11 forge test -vvvv

Connext contract: 0x2334937846Ab2A3FCE747b32587e1A1A2f6EEC5a
Connext domainId: 9991

### Goerli

Simulate receiving a bridge call from mumbai:

RPC=https://eth-goerli.rpc.x.superfluid.dev HOST=0x22ff293e14F1EC3A09B137e9e06084AFd63adDF9 ERC20=0x88271d333C72e51516B67f5567c728E702b3eeE8 SUPERTOKEN=0xF2d68898557cCb2Cf4C10c3Ef2B034b2a69DAD00 MULTICALL=0xcA11bde05977b3631167028862bE2a173976CA11 CONNEXT=0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649 SAFE=0x18A6dBAA09317C352CAd15F03A13F1f38862d124 MODULE=0x777EB1f42f933Bd3887A5C440634e01a37D0649F ORIGIN=9991 ORIGINSENDER=0x30B125d5Fc58c1b8E3cCB2F1C71a1Cc847f024eE forge test -vvvvv

calldata:
0x82ad56cb0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000140000000000000000000000000000000000000000000000000000000000000020000000000000000000000000088271d333c72e51516b67f5567c728e702b3eee8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000044095ea7b3000000000000000000000000f2d68898557ccb2cf4c10c3ef2b034b2a69dad000000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000f2d68898557ccb2cf4c10c3ef2b034b2a69dad0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000002445977d030000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000cfa132e353cb4e398080b9700609bb008eceb12500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000006457e6aa36000000000000000000000000f2d68898557ccb2cf4c10c3ef2b034b2a69dad00000000000000000000000000c20a5455035ab593682cf9b9916b9407cc9e47f3000000000000000000000000000000000000000000000000000000003b9aca0000000000000000000000000000000000000000000000000000000000

Connext contract: 0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649
Connext domainId: 1735353714

Safe: 0x18A6dBAA09317C352CAd15F03A13F1f38862d124
Zodiac Connext Module: 0x777EB1f42f933Bd3887A5C440634e01a37D0649F

## Next

Do an xcall on mumbai, from 0x30...
To be seen if the correct origin sender is set.


$ RPC=https://polygon-mumbai.rpc.x.superfluid.dev HOST=0x22ff293e14F1EC3A09B137e9e06084AFd63adDF9 ERC20=0x88271d333C72e51516B67f5567c728E702b3eeE8 SUPERTOKEN=0xF2d68898557cCb2Cf4C10c3Ef2B034b2a69DAD00 MULTICALL=0xcA11bde05977b3631167028862bE2a173976CA11 CONNEXT=0xFCa08024A6D4bCc87275b1E4A1E22B71fAD7f649 SAFE=0x18A6dBAA09317C352CAd15F03A13F1f38862d124 MODULE=0x777EB1f42f933Bd3887A5C440634e01a37D0649F ORIGIN=9991 ORIGINSENDER=0x30B125d5Fc58c1b8E3cCB2F1C71a1Cc847f024eE DEST=1735353714 CONNEXTSRC=0x2334937846Ab2A3FCE747b32587e1A1A2f6EEC5a npx hardhat --network any run scripts/xcall.js 
xcall executed in transaction 0xb52b8f9a6461320f1b316a03db346ee0e22cf2894c2b03a971b8cb5e1163296d
Transaction was mined in block 36325934