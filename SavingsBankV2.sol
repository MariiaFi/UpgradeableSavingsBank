// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import OpenZeppelin upgradeable contracts
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title SavingsBankV2 - Decentralized Upgradeable Savings Contract
 * @notice Enhanced version with donation analytics and emergency pause functionality
 * @dev Maintains storage compatibility with V1 while adding new features
 * @custom:security This is an upgradeable contract - always verify storage layout
 */
contract SavingsBankV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    // V1 Storage - must maintain layout for upgrades
    uint256 private _totalDeposits; // Counts all deposit transactions
    
    // Donation tracking from V1
    struct Donation {
        address sender;     // Donor's address
        uint256 amount;     // Donated amount in wei
        uint256 timestamp;  // Block timestamp of donation
    }
    Donation[] private _donations; // Historical donations array

    // V2 New Storage Variables
    uint256 private _totalDonated; // Cumulative sum of all donations (wei)
    bool private _paused;          // Emergency pause state

    // Events
    event Deposited(address indexed sender, uint256 amount);
    event Withdrawn(address indexed receiver, uint256 amount);
    event PausedStatusChanged(bool paused); // V2 addition

    /**
     * @dev Constructor that disables initializers for direct deployment
     * @notice This contract should ONLY be deployed as a proxy
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializer function (replaces constructor for upgradeable contracts)
     * @notice Sets the contract owner and initial state
     * @custom:important Must be called during proxy deployment
     */
    function initialize() public initializer {
        __Ownable_init(msg.sender); // Sets deployer as owner
        __UUPSUpgradeable_init();   // Initializes upgrade mechanism
        _paused = false;            // V2: Initialize pause state
    }

    /**
     * @dev Authorization function for upgrades
     * @param newImplementation Address of the new logic contract
     * @notice Only callable by the contract owner
     * @custom:security This critical function is protected by onlyOwner
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Deposit function with pause check
     * @notice Accepts ETH deposits when not paused, tracks donations
     * @require Contract must not be paused
     * @require msg.value > 0
     * @emits Deposited
     */
    function deposit() external payable {
        require(!_paused, "Contract is paused");
        require(msg.value > 0, "Deposit amount must be positive");
        
        _donations.push(Donation(msg.sender, msg.value, block.timestamp));
        _totalDeposits++;
        _totalDonated += msg.value; // V2: Track cumulative amount
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Withdraw contract balance to owner
     * @notice Only owner can withdraw all accumulated ETH
     * @require Contract must have positive balance
     * @emits Withdrawn
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Transfer failed");
        emit Withdrawn(owner(), balance);
    }

    // ========== V2 SPECIFIC FUNCTIONS ========== //

    /**
     * @dev Toggles emergency pause state
     * @notice Only owner can pause/unpause the contract
     * @emits PausedStatusChanged
     * @custom:security Protected by onlyOwner modifier
     */
    function togglePause() external onlyOwner {
        _paused = !_paused;
        emit PausedStatusChanged(_paused);
    }

    // ========== VIEW FUNCTIONS ========== //

    /**
     * @dev Returns current contract ETH balance
     * @return Contract balance in wei
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Returns donation details by index
     * @param index Position in donations array
     * @return sender Donor address
     * @return amount Donated amount in wei
     * @return timestamp Block time of donation
     */
    function getDonation(uint256 index) external view returns (address, uint256, uint256) {
        require(index < _donations.length, "Invalid index");
        Donation memory d = _donations[index];
        return (d.sender, d.amount, d.timestamp);
    }

    /**
     * @dev Returns total deposit transactions count
     * @return Number of all-time deposits
     * @notice Counts transactions, not amounts
     */
    function totalDeposits() external view returns (uint256) {
        return _totalDeposits;
    }

    /**
     * @dev Returns total donated ETH amount (V2)
     * @return Cumulative donation amount in wei
     * @notice New in V2 - tracks sum amounts
     */
    function totalDonated() external view returns (uint256) {
        return _totalDonated;
    }

    /**
     * @dev Returns current pause status (V2)
     * @return true if contract is paused
     */
    function isPaused() external view returns (bool) {
        return _paused;
    }

    /**
     * @dev Returns contract version identifier
     * @return Version string
     * @notice Used for upgrade compatibility checks
     */
    function version() external pure returns (string memory) {
        return "V2";
    }
}
