# Founders DAO

## Requirements:
- github
- docker

## Getting started:
- `make test` to run tests in local development environments

See the Makefile for a full list of possible operations


## Smart-contracts
Found in the `smart-contracts` folder.
### Quick access commands
- `make contracts` to start a development environment for smart-contracts and connect to it (***bash***)
- `make test-contracts` to run tests
- `make deploy-contracts` to deploy a smart contract. See ***Deploying smart-contracts*** section to setup your connections.

### Smart-contracts folder structure
- `/contracts` is where you write code for your smart-contracts
- `/test` should contain all the code used to test your smart-contracts
- `/data` contains heavy files that can be recalculated on the fly and shouldn't be saved to git
- `/scripts` has your smart-contracts lifecycle operations (deploy, etc)

### Deploying smart-contracts:
- Create a .env file (only required the first time) containing the following:
```
ALCHEMY_API_KEY = <KEY>
GOERLI_PRIVATE_KEY = <YOUR GOERLI PRIVATE KEY>
```
- add your network configuration to **hardhat.config.js** (https://hardhat.org/tutorial/deploying-to-a-live-network)
- `make deploy network=<network-name>`

