include .env

COMPOSE=docker compose --env-file .env -f docker-compose.yml -p ${PROJECT_NAME}

PHONY: build build-contracts contracts test-contracts deploy-contracts
build:
	${COMPOSE} build

test: test-contracts


###
# Smart-Contracts docker image
###
PHONY: build-contracts contracts test-contracts deploy-contracts verify
build-contracts:
	${COMPOSE} build contracts
clean-cache:
	rm -rf smart-contracts/data/artifacts/*
	rm -rf smart-contracts/data/cache/*

contracts: build-contracts
	${COMPOSE} run --rm contracts bash

test-contracts: build-contracts
	docker-compose pull --ignore-pull-failures
	${COMPOSE} run --rm contracts npx hardhat test

compile-contracts: clean-cache build-contracts
	${COMPOSE} run --rm contracts npx hardhat compile

network=polygon_mumbai
deploy-contracts: build-contracts
	${COMPOSE} run --rm contracts npx hardhat run scripts/deploy.js --network ${network}


buyingToken= 0x013197E45393B492Df21F90C047AC2d886896529
token= 0x978b781EDf23C16F40917A51f9dc3a2643DAB581
dynamic_ico= 0x9dEcAbFedAad33d064b2AA4b9dA4C4eFbf3DE4f8
cp_ambassadors= 0xBd97A5906D8B4EEcd3afA5aB862264d6B1f1Bc6d
cp_contributors= 0xAB70aa719D2C082A0667D0822D5B1A7457e86a26
cp_referrals= 0x1ce49D69763Cde984F18bA00b5Ca4D70cfBBC88C
verify-token:
	${COMPOSE} run --rm contracts npx hardhat verify --network ${network} ${token}

verify-buyingToken:
	${COMPOSE} run --rm contracts npx hardhat verify --network ${network} --contract "contracts/mock/USDCMock.sol:USDCMock" ${buyingToken}

verify-ico:
	${COMPOSE} run --rm contracts npx hardhat verify --network ${network} ${dynamic_ico}

verify-ambassadors:
	${COMPOSE} run --rm contracts npx hardhat verify --network ${network} --contract "contracts/CommunityPoolAmbassadors.sol:FNDRCommunityPoolAmbassadors" ${cp_ambassadors} ${token}

verify-contributors:
	${COMPOSE} run --rm contracts npx hardhat verify --network ${network} --contract "contracts/CommunityPoolContributors.sol:FNDRCommunityPoolContributors" ${cp_contributors} ${token}

verify-referrals:
	${COMPOSE} run --rm contracts npx hardhat verify --network ${network} ${cp_referrals}

verify: compile-contracts verify-token verify-buyingToken verify-ico verify-ambassadors verify-contributors verify-referrals
