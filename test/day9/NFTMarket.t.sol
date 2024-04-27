// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {IERC20Errors, IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import "../../src/day9/BaseERC20.sol";
import "../../src/day9/MusicNFT.sol";
import "../../src/day9/NFTMarkets.sol";

contract NFTMarketTest is Test {
    BaseERC20 baseERC20;
    MusicNFT musicNFT;
    NFTMarket market;
    address ercOwner = makeAddr("Frank");
    address nftOwner = makeAddr("Lucia");
    address other = makeAddr("Belly");
    function setUp() public {
        vm.prank(ercOwner);
        baseERC20 = new BaseERC20();

        vm.prank(nftOwner);
        musicNFT = new MusicNFT();

        vm.prank(other);
        market = new NFTMarket(address(baseERC20), address(musicNFT));
        
    }

function Aa() internal {}
    /**
     * 测试NFTMarket的list函数
     */
    function testNFTMarketList() public {
        // 告诉VM 期望下次调用返回ERC721NonexistentToken错误
        vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 1));
        market.list(1, 10000);

        // mint nft
        musicNFT.mint(nftOwner,"ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/1.json");
        vm.startPrank(other);

        // 告诉VM 期望下次调用返回ERC721NonexistentToken错误
        vm.expectRevert(abi.encodeWithSignature("ERC721InsufficientApproval(address,uint256)", address(market), 1));
        market.list(1, 10000);
        vm.stopPrank();

        vm.startPrank(nftOwner);
        musicNFT.approve(address(market), 1);
        market.list(1, 100000);
    }

    /**
     * 测试NFTMarket的buy函数
     */
    function testNFTMarketBuy() public {
        // 测试tokenId不存在
        vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 1));
        // vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, 1));
        market.buy(1, 10000);

        // mint nft
        musicNFT.mint(nftOwner,"ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/1.json");
        vm.expectRevert("Music NFT have aleady been selled");
        market.buy(1, 10000);

        // 进行授权和上架
        vm.startPrank(nftOwner);
        musicNFT.approve(address(market), 1);
        market.list(1, 10000);
        vm.stopPrank();

        // Token数量不够，无法购买
        vm.expectRevert("Music NFT cann not be buyed since price is lower");
        market.buy(1, 1000);

        // 没有对NFT Market授权BaseERC20的权限，无法购买
        vm.startPrank(ercOwner);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        market.buy(1, 10000);

        // 对NFT Market授权BaseERC20的权限, 购买成功
        baseERC20.approve(address(market), 1000000000);
        market.buy(1, 10000);
    }
}