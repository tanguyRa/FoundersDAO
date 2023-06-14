const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Account balance:", (await deployer.getBalance()).toString());
    console.log("deployer=", deployer.address);

    // token: ERC20 token
    const Token = await ethers.getContractFactory("FNDRToken");
    const token = await Token.deploy();
    await token.deployed();

    // dynamic ICO
    const DynamicICO = await ethers.getContractFactory("DynamicICO");
    const dynamicICO = await DynamicICO.deploy();

    // CP Ambassadors
    const CP_Ambassadors = await ethers.getContractFactory("FNDRCommunityPoolAmbassadors");
    const cp_ambassadors = await CP_Ambassadors.deploy(token.address);

    // CP Contributors
    const CP_Contributors = await ethers.getContractFactory("FNDRCommunityPoolContributors");
    const cp_contributors = await CP_Contributors.deploy(token.address);

    // CP Referrals
    const CP_Referrals = await ethers.getContractFactory("CommunityPoolReferrals");
    const cp_referrals = await CP_Referrals.deploy();

    // BuyingToken: USDC Mock contract
    const BuyingToken = await ethers.getContractFactory("USDCMock");
    const buyingToken = await BuyingToken.deploy();

    // DAO reserve
    const DAOReserve = await ethers.getContractFactory("DAOReserve");
    const daoReserve = await DAOReserve.deploy(token.address);

    await Promise.all([
        dynamicICO.deployed(),
        cp_ambassadors.deployed(),
        cp_contributors.deployed(),
        cp_referrals.deployed(),
        buyingToken.deployed(),
    ]);

    await buyingToken.initialize(
        "USDC Mock",
        "USDC",
        "Dollar",
        6,
        deployer.address,
        deployer.address,
        deployer.address,
        deployer.address
    );
    console.log("buyingToken=", buyingToken.address);

    const daoWallet = '0xB4cEC8b6E7ea61B4712B9c071de06dd0821FE118';
    const liquidityPool = '0x111DF07624Bf8791A3A2977a421342E5dA3356E3';

    const initToken = await token.initialize(
        daoWallet, // TODO: DAO wallet
        dynamicICO.address, // dynamic_ico
        cp_ambassadors.address,
        cp_contributors.address,
        deployer.address // TODO: Devs wallet
    );
    await initToken.wait();
    console.log("token=", token.address);
    const initICO = await dynamicICO.initialize(
        token.address,
        buyingToken.address,
        cp_contributors.address,
        daoWallet, // TODO: DAO wallet
    );
    await initICO.wait();
    console.log("dynamic_ico=", dynamicICO.address);
    await cp_referrals.initialize(
        token.address,
        cp_ambassadors.address,
        cp_contributors.address,
        daoWallet, // TODO: DAO wallet
        liquidityPool, // TODO: Liquidity wallet
    )

    console.log("cp_ambassadors=", cp_ambassadors.address);
    console.log("cp_contributors=", cp_contributors.address);
    console.log("cp_referrals=", cp_referrals.address);

    console.log('Done');
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });