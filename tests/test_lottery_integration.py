from brownie import Lottery, accounts, network, config
import pytest
import time
from scripts.helpful_scripts import fund_with_link_token, get_account, get_contract, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.deploy_lottery import deploy_lottery
from web3 import Web3

def test_can_pick_winner():
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()
    print("starting test_can_pick_winner")
    lottery = Lottery[-1]
    print("here is the lottery", lottery)
    account = get_account()
    print("i got the account and the lottery", account)
    lottery.startLottery({"from": account})
    print("The lottery is started, let the game begin")
    lottery.enter({"from": account, "value": Web3.toWei("0.042", "ether")})
    print("We have a new joiner, Houray!")
    fund_with_link_token(lottery)
    print("The lottery is funded, let's pick the winner")
    lottery.endLottery({"from": account})
    print("We ended the lottery")
    time.sleep(120)
    lottery.pickWinner({"from": account})
    print("The winner is", lottery.recentWinner())
    assert lottery.recentWinner() == account