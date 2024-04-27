    pragma solidity ^0.8.13;

    import {Script, console} from "forge-std/Script.sol";
    import {BaseERC20} from "../src/day9/BaseERC20.sol";
    import {MusicNFT} from "../src/day9/MusicNFT.sol";
    import {NFTMarket} from "../src/day9/NFTMarkets.sol";
    contract NFTScript is Script {
        function setUp() public {

        }

        function run() public {
            vm.broadcast();
            BaseERC20 token = new BaseERC20();
            MusicNFT nft = new MusicNFT();
            NFTMarket market = new NFTMarket(address(token), address(nft));

            address sender = 0xC3b0FAafeB7a80D9E3Bfde134972026B61c1F127;
            nft.mint(sender, "ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/1.json");
            nft.mint(sender, "ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/2.json");
        }
    }