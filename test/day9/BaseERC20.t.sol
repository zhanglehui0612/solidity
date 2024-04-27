// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {BaseERC20} from  "../../src/day9/BaseERC20.sol";
import "../../src/day9/MusicNFT.sol";
import "../../src/day9/NFTMarkets.sol";


contract BaseERC20Test is Test {
    BaseERC20 baseERC20;
    MusicNFT musicNFT;
    NFTMarket market;
    address ercOwner = makeAddr("Amy");
    address nftOwner = makeAddr("Halo");
    address other = makeAddr("Random");

    function setUp() public {
        vm.prank(ercOwner);
        baseERC20 = new BaseERC20();

        vm.prank(nftOwner);
        musicNFT = new MusicNFT();

        vm.prank(other);
        market = new NFTMarket(address(baseERC20), address(musicNFT));
    }

    /**
     * 测试BaseERC20的approve函数
     */
    function testBaseERC20Approve() public {
        vm.prank(ercOwner);
        assertTrue(baseERC20.approve(address(market), 1000000000));

        vm.prank(other);
        assertTrue(baseERC20.approve(address(market), 1000000000));
    }

    /**
     * 测试BaseERC20的balanceOf函数
     */
    function testBaseERC20BalanceOf() public {
        assertTrue(baseERC20.balanceOf(ercOwner) > 0);
        assertFalse(baseERC20.balanceOf(other) > 0);
    }

    /**
     * 测试BaseERC20的allowance函数
     */
    function testBaseERC20Allowance() public {
        vm.prank(ercOwner);
        baseERC20.approve(address(market), 1000000000);
        assertEq(baseERC20.allowance(ercOwner, address(market)), 1000000000);
        assertNotEq(baseERC20.allowance(ercOwner, address(market)), 2000000000);

        vm.prank(other);
        baseERC20.approve(address(market), 100000000000000);
        assertEq(baseERC20.allowance(other, address(market)), 100000000000000);
        assertNotEq(baseERC20.allowance(other, address(market)), 200000000000000);

    }

    /**
     * 测试BaseERC20的transfer函数
     */
    function testBaseERC20Transfer() public {
        vm.prank(ercOwner);
        vm.expectRevert("BaseERC20: invalid sender");
        baseERC20.transfer(address(0), 10000000);

        vm.prank(other);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        baseERC20.transfer(address(market), 10000000);

        vm.prank(ercOwner);
        assertTrue(baseERC20.transfer(address(market), 10000000));
    }

    /**
     * 测试BaseERC20的transferFrom函数
     */
    function testBaseERC20TransferFrom() public {
        vm.expectRevert("BaseERC20: invalid sender or recepient address");
        baseERC20.transferFrom(ercOwner, address(0), 10000000);

        vm.expectRevert("ERC20: transfer amount exceeds balance");
        baseERC20.transferFrom(other, address(market), 10000000);

        vm.prank(address(market));
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        baseERC20.transferFrom(ercOwner, address(market), 10000000);

        vm.prank(ercOwner);
        baseERC20.approve(address(market), 1000000000);
        
        vm.prank(address(market));
        assertTrue(baseERC20.transferFrom(ercOwner, address(market), 100000));
    }

    /**
     * 测试BaseERC20的transferCallback函数
     */
    function testBaseERC20TransferCallback() public {
        // 对tokenId进行编码
        bytes memory data = abi.encode(1);

        // 没有BaseERC20余额的用户，转账失败
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        baseERC20.transferWithCallback(other, address(market), 10000, data);


        // 用户有钱, 但是转账的不是合约地址，不会调用NFTMarket的tokensReceived函数
        // vm.expectEmit(address(baseERC20));
        vm.startPrank(ercOwner);
        // 没有mint和上架期望报错
        vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 1));
        baseERC20.transferWithCallback(ercOwner, address(market), 10000, data);
        vm.stopPrank();

        // mint nft
        vm.startPrank(nftOwner);
        musicNFT.mint(nftOwner,"ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/1.json");
        musicNFT.approve(address(market), 1);
        market.list(1, 10000);
        vm.stopPrank();

        vm.startPrank(ercOwner);
        // 未对NFT Market授权BaseERC20的权限, 购买失败
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        baseERC20.transferWithCallback(ercOwner, address(market), 10000, data);

        // 对NFT Market授权BaseERC20的权限, 购买成功
    
        baseERC20.approve(address(market), 1000000000);

        vm.expectEmit(address(market));
        emit TransferCallback();
        baseERC20.transferWithCallback(ercOwner, address(market), 10000, data);
        vm.stopPrank();
    }
}