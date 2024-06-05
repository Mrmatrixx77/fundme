// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.s.sol";
import {Script} from "forge-std/Script.sol";



contract HelperConfig is Script{
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; 

    struct NetworkConfig {
        address priceFeed;
    }

    constructor(){
        if(block.chainid == 111555111){
            activeNetworkConfig = getSepoliaConfig();
        }else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaConfig() public pure  returns(NetworkConfig memory sepoliaNetworkConfig){
        sepoliaNetworkConfig = NetworkConfig({
            priceFeed :  0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory anvilNetworkConfig){
         if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
         }
        //  vm.startBroadcast();
        //  MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
        //     DECIMALS,
        //     INITIAL_PRICE
        //  );

        //  vm.stopBroadcast();
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
         anvilNetworkConfig = NetworkConfig({
            priceFeed : address(mockPriceFeed)
         });

         


    }
}