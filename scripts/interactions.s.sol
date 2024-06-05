// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script,console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol"; 

contract FundFundme is Script{
    uint256 SEND_VAL = 0.01 ether;

    function fundfundme(address _mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(_mostRecentlyDeployed)).fund{value:SEND_VAL}();
        vm.stopBroadcast();
        console.log("funded dunf me with %s", SEND_VAL);
    }
    function run() external{
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundfundme(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}