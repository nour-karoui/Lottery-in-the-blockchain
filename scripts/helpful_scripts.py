from brownie import config, network, accounts, MockV3Aggregator, LinkToken, VRFCoordinatorV2Mock, Contract
from web3 import Web3

LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork-dev"]
DECIMALS = 18
STARTING_PRICE = 20000000000000000

contract_to_mock = {
    "eth_usd_price_feed": MockV3Aggregator,
    "wrapper_address": VRFCoordinatorV2Mock,
    "link_address": LinkToken
}

def get_account(index=None, id=None):
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS or network.show_active() in FORKED_LOCAL_ENVIRONMENTS:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

def deploy_mocks(decimals=DECIMALS, starting_price=STARTING_PRICE):
        account = get_account()
        aggregator_address = MockV3Aggregator.deploy(decimals, starting_price, {"from": account})
        link_token = LinkToken.deploy({"from": account})
        coordinator_address = VRFCoordinatorV2Mock.deploy(100000, 100000, {"from": account})
        print("Deployed!")

def fund_with_link_token(contract_address, account=None, link_token=None, amount=300000000000000000):
    account = account if account else get_account()
    link_token = link_token if link_token else get_contract("link_address")
    tx = link_token.transfer(contract_address, amount, {"from": account})
    tx.wait(1)
    print("Contract Funded")

def get_contract(contract_name):
    contract_type = contract_to_mock[contract_name]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(
                    contract_type._name, contract_address, contract_type.abi
                )
    return contract