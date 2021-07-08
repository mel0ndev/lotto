//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract LottoGame {
//	using SafeMath for uint256; 

address[] public winners; 
uint public potValue;

bool public hasTickets; 

bool public isGameActive = false; 

mapping(address => uint) public ticketBalance; 

uint public timer; 

mapping(address => uint) public payoutAmount; 




        uint256 minimumBuy; //minimum buy to be eligible to win share of the pot
        uint256 tokensToAddOneSecond; //number of tokens that will add one second to the timer
        uint256 maxTimeLeft; //maximum number of seconds the timer can be
        uint256 maxWinners; //number of players eligible for winning share of the pot
        uint256 potPayoutPercent; // what percent of the pot is paid out
        uint256 potLeftover; // what percent of pot is left over
        uint256 maxTickets; // max amount of tickets a player can hold
        

constructor() public {
	//REPLACE THIS LINE
    //Token token = Token(0x00000...);
    
    address buyer = msg.sender; 
    
    //set initial game gameSettings
    minimumBuy = 1; 
    tokensToAddOneSecond = 1000 * 10**9;
    maxTimeLeft = 300 seconds;
    maxWinners = 5; 
    potPayoutPercent = 60;
    potLeftover = 40; 
    maxTickets = 5;
    
}


function getGameSettings() public view returns (uint, uint, uint, uint, uint, uint) {
    return (minimumBuy, tokensToAddOneSecond, maxTimeLeft, maxWinners, potPayoutPercent, potLeftover);
}

function adjustBuyInAmount(uint newBuyInAmount) external {
    //add new buy in amount with 9 extra zeroes when calling this function (your token has 9 decimals)
	minimumBuy = newBuyInAmount;
}



function buyTicket(address buyer, uint amount) public {
	require(amount >= minimumBuy, "You must bet a minimum of 100,000 tokens.");
	require(ticketBalance[buyer] <= maxTickets, "You can only hold 5 tickets per round");
	
	ticketBalance[buyer] += 1; 
	hasTickets = true; 
	
	
	if (amount >= minimumBuy * 2 && amount < minimumBuy * 3) {
	    ticketBalance[buyer] += 1; 
	}
	
	if (amount >= minimumBuy * 3 && amount < minimumBuy * 4) {
	    ticketBalance[buyer] += 2;
	}
	
	if (amount >= minimumBuy * 4 && amount < minimumBuy * 5) {
	    ticketBalance[buyer] += 3;
	}
	
	if (amount >= minimumBuy * 5) {
	    ticketBalance[buyer] += 4;
	}
	
	if (winners.length <= maxWinners) {
	    winners.push(buyer);
	}
	
	if (winners.length > maxWinners) {
	    remove(0);
	    winners.push(buyer);
	}
	
	
    //	token.transfer(buyer, address(this), amount);
    potValue += amount; 
}

function startGame() public {
    isGameActive = true; 
    timer = block.timestamp; 
}

function endGame() public {
    require(maxTimeLeft >= block.timestamp);
    isGameActive = false; 
    timer = 0; 
    startGame(); 
}


function getPayoutAmount() external view returns(uint){
  //get number of tickets held by each winner in the array 
        uint winner1 = ticketBalance[winners[0]];
        uint winner2 = ticketBalance[winners[1]];
  
        uint totalTickets = winner1 + winner2; 
        
        uint totalToPay = potValue * (potPayoutPercent / 100);
        
        uint initalPayment = totalToPay / totalTickets; 
        return initalPayment;
       
}
    
  
  
  //divide pot amongst the winners by amount of tickets held
    

function remove(uint index) public {
    for(uint i = index; i < winners.length - 1; i++) {
        winners[i] = winners[i + 1];
    }
    winners.pop();
}


function pushTestAddresses() external {
    winners.push(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
    winners.push(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
    winners.push(0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c);
    winners.push(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
    winners.push(0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
}



}