// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BaseERC20} from "../src/day8/BaseERC20.sol";

contract BaseERC20Script is Script {

    function setUp() public {

    }

    function run() public {
        vm.broadcast(); // 开始记录脚本中合约的调用和创建
        BaseERC20 token = new BaseERC20(); // 创建合约
    }
}