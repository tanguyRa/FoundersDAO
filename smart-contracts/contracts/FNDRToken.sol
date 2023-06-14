// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// snippet-start: Token name
contract FNDRToken is ERC20, ERC20Capped, Ownable {
    // snippet-end: Token name

    // start-snippet: repartition addresses [definition]
    bool internal initialized;
    address public dao_reserve_addr;
    address public dynamic_ico_addr;
    address public community_pool_ambassadors_addr;
    address public community_pool_contributors_addr;
    address public team_addr;
    // end-snippet: repartition addresses [definition]

    uint256 public totalTokenBurnt;

    constructor() ERC20("FNDRToken", "FNDR") ERC20Capped(2 * 10 ** (9 + 18)) {
        // No constructor, because repartition addresses can cause mutual dependencies
    }

    // start-snippet: Initialize [repartition addresses > 0]
    function initialize(
        // start-snippet: repartition addresses [constructor args]
        address _dao_reserve,
        address _dynamic_ico,
        address _community_pool_ambassadors,
        address _community_pool_contributors,
        address _team // end-snippet: repartition addresses [constructor args]
    ) public {
        require(!initialized, "FiatToken: contract is already initialized");
        initialized = true;

        // start-snippet: mintable = false
        uint256 totalMinted = 2 * 10 ** (9 + 18);
        // end-snippet: mintable = false

        // start-snippet: repartition addresses [constructor init]
        dao_reserve_addr = _dao_reserve;
        dynamic_ico_addr = _dynamic_ico;
        community_pool_ambassadors_addr = _community_pool_ambassadors;
        community_pool_contributors_addr = _community_pool_contributors;
        team_addr = _team;
        // end-snippet: repartition addresses [constructor init]

        // start-snippet: repartition addresses [minting distribution]
        _mint(dao_reserve_addr, ((totalMinted * 20) / 100));
        _mint(dynamic_ico_addr, ((totalMinted * 50) / 100));
        _mint(community_pool_ambassadors_addr, ((totalMinted * 5) / 100));
        _mint(community_pool_contributors_addr, ((totalMinted * 5) / 100));
        _mint(team_addr, ((totalMinted * 20) / 100));
        // end-snippet: repartition addresses [minting distribution]
    }

    // end-snippet: Initialize [repartition addresses > 0]

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Capped) {
        super._mint(to, amount);
    }

    /*
     * @dev Destroy tokens. Used when certifying water.
     * @param amount The amount to burn.
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        totalTokenBurnt += amount;
    }
}
