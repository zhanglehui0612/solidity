    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

    contract MusicNFT is ERC721URIStorage {
        uint256 counter;
        constructor() ERC721("MusicNFT", "MNFT") {}

        function mint(address sender, string memory tokenURI) public returns (uint256) {
            counter++;
            uint256 newItemId = counter;
            _mint(sender, newItemId);
            _setTokenURI(newItemId, tokenURI);
            return newItemId;
        }
    }