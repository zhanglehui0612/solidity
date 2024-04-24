// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseERC20.sol";
import "./MusicNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMarket is IERC721Receiver{

    BaseERC20 baseERC20;

    MusicNFT music;

    mapping(uint => uint256) tokenPrices;

    mapping (uint => address) sellers;



    constructor(address _baseERC20, address _music) {
        baseERC20 = BaseERC20(_baseERC20);
        music = MusicNFT(_music);
    }

    /**
     * 当合约接收到ERC721代币时，ERC721合约会调用`onERC721Received`函数来通知合约
     * 通过重载`onERC721Received`函数，合约可以执行自定义的逻辑来处理接收到的ERC721代币
     * 在重载`onERC721Received`函数时，需要确保函数的返回值为`bytes4`类型，并且返回值为`this.onERC721Received.selector`，这样可以确保函数符合ERC721接口中定义的规范。
     * 1. 确认接收者是否有权接收该 NFT。
     * 2. 更新 NFT 的所有权信息。
     * 3. 触发事件通知其他合约或用户 NFT 的转移。
     * 4. 执行其他必要的逻辑，例如记录 NFT 的交易历史或更新 NFT 的元数据
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external override returns (bytes4) {
      return this.onERC721Received.selector;
    }

    /**
     * 购买NFT
     * @param tokenId NFT唯一标识
     * @param amount NFT用BaseERC20表示的价格数量
     */
    function buy(uint tokenId, uint amount) external {
        require(music.ownerOf(tokenId) == address(this), "Music NFT have aleady been selled");
        require(amount >0 && amount >= tokenPrices[tokenId], "Music NFT cann not be buyed since price is lower");
        // 方案1:
        // 先将用户转移指定数量的token到当前合约账户
        // baseERC20.transferFrom(msg.sender, address(this), tokenPrices[tokenId]);
        // 然后再从当前合约转给原NFT的ownerId
        // baseERC20.transfer(sellers(tokenId), tokenPrices[tokenId]);

        // 方案2:
        // 将按照上架价格的数量的BaseERC20转给原NFT的持有者,前提是需要授权给当前合约
        baseERC20.transferFrom(msg.sender, sellers[tokenId], tokenPrices[tokenId]);
        // 将NFT的所有权转给购买者
        music.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /**
     * NFT上架
     * @param tokenId NFT唯一标识
     * @param amount NFT用BaseERC20表示的价格数量
     */
    function list(uint tokenId, uint amount) external {
        // 用户要上架tokenId对应的
        // require(ownerOf(tokenId) == msg.sender, "Not the owner of the NFT, can not allowed be to list");
        // EOA用户将NFT授权给当前合约
        music.safeTransferFrom(msg.sender, address(this), tokenId);
        // 将该NFT设置价格
        tokenPrices[tokenId] = amount;
        // 更新当前NFT的卖家地址
        sellers[tokenId] = msg.sender;
    }


    /*
     * 定义回调函数函数需要调用的tokensReceived函数
     * @param from 持有代币的用户
     * @param tokenId NFT的tokeId
     * @param tokens 转入TokenBank的代币数量
     */
    function tokensReceived(address from, uint tokenId, uint256 tokens) external returns (bool) {
        require(tokenPrices[tokenId] <= tokens, "Have no engough tokens");
        baseERC20.transfer(sellers[tokenId], tokenPrices[tokenId]);
        music.safeTransferFrom(address(this), from, tokenId);
    }
}