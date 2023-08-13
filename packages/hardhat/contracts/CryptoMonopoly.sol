//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./CoinToken.sol";

contract CryptoMonopoly {
    CoinToken public coin;

    // State Variables
    address public immutable owner;
    Box[] public grid;
    uint256[] prices = [20, 25, 30, 80, 85, 90, 150, 160, 170, 300, 310, 325];
    uint256[] rents = [3, 5, 7, 15, 17, 20, 40, 45, 50, 65, 70, 75];
    mapping(address => bool) public isPaid;
    mapping(address => bool) public isJail;
    mapping(address => bool) public isChest;
    mapping(address => bool) public isChance;
    mapping(address => bool) public isOwnRent;
    mapping(address => uint256) public player;
    mapping(address => uint256[]) public playerProperties;

    struct Box {
        uint256 id;
        string typeGrid;
        address owner;
        uint256 numberOfPlayers;
        uint256 price;
        uint256 rent;
        uint256 level;
    }

    event RollResult(address player, string detail, uint256 num);
    event PlayEvent(address player, string detail, uint256 num);

    // Constructor: Called once on contract deployment
    // Check packages/hardhat/deploy/00_deploy_your_contract.ts
    constructor(address _owner, address tokenAddress) {
        owner = _owner;
        coin = CoinToken(tokenAddress);

        grid.push(Box(0, "Home", address(0), 0, 0, 0, 1));

        uint256 count = 0;
        for (uint256 id = 1; id < 21; id++) {
            if (id == 5) grid.push(Box(id, "Passing", address(0), 0, 0, 0, 1));
            else if (id == 3 || id == 13) grid.push(Box(id, "Chest", address(0), 0, 0, 0, 1));
            else if (id == 8 || id == 18) grid.push(Box(id, "Chance", address(0), 0, 0, 0, 1));
            else if (id == 10) grid.push(Box(id, "Free Parking", address(0), 0, 0, 0, 1));
            else if (id == 15) grid.push(Box(id, "Go to Jail", address(0), 0, 0, 0, 1));
            else if (id == 20) grid.push(Box(id, "Jail", address(0), 0, 0, 0, 1));
            else {
                grid.push(Box(id, "Building", address(0), 0, prices[count] * 10 ** 18, rents[count] * 10 ** 18, 1));
                count += 1;
            }
        }
    }

    function getGrid() public view returns (Box[] memory){
        return grid;
    }

    function getPlayerProperties(address playerAddress) public view returns (uint256[] memory){
        return playerProperties[playerAddress];
    }

    function addPlayer() public {
        grid[0].numberOfPlayers += 1;
        coin.mint(msg.sender, 500 * 10 ** 18);
        isPaid[msg.sender] = true;

        emit PlayEvent(msg.sender, "join the game", 0);
    }

    function movePlayer() public {
        require(player[msg.sender] != 20, "You need to get out of jail to move");
        require(player[msg.sender] != 20, "You need to get out of jail to move");
        require(!isOwnRent[msg.sender], "You need pay your rent");
        grid[player[msg.sender]].numberOfPlayers -= 1;

        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp, msg.sender))) % 5;
        // uint256 randomNumber = 4;
        player[msg.sender] += randomNumber + 1;

        if (player[msg.sender] >= 20) {
            player[msg.sender] = 0;
            grid[0].numberOfPlayers += 1;
            coin.mint(msg.sender, 200 * 10 ** 18);
             emit PlayEvent(msg.sender, "earn", 200);
        }
        else if (player[msg.sender] == 15) {
            player[msg.sender] = 20;
            grid[20].numberOfPlayers += 1;
            isJail[msg.sender] = true;
            emit PlayEvent(msg.sender, "went to jail", 0);
        }
        else {
            grid[player[msg.sender]].numberOfPlayers += 1;
        }

        if (player[msg.sender] == 3 || player[msg.sender] == 13) {
            isChest[msg.sender] = true;
        }
        else if (player[msg.sender] == 8 || player[msg.sender] == 18) {
            isChance[msg.sender] = true;
        }

        if (grid[player[msg.sender]].owner != address(0) && grid[player[msg.sender]].owner != msg.sender) {
            isOwnRent[msg.sender] = true;
        }

        emit RollResult(msg.sender, "roll", randomNumber + 1);
    }

    function buyProperty() public {
        Box memory currentSpot = grid[player[msg.sender]];
        
        require(coin.balanceOf(msg.sender) >= currentSpot.price, "Not enough money");

        coin.burn(msg.sender, currentSpot.price);
        grid[player[msg.sender]].owner = msg.sender;
        playerProperties[msg.sender].push(currentSpot.id);

        emit PlayEvent(msg.sender, "brought property #", currentSpot.id);
    }

    function leaveJail() public {
        require(coin.balanceOf(msg.sender) >= 20, "Not enough money");

        coin.burn(msg.sender, 20);
        player[msg.sender] = 5;
        isJail[msg.sender] = false;
        grid[20].numberOfPlayers -= 1;
        grid[5].numberOfPlayers += 1;
        emit PlayEvent(msg.sender, "left jail", 0);
    }

    function collectChest() public {
        require(player[msg.sender] == 3 || player[msg.sender] == 13, "You cannot collect your chest");
        require(isChest[msg.sender], "You already collect your chest");

        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp, msg.sender))) % 19;
        coin.mint(msg.sender, (randomNumber + 1) * 10 ** 18);
        isChest[msg.sender] = false;
        emit PlayEvent(msg.sender, "won", randomNumber + 1);
    }

    function playChance() public {
        require(player[msg.sender] == 8 || player[msg.sender] == 18, "You cannot play chance");
        require(isChance[msg.sender], "You already played chance");

        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp, msg.sender))) % 20;
        if (randomNumber > 10)  {
            coin.mint(msg.sender, 25 * 10 ** 18);
            emit PlayEvent(msg.sender, "won", randomNumber + 1);
        } else {
            coin.burn(msg.sender, 25 * 10 ** 18);
            emit PlayEvent(msg.sender, "lost", randomNumber + 1);
        }
       
        isChance[msg.sender] = false;
    }

     function payRent() public {
        Box memory currentSpot = grid[player[msg.sender]];
        require(coin.balanceOf(msg.sender) >= currentSpot.rent, "Not enough money");

        coin.burn(msg.sender, currentSpot.rent);
        coin.mint(currentSpot.owner, currentSpot.rent);
        isOwnRent[msg.sender] = false;
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
