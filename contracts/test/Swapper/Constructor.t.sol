// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.24;

import "./SwapperTest.t.sol";

contract Constructor is SwapperTest {
    function test_constructor_Normal() public {
        assertEq(swapper.swapRouter(), augustusSwapper, "SwapRouter should be augustusSwapper");
        assertEq(
            swapper.tokenTransferAddress(), tokenTransferAddress, "TokenTransferAddress should be tokenTransferAddress"
        );
    }

    function test_constructor_ZeroAddressSwapRouter() public {
        vm.expectRevert(Errors.ZeroAddress.selector);
        new Swapper(owner, address(0), tokenTransferAddress);
    }

    function test_constructor_ZeroAddressTokenTransferAddress() public {
        vm.expectRevert(Errors.ZeroAddress.selector);
        new Swapper(owner, augustusSwapper, address(0));
    }
}
