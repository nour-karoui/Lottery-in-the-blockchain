from brownie import Lottery, accounts, config, network
from web3 import Web3

def test_entrance_fee():
    account = accounts[0]
    assert network.show_active() == "mainnet-fork-dev"
    assert config["networks"][network.show_active()]["eth_usd_price_feed"] == '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419'
    lottery = Lottery.deploy(50, config["networks"][network.show_active()]["eth_usd_price_feed"], {"from": account})
    lottery.getEntranceFee()
    assert lottery.getEntranceFee() > Web3.toWei(0.039, "ether")