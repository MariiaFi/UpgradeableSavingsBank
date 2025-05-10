// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import OpenZeppelin upgradeable contracts
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title SavingsBank - Decentralized Upgradeable Savings Contract
 * @notice Allows users to deposit ETH and tracks donations with upgrade capability
 * @dev Implements UUPS upgrade pattern, owner-only withdrawals and donation tracking
 */
contract SavingsBank is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    // Tracks total number of deposits (not sum of amounts)
    uint256 private _totalDeposits;

    // Events
    event Deposited(address indexed sender, uint256 amount);
    event Withdrawn(address indexed receiver, uint256 amount);

    // Donation structure to store donation metadata
    struct Donation {
        address sender;     // Donor's address
        uint256 amount;     // Donated amount in wei
        uint256 timestamp;  // Block timestamp of donation
    }

    // Dynamic array storing all donations
    Donation[] private _donations;

    /**
     * @dev Constructor that disables initializers for direct deployment
     * @notice This contract should ONLY be deployed as a proxy
     */
    constructor() {
        _disableInitializers(); // Prevents direct deployment
    }

    /**
     * @dev Initializer function (replaces constructor for upgradeable contracts)
     * @notice Sets the contract owner and initializes upgrade functionality
     * @custom:important Must be called during proxy deployment
     */
    function initialize() public initializer {
        __Ownable_init(msg.sender); // Sets deployer as owner
        __UUPSUpgradeable_init();   // Initializes upgrade mechanism
    }

    /**
     * @dev Authorization function for upgrades
     * @param newImplementation Address of the new logic contract
     * @notice Only callable by the contract owner
     * @custom:security This critical function is protected by onlyOwner
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Accepts ETH deposits and records them as donations
     * @notice Anyone can deposit ETH which gets recorded in donations array
     * @dev Emits Deposited event on success
     * @require msg.value must be greater than 0
     * @custom:warning Donated ETH is immediately locked in contract
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be positive");
        _donations.push(Donation(msg.sender, msg.value, block.timestamp));
        _totalDeposits++;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Withdraws all contract ETH to owner
     * @notice Only contract owner can withdraw funds
     * @dev Emits Withdrawn event on success
     * @require Contract balance must be greater than 0
     * @custom:danger This transfers ALL contract ETH to owner
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");

        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Transfer failed");

        emit Withdrawn(owner(), balance);
    }

    /**
     * @dev Returns current contract ETH balance
     * @return Contract balance in wei
     * @notice Useful for checking total locked value
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Returns total donation count
     * @return Length of donations array
     * @notice Doesn't reflect sum amounts, just transaction count
     */
    function getDonationCount() external view returns (uint256) {
        return _donations.length;
    }

    /**
     * @dev Returns specific donation details
     * @param index Array position to query (0-based)
     * @return sender Donor address
     * @return amount Donated amount in wei
     * @return timestamp Block time of donation
     * @require Index must be less than donations array length
     */
    function getDonation(uint256 index)
        external
        view
        returns (address sender, uint256 amount, uint256 timestamp)
    {
        require(index < _donations.length, "Invalid index");
        Donation memory d = _donations[index];
        return (d.sender, d.amount, d.timestamp);
    }

    /**
     * @dev Returns total deposit transactions count
     * @return Number of all-time deposits
     * @notice Different from donation sum - counts transactions not amounts
     */
    function totalDeposits() external view returns (uint256) {
        return _totalDeposits;
    }

    /**
     * @dev Returns contract version
     * @return Version string
     * @notice Useful for upgrade compatibility checks
     */
    function version() external pure virtual returns (string memory) {
        return "V1";
    }
}
