// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface Buffer {
    function shareReceived(uint256 stage) external payable;
}

contract NFTcontract is ERC721Enumerable, ReentrancyGuard {
    string public baseURI;

    uint256 public maxPublicMint;
    uint256 public publicMintId = 1;
    uint256 public PUBLIC_SALE_PRICE;
    address public collectAddress;

    address public owner;
    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner.");
        _;
    }

    constructor(
        address _owner,
        string memory _baseURI,
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _maxPublicMint,
        uint256 _publicSalePrice,
        address _collectAddress
    ) ERC721(_tokenName, _tokenSymbol) {
        baseURI = _baseURI;
        maxPublicMint = _maxPublicMint;
        PUBLIC_SALE_PRICE = _publicSalePrice;
        collectAddress = _collectAddress;
        owner = _owner;
    }

    modifier isCorrectPayment(uint256 price, uint256 numberOfTokens) {
        require(
            price * numberOfTokens == msg.value,
            "Incorrect ETH value sent"
        );
        _;
    }

    modifier canMint(uint256 numberOfTokens) {
        require(
            publicMintId + numberOfTokens <= maxPublicMint,
            "Not enough tokens remaining to mint"
        );
        _;
    }

    function updateBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    // ============ PUBLIC FUNCTIONS FOR MINTING ============

    /**
     * @dev mints specified # of tokens to sender address
     * max supply 10000 initially, no limit on # of tokens
     */
    function publicMint(uint256 numberOfTokens)
        public
        payable
        isCorrectPayment(PUBLIC_SALE_PRICE, numberOfTokens)
        canMint(numberOfTokens)
        nonReentrant
    {
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _mint(msg.sender, publicMintId);
            publicMintId++;
        }
    }

    // ============ PUBLIC READ-ONLY FUNCTIONS ============

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: query for nonexistent token"
        );
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(tokenId), ".json")
            );
    }

    /**
     * @dev withdraw funds for to specified account
     */
    function withdraw() onlyOwner external {
        uint256 balance = address(this).balance;
        require(balance > 0, "The balance is 0 now.");
        // payable(collectAddress).transfer(balance);
        Buffer c = Buffer(collectAddress);
        c.shareReceived{value: balance}(50001);
    }

    function setCollectAddress(address _collectAddress) onlyOwner external {
        collectAddress = _collectAddress;
    }
}
