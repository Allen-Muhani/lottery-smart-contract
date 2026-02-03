// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle raffle, HelperConfig helperConfig) {
        helperConfig = new HelperConfig();

        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint256 subscriptionId,
            ,
            address linkToken

        ) = helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(
                vrfCoordinator
            );
        }

        vm.startBroadcast();
        raffle = new Raffle(
            entranceFee,
            interval,
            subscriptionId,
            vrfCoordinator,
            gasLane
        );
        vm.stopBroadcast();
    }
}
