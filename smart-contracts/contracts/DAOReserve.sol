//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./FloatingMaths.sol";

// start-snippet: token import
import "./FNDRToken.sol";

// end-snippet: token import

// start-snippet: Unlockable reserve name
contract DAOReserve is Ownable {
    // end-snippet: Unlockable reserve name

    // start-snippet: token definition
    FNDRToken public token;
    // end-snippet: token definition

    uint public cliff;
    uint immutable vesting_period;
    uint immutable vesting_percentage;
    uint immutable deployDate;

    constructor(address _token) {
        // start-snippet: init definitions
        token = FNDRToken(_token);
        cliff = 365;
        vesting_period = 0;
        vesting_percentage = 100;
        // end-snippet: init definitions
        deployDate = block.timestamp;
    }

    event Distribute(address indexed to, uint256 amount, uint256 nextCliff);

    /*
     * @dev Distributes the vesting percentage of the token it contains to owner.
     * Can only be called at most once every per vesting period.
     */
    function distribute() public onlyOwner {
        uint lastPeriod = deployDate + cliff * 1 days;
        require(
            block.timestamp >= lastPeriod,
            string(
                abi.encodePacked(
                    "Need to wait ",
                    Strings.toString(vesting_period),
                    " days after last distribution"
                )
            )
        );
        uint availableAmount = (token.balanceOf(address(this)) *
            vesting_percentage) / 100;
        token.transfer(owner(), availableAmount);
        cliff += vesting_period;
        emit Distribute(owner(), availableAmount, cliff);
    }
}
