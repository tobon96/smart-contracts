// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AZNFT is ERC721, PullPayment, Ownable {
    using Counters for Counters.Counter;

    // Constants
    uint256 public constant MINT_PRICE = 0.03 ether;

    // Setted constants
    uint256 public TOTAL_SUPPLY;
    string public BASE_TOKEN_URI;

    // Variables
    Counters.Counter private currentTokenId;
    bool public saleIsActive = false;

    /// @dev Base token URI used as a prefix by tokenURI().

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxNftSupply
    ) ERC721(name, symbol) {
        TOTAL_SUPPLY = maxNftSupply;
    }

    // Contract configuration functions

    function _baseURI() internal view virtual override returns (string memory) {
        return BASE_TOKEN_URI;
    }

    function setBaseTokenURI(string memory _baseTokenURI) public onlyOwner {
        BASE_TOKEN_URI = _baseTokenURI;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    // Contract interaction functions
    function withdrawPayments(address payable payee)
        public
        virtual
        override
        onlyOwner
    {
        uint256 balance = address(this).balance;
        payable(payee).transfer(balance);
    }

    function mintTo(address recipient) public payable returns (uint256) {
        uint256 tokenId = currentTokenId.current();
        require(tokenId < TOTAL_SUPPLY, "Max supply reached");
        require(
            msg.value == MINT_PRICE,
            "Transaction value did not equal the mint price"
        );

        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }
}
