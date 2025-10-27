// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {BasicNft} from "../src/BasicNft.sol";

contract MintBasicNft is Script {
    string public constant PUB = "ipfs://QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG";

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("BasicNft", block.chainid);
        console.log("The most recent BasicNft contract deployed is at:", mostRecentDeployed);
        mintNftOnContract(mostRecentDeployed);
    }

    function mintNftOnContract(address basicNftAddress) internal {
        vm.startBroadcast();
        BasicNft(basicNftAddress).mintNft(PUB);
        vm.stopBroadcast();
    }
}