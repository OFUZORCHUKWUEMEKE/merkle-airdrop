// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


/**
 * @title MerkleAirdrop Smart Contract
 * @author Ofuzor Chukwuemeke 
 * @author Ciara Nightingale
 * @notice 
 */
contract MerkleAirdrop{
    using SafeERC20 for IERC20;
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();


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
    function claim(address account, uint256 amount,bytes32[] calldata merkleProof) external{
        // CEI , Check , Effects , Interactions
        if(s_hasClaimed[account]){
            revert MerkleAirdrop__AlreadyClaimed();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account,amount))));
        if(MerkleProof.verify(merkleProof,i_merkleRoot,leaf)){
            revert MerkleAirdrop__InvalidProof();
        }
        emit Claim(account, amount);
    }

    function getMerkleRoot() external view returns(bytes32){
        return i_markleRoot;
    }

    function getAirdropToken() external view returns(IERC20){
        return i_airdropToken;
    }


}