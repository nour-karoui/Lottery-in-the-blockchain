from .helpful_scripts import get_account, get_contract, fund_with_link_token
from brownie import Lottery, config, network
def deploy_lottery():
    account = get_account()
    lottery = Lottery.deploy(
        50,
        get_contract("eth_usd_price_feed").address,
        get_contract("link_address").address,
        get_contract("wrapper_address").address,
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"]
    )
    print("Lottery address: ", lottery.address)
    return lottery

def start_lottery():
    account = get_account()
    lottery = Lottery[-1]
    starting_transaction = lottery.startLottery({"from": account})
    starting_transaction.wait(1)

def enter_lottery():
    account = get_account()
    lottery = Lottery[-1]
    value = lottery.getEntranceFee() + 100000000
    tx = lottery.enter({"from": account, "value": value})

def end_lottery():
    account = get_account()
    lottery = Lottery[-1]
    fund_with_link_token(lottery.address)
    ending_tx = lottery.endLottery({"from": account})
    ending_tx.wait(1)
    time.sleep(120)
    winner_tx = lottery.pickWinner({"from": account})
    winner_tx.wait(1)
    print(f"{lottery.recentWinner} wins!")

def main():
    deploy_lottery()
    start_lottery()
    enter_lottery()
    end_lottery()
