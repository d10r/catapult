// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { 
    ISuperToken,
    ISuperfluid,
    BatchOperation
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { IConstantFlowAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

interface IMulticall3 {
  struct Call3 {
    address target;
    bool allowFailure;
    bytes callData;
  }
 
  struct Result {
    bool success;
    bytes returnData;
  }

  function aggregate3(Call3[] calldata calls) external payable returns (Result[] memory returnData);
}

// Helper contract for the Catapult, useful for testing.
// For the actual Catapult operations, it is not needed.
contract CatapultL2 {
    using SuperTokenV1Library for ISuperToken;

    // amount refers to the erc20
    function executeSteps(IERC20 erc20, ISuperToken superToken, uint256 amount, address receiver, int96 flowRate) public {
        require(erc20.balanceOf(address(this)) >= amount, "amount exceeds balance");
        require(superToken.getUnderlyingToken() == address(erc20), "SuperToken wrapper mismatch");

        erc20.approve(address(superToken), amount);
        // TODO: check if we need to convert if underlying decimals isn't 18
        superToken.upgrade(amount);

        if (flowRate > 0) {
            // open or update a stream
            int96 oldFlowRate = superToken.getFlowRate(address(this), receiver);
            if (oldFlowRate > 0) {
                superToken.updateFlow(receiver, flowRate);
            } else {
                superToken.createFlow(receiver, flowRate);
            }
        }
    }

    function executeBatch(IERC20 erc20, ISuperToken superToken, uint256 amount, address receiver, int96 flowRate) public {
        require(erc20.balanceOf(address(this)) >= amount, "amount exceeds balance");
        require(superToken.getUnderlyingToken() == address(erc20), "SuperToken wrapper mismatch");

        erc20.approve(address(superToken), amount);

        ISuperfluid host = ISuperfluid(superToken.getHost());
        IConstantFlowAgreementV1 cfa = IConstantFlowAgreementV1(address(ISuperfluid(host).getAgreementClass(
                //keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1")
                0xa9214cc96615e0085d3bb077758db69497dc2dce3b2b1e97bc93c3d18d83efd3)));

        int96 oldFlowRate = superToken.getFlowRate(address(this), receiver);

        ISuperfluid.Operation[] memory ops = new ISuperfluid.Operation[](2);

        ops[0] = ISuperfluid.Operation({
            operationType: BatchOperation.OPERATION_TYPE_SUPERTOKEN_UPGRADE,
            target: address(superToken),
            data: abi.encode(amount)
        });

        ops[1] = ISuperfluid.Operation({
            operationType: BatchOperation.OPERATION_TYPE_SUPERFLUID_CALL_AGREEMENT,
            target: address(cfa),
            data: abi.encode(
                abi.encodeCall(
                    oldFlowRate > 0 ? cfa.createFlow : cfa.createFlow,
                    (
                        superToken,
                        receiver,
                        flowRate,
                        new bytes(0) // placeholder
                    )
                ),
                "0x" // userData
            )
        });

        host.batchCall(ops);
    }

    function executeMulticall3(address multicallAddr, address cfaFwd, IERC20 erc20, ISuperToken superToken, uint256 amount, address receiver, int96 flowRate) public {
        IMulticall3 mc3 = IMulticall3(multicallAddr);
        IMulticall3.Call3[] memory calls = new IMulticall3.Call3[](3);
        calls[0] = IMulticall3.Call3(address(erc20), true, abi.encodeWithSignature("approve(address,uint256)", abi.encode(address(superToken), amount)));
        calls[1] = IMulticall3.Call3(address(superToken), true, abi.encodeWithSignature("upgrade(uint256)", amount));
        calls[2] = IMulticall3.Call3(
            address(cfaFwd), 
            true, 
            abi.encodeWithSignature("setFlowrate(address,address,int96)", abi.encode(address(superToken), receiver, flowRate))
        );
        mc3.aggregate3(calls);
    }

    function getMulticall3Calldata(address multicallAddr, address cfaFwd, IERC20 erc20, ISuperToken superToken, uint256 amount, address receiver, int96 flowRate) 
        public pure returns(bytes memory)
    {
        IMulticall3 mc3 = IMulticall3(multicallAddr);
        IMulticall3.Call3[] memory calls = new IMulticall3.Call3[](3);
        calls[0] = IMulticall3.Call3(address(erc20), false, abi.encodeWithSignature("approve(address,uint256)", address(superToken), amount));
        calls[1] = IMulticall3.Call3(address(superToken), false, abi.encodeWithSignature("upgrade(uint256)", amount));
        calls[2] = IMulticall3.Call3(
            address(cfaFwd), 
            false, 
            abi.encodeWithSignature("setFlowrate(address,address,int96)", address(superToken), receiver, flowRate)
        );

        return abi.encodeCall(mc3.aggregate3, calls);
    }

    function executeDelegateMultiCall(address target, bytes memory data) public returns(bool, bytes memory) {
        return target.delegatecall(data);
    }
}

// what's annoying:
// * no setFlowRate or createOrUpdateFlow
// * ISuperfluid.sol doesn't include everything needed
// * ISuperToken isn't in interfaces/supertoken
// * SuperTokenV1Library isn't in interfaces/supertoken
