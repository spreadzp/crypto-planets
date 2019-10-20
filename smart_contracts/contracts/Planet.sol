pragma solidity ^0.5.0;

import '../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import '../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Metadata.sol';

contract Planet is ERC721, ERC721Metadata  {

	constructor() ERC721Metadata("Start", "Planet") public {
	}

	struct OnePlanet {
		string starName;
		string starStory;
		string ra;
		string dec;
		string mag;
		bytes32 coordsHash;
		uint256 temperaturePlanet;
		uint256 speed;
		uint256 orbit;
	}

	mapping(uint256 => OnePlanet) public tokenIdToStarInfo;
	mapping(bytes32 => bool) public unique;
	mapping(address => uint256) public idPlanetOfOwner;
	mapping(uint256 => uint256) public starsForSale;
	mapping(address => uint256) public starsOwner;

	event showId(uint256 Id);

	uint256 public tokenAt;

	function createStar(string memory starName, string memory starStory, string memory ra, string memory dec, string memory mag) public {
		tokenAt++;

		bytes32 coordinates;

		// It should be greater than 3
		require(bytes(starName).length > 3, "It should be greater than 3");

		// coordinates = keccak256(abi.encodePacked(ra, dec, mag));
		coordinates = coordinatesToHash(ra, dec, mag);

		require(!checkIfStarExist(coordinates), "We have that Star!");

		OnePlanet memory newStar = OnePlanet(starName, starStory, ra, dec, mag, coordinates, 5, 6, 5 );  //, "" , "", "", "", "", "");

		uint256 tokenId = tokenAt;
		tokenIdToStarInfo[tokenId] = newStar;
		unique[coordinates] = true;
		starsOwner[msg.sender] = tokenAt;
		_mint(msg.sender, tokenId);
	}

	function getListPlanets(address ownerOfPlanet) public view returns
	(string memory, string memory, string memory, string memory, string memory, bytes32, uint256, uint256, uint256) {
		uint256 idPlanet = starsOwner[ownerOfPlanet];
		string memory starName = tokenIdToStarInfo[idPlanet].starName;
		string memory starStory = tokenIdToStarInfo[idPlanet].starStory;
		string memory ra = tokenIdToStarInfo[idPlanet].ra;
		string memory dec = tokenIdToStarInfo[idPlanet].dec;
		string memory mag = tokenIdToStarInfo[idPlanet].mag;
		return (starName, starStory, ra, dec, mag,
		tokenIdToStarInfo[idPlanet].coordsHash, tokenIdToStarInfo[idPlanet].temperaturePlanet,
		tokenIdToStarInfo[idPlanet].speed, tokenIdToStarInfo[idPlanet].orbit
		);
	}

	function getIdPlanet(address ownerOfPlanet) public  returns (uint256) {
		uint256 idPlanet = starsOwner[ownerOfPlanet];
		emit showId(idPlanet);
		return idPlanet;
	}

	function getTokenIdToStarInfo(uint256 tokenId) public view returns(string memory, string memory, string memory, string memory, string memory) {
		return (tokenIdToStarInfo[tokenId].starName, tokenIdToStarInfo[tokenId].starStory, tokenIdToStarInfo[tokenId].ra,
				 tokenIdToStarInfo[tokenId].dec, tokenIdToStarInfo[tokenId].mag);
	}

	function checkIfStarExist(bytes32 coordinates) public view returns(bool) {
		return unique[coordinates];
	}

	// To avoid:  Warning: Function state mutability can be restricted to pure
	function coordinatesToHash(string memory ra, string memory dec, string memory mag) public pure returns(bytes32) {
		return keccak256(abi.encodePacked(ra, dec, mag));
	}

	function putStarUpForSale(uint256 tokenId, uint256 price) public {
		require(this.ownerOf(tokenId) == msg.sender, "You are not the owner of that Star!");
		starsForSale[tokenId] = price;
	}

	function buyStar(uint256 tokenId) public payable {
		// If it has a price, it is up for sale
		require(starsForSale[tokenId] > 0, "If it has a price, it is up for sale");

		uint256 starCost = starsForSale[tokenId];
		address payable starOwner = address(uint160(this.ownerOf(tokenId)));
		require(msg.value >= starCost, "It cost more!");

		_removeTokenFrom(starOwner, tokenId);

		_addTokenTo(msg.sender, tokenId);

		starOwner.transfer(starCost);

		// If the value sent is more than the value of the star, we send the remaining back
		if(msg.value > starCost) {
			msg.sender.transfer(msg.value - starCost);
		}

		// And since it was sold, we remove it from the mapping
		starsForSale[tokenId] = 0;
	}

	// https://medium.com/coinmonks/exploring-non-fungible-token-with-zeppelin-library-erc721-399cb180cfaf
	function mint(uint256 tokenId) public {
		super._mint(msg.sender, tokenId);
	}

	function transferStar(address starOwner, address to, uint256 tokenId) public {
		safeTransferFrom(starOwner, to, tokenId);
	}

	function exchangeStars(address  user1, uint256 user1TokenId, address user2, uint256 user2TokenId) public {

		require(this.ownerOf(user1TokenId) == user1, "it is owner1");
		require(this.ownerOf(user2TokenId) == user2, "it is owner2");

		_removeTokenFrom(user1, user1TokenId);
		_addTokenTo(user2, user1TokenId);

		_removeTokenFrom(user2, user2TokenId);
		_addTokenTo(user1, user2TokenId);
	}

	function _removeTokenFrom(address user, uint256 userTokenId) public {

	}

	function _addTokenTo(address user, uint256 userTokenId) public {

	}
}
