const { expect } = require("chai");
// Share common setups (fixtures) between tests to run tests faster
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
// ethers variable is available in the global scope but can be explicitely imported:
const { ethers } = require("hardhat");

const NAME = 'FNDRToken';
const SYMBOL = 'FNDR';
const e18 = '000000000000000000';

const balanceOwner = 0
const balanceAddr1 = 400000000
const balanceAddr2 = 1000000000
const balanceAddr3 = 100000000
const balanceAddr4 = 100000000
const balanceAddr5 = 400000000

describe("token contract", function () {
    // Creates a snapshot to reset for every test
    async function deploytokenFixture() {
        // Get the ContractFactory and Signers here.
        const [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();

        // token: ERC20 token
        // start-snippet: Load token contract
        const Token = await ethers.getContractFactory("FNDRToken");
        // end-snippet: Load token contract
        const token = await Token.deploy();
        await token.deployed();

        await token.initialize(addr1.address, addr2.address, addr3.address, addr4.address, addr5.address);

        // Fixtures can return anything you consider useful for your tests
        return { token, owner, addr1, addr2, addr3, addr4, addr5 };
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

    describe("Minting tokens", function () {
        it("Distributed the tokens", async () => {
            const { token, owner, addr1, addr2, addr3, addr4, addr5 } = await loadFixture(deploytokenFixture);
            expect(await token.balanceOf(addr1.address)).to.equal(balanceAddr1 + e18)
            expect(await token.balanceOf(addr2.address)).to.equal(balanceAddr2 + e18)
            expect(await token.balanceOf(addr3.address)).to.equal(balanceAddr3 + e18)
            expect(await token.balanceOf(addr4.address)).to.equal(balanceAddr4 + e18)
            expect(await token.balanceOf(addr5.address)).to.equal(balanceAddr5 + e18)
        });
    });

    describe("Transactions", function () {
        it("Should transfer tokens between accounts", async function () {
            const { token, addr1, owner } = await loadFixture(deploytokenFixture);

            await token.connect(addr1).transfer(owner.address, 100)
            const tokens = await token.balanceOf(owner.address)
            expect(tokens).to.equal(100)
        });

        it("should emit Transfer events", async function () {
            const { token, owner, addr1, addr2 } = await loadFixture(deploytokenFixture);
            // Transfer 50 tokens from addr1 to owner
            await expect(token.connect(addr1).transfer(owner.address, 50 + e18))
                .to.emit(token, "Transfer")
                .withArgs(addr1.address, owner.address, 50 + e18);

            // Transfer 5 tokens from addr1 to addr2
            // We use .connect(signer) to send a transaction from another account
            await expect(token.connect(addr1).transfer(addr2.address, 5 + e18))
                .to.emit(token, "Transfer")
                .withArgs(addr1.address, addr2.address, 5 + e18);

            expect(await token.balanceOf(owner.address)).to.equal(50 + e18)
            expect(await token.balanceOf(addr1.address)).to.equal((balanceAddr1 - 55) + e18)
            expect(await token.balanceOf(addr2.address)).to.equal((balanceAddr2 + 5) + e18)
        });

        it("Should fail if sender doesn't have enough tokens", async function () {
            const { token, owner, addr1 } = await loadFixture(deploytokenFixture);
            // Try to send 1 token from addr1 (0 tokens) to owner.
            await expect(
                token.connect(owner).transfer(addr1.address, 1)
            ).to.be.revertedWith("ERC20: transfer amount exceeds balance");

            // Owner balance shouldn't have changed.
            expect(await token.balanceOf(owner.address)).to.equal(0);
        });
    });

    describe("Burning token", () => {
        it("Update certifier balance", async () => {
            const { token, addr1 } = await loadFixture(deploytokenFixture);
            // Burn 200 tokens
            await token.connect(addr1).burn(200 + e18);
            expect(await token.balanceOf(addr1.address)).to.equal((balanceAddr1 - 200) + e18);
            expect(await token.totalTokenBurnt()).to.equal(200 + e18);
        });
    })
});