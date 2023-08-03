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
        address player;
    }

    event RollResult(address player, uint256 num);

    // Constructor: Called once on contract deployment
    // Check packages/hardhat/deploy/00_deploy_your_contract.ts
    constructor(address _owner, address tokenAddress) {
        owner = _owner;
        coin = CoinToken(tokenAddress);

        for (uint256 id = 0; id < 20; id++) {
            grid.push(Box(id, "empty", address(0), address(0)));
        }
    }

    function getGrid() public view returns (Box[] memory){
        return grid;
    }

    function addPlayer() public {
        grid[0].player = msg.sender;
        coin.mint(msg.sender, 100 * 10 ** 18);
    }

    function movePlayer() public {
        grid[player[msg.sender]].player = address(0);

        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp, msg.sender))) % 5;
        player[msg.sender] += randomNumber + 1;

        if (player[msg.sender] >= 20) {
            player[msg.sender] = 0;
            grid[0].player = msg.sender;
        }

        grid[player[msg.sender]].player = msg.sender;

        emit RollResult(msg.sender, randomNumber);
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
