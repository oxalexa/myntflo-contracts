// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";

// This contract represents the marketplace
contract MyntfloMarketplace is ERC2771Context, ERC1155Holder, ERC721Holder{
    
    using SafeMath for uint256;

    address public owner;

    // The contract that will be used as the payment token
    IERC20 public paymentToken;

    // The contract that will be used to mint and manage ERC-1155 tokens
    IERC1155 public erc1155Contract;

    // The contract that will be used to mint and manage ERC-721 tokens
    IERC721 public erc721Contract;

    // A mapping from token ID to the price of the token in payment tokens
    mapping(uint256 => uint256) public erc1155Prices;
    mapping(uint256 => uint256) public erc721Prices;

    // A mapping from token ID to the number of tokens available for sale
    mapping(uint256 => uint256) public erc1155Inventory;
    mapping(uint256 => uint256) public erc721Inventory;

    // Token on sale
    struct Listing {
        uint256 tokenId;
        uint256 inventory;
        uint256 price;
        address contractAddress;
        bool isERC1155;
    }

    Listing[] public listings;

   
    event TokenPurchased(
        address purchaser,
        uint256 tokenId,
        uint256 price
    );

    modifier onlyOwner() {
        require(_msgSender() == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor(MinimalForwarder forwarder, IERC20 _paymentToken, IERC1155 _erc1155Contract, IERC721 _erc721Contract) ERC2771Context(address(forwarder)) {
        paymentToken = _paymentToken;
        erc1155Contract = _erc1155Contract;
        erc721Contract = _erc721Contract;
        owner = _msgSender();
    }

    function setPaymentToken (IERC20 _paymentToken) public onlyOwner {
        paymentToken = _paymentToken;
    }

    function getListings() public view returns (Listing[] memory) {
        return listings;
    }

    function findListingByTokenId(uint256 tokenId, address contractAddress) public view returns (bool, uint256) {
        for (uint256 i = 0; i < listings.length; i++) {
            if (listings[i].tokenId == tokenId && listings[i].contractAddress == contractAddress) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    // This function allows the owner of the marketplace to add a new ERC-1155 token
    // to the marketplace and set its price in payment tokens
    function addERC1155(uint256 tokenId, address contractAddress, uint256 amount, uint256 price) public onlyOwner {
        require(erc1155Contract.balanceOf(_msgSender(), tokenId) >= amount, "Sender doesnt have the specified amount of tokens");
        erc1155Contract.safeTransferFrom(_msgSender(), address(this), tokenId, amount, '');
        // erc1155Prices[tokenId] = price;
        // erc1155Inventory[tokenId] = amount;

        (bool found, uint256 index) = findListingByTokenId(tokenId, contractAddress);
        if (!found) {
            Listing memory listing = Listing(tokenId, amount, price, contractAddress, true);
            listings.push(listing);
        } else {
            listings[index].inventory = listings[index].inventory + amount;
            listings[index].price = price;
        }

    }

    function removeERC1155(uint256 tokenId, address contractAddress, uint256 amount) public onlyOwner {
        (bool found, uint256 index) = findListingByTokenId(tokenId, contractAddress);
        require(found, "Token not found");
        require(listings[index].inventory >= 1, "Insufficient inventory");
        listings[index].inventory = listings[index].inventory.sub(amount);
        erc1155Contract.safeTransferFrom(address(this), _msgSender(), tokenId, amount, '');
    }

    function addERC721(uint256 tokenId, uint256 price, address contractAddress) public onlyOwner {
        require(erc721Contract.ownerOf(tokenId) == _msgSender(), "Sender does not own the token");
        (bool found, uint256 index) = findListingByTokenId(tokenId, contractAddress);
        if (!found) {
            Listing memory listing = Listing(tokenId, 1, price, contractAddress, false);
            listings.push(listing);
        } else {
            listings[index].inventory = 1;
            listings[index].price = price;
        }
        erc721Contract.safeTransferFrom(_msgSender(), address(this), tokenId);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function removeERC721(uint256 tokenId, address contractAddress) public onlyOwner {
        (bool found, uint256 index) = findListingByTokenId(tokenId, contractAddress);
        require(found, "Token not found");
        require(listings[index].inventory >= 1, "Insufficient inventory");
        listings[index].inventory = 0;
        erc721Contract.safeTransferFrom(address(this), _msgSender(), tokenId);
    }

    function buyToken(uint256 tokenId, address contractAddress) public {
        (bool found, uint256 index) = findListingByTokenId(tokenId, contractAddress);
        require(found, "Token not found");
        require(listings[index].inventory > 0, "Insufficient inventory");
        require(paymentToken.transferFrom(_msgSender(), owner, listings[index].price), "Payment token transfer failed");

        listings[index].inventory = listings[index].inventory - 1;

        if (listings[index].isERC1155) {
            erc1155Contract.safeTransferFrom(address(this), _msgSender(), tokenId, 1, '');
        } else {
            erc721Contract.safeTransferFrom(address(this), _msgSender(), tokenId);
        }

        emit TokenPurchased(_msgSender(), tokenId, listings[index].price);
        
    }
    

}

