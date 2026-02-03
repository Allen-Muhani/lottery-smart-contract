// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "chainlink-brownie-contracts/contracts/src/v0.8/shared/token/ERC677/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , , ) = helperConfig
            .activeNetworkConfig();

        return createSubscription(vrfCoordinator);
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint256) {
        console.log("Creating subsribption on chain id:", block.chainid);
        vm.startBroadcast();
        uint256 subscriptionId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Subscription created!", subscriptionId);
        console.log(
            "Please update the subscriptionId in the HelperConfig.s.sol"
        );
        return subscriptionId;
    }

    function run() external returns (uint256) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 1 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint256 subscriptionId,
            ,
            address linkToken
        ) = helperConfig.activeNetworkConfig();

        fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address linkToken
    ) public {
        console.log("Funding subscription:", subscriptionId);
        console.log("Using VRF coordinator:", vrfCoordinator);
        console.log("On chainb ID", block.chainid);

        if (block.chainid == 31337) {
            console.log("Using mock link token");
            vm.startBroadcast();
            // Implementation to fund subscription
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            console.log("Using real link token");
            vm.startBroadcast();
            // Implementation to fund subscription with real link token
            // Assumes LinkToken has a transferAndCall function
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(address consumerAddress) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint256 subscriptionId,
            ,

        ) = helperConfig.activeNetworkConfig();

        addConsumerToSubscription(vrfCoordinator, subscriptionId, consumerAddress);
    }

    function addConsumerToSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address consumerAddress
    ) public {
       console.log("Adding consumer : ", consumerAddress);
        console.log("to VRF coordinator : ", vrfCoordinator);
        console.log("to subscription id : ", subscriptionId);

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subscriptionId,
            consumerAddress
        );
        vm.stopBroadcast();
    }

    function run(address consumerAddress) external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumer(raffle);
    }
}
