// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IASTERO721 is IERC721 {
  
  function mint(address to, string memory arweave_tx) external returns (uint tokenId);
  
  function tokenURI(uint256 tokenId) external view returns (string memory);

  function setTokenURI(uint tokenId, string memory arweave_tx) external;

  function hashTypedDataV4(bytes32 structHash) external view returns (bytes32);

  function setBaseURI(string memory _str) external;
  
}
