//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./CoinToken.sol";

contract CryptoMonopoly {
    CoinToken public coin;

    // State Variables
    address public immutable owner;
    Box[] public grid;
    mapping(address => bool) public isPaid;
    mapping(address => bool) public isJail;
    mapping(address => bool) public isChestChance;
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

        grid.push(Box(0, "Home", address(0), 0, 0));

        uint256 count = 1;
        for (uint256 id = 1; id < 21; id++) {
            if (id == 5) grid.push(Box(id, "Passing", address(0), 0, 0));
            else if (id == 3 || id == 13) grid.push(Box(id, "Chest", address(0), 0, 0));
            else if (id == 10) grid.push(Box(id, "Free Parking", address(0), 0, 0));
            else if (id == 15) grid.push(Box(id, "Go to Jail", address(0), 0, 0));
            else if (id == 20) grid.push(Box(id, "Jail", address(0), 0, 0));
            else {
                grid.push(Box(id, "Building", address(0), 0, count * 10 * 10 ** 18));
                count += 1;
            }
        }
    }

    function getGrid() public view returns (Box[] memory){
        return grid;
    }

    function addPlayer() public {
        grid[0].numberOfPlayers += 1;
        coin.mint(msg.sender, 1000 * 10 ** 18);
        isPaid[msg.sender] = true;
    }

    function movePlayer() public {
        require(player[msg.sender] != 20, "You need to get out of jail to move");
        require(player[msg.sender] != 3 || player[msg.sender] != 13, "You need to collect your chest");
        grid[player[msg.sender]].numberOfPlayers -= 1;

        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp, msg.sender))) % 5;
        // uint256 randomNumber = 4;
        player[msg.sender] += randomNumber + 1;

        if (player[msg.sender] >= 20) {
            player[msg.sender] = 0;
            grid[0].numberOfPlayers += 1;
        }
        else if (player[msg.sender] == 15) {
            player[msg.sender] = 20;
            grid[20].numberOfPlayers += 1;
            isJail[msg.sender] = true;
        }
        else {
            grid[player[msg.sender]].numberOfPlayers += 1;
        }

        if (player[msg.sender] == 3 || player[msg.sender] == 13) {
            isChestChance[msg.sender] = true;
        }

        emit RollResult(msg.sender, randomNumber);
    }

    function buyProperty() public {
        Box memory currentSpot = grid[player[msg.sender]];
        
        require(coin.balanceOf(msg.sender) >= currentSpot.price, "Not enough money");

        coin.burn(msg.sender, currentSpot.price);
    }

    function leaveJail() public {
        require(coin.balanceOf(msg.sender) >= 20, "Not enough money");

        coin.burn(msg.sender, 20);
        player[msg.sender] = 5;
        isJail[msg.sender] = false;
        grid[20].numberOfPlayers -= 1;
        grid[5].numberOfPlayers += 1;
    }

    function collectChest() public {
        require(player[msg.sender] == 3 || player[msg.sender] == 13, "You cannot collect your chest");
        require(isChestChance[msg.sender], "You already collect your chest");

        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp, msg.sender))) % 19;
        coin.mint(msg.sender, (randomNumber + 1) * 10 ** 18);
        isChestChance[msg.sender] = false;
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
