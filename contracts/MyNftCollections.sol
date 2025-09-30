// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721A} from "erc721a/contracts/ERC721A.sol";

/// @notice 간단한 단일 민팅 예제를 제공하는 전통적인 OpenZeppelin ERC721 구현입니다.
contract SimpleERC721 is ERC721URIStorage, Ownable {
  uint256 private _nextTokenId = 1;

  constructor(string memory name_, string memory symbol_)
    ERC721(name_, symbol_)
    Ownable(msg.sender)
  {}

  function mintTo(address to, string memory tokenURI_) external onlyOwner {
    uint256 tokenId = _nextTokenId;
    _nextTokenId++;
    _safeMint(to, tokenId);
    _setTokenURI(tokenId, tokenURI_);
  }

  function burn(uint256 tokenId) external {
    address owner = _requireOwned(tokenId);
    _checkAuthorized(owner, msg.sender, tokenId);
    _burn(tokenId);
  }
}

/// @notice 가스 효율적인 배치 민팅을 지원하는 ERC721A 기반 컬렉션입니다.
contract SimpleERC721A is ERC721A, Ownable {
  string private baseTokenURI;
  uint96 public immutable maxSupply;
  uint64 public immutable maxPerWallet;
  uint128 public immutable mintPrice;
  bool public mintingActive;

  mapping(address => uint256) public minted;

  constructor(
    string memory collectionName,
    string memory collectionSymbol,
    string memory baseURI,
    uint96 maxSupply_,
    uint64 maxPerWallet_,
    uint128 mintPriceWei
  ) ERC721A(collectionName, collectionSymbol) Ownable(msg.sender) {
    require(maxSupply_ > 0, "Max supply required");
    baseTokenURI = baseURI;
    maxSupply = maxSupply_;
    maxPerWallet = maxPerWallet_;
    mintPrice = mintPriceWei;
    mintingActive = false;
  }

  function toggleMinting(bool active) external onlyOwner {
    mintingActive = active;
  }

  function setBaseURI(string calldata newBaseURI) external onlyOwner {
    baseTokenURI = newBaseURI;
  }

  function ownerMint(address to, uint256 quantity) external onlyOwner {
    require(totalSupply() + quantity <= maxSupply, "Exceeds max supply");
    _mint(to, quantity);
  }

  function publicMint(uint256 quantity) external payable {
    require(mintingActive, "Mint inactive");
    require(quantity > 0, "Quantity zero");
    require(totalSupply() + quantity <= maxSupply, "Exceeds max supply");
    require(minted[msg.sender] + quantity <= maxPerWallet, "Wallet limit");
    require(msg.value == uint256(mintPrice) * quantity, "Incorrect value");

    minted[msg.sender] += quantity;
    _mint(msg.sender, quantity);
  }

  function withdraw(address payable recipient) external onlyOwner {
    uint256 balance = address(this).balance;
    require(balance > 0, "Nothing to withdraw");
    recipient.transfer(balance);
  }

  function _baseURI() internal view override returns (string memory) {
    return baseTokenURI;
  }

  function _startTokenId() internal pure override returns (uint256) {
    return 1;
  }
}
