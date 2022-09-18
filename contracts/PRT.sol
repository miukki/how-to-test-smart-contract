// contracts/access-control/Auth.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

contract PRT is Ownable, ReentrancyGuard {

    using Strings for uint256;
    
    using Counters for Counters.Counter;
    Counters.Counter public _tokenPRTID_index;
    Counters.Counter public _win_counter;


    uint256 public constant NUM_TOTAL = 1000;
    uint256 public constant MAX_SUPPLY_FOR_TOKEN = 20000;


    uint256 public constant PRTID = 20000;
    uint256 public constant MAX_BUYABLE_AMOUNT = 100;
    uint256 public constant MAX_PRT_INDEX = 180000;
    uint256 public constant MAX_SUPPLY_PRT = 160000;

    uint[] public RTWinnerTikensList;

    uint public constant PRICE_PRT = 0.01 ether;//(uint): number of wei sent with the message

    bool public presalePRT = false;
    bool public presalepPRTDone = false;

    uint public idx = 0;

    bytes32 public root;
    

    // Public Raffles Ticket (PRT) : 160,000
    // ID #20,001 to ID #180,000
    mapping(address => uint256[]) private userPRTs;
    mapping(uint => address) private prtPerAddress;
    
    uint16[] public intArr;

    constructor() {
        intArr = new uint16[](MAX_SUPPLY_FOR_TOKEN/NUM_TOTAL); //intArr[20]
        intArr[0]=4;
    }


    event DitributePRTs(address indexed from, uint256[] list); /* This is an event */
    event RTWinnerTokenID(uint index, uint winnerTokenPRTID, uint counter);
    event TransferFromToContract(address from, uint amount);
    event RTWinnerAddress(address winner, uint winnerTokenPRTID);
    event LastIntArrStore(uint index, uint indexArr);
    


    // ---modifiers--- do not remove this function
    modifier isValidMerkleProof(bytes32[] calldata _proof) {//we need this magic to be sure accounts is holder of PRT
        require(MerkleProof.verify(
            _proof,
            root,
            keccak256(abi.encodePacked(msg.sender))
            ) == true, "Not allowed origin");
        _;
    }

    modifier onlyAccounts () { //for security
        require(msg.sender == tx.origin, "Not allowed origin");
        _;
    }
    
    modifier presalePRTIsDone () {
        require(presalepPRTDone, "Sale PRT is Not Done");
        _;
    }


    modifier presalePRTIsActiveAndNotOver () {
        require(presalePRT, "Sale PRT is Not Open");//needs be true, is active (not paused)
        require(!presalepPRTDone, "Sale PRT is Done"); //is not over
        _;
    }

    function togglePreSalePRT() public onlyOwner {
        presalePRT = !presalePRT;
    }


    function togglePresalepPRTDone() public onlyOwner {
        presalepPRTDone = !presalepPRTDone; //only owner can toggle presale
    }



    function createXRAND(uint number)  internal view returns(uint)  {
        //number = 17, 0 - 16 <- this is what we want
        return uint(blockhash(block.number-1)) % number;
    }

    function getAddrFromPRTID (uint _winnerTokenPRTID) internal view returns (address) {
        return prtPerAddress[_winnerTokenPRTID];
    }

    
    function random(uint number) public view returns(uint){
        // return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        // msg.sender))) % number;
        return uint(blockhash(block.number-1)) % number;
    }


    function raffle1stStage() public payable returns(uint256){
        
        //gold supply = ID 1-200, silver supply = 201-2000, bronze = 2001-20000
        uint8 randnum = uint8(random(255));
        uint8 randval = uint8(random(MAX_SUPPLY_FOR_TOKEN/NUM_TOTAL)); //0 to 19

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
    
    function _setStartIdx(uint i) private onlyOwner {
        idx = i; //only owner can toggle presale
    }

    function sendMP() public payable onlyAccounts onlyOwner presalePRTIsDone {
        uint xrand = createXRAND(17);
        _win_counter.increment();
        uint counter = _win_counter.current();

        if (counter <= 10) {

            for (uint i = idx; i < 1000*counter; i++) {
                uint24 _winnerTokenPRTID = uint24(PRTID + 1 + xrand + uint24(uint32((168888*i)/10000))); 
                address winneraddr = getAddrFromPRTID(_winnerTokenPRTID);
                if (winneraddr != address(0)) {
                    emit RTWinnerAddress(winneraddr, _winnerTokenPRTID); //this needs to be 10000+i <- and i needs to be random also, 1st stage sale
                }
                emit RTWinnerTokenID(i, _winnerTokenPRTID, counter);//in case to track all winer tickets in logs
            }
            _setStartIdx(1000*counter);
            

        }

       
    }

     function intArrIterate() public onlyAccounts onlyOwner presalePRTIsDone {

        for (uint i=0; i < intArr.length; i++) {
            emit LastIntArrStore(i, intArr[i]); //we need this for 2nd stage sale
        }
    
    }


     function buyPRT (address account, uint8 _amount_wanted_able_to_get) external payable onlyAccounts presalePRTIsActiveAndNotOver nonReentrant {
        require(account != owner(), "Owner of contract can not buy PRT");
        require(msg.sender == account,"Not allowed for owner of contract");
        require(presalePRT, "Sale PRT is Not Open");

        uint8 _presaleClaimedAmount = uint8(userPRTs[account].length);
        require(_presaleClaimedAmount >= 0 && _presaleClaimedAmount <= MAX_BUYABLE_AMOUNT, "You have exceeded 100 raffle tickets limit");


        require(_amount_wanted_able_to_get > 0, "Amount buyable needs to be greater than 0");

        if (_amount_wanted_able_to_get + _presaleClaimedAmount > MAX_BUYABLE_AMOUNT) {
            _amount_wanted_able_to_get = uint8(MAX_BUYABLE_AMOUNT - _presaleClaimedAmount);
        }

        require(_amount_wanted_able_to_get <= MAX_BUYABLE_AMOUNT, "You can't mint so much tokens");

        uint weiBalanceWallet = msg.value;

        require(weiBalanceWallet > PRICE_PRT, "Min 0.01 ether");

        require(PRICE_PRT * _amount_wanted_able_to_get <= weiBalanceWallet, "Insufficient funds");

        uint latestprtIndex = _tokenPRTID_index.current() + PRTID + _amount_wanted_able_to_get;

        if (latestprtIndex > MAX_PRT_INDEX) {  
            _amount_wanted_able_to_get = uint8(MAX_PRT_INDEX - _tokenPRTID_index.current() - PRTID); 
        }

        console.log("_amount_wanted_able_to_get!", msg.sender, _amount_wanted_able_to_get);

        //after recalc _amount_wanted_able_to_get, check again:
        require(PRICE_PRT * _amount_wanted_able_to_get <= weiBalanceWallet, "Insufficient funds");

        uint256 the_last_index_wanted = _tokenPRTID_index.current() + _amount_wanted_able_to_get + PRTID;
        require(the_last_index_wanted <= MAX_PRT_INDEX, "The Last ID PRT token is exceeded MAX_PRT_INDEX");    

        //pay first to owner of contract 
        payable(owner()).transfer(PRICE_PRT * _amount_wanted_able_to_get);// bulk send money from sender to owner
        emit TransferFromToContract(msg.sender, PRICE_PRT * _amount_wanted_able_to_get);

       
        for (uint i = 0; i < _amount_wanted_able_to_get; i++) {
           distributePRTInternal();
        }
        emit DitributePRTs(msg.sender, userPRTs[msg.sender]);
        console.log("got total", msg.sender, uint8(userPRTs[account].length));
        console.log("status! latestprtIndex, MAX_PRT_INDEX", latestprtIndex, MAX_PRT_INDEX);

        // console.log('_tokenPRTID_index.current()! end', _tokenPRTID_index.current());

        if (_tokenPRTID_index.current() == MAX_SUPPLY_PRT) {
            presalepPRTDone = true; //toggle presale is done
        }

     }


    function distributePRTInternal() internal {//That means the function has been called only once (within the transaction). 
        _tokenPRTID_index.increment();
        uint256 tokenPRTID = _tokenPRTID_index.current() + PRTID;
        
        //release PRT by update status
        console.log("distributePRTInternal!", msg.sender, tokenPRTID);

        userPRTs[msg.sender].push(tokenPRTID);
        prtPerAddress[tokenPRTID] = msg.sender;

    }

    function balanceOf () public payable onlyOwner returns (uint){
        return msg.value;
    }

     function withdraw () public payable onlyOwner {
         payable(msg.sender).transfer(address(this).balance);//This function allows the owner to withdraw from the contract

     }
     

}