// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 定义回调接口
interface TokenHook {
    /*
     * 定义回调函数
     * @param recepient 目标地址
     * @param tokens 转移的token数量
     * @param data 传递的数据
     */
    function tokensReceived(address recepient, uint256 tokens, bytes memory data) external returns (bool);
}