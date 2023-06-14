// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/*
 * @dev Wrappers over Solidity's arithmetic operations.
 */
library FMaths {
  uint8 constant decimalsDefault = 18;

  /*
   * @dev Returns the addition of two uint256 (a + b)
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert (c >= a);
    assert (c >= b);
    return c;
  }
  function add(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    uint256 result = a + b;
    assert (result >= a);
    assert (result >= b);
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }
  function add(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    uint8 deltaDecimalsA = decimalsDefault - decimalsA;
    uint8 deltaDecimalsB = decimalsDefault - decimalsB;
    uint256 result = add(a * 10 ** uint256(deltaDecimalsA), b * 10 ** uint256(deltaDecimalsB));
    return result;
  }
  function add(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint8 deltaDecimalsA = decimalsDefault - decimalsA;
    uint8 deltaDecimalsB = decimalsDefault - decimalsB;
    uint256 result = add(a * 10 ** uint256(deltaDecimalsA), b * 10 ** uint256(deltaDecimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the substraction of two uint256 (a - b)
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a - b;
    assert (c <= a);
    return c;
  }
  function sub(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    uint256 result = a - b;
    assert (result <= a);
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }
  function sub(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    return sub(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
  }
  function sub(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = sub(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the multiplication of two uint256 (a * b)
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = (a * b) / (10 ** decimalsDefault);
    return c;
  }
  function mul(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    uint256 result = mul(a, b);
    return result / 10 ** uint256(decimalsDefault - decimalsOut);
  }
  function mul(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    uint8 deltaDecimalsA = decimalsDefault - decimalsA;
    uint8 deltaDecimalsB = decimalsDefault - decimalsB;
    return mul(a * 10 ** uint256(deltaDecimalsA), b * 10 ** uint256(deltaDecimalsB));
  }
  function mul(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = mul(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the division of two uint256 (a / b)
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * (10 ** decimalsDefault) / b;
  }
  function div(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    uint256 result = div(a, b);
    return result / 10 ** uint256(decimalsDefault - decimalsOut);
  }
  function div(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    return div(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
  }
  function div(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = div(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the maximum between two values
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a > b ? a : b;
  }
  function max(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    return max(a, b) / (10 ** uint256(decimalsDefault - decimalsOut));
  }
  function max(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    return max(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
  }
  function max(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = max(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the minimum between two values
   * @param a
   * @param b
   * @param decimalsA [optional] the number of floating points for a
   * @param decimalsB [optional] the number of floating points for b
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a > b ? b : a;
  }
  function min(uint256 a, uint256 b, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsOut <= decimalsDefault);
    return min(a, b) / (10 ** uint256(decimalsDefault - decimalsOut));
  }
  function min(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    return min(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
  }
  function min(uint256 a, uint256 b, uint8 decimalsA, uint8 decimalsB, uint8 decimalsOut) internal pure returns (uint256) {
    assert (decimalsA <= decimalsDefault);
    assert (decimalsB <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    uint256 result = min(a * 10 ** uint256(decimalsDefault - decimalsA), b * 10 ** uint256(decimalsDefault - decimalsB));
    return result / (10 ** uint256(decimalsDefault - decimalsOut));
  }

  /*
   * @dev Returns the squre root of a value
   * @param x
   * @param decimalsX [optional] the number of floating points for x
   * @param decimalsOut [optional] the number of floating points for the result
   */
  function sqrt(uint256 _x) internal pure returns (uint256 result) {
    uint256 x = _x * 10 ** decimalsDefault;
    if (x == 0) {
        return 0;
    }

    // Calculate the square root of the perfect square of a power of two that is the closest to x.
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 0x100000000000000000000000000000000) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 0x10000000000000000) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 0x100000000) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 0x10000) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 0x100) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 0x10) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 0x8) {
        result <<= 1;
    }

    // The operations can never overflow because the result is max 2^127 when it enters this block.
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1; // Seven iterations should be enough
        uint256 roundedDownResult = x / result;
        return result >= roundedDownResult ? roundedDownResult : result;
    }
  }
  function sqrt(uint256 x, uint8 decimalsX) internal pure returns (uint256 result) {
    assert (decimalsX <= decimalsDefault);
    return sqrt(x * (10 ** uint256(decimalsDefault - decimalsX)));
  }
  function sqrt(uint256 x, uint8 decimalsX, uint8 decimalsOut) internal pure returns (uint256 result) {
    assert (decimalsX <= decimalsDefault);
    assert (decimalsOut <= decimalsDefault);
    return sqrt(x * (10 ** uint256(decimalsDefault - decimalsX))) / (10 ** uint256(decimalsDefault - decimalsOut));
  }
}
