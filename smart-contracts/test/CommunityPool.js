const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");

const e18 = '000000000000000000'

describe("Community pool contract", function () {
    // Creates a snapshot to reset for every test
    async function deployFixture() {
        // Get the ContractFactory and Signers here.
        const [owner, addr1, addr2, addr3] = await ethers.getSigners();

        // Token: ERC20 token
        // start-snippet: Load token contract
        const Token = await ethers.getContractFactory("FNDRToken");
        // end-snippet: Load token contract
        const token = await Token.deploy();
        await token.deployed();

        // Reserve : Reward pool
        // start-snippet: Load contract
        const UnlockableReserve = await ethers.getContractFactory("FNDRCommunityPoolAmbassadors");
        // end-snippet: Load contract
        const unlockableReserve = await UnlockableReserve.deploy(token.address);
        await unlockableReserve.deployed();

        await token.initialize(owner.address, addr1.address, unlockableReserve.address, addr2.address, addr3.address);

        // Fixtures can return anything you consider useful for your tests
        return { token, unlockableReserve, owner, addr1, addr2 };
    }

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            const { unlockableReserve, owner } = await loadFixture(deployFixture);
            expect(await unlockableReserve.owner()).to.equal(owner.address);
        });
    });

    describe("Transfer", function () {
        it("Should reject the transfer", async () => {
            const { unlockableReserve } = await loadFixture(deployFixture);
            //Rejects distribution before cliff period
            await expect(unlockableReserve.distribute()).to.be.reverted;
        });

        it("Should accept the transfer and update the counterDistribution variable", async () => {
            const { unlockableReserve } = await loadFixture(deployFixture);
            // Advance time by days equal to cliff period
            await ethers.provider.send('evm_increaseTime', [parseInt(await unlockableReserve.cliff()) * 24 * 60 * 60]);
            const counter = await unlockableReserve.cliff();
            await unlockableReserve.distribute();
            const counter2 = await unlockableReserve.cliff();
            //Re-distribution possible after veting period days
            expect(parseInt(counter) + parseInt(await unlockableReserve.vesting_period())).to.equal(counter2)
        });

        it("Should reject double transfert", async () => {
            const { unlockableReserve } = await loadFixture(deployFixture);
            // Advance time by days equal to cliff period
            await ethers.provider.send('evm_increaseTime', [parseInt(await unlockableReserve.cliff()) * 24 * 60 * 60]);
            await unlockableReserve.distribute();
            // Double distribution rejected
            await expect(unlockableReserve.distribute()).to.be.reverted;
        });

        it("Should accept second transfer after vesting period", async () => {
            const { unlockableReserve } = await loadFixture(deployFixture);
            // Advance time by days equal to cliff period
            await ethers.provider.send('evm_increaseTime', [parseInt(await unlockableReserve.cliff()) * 24 * 60 * 60]);
            // Distribution
            await unlockableReserve.distribute();
            // Advance time by one vesting period
            await ethers.provider.send('evm_increaseTime', [parseInt(await unlockableReserve.vesting_period()) * 24 * 60 * 60]);
            // Distribution
            await unlockableReserve.distribute();
        });

        // start-snippet: Transfer [V2: too many variables]
        it("Should transfer the right amount of tokens", async () => {
            const { unlockableReserve, owner, token } = await loadFixture(deployFixture);
            await ethers.provider.send('evm_increaseTime', [parseInt(await unlockableReserve.cliff()) * 24 * 60 * 60]);
            // Mint 1000 tokens in reserve
            // await token.mint(unlockableReserve.address, 1000)
            expect(await token.balanceOf(owner.address)).to.equal('400000000' + e18);

            // Distributes reserve to NFT holders
            await unlockableReserve.distribute();

            // Vesting percentage of the tokens have been distributed to the owner
            expect(await token.balanceOf(unlockableReserve.address)).to.equal('98000000' + e18);
            expect(await token.balanceOf(owner.address)).to.equal('402000000' + e18);
        });
        // end-snippet: Transfer [V2: too many variables]
    });
});
