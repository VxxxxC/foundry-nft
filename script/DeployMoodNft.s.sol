// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployMoodNft is Script {
    constructor(){}

    function run() external returns(MoodNft) {
        string memory happySvg = vm.readFile("./img/happySvg.svg");
        string memory sadSvg = vm.readFile("./img/sadSvg.svg");

        console.log("Happy SVG:", happySvg);
        console.log("Sad SVG:", sadSvg);
    }

    function svgToImageURI(string memory svg) public pure returns(string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

}
