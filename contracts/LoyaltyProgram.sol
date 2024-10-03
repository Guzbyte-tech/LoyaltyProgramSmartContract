// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LoyaltyProgram is ERC20, Ownable, ReentrancyGuard {
    // Struct to store user information
    struct User {
        uint256 points;
        uint256 lastActivity; // To track activity for expiration
    }

    mapping(address => User) private users;

    // Configurable expiration period for loyalty points (in seconds)
    uint256 public expirationPeriod;

    event PointsIssued(address indexed user, uint256 amount);


    event PointsRedeemed(address indexed user, uint256 amount);


    event PointsExpired(address indexed user, uint256 amount);

    // Mapping to handle approved partners/vendors for redeeming points
    mapping(address => bool) public approvedPartners;

    // Maximum points a user can redeem at once (safety limit)
    uint256 public maxRedeemablePoints;


    constructor(
        address initialOwner,
        string memory name,
        string memory symbol,
        uint256 _expirationPeriod,
        uint256 _maxRedeemablePoints
    ) ERC20(name, symbol) Ownable(initialOwner) {
        expirationPeriod = _expirationPeriod;
        maxRedeemablePoints = _maxRedeemablePoints;
        _mint(initialOwner, 1000000 * 10 ** decimals()); // Initial supply to the owner
    }

    // Function to issue loyalty points to a user (onlyOwner)
    function issuePoints(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Invalid user address");
        require(amount > 0, "Amount must be greater than zero");

        _mint(to, amount);
        users[to].points += amount;
        users[to].lastActivity = block.timestamp;

        emit PointsIssued(to, amount);
    }

    // Function to redeem loyalty points (non-reentrant for added security)
    function redeemPoints(address from, uint256 amount) public nonReentrant onlyOwner {
        require(from != address(0), "Invalid user address");
        require(amount > 0, "Amount must be greater than zero");
        require(users[from].points >= amount, "Insufficient points");
        require(amount <= maxRedeemablePoints, "Exceeds max redeemable limit");

        _burn(from, amount);
        users[from].points -= amount;

        emit PointsRedeemed(from, amount);
    }

    // Function to check and expire points if they are past the expiration period
    function expirePoints(address user) public onlyOwner {
        require(user != address(0), "Invalid user address");
        uint256 timeElapsed = block.timestamp - users[user].lastActivity;
        if (timeElapsed >= expirationPeriod) {
            uint256 expiredAmount = users[user].points;
            users[user].points = 0;

            emit PointsExpired(user, expiredAmount);
        }
    }

    // Function to add or remove an approved partner for redeeming points
    function setApprovedPartner(address partner, bool status) public onlyOwner {
        require(partner != address(0), "Invalid partner address");
        approvedPartners[partner] = status;
    }

    // Function to redeem points with an approved partner
    function redeemWithPartner(
        address from,
        uint256 amount,
        address partner
    ) public nonReentrant {
        require(approvedPartners[partner], "Partner not approved");
        require(users[from].points >= amount, "Insufficient points");
        require(amount <= maxRedeemablePoints, "Exceeds max redeemable limit");

        _burn(from, amount);
        users[from].points -= amount;

        emit PointsRedeemed(from, amount);
    }

    // View function to check points balance of a user
    function getPointsBalance(address user) public view returns (uint256) {
        return users[user].points;
    }

    // View function to check if points are expired
    function isExpired(address user) public view returns (bool) {
        uint256 timeElapsed = block.timestamp - users[user].lastActivity;
        return timeElapsed >= expirationPeriod;
    }

    // Function to update the expiration period (onlyOwner)
    function updateExpirationPeriod(uint256 newExpirationPeriod) public onlyOwner {
        expirationPeriod = newExpirationPeriod;
    }

    // Function to update the max redeemable points limit (onlyOwner)
    function updateMaxRedeemablePoints(uint256 newMaxRedeemablePoints) public onlyOwner {
        maxRedeemablePoints = newMaxRedeemablePoints;
    }
}
