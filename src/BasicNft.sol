// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    uint256 private s_tokenCounter;

    constructor() ERC721("BasicNft", "BNFT") {
        s_tokenCounter = 0;
    }

    function mintNft(address to) external {
        s_tokenCounter++;
        _mint(to, s_tokenCounter);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return "";
    }
}