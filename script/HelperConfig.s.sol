//SPDX-License-Identifier：MIT

/**
 * 1.当我们使用本地链时候会调用mock
 * 2.跟踪不同合约的跨链行为
 *
 */
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //如果是本地链我们就需要自己去部署mock合约
    NetworkConfig public activateNetwork;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activateNetwork = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activateNetwork = getMainnetEthConfig();
        } else {
            activateNetwork = getLocalEthconfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory networkConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return networkConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory networkConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return networkConfig;
    }

    function getLocalEthconfig() public returns (NetworkConfig memory) {
        //price feed address
        //1.deplpy mocks
        //2.return the mock address
        if (activateNetwork.priceFeed != address(0)) return activateNetwork;

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory networkConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return networkConfig;
    }
}
