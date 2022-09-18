// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

// import ERC 1155 from open zeppelin

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
//https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTContract is ERC1155, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    address proxyRegistryAddress;

    uint256 public constant NUM_TOTAL = 1000;
    uint256 public constant MAX_SUPPLY_FOR_TOKEN = 20000;

    uint256 public counterTokenID;

    uint256 private start = 1636914760; // timestamp, Date.parse('11/16/2021')/1000

    using Counters for Counters.Counter;
    Counters.Counter public _tokenIdCounter;
    Counters.Counter public _tokenID;

    uint16[] public intArr;

    mapping(address => uint256) userBalances;
    mapping (uint256 => string) private _uris;
    //string memory uri_ pass to  ERC1155 look here  https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol
    
    constructor(address _proxyRegistryAddress)
        ERC1155(
            "ipfs://QmU5rGmMp93x6wAZctKiiTxiVbVoQ5h72R9e9SHgQqv6Up/nft/collections/genesis/json/{id}.json" //default way
        ) ReentrancyGuard() // A modifier that can prevent reentrancy during certain functions
    {

        intArr = new uint16[](MAX_SUPPLY_FOR_TOKEN/NUM_TOTAL);
        intArr[0]=4;
        proxyRegistryAddress = _proxyRegistryAddress;
    }


    function uri(uint256 tokenId) override public view returns (string memory) {
        return(_uris[tokenId]);
    }
    
    function setTokenUri(uint256 tokenId, string memory uri_to_update) public onlyOwner {
        require(bytes(_uris[tokenId]).length == 0, "Cannot set uri twice"); //can do it once once
        _uris[tokenId] = uri_to_update; 
    }


    event Minter(address indexed from, uint256 tokenID, uint256 counterTokenID, uint price); /* This is an event */

    function random(uint number) public view returns(uint){
        // return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        // msg.sender))) % number;
        return uint(blockhash(block.number-1)) % number;
    }


    function raffle() public payable returns(uint256){
        
        //gold supply = ID 1-200, silver supply = 201-2000, bronze = 2001-20000
        uint8 randnum = uint8(random(255));
        uint8 randval = uint8(random(MAX_SUPPLY_FOR_TOKEN/NUM_TOTAL));

        if (randval == 0) {
            if (uint8(randnum % 9) == 1) {
                if (intArr[randval] == 96) {
                    randval = uint8(random(MAX_SUPPLY_FOR_TOKEN/NUM_TOTAL-1)+1);
                }
            } else  {
                randval = uint8(random(MAX_SUPPLY_FOR_TOKEN/NUM_TOTAL-1)+1);
            }
            //randval == 0  gold ticket
        }
        intArr[randval] = intArr[randval]+1;
        uint16 getval = intArr[randval]+1;

        return uint256(getval)+(uint16(randval)*NUM_TOTAL);
    }
    
    
    //mint free
    function mintWithRandomID() public {

        counterTokenID = _tokenIdCounter.current();

        require(counterTokenID >= 0 && counterTokenID < NUM_TOTAL*10, "Error: exceeded max supply NUM_TOTAL*10");

        uint256 tokenID = raffle();

        require(tokenID >= 5 && tokenID <= MAX_SUPPLY_FOR_TOKEN, "Error: tokenID < 5 OR tokenID > MAX_SUPPLY_FOR_TOKEN");
        // require(getTokenID(msg.sender) == 0, "This address already own token");

        if (counterTokenID < 1000) {
            mintFree(tokenID);
        } else {
            uint weiPrice = 20987550000000; //0.00002098755 eth;
            mintPayable(tokenID, weiPrice);
        }
        _tokenIdCounter.increment();
    }

    function mintFree(uint256 tokenID) public {
        _mint(msg.sender, tokenID, 1, "");
        emit Minter(msg.sender, tokenID, counterTokenID, 0);

    }

    //mint with price
     function mintPayable(uint256 tokenID, uint weiPrice) public payable {
        uint weiAmount = msg.value;//number of wei sent with the message
        require(weiAmount >=weiPrice, "not enough ETH"); //1 amount, ether is a shortcut for 10^18)
        
        userBalances[msg.sender] = weiAmount;
        require(userBalances[msg.sender].sub(weiPrice) >=0, "not enough ETH");

        payable(owner()).transfer(weiPrice);// Send money to owner of contract

        _mint(msg.sender, tokenID, 1, "");

        emit Minter(msg.sender, tokenID, counterTokenID, weiPrice);


    }

      /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }


}


/**
  @title An OpenSea delegate proxy contract which we include for whitelisting.
  @author OpenSea
*/
contract OwnableDelegateProxy {}

/**
  @title An OpenSea proxy registry contract which we include for whitelisting.
  @author OpenSea
*/
contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}
