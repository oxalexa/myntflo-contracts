// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "./ERC721A.sol";


contract MyntfloNFT is ERC721A, ReentrancyGuard, DefaultOperatorFilterer, ERC2771Context {

    using Strings for uint256;

    uint256 public maxSupply = 5000;
    uint256 private pricePublic = 0 ether;
    uint256 public maxPerTxPublic = 10;
    
    string private baseURI = "";
    string public provenance = "";
    
    bool public paused = false;
    
    uint256 public saleStatus = 1; 
    
    address public owner;
    address public relayer;

    event Minted(address caller);

    modifier onlyOwner() {
        require(_msgSender() == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor(MinimalForwarder forwarder) ERC2771Context(address(forwarder)) ERC721A("Ollie's World", "OW") {
        owner = _msgSender();
    }
    
    function mintPublic(uint256 count, address to) external payable nonReentrant{
        require(!paused, "Minting is paused");
        require(saleStatus == 1, 'Public mint not active');
        uint256 supply = totalSupply();
        require(supply + count <= maxSupply, "Sorry, not enough left!");
        require(count <= maxPerTxPublic, "Sorry, too many per transaction");
        require(msg.value >= pricePublic * count, "Sorry, not enough amount sent!"); 
        require(balanceOf(to) + count <= 2, "Sorry, max 2 nfts per wallet");
        require(pricePublic > 0 || _msgSender() == relayer || msg.sender == relayer || tx.origin == relayer, "Minting disabled");

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

    function getPricePublic() public view returns (uint256){
        return pricePublic;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory base = baseURI;
        return bytes(base).length > 0 ? string(abi.encodePacked(base, tokenId.toString(), ".json")) : "";
    }

    function getTokensByOwner(address _owner) external view returns(uint256[] memory) {
        uint256 balance = balanceOf(_owner);
        uint256 supply = totalSupply();
        uint256[] memory tokensId = new uint256[](balance);
        uint256 j = 0;
        for (uint256 i = 0; i < supply; i++) {
            if(ownerOf(i) == _owner){
                tokensId[j] = i;
                j++;
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
    
    function setBaseURI(string memory _URI) public onlyOwner {
        baseURI = _URI;
    }
    
    function setPricePublic(uint256 _newPrice) public onlyOwner {
        pricePublic = _newPrice;
    }

    function setMaxPerTxPublic(uint256 _newMax) public onlyOwner {
        maxPerTxPublic = _newMax;
    }

    function setProvenanceHash(string memory _provenance) public onlyOwner {
        provenance = _provenance;
    }

    function setSaleStatus(uint256 _saleStatus) public onlyOwner {
        saleStatus = _saleStatus;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(payable(msg.sender).send(balance));
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setRelayerAddress(address _relayer) external onlyOwner {
        relayer = _relayer;
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

    function _msgSender() internal view override(Context, ERC2771Context)
        returns (address sender) {
        sender = ERC2771Context._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Context)
        returns (bytes calldata) {
        return ERC2771Context._msgData();
    }

    receive() external payable {}
    
}