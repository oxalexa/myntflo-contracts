// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract MyntfloToken is ERC20, ERC20Burnable, Pausable, ERC2771Context {

    constructor(MinimalForwarder forwarder, uint256 initialSupply) ERC20("Myntflo", "MYNT") ERC2771Context(address(forwarder)){
        _mint(msg.sender, initialSupply);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override{
        super._beforeTokenTransfer(from, to, amount);
    }

    function _msgSender() internal view override(Context, ERC2771Context) returns (address sender) {
        sender = ERC2771Context._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Context) returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

}