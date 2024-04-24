    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.0;

    import "@openzeppelin/contracts/utils/Counters.sol";
    import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

    contract MusicNFT is ERC721URIStorage {
        using Counters for Counters.Counter;
        Counters.Counter private tokenIds;
        constructor() ERC721("MusicNFT", "MNFT") {}

        function mint(address music, string memory tokenURI) public returns (uint256) {
            tokenIds.increment();
            uint256 newItemId = tokenIds.current();
            _mint(music, newItemId);
            _setTokenURI(newItemId, tokenURI);
            return newItemId;
        }
    }