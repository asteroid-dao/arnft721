// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "../IASTERO721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Minter {
  address token;
  mapping(string => uint) public ids;
  mapping(string => address) public contracts;
  mapping(string => uint) public nonces;
  mapping(uint => bytes32) public long_ids;
  mapping(bytes32 => string) public short_ids;

  constructor(address _token) {
    token = _token;
  }
  
  function mint (string memory short_id, bytes memory signature, string memory arweave_tx, uint nonce, bytes32 _extra, bytes memory signature2, uint _uint, uint _uint2) public {
    require(_extra == keccak256(abi.encode(_uint, _uint2)), "extra parameters don't match");
    require(nonces[short_id] < nonce, "nonce must be greater");
    bytes32 long_id = keccak256(signature);
    address to = ECDSA.recover(IASTERO721(token).hashTypedDataV4(keccak256(abi.encode(keccak256("NFT(bytes signature,string arweave_tx,uint256 nonce,bytes32 extra)"), long_id, keccak256(bytes(arweave_tx)), nonce, _extra))), signature2);
    nonces[short_id] = nonce;
    require(ids[short_id] == 0, "id already exists");
    require(ECDSA.recover(IASTERO721(token).hashTypedDataV4(keccak256(abi.encode(keccak256("Article(string id)"), keccak256(bytes(short_id))))), signature) == to, "author is not signer");
    uint tokenId = IASTERO721(token).mint(to, arweave_tx);
    ids[short_id] = tokenId;
    contracts[short_id] = token;
    short_ids[long_id] = short_id;
    long_ids[tokenId] = long_id;
  }

  function getChainId() external view returns (uint256) {
    return block.chainid;
  }
  
}
