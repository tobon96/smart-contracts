// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AZNFT is ERC721, ERC721Enumerable, PullPayment, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    //Constants
    uint256 public constant MINT_PRICE = 0.04 ether;
    uint256 public constant MAX_MINT = 20;

    //Variables
    uint256 public maxSupply;
    Counters.Counter private currentTokenId;
    //uint256 public revealTimestamp;
    string public baseTokenURI;
    bool public saleIsActive = false;
    uint256 public startingIndexBlock;
    uint256 public startingIndex;

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxNftSupply
    ) ERC721(name, symbol) {
        maxSupply = maxNftSupply;
    }

    function mintTo(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Sale must be active to mint");
        require(MAX_MINT > numberOfTokens, "Can only mint 20 tokens at a time");
        require(
            maxSupply > totalSupply().add(numberOfTokens),
            "Purchase would exceed max supply"
        );
        /*
        require(
            MINT_PRICE.mul(numberOfTokens) <= msg.value,
            "Ether value sent is not correct"
        );
        */

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if (maxSupply >= mintIndex) {
                _safeMint(msg.sender, mintIndex);
            }
        }

        // If we haven't set the starting index and this is either 1) the last saleable token or 2) the first token to be sold after
        // the end of pre-sale, set the starting index block
        // replace: (totalSupply() == maxSupply || revealTimestamp < block.timestamp)
        if (
            startingIndexBlock == 0 &&
            (totalSupply() == maxSupply)
        ) {
            startingIndexBlock = block.number;
        }
    }

    /*
    function setRevealTimestamp(uint256 revealTimeStamp) public onlyOwner {
        revealTimestamp = revealTimeStamp;
    }
    */

    /// @dev Returns an URI for a given token ID
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /// @dev Sets the base token URI prefix.
    function setBaseTokenURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    /// @dev Pause sale if active, make active if paused
    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

        /**
     * Set the starting index for the collection
     */
    function setStartingIndex() public {
        require(startingIndex == 0, "Starting index is already set");
        require(startingIndexBlock != 0, "Starting index block must be set");

        startingIndex = uint256(blockhash(startingIndexBlock)) % maxSupply;
        // Just a sanity case in the worst case if this function is called late (EVM only stores last 256 block hashes)
        if (block.number.sub(startingIndexBlock) > 255) {
            startingIndex = uint256(blockhash(block.number - 1)) % maxSupply;
        }
        // Prevent default sequence
        if (startingIndex == 0) {
            startingIndex = startingIndex.add(1);
        }
    }

    /**
     * Set the starting index block for the collection, essentially unblocking
     * setting starting index
     */
    function emergencySetStartingIndexBlock() public onlyOwner {
        require(startingIndex == 0, "Starting index is already set");
        startingIndexBlock = block.number;
    }

    function withdrawPayments(address payable payee)
        public
        virtual
        override
        onlyOwner
    {
        super.withdrawPayments(payee);
    }

    ///////////// Overrides, implementations and internal functions

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

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
