// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "../IASTERO721.sol";

contract Minter {
  address token;
  constructor(address _token) {
    token = _token;
  }
  function mint (string memory short_id, bytes memory signature, string memory arweave_tx, uint nonce, bytes32 _extra, bytes memory signature2, uint _uint, uint _uint2) public {
    require(_extra == keccak256(abi.encode(_uint, _uint2)), "extra parameters don't match");
    IASTERO721(token).mint(short_id, signature, arweave_tx, nonce, _extra, signature2);
  }
}
