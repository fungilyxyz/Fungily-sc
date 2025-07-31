// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {FungilyCollectionFactory} from "../src/Fungily-NFTs-Launchpad/Fungily.sol";

contract Deploy is Script {
    function run() public {
        address initialFeeReceiver = 0x7cC8F5d78acfaa517eA62C5C579241eD9E1D190b; // Replace with actual address
        uint256 initialPlatformMintFee = 0.0005 ether; // Example mint fee
        uint16 initialPlatformSalesFeeBps = 500; // Example sales fee in basis points (2.5%)

        vm.startBroadcast();
        FungilyCollectionFactory factory =
            new FungilyCollectionFactory(initialFeeReceiver, initialPlatformMintFee, initialPlatformSalesFeeBps);

        vm.stopBroadcast();

        // Additional setup or configuration can be done here if needed
    }
}
