// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "./ERC721A.sol";

contract MyntfloNFT is ERC721A, Ownable, ReentrancyGuard, DefaultOperatorFilterer {

    using Strings for uint256;

    mapping (address => uint256) private mintedWL;

    uint256 public maxSupply = 8888;
    uint256 private pricePublic = 0 ether;
    uint256 private priceWL = 0 ether;
    uint256 public maxPerTxPublic = 10;
    uint256 public maxPerTxWL = 10;
    uint256 public maxPerWalletWL = 10;
    uint256 public maxPerWL = 10;

    string private baseURI = "";
    string public provenance = "";
    string public uriPass = "";
    
    bool public paused = false;
    
    uint256 public saleStatus = 0; // 0 - whitelist, 1 - public
    
    bytes32 public merkleRootWL = "";
    
    event Minted(address caller);

    constructor() ERC721A("Myntflo", "MYNT") {}
    
    function mintPublic(uint256 count, address to) external payable nonReentrant{
        require(!paused, "Minting is paused");
        require(saleStatus == 1, 'Public mint not active');
        uint256 supply = totalSupply();
        require(supply + count <= maxSupply, "Sorry, not enough left!");
        require(count <= maxPerTxPublic, "Sorry, too many per transaction");
        require(msg.value >= pricePublic * count, "Sorry, not enough amount sent!"); 
        
        _safeMint(to, count);

        emit Minted(to);
    }

    function mintGiveaway(address _to, uint256 qty) external onlyOwner{
        uint256 supply = totalSupply();
        require(supply + qty <= maxSupply, "Sorry, not enough left!");
        _safeMint(_to, qty);
    }
    
    function remaining() public view returns(uint256){
        uint256 left = maxSupply - totalSupply();
        return left;
    }

    function getPriceWL() public view returns(uint256){
        return priceWL;
    }

    function getPricePublic() public view returns (uint256){
        return pricePublic;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory base = baseURI;
        return bytes(base).length > 0 ? string(abi.encodePacked(base, tokenId.toString(), ".json")) : "";
    }

    // verify merkle tree leaf
    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns (bool){
        return MerkleProof.verify(proof, merkleRootWL, leaf);
    }
    
    function getTokensByOwner(address _owner) external view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            if(ownerOf(i) == _owner){
                tokensId[i] = i;
            }
        }
        return tokensId;
    }


    // ADMIN FUNCTIONS

    function flipPaused() public onlyOwner {
        paused = !paused;
    }

    function closeMinting() public onlyOwner {
        uint256 supply = totalSupply();
        maxSupply = supply;
    }
    
    function setMaxPerWL(uint256 _max) public onlyOwner {
        maxPerWL = _max;
    }

    function setBaseURI(string memory _URI) public onlyOwner {
        baseURI = _URI;
    }

    function setUriPass(string memory _URI) public onlyOwner {
        uriPass = _URI;
    }

    function setPricePublic(uint256 _newPrice) public onlyOwner {
        pricePublic = _newPrice;
    }

    function setPriceWL(uint256 _newPrice) public onlyOwner {
        priceWL = _newPrice;
    }

    function setMaxPerTxPublic(uint256 _newMax) public onlyOwner {
        maxPerTxPublic = _newMax;
    }

    function setMaxPerTxWL(uint256 _newMax) public onlyOwner {
        maxPerTxWL = _newMax;
    }

    function setProvenanceHash(string memory _provenance) public onlyOwner {
        provenance = _provenance;
    }

    function setMerkleRootWL(bytes32 _merkleRoot) public onlyOwner {
        merkleRootWL = _merkleRoot;
    }

    function setSaleStatus(uint256 _saleStatus) public onlyOwner {
        saleStatus = _saleStatus;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(payable(msg.sender).send(balance));
    }

    // royalties overrides
    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override onlyAllowedOperator(from){
        super.safeTransferFrom(from, to, tokenId, data);
    }

    receive() external payable {}
    
}