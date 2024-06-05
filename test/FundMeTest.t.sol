// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test,console} from  "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../scripts/deployFundMe.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";



contract FundMeTest is Test {
    FundMe public fundme;
    address dummyOwner = makeAddr("dummyOwner");
    uint256 constant SEND_VAL = 0.1 ether;
    uint256 constant STARTING_BAL = 10 ether;

    //moddifiers

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(dummyOwner, STARTING_BAL);
        
    }
    function testDemo() public{
        console.log("fundme");
        assertEq(fundme.MINIMUM_USD(), 5*10**18);
    }
    function testPriceFeedVersion() public {
        uint256 version = fundme.getVersion();
        assertEq(version , 4);

    }
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundme.fund();
    }
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(dummyOwner);
        fundme.fund{value : SEND_VAL}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(dummyOwner);
        assertEq(amountFunded,SEND_VAL); 
    }
    function testAddsFunderToArrayOfFunders() public{
        vm.prank(dummyOwner);
        fundme.fund{value:SEND_VAL}();

        address funder = fundme.getFunder(0);
        assertEq(funder, dummyOwner);
    }
    function testOnlyOwnerCanWithdraw() public funded {
        
        vm.expectRevert();
        vm.prank(dummyOwner);
        fundme.withdraw();

    }
    function testWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;

        assertEq(endingFundmeBalance, 0);

        assertEq(startingOwnerBalance + startingFundmeBalance, endingOwnerBalance);


    }

    modifier funded(){
        vm.prank(dummyOwner);
        fundme.fund{value:SEND_VAL}();
        _;
    }
    function testWithdrawFromMultipleFunders() public funded{
        // console.log("initial fundme balance :" , address(fundme).balance);
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for(uint160 i = startingFunderIndex;i < numberOfFunders + startingFunderIndex;i++){


            hoax(address(i),STARTING_BAL);
            console.log(address(i));
             fundme.fund{value:SEND_VAL}();

        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        console.log("starting owner balance : ",startingOwnerBalance);
        uint256 startingFundMeBalance = address(fundme).balance;
        console.log("startingFundmeBalance : ", startingFundMeBalance);

        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        assertEq(address(fundme).balance, 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundme.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VAL == fundme.getOwner().balance - startingOwnerBalance);


    }
 
 }