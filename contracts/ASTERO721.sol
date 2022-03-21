// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "hardhat/console.sol";

contract ASTERO721 is ERC721, ERC721Royalty, ERC721Enumerable, ERC721URIStorage, Pausable, AccessControl, ERC721Burnable, EIP712 {
  using Counters for Counters.Counter;
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  Counters.Counter private _tokenIdCounter;

  mapping(string => uint) public ids;
  mapping(string => uint) public nonces;
  mapping(uint => bytes32) public long_ids;
  mapping(bytes32 => string) public short_ids;

  modifier onlyMinter() {
    require(hasRole(MINTER_ROLE,msg.sender), "only MINTER can execute");
    _;
  }
  
  constructor(string memory _name, string memory _symbol, string memory _version) ERC721(_name, _symbol)  EIP712(_name, _version) {
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
  
  function mint(string memory short_id, bytes memory signature, string memory arweave_tx, uint nonce, bytes32 _extra, bytes memory signature2) public onlyMinter returns (uint tokenId) {
    require(nonces[short_id] < nonce, "nonce must be greater");
    bytes32 long_id_32 = keccak256(signature);
    address to = ECDSA.recover(_hashTypedDataV4(keccak256(abi.encode(keccak256("NFT(bytes signature,string arweave_tx,uint256 nonce,bytes32 extra)"), long_id_32, keccak256(bytes(arweave_tx)), nonce, _extra))), signature2);
    tokenId = _tokenIdCounter.current();
    nonces[short_id] = nonce;
    if(ids[short_id] == 0){
      require(ECDSA.recover(_hashTypedDataV4(keccak256(abi.encode(keccak256("Article(string id)"), keccak256(bytes(short_id))))), signature) == to, "author is not signer");
      _tokenIdCounter.increment();
      ids[short_id] = tokenId;
      long_ids[tokenId] = long_id_32;
      short_ids[long_id_32] = short_id;
      _safeMint(to, tokenId);
    }else{
      require(long_ids[ids[short_id]] == long_id_32, "id must match");
      tokenId = ids[short_id];
      require(ownerOf(tokenId) == to, "signer is not owner");
    }
    _setTokenURI(tokenId, arweave_tx);
  }
  
  function getChainId() external view returns (uint256) {
    return block.chainid;
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override(ERC721, ERC721Enumerable)
  {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage, ERC721Royalty) {
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
    override(ERC721, ERC721Enumerable, AccessControl, ERC721Royalty)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}
