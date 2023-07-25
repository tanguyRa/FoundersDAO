//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./FloatingMaths.sol";

// import "hardhat/console.sol";
// start-snippet: token import
import "./FNDRToken.sol";

// end-snippet: token import

// start-snippet: Unlockable reserve name
contract CommunityPoolReferrals is Ownable {
    // end-snippet: Unlockable reserve name

    // start-snippet: token definition
    FNDRToken public token;
    address public communityPoolAmbassadors_addr;
    address public communityPoolContributors_addr;
    address public daoWallet_addr;
    address public liquidityWallet_addr;
    // end-snippet: token definition

    uint public cliff;
    uint public immutable vesting_period;
    uint public immutable vesting_percentage;
    uint public immutable deployDate;

    uint8 public tokenDecimals;

    // start-snippet: custom vars
    uint256 internal contributorsCounter;
    mapping(address => uint256) public contributorIds;
    mapping(uint256 => address) public contributorWallets;
    mapping(uint256 => uint256) public subscriptions;
    mapping(uint256 => uint256) public patrons;
    uint256 public totalPatrons;

    uint256 public subscriptionPrice;
    uint256 public lockedSubscriptionPrice;
    uint256 public subscriptionPriceUnlockDate;
    uint256 public constant subscriptionPriceLockPeriod = 7 * 1 days;

    bool private initialized;

    // end-snippet: custom vars

    constructor() {
        // start-snippet: init definitions
        cliff = 30;
        vesting_period = 30;
        vesting_percentage = 50;
        // end-snippet: init definitions
        deployDate = block.timestamp;
    }

    function initialize(
        address _token,
        address _communityPoolAmbassadors_addr,
        address _communityPoolContributors_addr,
        address _daoWallet_addr,
        address _liquidityWallet_addr
    ) public onlyOwner {
        require(!initialized, "DynamicICO: contract is already initialized");

        token = FNDRToken(_token);
        tokenDecimals = token.decimals();

        initialized = true;

        subscriptionPrice = FMaths.mul(50000, 1, 0, 0, tokenDecimals);
        // redistribution addresses
        require(
            _communityPoolAmbassadors_addr != address(0),
            "CommunityPoolReferrals: communityPoolAmbassadors_addr is the zero address"
        );
        communityPoolAmbassadors_addr = _communityPoolAmbassadors_addr;
        require(
            _communityPoolContributors_addr != address(0),
            "CommunityPoolReferrals: communityPoolContributors_addr is the zero address"
        );
        communityPoolContributors_addr = _communityPoolContributors_addr;
        require(
            _daoWallet_addr != address(0),
            "CommunityPoolReferrals: daoWallet_addr is the zero address"
        );
        daoWallet_addr = _daoWallet_addr;
        require(
            _liquidityWallet_addr != address(0),
            "CommunityPoolReferrals: liquidityWallet_addr is the zero address"
        );
        liquidityWallet_addr = _liquidityWallet_addr;
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
        uint availableAmount = token.balanceOf(address(this)) *
            vesting_percentage;

        for (
            uint contributorId = 0;
            contributorId < contributorsCounter;
            contributorId++
        ) {
            if (patrons[contributorId] > 0) {
                token.transfer(
                    contributorWallets[contributorId],
                    (patrons[contributorId] * availableAmount) /
                        (100 * totalPatrons)
                );
            }
        }
        cliff += vesting_period;
        emit Distribute(owner(), availableAmount / 100, cliff);
    }

    // start-snippet: custom code
    event RenewedSubscription(
        address contributor,
        address sponsor,
        uint256 endDate
    );
    event SubscriptionPriceUpdated(uint256 newPrice, uint256 oldPrice);

    // time locked subscription price management
    event NewSubscriptionPriceLocked(uint256 price, uint256 unlockDate);
    event SubscriptionPriceUnlocked(uint256 price);
    event SubscriptionPriceUpdateCanceled();

    function queueSubscriptionPrice(uint256 newPrice) public onlyOwner {
        require(
            subscriptionPriceUnlockDate <= block.timestamp,
            "CommunityPoolReferrals: subscription price is locked"
        );
        subscriptionPriceUnlockDate =
            block.timestamp +
            subscriptionPriceLockPeriod;
        lockedSubscriptionPrice = newPrice;
        emit NewSubscriptionPriceLocked(newPrice, subscriptionPriceUnlockDate);
    }

    function setSubscriptionPrice(uint256 newPrice) public onlyOwner {
        require(
            subscriptionPriceUnlockDate <= block.timestamp,
            "CommunityPoolReferrals: subscription price is locked"
        );
        require(
            newPrice > 0 && newPrice == lockedSubscriptionPrice,
            "CommunityPoolReferrals: subscription price must be greater than 0 and must be the queued price"
        );
        emit SubscriptionPriceUpdated(newPrice, subscriptionPrice);
        subscriptionPrice = newPrice;
        lockedSubscriptionPrice = 0;
    }

    function cancelSubscriptionPriceUpdate() public onlyOwner {
        emit SubscriptionPriceUpdateCanceled();
        lockedSubscriptionPrice = 0;
        subscriptionPriceUnlockDate = 0;
    }

    function isSubscribed(
        address subscriber
    ) public view returns (bool subscription) {
        return block.timestamp <= subscriptions[contributorIds[subscriber]];
    }

    /*
     * @dev Renew subscription of contributor to allow rides creation
     */
    function renewSubscription(address sponsor) public {
        renewSubscriptionFor(msg.sender, sponsor, address(0));
    }

    function renewSubscriptionFor(
        address contributor,
        address sponsor,
        address payer
    ) public {
        if (payer == address(0)) {
            require(
                contributor == msg.sender || msg.sender == owner(),
                "CommunityPoolReferrals: contributor must be msg.sender"
            );
            _transferTokens(contributor);
        } else {
            require(
                payer == msg.sender || msg.sender == owner(),
                "CommunityPoolReferrals: payer must be msg.sender or Founders DAO (owner)"
            );
            _transferTokens(payer);
        }

        if (contributorIds[contributor] == 0) {
            // new account
            contributorsCounter += 1;
            contributorIds[contributor] = contributorsCounter;
            contributorWallets[contributorsCounter] = contributor;
        }

        if (subscriptions[contributorIds[contributor]] > block.timestamp) {
            subscriptions[contributorIds[contributor]] += 365 * 1 days;
        } else {
            subscriptions[contributorIds[contributor]] =
                block.timestamp +
                365 *
                1 days;
        }

        if (sponsor != address(0)) {
            patrons[contributorIds[sponsor]] += 1;
            totalPatrons += 1;
        }

        emit RenewedSubscription(
            contributor,
            sponsor,
            subscriptions[contributorIds[contributor]]
        );
    }

    function offerSubscription(
        address contributor,
        uint256 daysOffered
    ) public onlyOwner {
        if (contributorIds[contributor] == 0) {
            // new account
            contributorsCounter += 1;
            contributorIds[contributor] = contributorsCounter;
            contributorWallets[contributorsCounter] = contributor;
        }

        if (subscriptions[contributorIds[contributor]] > block.timestamp) {
            subscriptions[contributorIds[contributor]] += daysOffered * 1 days;
        } else {
            subscriptions[contributorIds[contributor]] =
                block.timestamp +
                daysOffered *
                1 days;
        }

        emit RenewedSubscription(
            contributor,
            address(0),
            subscriptions[contributorIds[contributor]]
        );
    }

    function _transferTokens(address sender) internal {
        uint256 communityPoolAmbassadors_amount = FMaths.div(
            FMaths.mul(subscriptionPrice, 5, tokenDecimals, 0, tokenDecimals),
            100,
            tokenDecimals,
            0,
            tokenDecimals
        );
        uint256 communityPoolContributors_amount = FMaths.div(
            FMaths.mul(subscriptionPrice, 5, tokenDecimals, 0, tokenDecimals),
            100,
            tokenDecimals,
            0,
            tokenDecimals
        );
        uint256 communityPoolReferrals_amount = FMaths.div(
            FMaths.mul(subscriptionPrice, 5, tokenDecimals, 0, tokenDecimals),
            100,
            tokenDecimals,
            0,
            tokenDecimals
        );
        uint256 daoWallet_amount = FMaths.div(
            FMaths.mul(subscriptionPrice, 60, tokenDecimals, 0, tokenDecimals),
            100,
            tokenDecimals,
            0,
            tokenDecimals
        );
        uint256 liquidityWallet_amount = FMaths.div(
            FMaths.mul(subscriptionPrice, 25, tokenDecimals, 0, tokenDecimals),
            100,
            tokenDecimals,
            0,
            tokenDecimals
        );

        token.transferFrom(
            sender,
            communityPoolAmbassadors_addr,
            communityPoolAmbassadors_amount
        );
        token.transferFrom(
            sender,
            communityPoolContributors_addr,
            communityPoolContributors_amount
        );
        token.transferFrom(
            sender,
            address(this),
            communityPoolReferrals_amount
        );
        token.transferFrom(sender, daoWallet_addr, daoWallet_amount);
        token.transferFrom(
            sender,
            liquidityWallet_addr,
            liquidityWallet_amount
        );
    }
    // end-snippet: custom code
}
