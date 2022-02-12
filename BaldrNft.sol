// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.4.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.4.2/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.4.2/security/Pausable.sol";
import "@openzeppelin/contracts@4.4.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.4.2/utils/Counters.sol";

/* BaldrNft ITO Contract
Minting these NFTs will give you access to Baldr Tokens
*/

contract BaldrNft is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter ;
    Counters.Counter private _tokenIdTracker;
    using SafeERC20 for IERC20;

    ERC20 public PAYABLE_TOKEN;
    address public BALDR_DEPLOYER;
    uint256 public MAX_ELEMENTS = 50;
    uint256 public PRICE = 1000000000000000000; // price in token dec
    string private constant TOKEN_URI = "/0.json"; //Metadata Id

    constructor(address _payableToken, address _baldrDeployer) ERC721("Baldr INO NFT", "pBALDR") {
        PAYABLE_TOKEN = ERC20(_payableToken);
        BALDR_DEPLOYER = _baldrDeployer;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://"; //metadata url
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _totalSupply() internal view returns (uint256) {
        return _tokenIdTracker.current();
    }

    function totalMint() public view returns (uint256) {
        return _totalSupply();
    }

    //Set payment values
    function mint(address _to, uint256 _count) public payable {
        uint256 total = _totalSupply();
        require(total + _count <= MAX_ELEMENTS, "Max limit");
        require(total <= MAX_ELEMENTS, "Sale end");
        require(_count > 0, "Min amount 1");

        uint256 totalPrice = getPrice() * _count;
        IERC20(PAYABLE_TOKEN).safeTransferFrom(
            address(msg.sender),
            address(BALDR_DEPLOYER),
            totalPrice
        );
        for (uint256 i = 0; i < _count; i++) {
            _mintAnElement(_to);
        }
    }

    function _mintAnElement(address _to) private {
        uint256 id = _totalSupply();
        _tokenIdTracker.increment();
        _safeMint(_to, id);
    }

    function setPrice(uint256 _price) public onlyOwner {
        require(_price > 0, "Price lower limit");
        PRICE = _price;
    }

    function getPrice() public view returns (uint256) {
        return PRICE;
    }

    function setMaxElements(uint256 _maxElements) public onlyOwner {
        uint256 total = _totalSupply();
        require(_maxElements > total, "Limit low than existance");
        MAX_ELEMENTS = _maxElements;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory base = _baseURI();
        return string(abi.encodePacked(base, TOKEN_URI));
    }
}
