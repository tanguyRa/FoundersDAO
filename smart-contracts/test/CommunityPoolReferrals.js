const { expect } = require("chai");
// Share common setups (fixtures) between tests to run tests faster
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
// ethers variable is available in the global scope but can be explicitely imported:
const { ethers } = require("hardhat");

const NAME = 'FNDRToken';
const SYMBOL = 'FNDR';
const e18 = '000000000000000000';
const e17 = '00000000000000000';
const OxO = '0x0000000000000000000000000000000000000000'

describe("CP Referrals contract", function () {
    // Creates a snapshot to reset for every test
    async function deploytokenFixture() {
        // Get the ContractFactory and Signers here.
        const [
            owner, dao_wallet, cp_ambassadors, cp_contributors, liquiditypool,
            dynamic_ico, team, user1, user2,
        ] = await ethers.getSigners();

        // token: ERC20 token
        // start-snippet: Load token contract
        const Token = await ethers.getContractFactory("FNDRToken");
        // end-snippet: Load token contract
        const token = await Token.deploy();
        await token.deployed();

        // cp referrals
        const CP_Referrals = await ethers.getContractFactory("CommunityPoolReferrals");
        const cp_referrals = await CP_Referrals.deploy();
        await cp_referrals.deployed();

        await token.initialize(
            dao_wallet.address,
            owner.address, // dynamic_ico
            cp_ambassadors.address,
            cp_contributors.address,
            team.address
        );
        await cp_referrals.initialize(
            token.address,
            cp_ambassadors.address,
            cp_contributors.address,
            dao_wallet.address,
            liquiditypool.address
        )

        // Fixtures can return anything you consider useful for your tests
        return {
            token, cp_referrals,
            owner, dao_wallet, cp_ambassadors, cp_contributors, liquiditypool,
            dynamic_ico, team, user1, user2,
        };
    }

    describe("Deployment", function () {
        it("Should be owned by owner", async function () {
            const { token, owner } = await loadFixture(deploytokenFixture);
            expect(await token.owner()).to.equal(owner.address);
        });

        it('has a name', async function () {
            const { token } = await loadFixture(deploytokenFixture);
            expect(await token.name()).to.be.equal(NAME);
        });

        it('has a symbol', async function () {
            const { token } = await loadFixture(deploytokenFixture);
            expect(await token.symbol()).to.be.equal(SYMBOL);
        });
    });

    describe("Scenario", function () {
        it("Should enable user to renew subscription", async function () {
            const {
                token, cp_referrals,
                owner, dao_wallet, cp_ambassadors, cp_contributors, liquiditypool,
                dynamic_ico, team, user1, user2,
            } = await loadFixture(deploytokenFixture);

            const balance = await token.balanceOf(owner.address)

            // allowance
            await token.connect(owner).approve(cp_referrals.address, '50000' + e18);
            // subscription
            await cp_referrals.connect(owner).renewSubscription(OxO)

            const balanceAfter = await token.balanceOf(owner.address)

            expect(balanceAfter).to.equal(999950000 + e18)
            expect(await token.balanceOf(cp_referrals.address)).to.equal(50000 * 5 / 100 + e18)
        });

        it('Should enable user to renew subscription with referral', async function () {
            const {
                token, cp_referrals,
                owner, dao_wallet, cp_ambassadors, cp_contributors, liquiditypool,
                dynamic_ico, team, user1, user2,
            } = await loadFixture(deploytokenFixture);
            // allowance
            await token.connect(owner).approve(cp_referrals.address, '50000' + e18);
            // subscription
            await cp_referrals.connect(owner).renewSubscriptionFor(user2.address, owner.address, owner.address)

            expect(await token.balanceOf(owner.address)).to.equal(999950000 + e18)
            expect(await token.balanceOf(cp_referrals.address)).to.equal(50000 * 5 / 100 + e18)

            const subscriptionDays = 365 * 24 * 60 * 60;

            const blockNumBefore = await ethers.provider.getBlockNumber();
            const blockBefore = await ethers.provider.getBlock(blockNumBefore);
            const timestampBefore = blockBefore.timestamp;

            const userId = await cp_referrals.contributorIds(user2.address)
            expect(await cp_referrals.subscriptions(userId)).to.equal(timestampBefore + subscriptionDays)

            const ownerId = await cp_referrals.contributorIds(owner.address)
            expect(await cp_referrals.patrons(ownerId)).to.equal(1)
        });

        it('Should be a valid for the subscription period', async function () {
            const {
                token, cp_referrals,
                owner, dao_wallet, cp_ambassadors, cp_contributors, liquiditypool,
                dynamic_ico, team, user1, user2,
            } = await loadFixture(deploytokenFixture);
            // allowance
            await token.connect(owner).approve(cp_referrals.address, '50000' + e18);
            // subscription
            await cp_referrals.connect(owner).renewSubscriptionFor(user2.address, owner.address, owner.address)

            expect(await cp_referrals.isSubscribed(user2.address)).to.equal(true);
            // time travel
            await ethers.provider.send('evm_increaseTime', [360 * 24 * 60 * 60]);
            await ethers.provider.send('evm_mine');
            expect(await cp_referrals.isSubscribed(user2.address)).to.equal(true);
            // time travel
            await ethers.provider.send('evm_increaseTime', [6 * 24 * 60 * 60]);
            await ethers.provider.send('evm_mine');
            expect(await cp_referrals.isSubscribed(user2.address)).to.equal(false);
        });

        it('Should distribute the pool to valid users [simple]', async function () {
            const {
                token, cp_referrals,
                owner, dao_wallet, cp_ambassadors, cp_contributors, liquiditypool,
                dynamic_ico, team, user1, user2,
            } = await loadFixture(deploytokenFixture);
            // allowance
            await token.connect(owner).approve(cp_referrals.address, '100000' + e18);
            // subscriptions
            await cp_referrals.connect(owner).renewSubscription(OxO)
            await cp_referrals.connect(owner).renewSubscriptionFor(user2.address, owner.address, owner.address)

            // time travel
            await ethers.provider.send('evm_increaseTime', [31 * 24 * 60 * 60]);
            await ethers.provider.send('evm_mine');

            await cp_referrals.distribute()
            expect(await token.balanceOf(owner.address)).to.equal(999902500 + e18)
        });

        it('Should distribute the pool to valid users [complexe]', async function () {
            const {
                token, cp_referrals,
                owner, dao_wallet, cp_ambassadors, cp_contributors, liquiditypool,
                dynamic_ico, team, user1, user2,
            } = await loadFixture(deploytokenFixture);
            // allowance
            await token.connect(owner).approve(cp_referrals.address, '250000' + e18);
            // subscriptions
            await cp_referrals.connect(owner).renewSubscription(OxO)
            await cp_referrals.connect(owner).renewSubscriptionFor(user1.address, owner.address, owner.address)
            await cp_referrals.connect(owner).renewSubscriptionFor(user1.address, owner.address, owner.address)
            await cp_referrals.connect(owner).renewSubscriptionFor(user1.address, owner.address, owner.address)
            await cp_referrals.connect(owner).renewSubscriptionFor(user2.address, user1.address, owner.address)

            // time travel
            await ethers.provider.send('evm_increaseTime', [31 * 24 * 60 * 60]);
            await ethers.provider.send('evm_mine');

            await expect(await cp_referrals.distribute())
                .to.emit(cp_referrals, "Distribute")
                .withArgs(owner.address, '6250' + e18, '60')
            expect(await token.balanceOf(owner.address)).to.equal(9997546875 + e17)
            expect(await token.balanceOf(user1.address)).to.equal(15625 + e17)
        });

        it('Should be able to offer subscriptions (admin)', async function () {
            const {
                token, cp_referrals,
                owner, dao_wallet, cp_ambassadors, cp_contributors, liquiditypool,
                dynamic_ico, team, user1, user2,
            } = await loadFixture(deploytokenFixture);
            // subscription
            await cp_referrals.connect(owner).offerSubscription(user2.address, 30)

            expect(await cp_referrals.isSubscribed(user2.address)).to.equal(true);
            // time travel
            await ethers.provider.send('evm_increaseTime', [29 * 24 * 60 * 60]);
            await ethers.provider.send('evm_mine');
            expect(await cp_referrals.isSubscribed(user2.address)).to.equal(true);
            // time travel
            await ethers.provider.send('evm_increaseTime', [1 * 23 * 60 * 60]);
            await ethers.provider.send('evm_mine');
            expect(await cp_referrals.isSubscribed(user2.address)).to.equal(true);
            // time travel
            await ethers.provider.send('evm_increaseTime', [2 * 60 * 60]);
            await ethers.provider.send('evm_mine');
            expect(await cp_referrals.isSubscribed(user2.address)).to.equal(false);
        });

        it('Should be able to change subscription price over time (admin)', async function () {
            const {
                token, cp_referrals,
                owner, dao_wallet, cp_ambassadors, cp_contributors, liquiditypool,
                dynamic_ico, team, user1, user2,
            } = await loadFixture(deploytokenFixture);
            // change price
            await cp_referrals.setSubscriptionPrice(10000 + e18)
            // allowance
            await token.connect(owner).approve(cp_referrals.address, '50000' + e18);
            // subscription
            await cp_referrals.connect(owner).renewSubscription(OxO)

            const balanceAfter = await token.balanceOf(owner.address)

            expect(balanceAfter).to.equal(999990000 + e18)
            expect(await token.balanceOf(cp_referrals.address)).to.equal(10000 * 5 / 100 + e18)
        });
    });
})