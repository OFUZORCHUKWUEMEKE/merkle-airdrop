// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { SignatureChecker } from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


/**
 * @title MerkleAirdrop Smart Contract
 * @author Ofuzor Chukwuemeke 
 * @author Ciara Nightingale
 * @notice 
 */
contract MerkleAirdrop is EIP712{
    using ECDSA for bytes32;
    using SafeERC20 for IERC20; // Prevent sending tokens to recipients who can’t receive
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();


    address[] claimers;
    bytes32 private immutable i_markleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address user => bool claimed) private s_hasClaimed;

    event Claim(address merkleRoot,IERC20 airdropToken);

    constructor(bytes32 merkleRoot,IERC20 airdropToken){
       i_merkleRoot = merkleRoot;
       i_airdropToken = i_airdropToken; 
    }

    /**
     * 
     * @param account account of the user that needs airdrop tokens
     * @param amount amount to be sent to the user
     * @param merkleProof the merkleProof that needs to be verified
     */ 
      // claim the airdrop using a signature from the account owner
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // Verify the signature
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // Verify the merkle proof
        // calculate the leaf node hash
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        // verify the merkle proof
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        s_hasClaimed[account] = true; // prevent users claiming more than once and draining the contract
        emit Claimed(account, amount);
        // transfer the tokens
        i_airdropToken.safeTransfer(account, amount);
    }


    function getMerkleRoot() external view returns(bytes32){
        return i_markleRoot;
    }

    function getAirdropToken() external view returns(IERC20){
        return i_airdropToken;
    }


}