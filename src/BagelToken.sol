// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BagelToken is ERC20,Ownable {
    constructor() ERC20("Bagel Token", "BT")Ownable(msg.sender){}

    function _mint(address account,uint256 amount) external onlyOwner{
        _mint(account, amount);
    }
}