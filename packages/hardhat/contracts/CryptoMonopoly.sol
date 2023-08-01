//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract CryptoMonopoly {
    // State Variables
    address public immutable owner;
    Box[] public grid;
    mapping(address => uint256) public player;

    struct Box {
        uint256 id;
        string typeGrid;
        address owner;
    }

    event RollResult(address player, uint256 num);

    // Constructor: Called once on contract deployment
    // Check packages/hardhat/deploy/00_deploy_your_contract.ts
    constructor(address _owner) {
        owner = _owner;

        for (uint256 id = 0; id < 20; id++) {
            grid.push(Box(id, "empty", address(0)));
        }
    }

    function getGrid() public view returns (Box[] memory){
        return grid;
    }

    function movePlayer() public {
      uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp, msg.sender))) % 5;
      player[msg.sender] += randomNumber + 1;

      if (player[msg.sender] >= 20) {
        player[msg.sender] = 0;
      }

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
