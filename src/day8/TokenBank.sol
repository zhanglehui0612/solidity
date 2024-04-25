// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseERC20.sol";

contract TokenBank {
    // 存储每一个地址对应的token数量
    mapping (address => uint256) deposits;

    BaseERC20 baseERC20;

    constructor(address _baseERC20) {
        baseERC20 = BaseERC20(_baseERC20);
    }

    /*
     * 用户授权Token Bank从BaseERC20可以转到Token Bank的token数量
     * @param tokens token数量
     */
    function deposit(uint256 tokens) public {
        // 该用户token足够且授权的token足够，则允许将用户在BaseERC20中的代币转到TokenBank
        baseERC20.transferFrom(msg.sender, address(this), tokens);
        deposits[msg.sender] += tokens;
    }

    /*
     * 用户可以从Token Bank取出的token数量
     * @param tokens token数量
     */
    function withdraw(uint256 tokens) public {
        require(deposits[msg.sender] >= tokens, "TokenBank: No suffcient tokens");
        baseERC20.transfer(msg.sender, tokens);
        deposits[msg.sender] -= tokens;
    }


    /*
     * 定义回调函数函数需要调用的tokensReceived函数
     * @param _from 持有代币的用户
     * @param tokens 转入TokenBank的代币数量
     */
    function tokensReceived(address from, uint256 tokens) external returns (bool) {
        require(msg.sender == address(baseERC20), "Only BaseERC20 contract could execute!");
        deposits[from] += tokens;
        return true;
    }
}