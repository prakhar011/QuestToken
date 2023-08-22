// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract QuestToken is ERC1155, Ownable {
    uint256 private _currentTokenId = 0;
    mapping(uint256 => bool) private _tokenExists;
    mapping(uint256 => bool) private _unlimitedSupply;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) private _availableSupply;

    event QuestTokenCreated(uint256 tokenId, uint256 totalSupply, bool isUnlimited, string uri);
    event QuestCompletedAndRewardGiven(address indexed account, uint256 questId);
    event URIUpdated(uint256 tokenId, string newUri);

    constructor() ERC1155("") {}

    function createNewQuestToken(bool isUnlimited, string memory _uri, uint256 supply) public onlyOwner {
    _currentTokenId++;
    _tokenExists[_currentTokenId] = true;
    _unlimitedSupply[_currentTokenId] = isUnlimited;
    _tokenURIs[_currentTokenId] = _uri;
    _availableSupply[_currentTokenId] = supply;
    emit QuestTokenCreated(_currentTokenId, supply, isUnlimited, _uri);
}


    function completeQuestAndReward(address account, uint256 questId) public onlyOwner {
    require(_tokenExists[questId], "Quest ID does not exist.");
    if (_unlimitedSupply[questId]) {
        _mint(account, questId, 1, "");
    } else {
        require( _availableSupply[questId] > 0, "No tokens left to reward.");
        _availableSupply[questId]--;
        _mint(account, questId, 1, "");
    }
    emit QuestCompletedAndRewardGiven(account, questId);
}

    function uri(uint256 _tokenId) override public view returns (string memory) {
        require(_tokenExists[_tokenId], "Token ID does not exist.");
        return _tokenURIs[_tokenId];
    }

    function setTokenURI(uint256 _tokenId, string memory newUri) public onlyOwner {
        require(_tokenExists[_tokenId], "Token ID does not exist.");
        _tokenURIs[_tokenId] = newUri;
        emit URIUpdated(_tokenId, newUri);
    }

    function getCurrentTokenId() public view returns (uint256) {
        return _currentTokenId;
    }

    function tokenExists(uint256 tokenId) public view returns (bool) {
        return _tokenExists[tokenId];
    }

    function unlimitedSupply(uint256 tokenId) public view returns (bool) {
        return _unlimitedSupply[tokenId];
    }

    function availableSupply(uint256 tokenId) public view returns (uint256) {
        return _availableSupply[tokenId];
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public virtual override {
        revert("Transfers are not allowed.");
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual override {
        revert("Batch transfers are not allowed.");
    }
}
