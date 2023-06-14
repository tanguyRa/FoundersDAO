// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../FloatingMaths.sol";

contract MathMock {
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return FMaths.add(a, b);
    }

    function add_out(
        uint256 a,
        uint256 b,
        uint8 decimals
    ) public pure returns (uint256) {
        return FMaths.add(a, b, decimals);
    }

    function add_decimals(
        uint256 a,
        uint256 b,
        uint8 decimalsA,
        uint8 decimalsB
    ) public pure returns (uint256) {
        return FMaths.add(a, b, decimalsA, decimalsB);
    }

    function add_decimals_out(
        uint256 a,
        uint256 b,
        uint8 decimalsA,
        uint8 decimalsB,
        uint8 decimalsOut
    ) public pure returns (uint256) {
        return FMaths.add(a, b, decimalsA, decimalsB, decimalsOut);
    }

    function sub(uint256 a, uint256 b) public pure returns (uint256) {
        return FMaths.sub(a, b);
    }

    function sub_out(
        uint256 a,
        uint256 b,
        uint8 decimals
    ) public pure returns (uint256) {
        return FMaths.sub(a, b, decimals);
    }

    function sub_decimals(
        uint256 a,
        uint256 b,
        uint8 decimalsA,
        uint8 decimalsB
    ) public pure returns (uint256) {
        return FMaths.sub(a, b, decimalsA, decimalsB);
    }

    function sub_decimals_out(
        uint256 a,
        uint256 b,
        uint8 decimalsA,
        uint8 decimalsB,
        uint8 decimalsOut
    ) public pure returns (uint256) {
        return FMaths.sub(a, b, decimalsA, decimalsB, decimalsOut);
    }

    function mult(uint256 a, uint256 b) public pure returns (uint256) {
        return FMaths.mul(a, b);
    }

    function mult_out(
        uint256 a,
        uint256 b,
        uint8 decimals
    ) public pure returns (uint256) {
        return FMaths.mul(a, b, decimals);
    }

    function mult_decimals(
        uint256 a,
        uint256 b,
        uint8 decimalsA,
        uint8 decimalsB
    ) public pure returns (uint256) {
        return FMaths.mul(a, b, decimalsA, decimalsB);
    }

    function mult_decimals_out(
        uint256 a,
        uint256 b,
        uint8 decimalsA,
        uint8 decimalsB,
        uint8 decimalsOut
    ) public pure returns (uint256) {
        return FMaths.mul(a, b, decimalsA, decimalsB, decimalsOut);
    }

    function div(uint256 a, uint256 b) public pure returns (uint256) {
        return FMaths.div(a, b);
    }

    function div_out(
        uint256 a,
        uint256 b,
        uint8 decimals
    ) public pure returns (uint256) {
        return FMaths.div(a, b, decimals);
    }

    function div_decimals(
        uint256 a,
        uint256 b,
        uint8 decimalsA,
        uint8 decimalsB
    ) public pure returns (uint256) {
        return FMaths.div(a, b, decimalsA, decimalsB);
    }

    function div_decimals_out(
        uint256 a,
        uint256 b,
        uint8 decimalsA,
        uint8 decimalsB,
        uint8 decimalsOut
    ) public pure returns (uint256) {
        return FMaths.div(a, b, decimalsA, decimalsB, decimalsOut);
    }

    function sqrt(uint256 a) public pure returns (uint256) {
        return FMaths.sqrt(a);
    }

    function sqrt_out(
        uint256 a,
        uint8 decimalsA
    ) public pure returns (uint256) {
        return FMaths.sqrt(a, decimalsA);
    }

    function sqrt_decimals(
        uint256 a,
        uint8 decimalsA,
        uint8 decimalsOut
    ) public pure returns (uint256) {
        return FMaths.sqrt(a, decimalsA, decimalsOut);
    }
}
