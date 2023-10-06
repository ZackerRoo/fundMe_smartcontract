// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/fundme.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

/**
 * @title
 * @author
 * @notice 需要你导入的合约名称是一模一样的不能自己改名
 */
contract FundmeTest is Test {
    uint256 number = 1;
    FundMe fundme;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BALANCE = 10 ether;
    address USER = makeAddr("USER");
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // number = 2;
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(USER, START_BALANCE);
    }

    function testDemoMiniDollar() public {
        // console.log(number);
        // assertEq(number, 2);
        assertEq(fundme.MINIMUM_USD(), 5e18);
        // console.log(number);
    }

    // /**
    //  * 有四个测试的方法分别是
    //  * 1.Unit test
    //  *      测试一个具体的函数或者是我们代码的一部分
    //  * 2.Integration
    //  *      测试我们的代码与其他代码的交互是如何运作的
    //  * 3.Forked
    //  *      测试我们的代码在模拟的环境上进行测试
    //  * 4.Staging
    //  *      测试我们的代码在一个真实的环境进行测试
    //  */

    function testOwnerIsMsgSender() public {
        // us --> fundmeTest -->fundme
        console.log(fundme.i_owner());
        console.log(msg.sender);
        assertEq(fundme.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); //这个表示下面的行为要fail才会pass如果下面行为true就不会fail
        fundme.fund();
    }

    function testFundupdatesFundedDataStructure() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayFunders() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier Fundme() {
        vm.prank(USER); //这个只能保证下面一行代码或者一个交易是由USER发起的
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testwithdrawmoney() public Fundme {
        // vm.prank(USER); //这个只能保证下面一行代码或者一个交易是由USER发起的
        // fundme.fund{value: SEND_VALUE}();

        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithdrawallmoneyBysingleFunder() public Fundme {
        //arrage
        uint256 startOwneramount = fundme.getOwner().balance;
        uint256 startFundmeamount = address(fundme).balance;
        //Act
        uint256 gasstart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getOwner());
        fundme.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasstart - gasEnd) * GAS_PRICE;
        console.log(gasUsed);
        //assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startOwneramount + startFundmeamount, endingOwnerBalance);
    }

    function testcheaperWithdrawallmoneyBysingleFunder() public Fundme {
        //arrage
        uint256 startOwneramount = fundme.getOwner().balance;
        uint256 startFundmeamount = address(fundme).balance;
        //Act
        uint256 gasstart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundme.getOwner());
        fundme.cheaperWithdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasstart - gasEnd) * GAS_PRICE;
        console.log(gasUsed);
        //assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startOwneramount + startFundmeamount, endingOwnerBalance);
    }

    function testwithdrawwithMultipleFunders() public Fundme {
        //arrage
        uint160 numberofFunders = 10;
        uint160 indexofstart = 1;
        for (uint160 i = indexofstart; i < numberofFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
        uint256 startownerbalance = fundme.getOwner().balance;
        uint256 startFundMebalance = address(fundme).balance;
        //Act
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();
        //assert
        assert(address(fundme).balance == 0);
        assert(
            startownerbalance + startFundMebalance == fundme.getOwner().balance
        );
    }
}
