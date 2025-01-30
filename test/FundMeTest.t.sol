//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {FundMeScript} from "../script/FundMeScript.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); //Cheat code for creating a fake user address.
    uint256 constant SEND_VALUE = 0.1 ether; //100000000000000000 wei 17 zeros.
    uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() external {
        FundMeScript fundMeScript = new FundMeScript();
        fundMe = fundMeScript.run();
        vm.deal(USER, STARTING_BALANCE); // vm.deal is a cheat code to give the user some ether. or set user balance.
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testMsgSenderIsOwner() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutETH() public {
        vm.expectRevert(); // hey, after this line should revert or fail to pass the test!
        fundMe.fund(); //sending 0 value
    }

    function testFundUpdateDataFunded() public {
        vm.prank(USER); //The next transaction will be from this user.
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }
}
