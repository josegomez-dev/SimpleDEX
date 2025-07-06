// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title TokenA - Basic ERC-20 Token for DEX Testing
/// @notice This token is used as one of the trading pairs in a decentralized exchange
/// @dev Implements a basic ERC-20 standard with allowance and transferFrom logic
contract TokenA {
    string public constant name = "TokenA";           // Token name
    string public constant symbol = "TKA";            // Token symbol
    uint8 public constant decimals = 18;              // Decimal precision (18 standard)

    uint256 public totalSupply_;                      // Total token supply

    mapping(address => uint256) private balances;     // Address => Token balance
    mapping(address => mapping(address => uint256)) private allowed;  // Allowances

    /// @notice Emitted when tokens are transferred between addresses
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when an address is approved to spend tokens
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Constructor that mints the total supply to the deployer
    /// @param total The total token supply (in wei, e.g. 1_000_000 * 10^18)
    constructor(uint256 total) {
        totalSupply_ = total;
        balances[msg.sender] = total;
    }

    /// @notice Returns the total token supply
    function totalSupply() external view returns (uint256) {
        return totalSupply_;
    }

    /// @notice Returns the balance of a specific address
    /// @param tokenOwner The address to query
    function balanceOf(address tokenOwner) external view returns (uint256) {
        return balances[tokenOwner];
    }

    /// @notice Transfers tokens from the caller to a specified address
    /// @param receiver The destination address
    /// @param numTokens The number of tokens to transfer
    /// @return success Whether the transfer was successful
    function transfer(address receiver, uint256 numTokens) external returns (bool success) {
        require(numTokens <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;

        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    /// @notice Approves a delegate to spend tokens on behalf of the caller
    /// @param delegate The address allowed to spend tokens
    /// @param numTokens The number of tokens allowed
    /// @return success Whether the approval succeeded
    function approve(address delegate, uint256 numTokens) external returns (bool success) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    /// @notice Returns how many tokens a delegate is approved to spend
    /// @param owner The token owner
    /// @param delegate The approved spender
    /// @return The number of tokens remaining
    function allowance(address owner, address delegate) external view returns (uint256) {
        return allowed[owner][delegate];
    }

    /// @notice Transfers tokens using the allowance mechanism
    /// @param owner The address from which tokens are pulled
    /// @param buyer The address receiving tokens
    /// @param numTokens The number of tokens to transfer
    /// @return success Whether the transfer succeeded
    function transferFrom(address owner, address buyer, uint256 numTokens) external returns (bool success) {
        require(numTokens <= balances[owner], "Insufficient balance");
        require(numTokens <= allowed[owner][msg.sender], "Allowance exceeded");

        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;

        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}
