// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import the Interface of the ERC-20 standard
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 

/** 
 * @title Defi Staking 
 * @dev Implements Defi Staking for Feufo firm
 */
contract Feufo {
    IERC20 public feufoToken;

    mapping(address => uint256) public dAmounts; // The Staked Amount
    mapping(address => uint256) public dRewards; //
    mapping(address => uint256) public dBlock;  // The last claimed block

    uint256 public constant rewardRate = 1 ether; // 1 DEFI per day per 1000 DEFI staked
    uint256 public constant blocksPerDay = 14400; // Assuming 6s block time

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

   // Create a new Feufo Token'.
    constructor(address _feufoToken) {
        feufoToken = IERC20(_feufoToken);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0 tokens. Please check and try again.");
        require(feufoToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        updateReward(msg.sender);

        dAmounts[msg.sender] += amount;

        emit Staked(msg.sender, amount);
    }

    function withdraw() external {
        uint256 amount = dAmounts[msg.sender];
        require(amount > 0, "No tokens staked");

        updateReward(msg.sender);

        uint256 reward = dRewards[msg.sender];
        uint256 totalAmount = amount + reward;

        dAmounts[msg.sender] = 0;
        dRewards[msg.sender] = 0;
        
        require(feufoToken.transfer(msg.sender, totalAmount), "Transfer failed");

        emit Withdrawn(msg.sender, totalAmount);
        emit RewardPaid(msg.sender, reward);
    }

    function viewReward(address user) external view returns (uint256) {
        uint256 reward = dRewards[user];
        uint256 blocksSinceLastClaim = block.number - dBlock[user];
        uint256 additionalReward = (blocksSinceLastClaim * dAmounts[user] * rewardRate) / (blocksPerDay * 1000);
        return reward + additionalReward;
    }

    function updateReward(address user) internal {
        uint256 blocksSinceLastClaim = block.number - dBlock[user];
        uint256 additionalReward = (blocksSinceLastClaim * dAmounts[user] * rewardRate) / (blocksPerDay * 1000);
        dRewards[user] += additionalReward;
        dBlock[user] = block.number;
    }
}
