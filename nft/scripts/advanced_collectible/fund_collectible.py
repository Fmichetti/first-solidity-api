from brownie import AdvancedCollectible
from scripts.helpful_scripts import fund_advanced_collectible

def main():
    advancedCollectible = AdvancedCollectible([len(advancedCollectible) - 1])
    fund_advanced_collectible(advancedCollectible)