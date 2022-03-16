// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract ASTERO721 is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, AccessControl, ERC721Burnable {
  using Counters for Counters.Counter;
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  Counters.Counter private _tokenIdCounter;

  mapping(string => uint) public ids;
  mapping(string => uint) public nonces;
  mapping(uint => string) public long_ids;
  mapping(string => string) public short_ids;

  modifier onlyMinter() {
    require(hasRole(MINTER_ROLE,msg.sender), "only MINTER can execute");
    _;
  }
  
  constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(PAUSER_ROLE, msg.sender);
    _grantRole(MINTER_ROLE, msg.sender);
  }

  function _baseURI() internal pure override returns (string memory) {
    return "ar://";
  }

  function pause() public onlyRole(PAUSER_ROLE) {
    _pause();
  }

  function unpause() public onlyRole(PAUSER_ROLE) {
    _unpause();
  }
  
  function compare(string memory a, string memory b) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }
  
  function mint(string memory short_id, string memory long_id, string memory arweave_tx, uint nonce, bytes memory signature) public onlyMinter returns (uint tokenId) {
    require(nonces[short_id] < nonce, "nonce must be greater");
    address author = ECDSA.recover(ECDSA.toEthSignedMessageHash(abi.encodePacked(short_id)), toBytes(long_id));
    address to = ECDSA.recover(ECDSA.toEthSignedMessageHash(abi.encodePacked(long_id, "&", arweave_tx, "&", Strings.toString(nonce))), signature);
    tokenId = _tokenIdCounter.current();
    bool exists = ids[short_id] > 0;
    nonces[short_id] = nonce;
    if(!exists){
      require(author == to, "author is not signer");
      _tokenIdCounter.increment();
      ids[short_id] = tokenId;
      long_ids[tokenId] = long_id;
      short_ids[long_id] = short_id;
      _safeMint(to, tokenId);
    }else{
      require(compare(long_ids[ids[short_id]], long_id), "id must match");
      tokenId = ids[short_id];
      require(ownerOf(tokenId) == to, "signer is not owner");
    }
    _setTokenURI(tokenId, arweave_tx);
  }

  function toDec(bytes1 b) internal pure returns (uint8){
    uint8 u8 = uint8(b);
    uint8 n = u8 / 16 * 10 + u8 % 16;
    return n < 40 ? n - 30 : n - 51;
  }
  
  function toBytes(string memory a) internal pure returns (bytes memory){
    bytes memory b = bytes(a);
    uint8 n1;
    bytes memory _bytes = new bytes(b.length / 2 - 1);
    for(uint i = 2; i < b.length; i++){
      if(i % 2 == 0){
	n1 = toDec(b[i]);
      }else{
	_bytes[(i - 3) / 2] = bytes1(n1 * 16 + toDec(b[i]));
      }
    }
    return _bytes;
  }
  
  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override(ERC721, ERC721Enumerable)
  {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  // The following functions are overrides required by Solidity.

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
  {
    return super.tokenURI(tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable, AccessControl)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
  
}
