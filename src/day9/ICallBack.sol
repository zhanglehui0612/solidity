// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 定义回调接口
interface ICallBack {
    /*
     * 定义回调函数
     * @param recepient 目标地址
     * @param tokenId NFT的tokenId
     * @param tokens 转移的token数量
     */
    function tokensReceived(address recepient, uint tokenId, uint256 tokens) external returns (bool);
}