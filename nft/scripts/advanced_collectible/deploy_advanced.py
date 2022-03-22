from brownie import AdvancedCollectible, accounts, network, config
from scripts.helpful_scripts import fund_advanced_collectible

def main():
    account_address = accounts.add(config['wallets']['from_key'])
    publish_source = False
    advancedCollectible = AdvancedCollectible.deploy(
        config['networks'][network.show_active()]['vrf_coordinator'],
        config['networks'][network.show_active()]['link_token'],
        config['networks'][network.show_active()]['keyhash'],
        {"from": account_address},
        publish_source = publish_source
    )
    fund_advanced_collectible(advancedCollectible)
    return advancedCollectible
    