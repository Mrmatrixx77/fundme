// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../scripts/deployFundMe.s.sol";
import {FundFundme,WithdrawFundMe} from "../../scripts/interactions.s.sol";

contract interaction is Test{
    FundMe fundMe;

    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;
    address USER = makeAddr("user");

    function setUp() external{
        DeployFundMe deploy  = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    
    function testUserCanFundAndOwnerWithdraw() public  {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }

}