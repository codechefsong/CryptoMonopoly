//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./CoinToken.sol";

contract CryptoMonopoly {
    CoinToken public coin;

    // State Variables
    address public immutable owner;
    Box[] public grid;
    mapping(address => uint256) public player;

    struct Box {
        uint256 id;
        string typeGrid;
        address owner;
        uint256 numberOfPlayers;
        uint256 price;
    }

    event RollResult(address player, uint256 num);

    // Constructor: Called once on contract deployment
    // Check packages/hardhat/deploy/00_deploy_your_contract.ts
    constructor(address _owner, address tokenAddress) {
        owner = _owner;
        coin = CoinToken(tokenAddress);

        uint256 count = 1;
        for (uint256 id = 0; id < 20; id++) {
            grid.push(Box(id, "empty", address(0), 0, count * 5 * 10 ** 18));
            count += 1;
        }
    }

    function getGrid() public view returns (Box[] memory){
        return grid;
    }

    function addPlayer() public {
        grid[0].numberOfPlayers += 1;
        coin.mint(msg.sender, 100 * 10 ** 18);
    }

    function movePlayer() public {
        grid[player[msg.sender]].numberOfPlayers -= 1;

        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp, msg.sender))) % 5;
        player[msg.sender] += randomNumber + 1;

        if (player[msg.sender] >= 20) {
            player[msg.sender] = 0;
            grid[0].numberOfPlayers += 1;
        }
        else {
            grid[player[msg.sender]].numberOfPlayers += 1;
        }

        emit RollResult(msg.sender, randomNumber);
    }

    function buyProperty() public {
        Box memory currentSpot = grid[player[msg.sender]];
        
        require(coin.balanceOf(msg.sender) >= currentSpot.price);

        coin.burn(msg.sender, currentSpot.price);
        grid[player[msg.sender]].owner = msg.sender;
    }


    modifier isOwner() {
        require(msg.sender == owner, "Not the Owner");
        _;
    }

    /**
    * Function that allows the owner to withdraw all the Ether in the contract
    * The function can only be called by the owner of the contract as defined by the isOwner modifier
    */
    function withdraw() public isOwner {
        (bool success, ) = owner.call{ value: address(this).balance }("");
        require(success, "Failed to send Ether");
    }

    /**
    * Function that allows the contract to receive ETH
    */
    receive() external payable {}
}
