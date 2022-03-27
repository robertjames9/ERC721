// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Superalpha is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {
    using Counters for Counters.Counter;
    string public baseExtension = ".json";
    Counters.Counter private _tokenIdCounter;
    uint256 public price = 0.06 ether; //mint price
    uint256 public maxMintAmount = 5; //per address wallet
    uint256 public maxSupply = 2000; //total supply
    uint256[2000] public ids;
    uint256 private index;

    constructor() ERC721("Redacted Alpha Pass", "RAP") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://gateway.pinata.cloud/ipfs/QmTXA53QhVqPcSuZ6cN1mciEz4DmB359b12gxmoiU6FaCJ/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, uint256 mintAmount) public payable {
        uint256 supply = totalSupply();
        require (mintAmount > 0, "Please enter amount");
        require (mintAmount <= maxMintAmount, "Maximum mint for 5");
        require (supply + mintAmount <= maxSupply, "Exceeds max supply");
            
            if (totalSupply() <= 35) {
                require (msg.value >= price * 0 * mintAmount);
            } else {
                require (msg.value >= price * mintAmount, "No enough ETH, please check the price");
            }
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        for (uint256 i = 1; i <= mintAmount; i++){
            uint256 _random = uint256(keccak256(abi.encodePacked(index++, msg.sender, block.timestamp, blockhash(block.number-1))));
            _safeMint(to, _pickRandomUniqueId(_random));
        }
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

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        Strings.toString(tokenId),
                        baseExtension
                    )
                )
                : "";
    }
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        price = _newPrice;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    function _pickRandomUniqueId(uint256 random) private returns (uint256 id) {
    uint256 len = ids.length - index++;
    require(len > 0, 'no ids left');
    uint256 randomIndex = random % len;
    id = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;
    ids[randomIndex] = uint16(ids[len - 1] == 0 ? len - 1 : ids[len - 1]);
    ids[len - 1] = 0;
    }
}
