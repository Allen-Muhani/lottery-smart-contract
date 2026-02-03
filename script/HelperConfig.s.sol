// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "chainlink-brownie-contracts/contracts/src/v0.8/shared/token/ERC677/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        address linkToken; // the link token address
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreatAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30, // 30 seconds.
                vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                subscriptionId: 115225673082022381584097920524979586788845790511538044528130011264584714022022,
                callbackGasLimit: 500_000, //500,000 gass
                linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789
            });
    }

    /**
     * Dploys a virf corinator mock an generates the Networkconfig details for anvil.
     */
    function getOrCreatAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.002 ether;

        uint96 gasPriceLink = 40 gwei; // 0.00000004 LINK per gas

        int256 weiPerUnitLink = 0.004 ether; // 0.0000005 ETH per LINK


        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(
            baseFee,
            gasPriceLink,
            weiPerUnitLink
        );

        // deploy a mock erc-677 link token
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30, // 30 seconds.
            vrfCoordinator: address(vrfCoordinatorMock),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0, //will add from script
            callbackGasLimit: 500_000, //500,000 gass
            linkToken: address(linkToken)
        });
    }
}
