// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "../IASTERO721.sol";

contract Minter {
  address token;
  constructor(address _token) {
    token = _token;
  }
  function mint (string memory short_id, string memory long_id, string memory arweave_tx, uint nonce, bytes memory signature) public {
    IASTERO721(token).mint(short_id, long_id, arweave_tx, nonce, signature);
  }
}
