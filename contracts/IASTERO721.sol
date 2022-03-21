// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IASTERO721 {
  function mint(address to, string memory arweave_tx) external returns (uint tokenId);
  
}
