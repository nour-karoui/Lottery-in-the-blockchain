HELLO <img src="https://raw.githubusercontent.com/MartinHeinz/MartinHeinz/master/wave.gif" width="30px"> This is LOTTERY IN THE BLOCKCHAIN
---
## What is Lottery in the blockchain?

It is a **decentralized app** hosted on **Goerli Testnet** built with ***Brownie Framework*** and ***Web3.py*** Library.

1. The contract owner starts the lottery
2. Gamblers can enter Lottery with ETH based on USD
3. The contract owner will choose when the lottery is over
4. A winner is selected randomly, and he gets to win all the ether in the contract

## Install Dependencies
#### In order to compile and deploy the contracts locally or on a testnet, you need to have ***Ganache and Metamask***

Run this command to install dependencies:
```shell
    pip3 install eth-brownie python-dotenv pytest
```
For me, I had to install a virtual environment before installing dependencies;
check out this [link](https://stackoverflow.com/questions/69819421/importerror-no-module-named-solcx) for more details

## Compile Contracts
To compile the contracts, simply run this command:
```shell
    brownie compile
```
## Deploy Contracts
Before deploying the contract, you first have to make sure to fill the .env file. Check .env.example

#### Locally
run this command:
```shell
    ganache-cli
```
and then in another terminal, run this command
```shell
    brownie run scripts/deploy_lottery.py
```
**Here is the result of deploying the contract locally**
## <img width="736" alt="image" src="https://user-images.githubusercontent.com/47257753/207886837-379c7e3a-31d6-4b42-8b35-380d119ed80e.png">

#### Testnet
```shell
    brownie run scripts/deploy_lottery.py --network goerli
```
> Deploying the contract on a Testnet takes more time than deploying it locally so be patient.

Here is the result of Deploying the contract on Goerli, you can verify it on [etherscan](https://goerli.etherscan.io/tx/0xf0994973fb6ca791b6bdb864700b42077a8938a447175ae1d591419c341e2f2c)
## <img width="739" alt="image" src="https://user-images.githubusercontent.com/47257753/207889441-318e2e17-210d-4889-94c2-80113d3deea3.png">

#### RemixIDE
Copy and paste the content of contracts/Lottery.sol in RemixIDE and play with it

## Testing the Contract's Functionalities
To test the functionalities of our smart contract, you can first do that manually by going to scripts/deploy_lottery.py and uncomment the method calls, as shown in the screenshot below
## <img width="212" alt="image" src="https://user-images.githubusercontent.com/47257753/207891013-03412e8b-0f51-4713-b29b-8dab0c0afc57.png">
and run the command
```shell
    brownie run scripts/deploy_lottery.py --network goerli
```
### Limitations
> Locally, end_lottery() and pick_winner() won't work because we are using contract deployed on the blockchain and for the VRFV2Wrapper there are no current mocks that we can use

### Automated Testing
**Unit Tests** will only run on a development local blockchain with this command
```shell
    brownie test -s
```
**Integration Tests** will only run on a Testnet with this command
```shell
    brownie test -s --network goerli
```
