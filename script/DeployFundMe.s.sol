//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/fundme.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is
    Script //一般都这样写vmstart vmstop
{
    function run() external returns (FundMe) {
        //在startBroadcast之前被视为not a real tx
        HelperConfig helperConfig = new HelperConfig();
        address PriceFeed = helperConfig.activateNetwork();
        vm.startBroadcast();
        //模拟链 如果没有用测试网
        FundMe fundme = new FundMe(PriceFeed);
        vm.stopBroadcast();
        return fundme;
    }
}
