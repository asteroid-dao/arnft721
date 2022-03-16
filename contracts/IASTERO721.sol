// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IASTERO721 {
  function mint(string memory short_id, string memory long_id, string memory arweave_tx, uint nonce, bytes memory signature) external returns (uint tokenId);
  
}
