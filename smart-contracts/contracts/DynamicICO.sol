// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./FloatingMaths.sol";

// start-snippet: token import
import "./FNDRToken.sol";

// end-snippet: token import

// start-snippet: custom smart-contract
contract DynamicICO is Ownable {
    bool internal initialized;
    uint256 public amountSold;
    uint256 public initialValuation;

    FNDRToken public token;
    uint8 internal tokenDecimals;
    IERC20Metadata public buyingToken;
    uint8 internal buyingTokenDecimals;
    uint256 public firstContributorsAllocation;

    address daoWallet_addr;

    function initialize(
        address _token,
        address _buyingToken,
        address _firstContributors,
        address _daoWallet_addr
    ) public onlyOwner {
        require(!initialized, "DynamicICO: contract is already initialized");

        token = FNDRToken(_token);
        require(token.balanceOf(address(this)) > 0, "Initialize token first!");

        buyingToken = IERC20Metadata(_buyingToken);
        tokenDecimals = token.decimals();
        buyingTokenDecimals = buyingToken.decimals();
        require(
            _daoWallet_addr != address(0),
            "DynamicICO: daoWallet_addr is the zero address"
        );
        daoWallet_addr = _daoWallet_addr;

        initialized = true;

        initialValuation = 1 * (10 ** uint256(tokenDecimals - 2));
        firstContributorsAllocation = 548583800;
        token.transfer(_firstContributors, firstContributorsAllocation);
        amountSold =
            firstContributorsAllocation *
            (10 ** uint256(tokenDecimals));
    }

    event Purchase(
        address indexed to,
        uint256 tokenAmount,
        uint256 averageTokenPrice,
        uint256 buyingTokenAmount
    );

    /**
     * @dev Purchase tokens
     * @param amount The amount to be created (with FNDRToken Decimals).
     */
    function purchaseAmount(uint256 amount) public {
        purchaseAmountFor(msg.sender, amount);
    }

    /**
     * @dev Purchase tokens for specified address.
     * @param recipient The address to mint tokens for.
     * @param amount The amount to be created (with FNDRToken Decimals).
     */
    function purchaseAmountFor(address recipient, uint256 amount) public {
        uint256 x0 = _price(amountSold);
        uint256 x1 = _price(amountSold + amount);
        uint256 averageTokenPrice = FMaths.div(
            FMaths.add(x0, x1, tokenDecimals, tokenDecimals, tokenDecimals),
            2,
            tokenDecimals,
            0,
            buyingTokenDecimals
        );
        uint256 buyingTokenAmount = FMaths.mul(
            averageTokenPrice,
            amount,
            buyingTokenDecimals,
            tokenDecimals,
            buyingTokenDecimals
        );
        amountSold = FMaths.add(
            amountSold,
            amount,
            tokenDecimals,
            tokenDecimals,
            tokenDecimals
        );

        require(
            buyingToken.transferFrom(
                msg.sender,
                daoWallet_addr,
                buyingTokenAmount
            ),
            "DynamicICO: transferFrom failed"
        );
        token.transfer(recipient, amount);

        emit Purchase(recipient, amount, averageTokenPrice, buyingTokenAmount);
    }

    /**
     * @dev Purchase tokens
     * @param buyingTokenAmount The price in StableCoin to purchase for.
     */
    function purchasePrice(uint256 buyingTokenAmount) public {
        purchasePriceFor(msg.sender, buyingTokenAmount);
    }

    /**
     * @dev Purchase tokens for specified address.
     * @param recipient The address to mint tokens for.
     * @param buyingTokenAmount The price in StableCoin to purchase for
     */
    function purchasePriceFor(
        address recipient,
        uint256 buyingTokenAmount
    ) public {
        // 1/3 * ((-1* 10^9) - (3 * x0) + sqrt((1* 10^18) + (6*10 ^9 * x0) + (9 * x0^2) + (6*10 ^11 * y)))
        uint256 amount = FMaths.div( // (...) * 1/3
            FMaths.sub( // (sqrt(...) - (3 * x0)) - 10^9
                FMaths.sub( // sqrt(...) - (3 * x0)
                    FMaths.sqrt( // sqrt(...)
                        FMaths.add(
                            FMaths.add( // (10^18 + (x0 * (6 * 10^9)))
                                10 ** 18,
                                FMaths.mul( // x0 * (6 * 10^9)
                                    amountSold,
                                    FMaths.mul(6, 10 ** 9, 0, 0, tokenDecimals),
                                    tokenDecimals,
                                    tokenDecimals,
                                    tokenDecimals
                                ),
                                0,
                                tokenDecimals,
                                tokenDecimals
                            ),
                            FMaths.add(
                                FMaths.mul( // 9 * (x0 ^2)
                                    9,
                                    FMaths.mul( // x0 ^ 2
                                        amountSold,
                                        amountSold,
                                        tokenDecimals,
                                        tokenDecimals,
                                        tokenDecimals
                                    ),
                                    0,
                                    tokenDecimals,
                                    tokenDecimals
                                ),
                                FMaths.mul( // y * (6 * 10^11)
                                    buyingTokenAmount,
                                    FMaths.mul(
                                        6,
                                        10 ** 11,
                                        0,
                                        0,
                                        tokenDecimals
                                    ), // 6 * 10^11
                                    buyingTokenDecimals,
                                    tokenDecimals,
                                    tokenDecimals
                                ),
                                tokenDecimals,
                                tokenDecimals,
                                tokenDecimals
                            ),
                            tokenDecimals,
                            tokenDecimals,
                            tokenDecimals
                        ),
                        tokenDecimals,
                        tokenDecimals
                    ),
                    FMaths.mul(3, amountSold, 0, tokenDecimals, tokenDecimals),
                    tokenDecimals,
                    tokenDecimals,
                    tokenDecimals
                ),
                10 ** 9,
                tokenDecimals,
                0,
                tokenDecimals
            ),
            3,
            tokenDecimals,
            0,
            tokenDecimals
        );

        uint256 averageTokenPrice = FMaths.div(
            buyingTokenAmount,
            amount,
            buyingTokenDecimals,
            tokenDecimals,
            buyingTokenDecimals
        );

        amountSold = FMaths.add(
            amountSold,
            amount,
            tokenDecimals,
            tokenDecimals,
            tokenDecimals
        );

        require(
            buyingToken.transferFrom(
                msg.sender,
                daoWallet_addr,
                buyingTokenAmount
            ),
            "DynamicICO: transferFrom failed"
        );
        token.transfer(recipient, amount);

        emit Purchase(recipient, amount, averageTokenPrice, buyingTokenAmount);
    }

    function _price(uint256 x) internal view returns (uint256 price) {
        return
            FMaths.mul(
                FMaths.add(
                    FMaths.mul(
                        x,
                        FMaths.mul(
                            3, // a
                            1, // b
                            0, // decimals a
                            tokenDecimals - 9, // decimals b
                            tokenDecimals // decimals output
                        ),
                        tokenDecimals,
                        tokenDecimals,
                        tokenDecimals
                    ), // a
                    1, // b
                    tokenDecimals, // nb of decimals for a
                    0, // nb of decimals for b,
                    tokenDecimals // nb of decimals for output
                ),
                initialValuation
            );
    }
}
// end-snippet: custom smart-contract
