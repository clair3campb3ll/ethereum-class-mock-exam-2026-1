// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ERC20.sol";

// =============================================================================
// TASK 1. One thing to fill in.
// You deploy this contract twice, once for token A and once for token B.
//
// MOCK. The real exam calls this contract something else and names its arguments
// differently. Understand the line you are writing, do not memorise it.
// =============================================================================

contract PracticeToken is ERC20 {
    /// @notice Whoever deployed this token, and therefore who holds all of it.
    address public immutable issuer;

    constructor(string memory name_, string memory symbol_, uint256 startingSupply_)
        ERC20(name_, symbol_, 18)
    {
        issuer = msg.sender;

        // TODO 1.1 --------------------------------------------------------
        // Create the whole starting supply and put it in the issuer's hands.
        //
        // ERC20.sol gives you an internal function:
        //     _mint(address to, uint256 amount)
        //
        // The issuer is already stored just above. The amount is startingSupply_.
        // Write one line below.
        _mint(issuer, startingSupply_);
    }
}
