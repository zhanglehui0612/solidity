    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

    contract MusicNFT is ERC721URIStorage {
        uint256 counter;
        constructor() ERC721("MusicNFT", "MNFT") {}

        event NFT_MINT(address indexed sender, uint256 tokenId, string tokenURI);

        function mint(address sender, string memory tokenURI) public returns (uint256) {
            counter++;
            uint256 newItemId = counter;
            _mint(sender, newItemId);
            _setTokenURI(newItemId, tokenURI);
            emit NFT_MINT(sender, newItemId, tokenURI);
            return newItemId;
        }
    }