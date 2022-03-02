// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BPSC is ERC721, PullPayment, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private tokenCounter;

    uint256 public constant _mintPrice = 0.02 ether;
    uint256 public constant _presaleFirstMintPrice = 0.01 ether;
    uint8 public constant _maxMintPerTx = 5;
    uint256 public constant _maxSupply = 10;
    string public constant _baseFileType = ".json";

    string public _provenance;
    string public _hiddenMetadataURI;
    string public _baseTokenURI;
    string public _contractMetadataURI;

    bool public isPublicSaleActive = false;
    bool public isPresaleActive = false;
    bool public isRevealed = false;

    struct Whitelist {
        address addr;
        uint256 hasMinted;
    }
    mapping(address => Whitelist) public whitelist;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _hiddenMetadata,
        string memory _contractMetadata
    ) ERC721(_name, _symbol) {
        setContractMetadataURI(_contractMetadata);
        setHiddenMetadataURI(_hiddenMetadata);
    }

    /////////////////////////////////////////////////////////////////////
    /// Overriden functions

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: Nonexistent token");
        return
            isRevealed
                ? string(
                    abi.encodePacked(
                        _baseTokenURI,
                        tokenId.toString(),
                        _baseFileType
                    )
                )
                : _hiddenMetadataURI;
    }

    /////////////////////////////////////////////////////////////////////
    /// Setters

    function setBaseTokenURI(string memory _newBaseURI) public onlyOwner {
        _baseTokenURI = _newBaseURI;
    }

    function setContractMetadataURI(string memory _newContractMetadataURI)
        public
        onlyOwner
    {
        _contractMetadataURI = _newContractMetadataURI;
    }

    function setHiddenMetadataURI(string memory _newHiddenMetadataURI)
        public
        onlyOwner
    {
        _hiddenMetadataURI = _newHiddenMetadataURI;
    }

    function setProvenanceHash(string memory _provenanceHash) public onlyOwner {
        _provenance = _provenanceHash;
    }

    function flipPublicSaleState() public onlyOwner {
        isPublicSaleActive = !isPublicSaleActive;
    }

    function flipPresaleState() public onlyOwner {
        isPresaleActive = !isPresaleActive;
    }

    function flipRevealed() public onlyOwner {
        isRevealed = !isRevealed;
    }

    /////////////////////////////////////////////////////////////////////
    /// OTHER

    function totalSupply() public view returns (uint256) {
        return tokenCounter.current();
    }

    function withdrawPayments(address payable payee)
        public
        virtual
        override
        onlyOwner
    {
        (bool success, ) = payable(payee).call{value: address(this).balance}(
            ""
        );
        require(success);
    }

    /////////////////////////////////////////////////////////////////////
    /// MINT

    function presaleFirstMint() public payable {
        require(
            isWhitelisted(msg.sender),
            "Address must be whitelisted to mint"
        );
        require(
            whitelist[msg.sender].hasMinted == 0,
            "Already minted the token, please wait until presale mint"
        );
        require(
            msg.value >= _presaleFirstMintPrice,
            "Ether value sent is not correct"
        );
        _mintTokens(msg.sender, 1);
        whitelist[msg.sender].hasMinted = 1;
    }

    function mint(uint256 _mintAmount)
        public
        payable
        mintCompliance(_mintAmount)
    {
        if (isPresaleActive) {
            require(
                isWhitelisted(msg.sender),
                "Address must be whitelisted to mint"
            );
        } else
            require(isPublicSaleActive, "Public sale must be active to mint");

        _mintTokens(msg.sender, _mintAmount);
    }

    function airdropMint(address _addressToAirdrop) public onlyOwner {
        require(
            totalSupply().add(1) <= _maxSupply,
            "Purchase would exceed max supply"
        );
        _mintTokens(_addressToAirdrop, 1);
    }

    function reserveToken(uint256 _reserveAmount) public onlyOwner {
        require(
            totalSupply().add(_reserveAmount) <= _maxSupply,
            "Purchase would exceed max supply"
        );
        _mintTokens(msg.sender, _reserveAmount);
    }

    function _mintTokens(address _receiver, uint256 _mintAmount) internal {
        for (uint256 i = 0; i < _mintAmount; i++) {
            tokenCounter.increment();
            _safeMint(_receiver, tokenCounter.current());
        }
    }

    /////////////////////////////////////////////////////////////////////
    /// WHITELIST

    function addAddressesToWhitelist(address[] memory addrs) public onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            require(!isWhitelisted(addrs[i]), "Address already whitelisted");
            whitelist[addrs[i]].addr = addrs[i];
            whitelist[addrs[i]].hasMinted = 0;
        }
    }

    function isWhitelisted(address addr)
        public
        view
        returns (bool isWhiteListed)
    {
        return whitelist[addr].addr == addr;
    }

    function contractURI() public view returns (string memory) {
        return _contractMetadataURI;
    }

    /////////////////////////////////////////////////////////////////////
    /// WHITELIST

    modifier mintCompliance(uint256 _mintAmount) {
        require(
            msg.value >= _mintPrice.mul(_mintAmount),
            "Ether value sent is not correct"
        );
        require(
            _mintAmount > 0 && _mintAmount <= _maxMintPerTx,
            "Can only mint 5 tokens at a time"
        );
        require(
            totalSupply().add(_mintAmount) <= _maxSupply,
            "Purchase would exceed max supply"
        );
        _;
    }
}
