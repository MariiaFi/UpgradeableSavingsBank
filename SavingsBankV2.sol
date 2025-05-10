// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SavingsBank.sol";

/**
 * @title SavingsBankV2 - Upgraded Savings Contract
 * @notice Adds donation analytics and emergency pause functionality
 * @dev Maintains storage layout compatibility with V1 while adding new features
 * @custom:security This is an upgradeable contract - always verify storage layout
 */
contract SavingsBankV2 is SavingsBank {
    // Tracks cumulative sum of all donated ETH (in wei)
    uint256 private _totalDonated;
    
    // Emergency pause switch (false by default)
    bool private _paused;

    // Event emitted when pause status changes
    event PausedStatusChanged(bool paused);

    /**
     * @dev Reinitializer for upgrade to V2
     * @notice Sets initial pause state to false
     * @custom:important Must use reinitializer(2) for version upgrade
     * @custom:security Only callable during proxy upgrade process
     */
    function reinitialize() public reinitializer(2) {
        _paused = false; // Initialize pause state
    }

    /**
     * @dev Modified deposit function with pause check
     * @notice Reverts if contract is paused, otherwise processes deposit normally
     * @dev Updates total donated amount after parent contract processing
     * @override SavingsBank.deposit
     * @require Contract must not be paused
     * @require msg.value > 0 (enforced by parent)
     * @emits Deposited (from parent contract)
     */
    function deposit() external payable override {
        require(!_paused, "Contract is paused");
        super.deposit(); // Calls V1 deposit logic
        _totalDonated += msg.value; // Track new donation
    }

    /**
     * @dev Toggles emergency pause state
     * @notice Only owner can pause/unpause the contract
     * @dev Flips the _paused boolean value
     * @emits PausedStatusChanged
     * @custom:security Critical function - protected by onlyOwner
     */
    function togglePause() external onlyOwner {
        _paused = !_paused;
        emit PausedStatusChanged(_paused);
    }

    /**
     * @dev Returns total donated ETH amount
     * @notice Sum of all historical donations (in wei)
     * @return Cumulative donation amount
     * @dev Differs from totalDeposits() which counts transactions
     */
    function totalDonated() external view returns (uint256) {
        return _totalDonated;
    }

    /**
     * @dev Returns current pause status
     * @notice 'true' means contract is paused (deposits blocked)
     * @return Current pause state
     */
    function isPaused() external view returns (bool) {
        return _paused;
    }

    /**
     * @dev Returns contract version identifier
     * @notice Used for upgrade compatibility checks
     * @return Version string
     * @override SavingsBank.version
     */
    function version() external pure override returns (string memory) {
        return "V2";
    }
}
