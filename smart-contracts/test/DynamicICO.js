const { expect } = require("chai");
// Share common setups (fixtures) between tests to run tests faster
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
// ethers variable is available in the global scope but can be explicitely imported:
const { ethers } = require("hardhat");

const e9 = '000000000';
const e18 = '000000000' + e9;

describe("DynamicICO contract", function () {
    // Creates a snapshot to reset for every test
    async function deployTokenFixture() {
        // Get the ContractFactory and Signers here.
        const [owner, first_contributors, addr2, addr3, addr4, addr5] = await ethers.getSigners();

        // token: ERC20 token
        // start-snippet: Load token contract
        const Token = await ethers.getContractFactory("FNDRToken");
        // end-snippet: Load token contract
        const token = await Token.deploy();
        await token.deployed();

        // DynamicICO
        const DynamicICO = await ethers.getContractFactory("DynamicICO");
        const dynamicICO = await DynamicICO.deploy();
        await dynamicICO.deployed();

        // BuyingToken: USDC Mock contract
        const BuyingToken = await ethers.getContractFactory("USDCMock");
        const buyingToken = await BuyingToken.deploy();
        await buyingToken.deployed();
        await buyingToken.initialize(
            "USDC Mock",
            "USDC",
            "Dollar",
            18, // between [9, 18] for unit tests to cover (rounding pbs otherwise)
            owner.address,
            owner.address,
            owner.address,
            owner.address
        );

        await token.initialize(addr2.address, dynamicICO.address, addr3.address, addr4.address, addr5.address);
        await dynamicICO.initialize(
            token.address,
            buyingToken.address,
            first_contributors.address,
            addr2.address
        );

        // Fixtures can return anything you consider useful for your tests
        return {
            token, buyingToken, dynamicICO, owner, first_contributors,
            addr2, addr3, addr4, addr5
        };
    }
    async function mintUSDCFixture() {
        const {
            token, buyingToken, dynamicICO, owner, first_contributors,
            addr2, addr3, addr4, addr5
        } = await deployTokenFixture();
        // setup minter
        await buyingToken.configureMinter(owner.address, '1000000000' + e18 + e18);
        // mint USDC
        await buyingToken.mint(owner.address, '15000000' + e18);

        // Fixtures can return anything you consider useful for your tests
        return {
            buyingToken,
            token, dynamicICO, owner, first_contributors,
            addr2, addr3, addr4, addr5
        };
    }

    describe("Deployment", function () {
        it("Should be owned by owner", async function () {
            const { token, owner } = await loadFixture(deployTokenFixture);
            expect(await token.owner()).to.equal(owner.address);
        });
    });

    describe("PurchaseAmount", function () {
        it("Distributed the tokens", async () => {
            const {
                token, buyingToken, dynamicICO, owner,
                addr2
            } = await loadFixture(deployTokenFixture);
            const eBuying = new Array(await buyingToken.decimals() + 1 - 9).join('0')
            await buyingToken.configureMinter(owner.address, '1000000000' + e9 + eBuying);
            // mint USDC
            await buyingToken.mint(owner.address, '15000000' + e9 + eBuying);

            // purchase all => 15M$
            await buyingToken.connect(owner).approve(dynamicICO.address, '15000000' + e9 + eBuying);

            await expect(await dynamicICO.purchaseAmount('451416200' + e18))
                .to.emit(dynamicICO, "Purchase")
                .withArgs(owner.address, '451416200' + e18, '33228757' + eBuying, '14999999215663400' + eBuying);

            expect(await token.balanceOf(owner.address))
                .to.equal('451416200' + e18)
            expect(await buyingToken.balanceOf(owner.address))
                .to.equal('784336600' + eBuying)

            expect(await buyingToken.balanceOf(addr2.address))
                .to.equal('14999999215663400' + eBuying);
        });
    });

    describe("PurchasePrice", function () {
        it("Distribute the tokens", async () => {
            const {
                token, buyingToken, dynamicICO, owner, first_contributors,
                addr2
            } = await loadFixture(deployTokenFixture);
            const eBuying = new Array(await buyingToken.decimals() + 1 - 9).join('0')
            await buyingToken.configureMinter(owner.address, '1000000000' + e9 + eBuying);
            // mint USDC
            await buyingToken.mint(owner.address, '15000000' + e9 + eBuying);

            // purchase all => 15M$
            await buyingToken.connect(owner).approve(dynamicICO.address, '15000000' + e9 + eBuying);

            await expect(await dynamicICO.purchasePrice('14999999215663400' + eBuying))
                .to.emit(dynamicICO, "Purchase")
                .withArgs(
                    owner.address,
                    '451416200' + e18,
                    '33228757' + eBuying,
                    '14999999215663400' + eBuying
                );

            expect(await token.balanceOf(owner.address))
                .to.equal('451416200' + e18)
            expect(await buyingToken.balanceOf(owner.address))
                .to.equal('784336600' + eBuying)

            expect(await buyingToken.balanceOf(addr2.address))
                .to.equal('14999999215663400' + eBuying);
        });

        // it("Test amount vs price", async () => {
        //     let {
        //         token, buyingToken, dynamicICO, owner, first_contributors,
        //         addr2, addr3, addr4, addr5, addr6
        //     } = await loadFixture(deployTokenFixture);
        //     const eBuying = new Array(await buyingToken.decimals() + 1 - 9).join('0')
        //     await buyingToken.configureMinter(owner.address, '1000000000' + e9 + eBuying);
        //     // mint USDC
        //     await buyingToken.mint(owner.address, '15000000' + e9 + eBuying);
        //     const balanceBefore = await buyingToken.balanceOf(owner.address);

        //     // purchase some
        //     await buyingToken.connect(owner).approve(dynamicICO.address, '15000000' + e9 + eBuying);
        //     await dynamicICO.purchaseAmount('4666198041118806' + e18);

        //     const balanceAmount = JSON.stringify(balanceBefore - await buyingToken.balanceOf(owner.address));
        //     ({
        //         token, buyingToken, dynamicICO, owner, first_contributors,
        //         addr2, addr3, addr4, addr5, addr6
        //     } = await loadFixture(deployTokenFixture))
        //     await buyingToken.configureMinter(owner.address, '1000000000' + e9 + eBuying);
        //     // mint USDC
        //     await buyingToken.mint(owner.address, '15000000' + e9 + eBuying);
        //     console.log('ttt:', balanceAmount)
        //     // purchase some
        //     await buyingToken.connect(owner).approve(dynamicICO.address, '15000000' + e9 + eBuying);
        //     await dynamicICO.purchasePrice(balanceAmount);
        //     expect(await token.balanceOf(owner.address)).to.equal('4666198041118806' + e18);
        // });
    });
});