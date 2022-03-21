// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash) public
    VRFConsumer(_VRFCoordinator, _LinkToken)
    ERC721("Doggies", "DOG")
    {

    }

    function createCollectible(uint256 userProvidedSeed, string memory tokenURI) public returns (bytes32) {
        
    }

}