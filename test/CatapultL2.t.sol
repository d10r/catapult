// SPDX-License-Identifier: AGPLv3
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/StdCheats.sol";
import "../contracts/CatapultL2.sol";
import { 
    ISuperfluid,
    ISuperfluidGovernance,
    ISuperToken
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";
import { CallUtils } from "@superfluid-finance/ethereum-contracts/contracts/libs/CallUtils.sol";
import "@gnosis.pm/safe-contracts/contracts/common/Enum.sol";

// https://github.com/connext/interfaces/blob/main/core/IXReceiver.sol
interface IXReceiver {
  function xReceive(
    bytes32 _transferId,
    uint256 _amount,
    address _asset,
    address _originSender,
    uint32 _origin,
    bytes memory _callData
  ) external returns (bytes memory);
}

contract Upgrade_SuperTokens is Test {
    
    using SuperTokenV1Library for ISuperToken;

    address HOST;
    address ERC20;
    address SUPERTOKEN;
    address MULTICALL;
    ISuperfluid host;
    ISuperfluidGovernance gov;
    address govOwner;
    IERC20 erc20;
    ISuperToken superToken;
    CatapultL2 catapultL2;

    constructor() {
        string memory rpc = vm.envString("RPC");
        vm.createSelectFork(rpc);
        HOST = vm.envAddress("HOST");
        ERC20 = vm.envAddress("ERC20");
        SUPERTOKEN = vm.envAddress("SUPERTOKEN");
        MULTICALL = vm.envAddress("MULTICALL");
        
        host = ISuperfluid(HOST);
        gov = ISuperfluidGovernance(host.getGovernance());
        govOwner = Ownable(address(gov)).owner();
        erc20 = IERC20(ERC20);
        superToken = ISuperToken(SUPERTOKEN);
    }

    function setUp() public {
        catapultL2 = new CatapultL2();
        vm.label(address(catapultL2), "catapultL2");
    }

    //function execute(IERC20 erc20, ISuperToken superToken, uint256 amount, address receiver, int96 flowRate) public {
    function notestExecuteSteps(/*uint256 amount,*/ /*address receiver, int96 flowRate*/) public {
        // fund the catapult contract with 100 tokens
        console.log("token supply: %s", erc20.totalSupply() / 1e18);
        deal(address(erc20), address(catapultL2), uint256(100e18));
        console.log("catapult erc20 balance: %s", erc20.balanceOf(address(catapultL2)));

        uint256 amount = 10e18; //erc20.balanceOf(address(catapultL2));
        console.log("amount to process: %s", amount / 1e18);

        int96 flowRate = 1e9;
        address receiver = 0xd15D5d0f5b1b56A4daEF75CfE108Cb825E97d015;
        
        catapultL2.executeSteps(erc20, superToken, amount, receiver, flowRate);

        console.log("flowRate after: %s", uint256(int256(superToken.getFlowRate(address(catapultL2), receiver))));
    }

    function notestExecuteBatch(/*uint256 amount,*/ /*address receiver, int96 flowRate*/) public {
        // fund the catapult contract with 100 tokens
        console.log("token supply: %s", erc20.totalSupply() / 1e18);
        deal(address(erc20), address(catapultL2), uint256(100e18));
        console.log("catapult erc20 balance: %s", erc20.balanceOf(address(catapultL2)));

        uint256 amount = 10e18; //erc20.balanceOf(address(catapultL2));
        console.log("amount to process: %s", amount / 1e18);

        int96 flowRate = 1e9;
        address receiver = 0xC20a5455035Ab593682Cf9b9916b9407cc9e47f3;
        
        catapultL2.executeBatch(erc20, superToken, amount, receiver, flowRate);

        console.log("flowRate after: %s", uint256(int256(superToken.getFlowRate(address(catapultL2), receiver))));
    }

    function notestInlineMulticall(/*uint256 amount,*/ /*address receiver, int96 flowRate*/) public {
        console.log("token supply: %s", erc20.totalSupply() / 1e18);
        // fund the test contract
        deal(address(erc20), address(this), uint256(100e18));
        console.log("self erc20 balance: %s", erc20.balanceOf(address(this)));

        uint256 amount = 10e12; //erc20.balanceOf(address(catapultL2));
        console.log("amount to process: %s", amount);

        int96 flowRate = 1e9;
        address receiver = 0xC20a5455035Ab593682Cf9b9916b9407cc9e47f3;
        address cfaFwd = 0xcfA132E353cB4E398080B9700609bb008eceB125;
        
        IMulticall3 mc3 = IMulticall3(MULTICALL);
        IMulticall3.Call3[] memory calls = new IMulticall3.Call3[](3);
        calls[0] = IMulticall3.Call3(address(erc20), true, abi.encodeWithSignature("approve(address,uint256)", address(superToken), amount));
        calls[1] = IMulticall3.Call3(address(superToken), true, abi.encodeWithSignature("upgrade(uint256)", amount));
        calls[2] = IMulticall3.Call3(
            address(cfaFwd), 
            true, 
            abi.encodeWithSignature("setFlowrate(address,address,int96)", address(superToken), receiver, flowRate)
        );
        (bool success, bytes memory returnData) = address(mc3).delegatecall(abi.encodeWithSignature("aggregate3((address,bool,bytes)[])", calls));

        console.log("flowRate after: %s", uint256(int256(superToken.getFlowRate(address(this), receiver))));
    }

    function notestExecuteMulticall(/*uint256 amount,*/ /*address receiver, int96 flowRate*/) public {
        // fund the catapult contract with 100 tokens
        console.log("token supply: %s", erc20.totalSupply() / 1e18);
        deal(address(erc20), address(catapultL2), uint256(100e18));
        console.log("catapult erc20 balance: %s", erc20.balanceOf(address(catapultL2)));

        uint256 amount = 10e18; //erc20.balanceOf(address(catapultL2));
        console.log("amount to process: %s", amount / 1e18);

        int96 flowRate = 1e9;
        address receiver = 0xC20a5455035Ab593682Cf9b9916b9407cc9e47f3;
        address cfaFwd = 0xcfA132E353cB4E398080B9700609bb008eceB125;
        
        address(catapultL2).delegatecall(abi.encodeWithSignature(
            "executeMulticall3(address,address,address,address,uint256,address,int96)",
            abi.encode(MULTICALL, address(cfaFwd), erc20, superToken, amount, receiver, flowRate)
        ));

        console.log("flowRate after: %s", uint256(int256(superToken.getFlowRate(address(catapultL2), receiver))));
    }

    function workstestExecuteMulticallWithCalldata(/*uint256 amount,*/ /*address receiver, int96 flowRate*/) public {
        // fund the test contract (I feel like a Safe now)
        deal(address(erc20), address(this), uint256(100e18));
        console.log("self erc20 balance: %s", erc20.balanceOf(address(this)));

        uint256 amount = 10e18;
        console.log("amount to process: %s", amount);

        int96 flowRate = 1e9;
        address receiver = 0xC20a5455035Ab593682Cf9b9916b9407cc9e47f3;
        address cfaFwd = 0xcfA132E353cB4E398080B9700609bb008eceB125;
        
        bytes memory data = catapultL2.getMulticall3Calldata(MULTICALL, address(cfaFwd), erc20, superToken, amount, receiver, flowRate);
        IMulticall3 mc3 = IMulticall3(MULTICALL);
        (bool success, bytes memory returnData) = address(mc3).delegatecall(data);

        console.log("flowRate after: %s", uint256(int256(superToken.getFlowRate(address(this), receiver))));

        if (!success) {
            CallUtils.revertFromReturnedData(data);
        }
        //require(success, "multicall failed");
    }

    // let the catapult contract itself hold the funds
    function notestExecuteExtContractMulticall(/*uint256 amount,*/ /*address receiver, int96 flowRate*/) public {
        // fund the test contract
        deal(address(erc20), address(catapultL2), uint256(100e18));
        console.log("catapult erc20 balance: %s", erc20.balanceOf(address(catapultL2)));

        uint256 amount = 10e18;
        console.log("amount to process: %s", amount);

        int96 flowRate = 1e9;
        address receiver = 0xC20a5455035Ab593682Cf9b9916b9407cc9e47f3;
        address cfaFwd = 0xcfA132E353cB4E398080B9700609bb008eceB125;
        
        bytes memory data = catapultL2.getMulticall3Calldata(MULTICALL, address(cfaFwd), erc20, superToken, amount, receiver, flowRate);
        IMulticall3 mc3 = IMulticall3(MULTICALL);
        (bool success, bytes memory returnData) = catapultL2.executeDelegateMultiCall(MULTICALL, data);

        console.log("flowRate after: %s", uint256(int256(superToken.getFlowRate(address(catapultL2), receiver))));
        console.logBytes(data);

        if (!success) {
            CallUtils.revertFromReturnedData(data);
        }
        //require(success, "multicall failed");
    }

    function testSafeConnextReceive() public {
        address CONNEXT;
        address SAFE;
        address MODULE;
        uint32 ORIGIN;
        address ORIGINSENDER;
        CONNEXT = vm.envAddress("CONNEXT");
        SAFE = vm.envAddress("SAFE");
        MODULE = vm.envAddress("MODULE");
        ORIGIN = uint32(vm.envUint("ORIGIN"));
        ORIGINSENDER = vm.envAddress("ORIGINSENDER");

        IXReceiver xr = IXReceiver(MODULE);

        // fund the Safe contract
        deal(address(erc20), SAFE, uint256(100e18));
        console.log("Safe erc20 balance: %s", erc20.balanceOf(SAFE));

        uint256 amount = 1e18;
        console.log("amount to process: %s", amount);

        int96 flowRate = 1e9;
        address receiver = 0xC20a5455035Ab593682Cf9b9916b9407cc9e47f3;
        address cfaFwd = 0xcfA132E353cB4E398080B9700609bb008eceB125;

        bytes memory data = catapultL2.getMulticall3Calldata(MULTICALL, address(cfaFwd), erc20, superToken, amount, receiver, flowRate);

        bytes memory dataForSafe = abi.encode(
            MULTICALL, 
            0, 
            data,
            Enum.Operation.DelegateCall
        );

        vm.startPrank(CONNEXT);
        // bytes32 _transferId, uint256 _amount, address _asset, address _originSender, uint32 _origin, bytes memory _callData) external returns (bytes memory);
        bytes memory ret = xr.xReceive(
            keccak256("randomid"),
            0,
            address(erc20),
            ORIGINSENDER,
            ORIGIN,
            dataForSafe //new bytes(0)
        );
        vm.stopPrank();

        console.log("flowRate after: %s", uint256(int256(superToken.getFlowRate(SAFE, receiver))));
        console.logBytes(data);

        //require(success, "multicall failed");

    }
}