// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AZNFT is ERC721, ERC721Enumerable, PullPayment, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    // Constants
    uint256 public constant MINT_PRICE = 0.02 ether;
    uint8 public constant MAX_MINT_QTY = 20;
    uint8 public constant MAX_MINT_QTY_PRESALE = 30;
    string public constant BASE_EXTENSION = ".json";

    // Setted constants
    string public PROVENANCE;
    string public NOT_REVEALED_TOKEN_URI;
    string public BASE_TOKEN_URI;
    string public CONTRACT_METADATA_URI;
    uint256 public MAX_SUPPLY;
    uint256 public REVEAL_TIMESTAMP;

    // Variables
    bool public isPublicSaleActive = false;
    bool public isPresaleActive = false;
    bool public revealed = false;

    /// Structures
    struct Whitelist {
        address addr;
        uint256 hasMinted;
    }
    mapping(address => Whitelist) public whitelist;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _notRevealedTokenURI,
        string memory _contractMetadataURI,
        uint256 _maxNftSupply
    ) ERC721(_name, _symbol) {
        MAX_SUPPLY = _maxNftSupply;
        setContractMetadataURI(_contractMetadataURI);
        setNotRevealedTokenURI(_notRevealedTokenURI);
    }

    ////////////////////////////////
    /// Event setup

    /**
     * @dev Fired in setBaseTokenURI()
     *
     * @param _by an address which executed update
     * @param _oldVal old BASE_TOKEN_URI value
     * @param _newVal new BASE_TOKEN_URI value
     */
    event BaseURIChanged(address _by, string _oldVal, string _newVal);

    /**
     * @dev Fired in flipSaleState()
     *
     * @param _by an address which executed update
     * @param _newSaleState new saleIsActive value
     */
    event SaleStateChanged(address _by, string _saleType, bool _newSaleState);

    /**
     * @dev Fired in setRevealTimestamp()
     *
     * @param _by an address which executed update
     * @param _newTimestamp new REVEAL_TIMESTAMP
     */
    event RevealTimestampChanged(address _by, uint256 _newTimestamp);

    /**
     * @dev Fired in setProvenanceHash()
     *
     * @param _by an address which executed update
     * @param _provenance new PROVENANCE_HASH
     */
    event ProvenanceHashChanged(address _by, string _provenance);

    ////////////////////////////////
    /// Contract configuration functions

    function _baseURI() internal view virtual override returns (string memory) {
        return BASE_TOKEN_URI;
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
            revealed
                ? string(
                    abi.encodePacked(
                        BASE_TOKEN_URI,
                        tokenId.toString(),
                        BASE_EXTENSION
                    )
                )
                : NOT_REVEALED_TOKEN_URI;
    }

    function setBaseTokenURI(string memory _baseTokenURI) public onlyOwner {
        emit BaseURIChanged(msg.sender, BASE_TOKEN_URI, _baseTokenURI);
        BASE_TOKEN_URI = _baseTokenURI;
    }

    function setContractMetadataURI(string memory _contractMetadataURI)
        public
        onlyOwner
    {
        CONTRACT_METADATA_URI = _contractMetadataURI;
    }

    function setNotRevealedTokenURI(string memory _notRevealedTokenURI)
        public
        onlyOwner
    {
        NOT_REVEALED_TOKEN_URI = _notRevealedTokenURI;
    }

    function flipPublicSaleState() public onlyOwner {
        emit SaleStateChanged(msg.sender, "Public Sale", !isPublicSaleActive);
        isPublicSaleActive = !isPublicSaleActive;
    }

    function flipPresaleState() public onlyOwner {
        emit SaleStateChanged(msg.sender, "Presale", !isPresaleActive);
        isPresaleActive = !isPresaleActive;
    }

    function setRevealTimestamp(uint256 _revealTimestampInSec)
        public
        onlyOwner
    {
        emit RevealTimestampChanged(msg.sender, _revealTimestampInSec);
        REVEAL_TIMESTAMP = block.timestamp + _revealTimestampInSec;
    }

    function setProvenanceHash(string memory _provenanceHash) public onlyOwner {
        emit ProvenanceHashChanged(msg.sender, _provenanceHash);
        PROVENANCE = _provenanceHash;
    }

    function flipRevealed() public onlyOwner {
        revealed = !revealed;
    }

    ////////////////////////////////
    /// Contract interaction functions
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

    function publicMint(uint256 numberOfTokens) public payable {
        require(isPublicSaleActive, "Public sale must be active to mint");
        require(
            totalSupply().add(numberOfTokens) <= MAX_SUPPLY,
            "Purchase would exceed max supply"
        );
        require(
            msg.value >= MINT_PRICE.mul(numberOfTokens),
            "Ether value sent is not correct"
        );
        require(
            numberOfTokens > 0 && numberOfTokens <= MAX_MINT_QTY,
            "Can only mint MAX_MINT_QTY tokens at a time"
        );

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex + 1);
            }
        }
    }

    function presaleMint(uint256 numberOfTokens) public payable {
        require(isPresaleActive, "Presale must be active to mint");
        require(isWhitelisted(msg.sender), "Address is not whitelisted");
        require(
            msg.value >= MINT_PRICE.mul(numberOfTokens),
            "Ether value sent is not correct"
        );
        require(
            whitelist[msg.sender].hasMinted.add(numberOfTokens) <=
                MAX_MINT_QTY_PRESALE,
            "Above presale max allowed mint quantity"
        );
        require(
            numberOfTokens > 0 && numberOfTokens <= MAX_MINT_QTY_PRESALE,
            "Can only mint MAX_MINT_QTY_PRESALE tokens at a time"
        );
        whitelist[msg.sender].hasMinted = whitelist[msg.sender].hasMinted.add(
            numberOfTokens
        );

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                _safeMint(msg.sender, mintIndex + 1);
            }
        }
    }

    function airdropMint(address _addressToAirdrop) public onlyOwner {
        uint256 mintIndex = totalSupply();
        _safeMint(_addressToAirdrop, mintIndex + 1);
    }

    function reserveToken(uint256 _tokensToReserve) public onlyOwner {
        uint256 supply = totalSupply();
        for (uint256 i = 0; i < _tokensToReserve; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function addAddressesToWhitelist(address[] memory addrs) public onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            require(!isWhitelisted(addrs[i]), "Already whitelisted");
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
        return CONTRACT_METADATA_URI;
    }

    ////////////////////////////////
    /// Extended overriden functions

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
