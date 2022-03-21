// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IASTERO721 {
  function mint(string memory short_id, bytes memory signature, string memory arweave_tx, uint nonce, bytes32 _extra, bytes memory signature2) external returns (uint tokenId);
  
}
