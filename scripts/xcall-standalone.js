/*
 * Standalone nodejs script for triggering a Connext xcall
 * which bridges tokens, upgrades them to a SuperToken on the other side and then streams them. 
 */

const { ethers } = require("hardhat");
const { Contract, utils } = ethers;

const Multicall3Abi = require("../abis/Multicall3Abi");
const IERC20Abi = require("../abis/IERC20Abi");
const ISuperTokenAbi = require("../abis/ISuperTokenAbi");
const CFAFwdAbi = require("../abis/CFAv1ForwarderAbi");
const L2CatapultAbi = require("../abis/L2CatapultAbi");

async function getUpgradeAndStreamMulticall3Calldata(cfaFwd, l2Erc20, superToken, amount, receiver, flowRate, multicallAddr="0xcA11bde05977b3631167028862bE2a173976CA11") {
  const mc3 = new Contract(multicallAddr, Multicall3Abi);
  const calls = [
      {
          target: l2Erc20,
          allowFailure: false,
          callData: new utils.Interface(IERC20Abi).encodeFunctionData("approve", [superToken, amount])
      },
      {
          target: superToken,
          allowFailure: false,
          callData: new utils.Interface(ISuperTokenAbi).encodeFunctionData("upgrade", [amount])
      },
      {
          target: cfaFwd,
          allowFailure: false,
          callData: new utils.Interface(CFAFwdAbi).encodeFunctionData("setFlowrate", [superToken, receiver, flowRate])
      }
  ];

  return mc3.populateTransaction.aggregate3(calls);
}

// if the target contract is a minimal contract wallet (for testing purposes only), use this
async function getCatapultCalldata(data, target="0xcA11bde05977b3631167028862bE2a173976CA11") {
  // function executeDelegateMultiCall(address target, bytes memory data) public returns(bool, bytes memory)
  return new utils.Interface(L2CatapultAbi).encodeFunctionData("executeDelegateMultiCall", [target, data]);
}

// default target is the canonical multicall address, see https://github.com/mds1/multicall#deployments-and-abi
async function getSafeModuleCalldata(data, target="0xcA11bde05977b3631167028862bE2a173976CA11") {
  return ethers.utils.defaultAbiCoder.encode(
      // to, value, data, operation
      ['address', 'uint256', 'bytes', 'uint8'], // array of types
      [target, 0, data, 1] // operation 1 is DelegateCall
  );
}

async function main() {
  const [deployer] = await ethers.getSigners();

  const l1Erc20Addr = process.env.L1ERC20;

  // see https://docs.connext.network/resources/deployments
  const destinationDomain = process.env.L2DOMAIN || 1735353714; // defaults to görli

  const targetAddr = process.env.L2TARGET; // in case of Safe, the zodiac connext module
  const target = ethers.utils.getAddress(targetAddr);

  const l1ConnextAddress = process.env.L1CONNEXT;
  const cfaFwd = process.env.CFAFWD || "0xcfA132E353cB4E398080B9700609bb008eceB125";
  const l2Erc20 = process.env.L2ERC20;
  const superToken = process.env.SUPERTOKEN;
  const decimals = process.env.DECIMALS || 18;
  const amount = ethers.utils.parseUnits(process.env.AMOUNT || "1", decimals);
  const receiver = process.env.RECEIVER || "0xC20a5455035Ab593682Cf9b9916b9407cc9e47f3"; // random dude
  const flowRate = process.env.FLOWRATE || ethers.utils.parseUnits("1", 9); // 1e9 if not specified
  const maxSlippage = process.env.MAXSLIPPAGE || 30; // bps - 30 = 0.3%
  const l1ApproveAmount = process.env.L1_APPROVE_AMOUNT ? ethers.utils.parseUnits(process.env.L1_APPROVE_AMOUNT) : undefined;

  if (l1ApproveAmount !== undefined) {
    console.log(`erc20 approving connext for ${l1ApproveAmount.toString()} tokens`);
    const l1Erc20Contract = new Contract(l1Erc20Addr, IERC20Abi, deployer);
    const tx = await l1Erc20Contract.approve(l1ConnextAddress, l1ApproveAmount);
    console.log(`approve tx pending: ${tx.hash}`);
    const receipt = await tx.wait();
    console.log(`tx mined in block ${receipt.blockNumber}`);
  }

  // TODO: what to put here?
  // see https://docs.connext.network/developers/guides/estimating-fees
  // mumbai relayer threshold seems to be around 0.09
  const relayerFee = ethers.utils.parseEther(process.env.RELAYER_FEE || '0.1');
  
  const mc3CallData = process.env.EMPTYCALLDATA ? 0 : (await getUpgradeAndStreamMulticall3Calldata(
    cfaFwd,
    l2Erc20,
    superToken,
    amount.sub(amount.mul(30).div(10000)),
    receiver,
    flowRate
  )).data;
  console.log("mc3Calldata:", mc3CallData);

  //const callData = process.env.EMPTYCALLDATA ? 0 : await getCatapultCalldata(mc3CallData);

  const callData = process.env.EMPTYCALLDATA ? 0 : await getSafeModuleCalldata(mc3CallData);

  console.log("calldata:", callData);

  if (process.env.SKIP_EXECUTION) {
    process.exit(0);
  }

  // setup Connext interface
  const connextAbi = [
    'function xcall(uint32,address,address,address,uint256,uint256,bytes) external payable returns (bytes32)',
  ];
  const connext = new ethers.Contract(l1ConnextAddress, connextAbi, deployer);

  // execute the xcall operation
  const tx = await connext.xcall(
    destinationDomain,
    target, // contract on destination, e.g. Safe module
    l1Erc20Addr || ethers.constants.AddressZero, // asset
    deployer.address, // delegate - authenticated call
    amount, // amount
    maxSlippage, // slippage - 0 without asset - is bps, e.g. 30 would be 0.3%
    callData,
    { value: relayerFee }
  );

  console.log(`xcall tx pending: ${tx.hash}`);

  // wait for transaction to be mined
  const receipt = await tx.wait();
  console.log(`tx mined in block ${receipt.blockNumber}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
