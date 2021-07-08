//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/math/SafeMath.sol";

contract LottoGame {
using SafeMath for uint256; 

address[] public winners; 
uint public potValue;

mapping(address => bool) public hasTickets; 

bool public isGameActive = false; 

mapping(address => uint) public ticketBalance; 

uint public timer; 

uint public payoutAmount; 

mapping(address => uint) public profits; 

uint public totalToPay = potValue.mul(potPayoutPercent.div(10));

uint public totalTickets; 






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
    
    //set initial game gameSettings
    minimumBuy = 100; 
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
    require(isGameActive == true, "Game is not active!");
	require(amount >= minimumBuy, "You must bet a minimum of 100,000 tokens.");
	require(ticketBalance[buyer] <= maxTickets, "You can only hold 5 tickets per round");
	
    if (hasTickets[buyer] == false) {
        hasTickets[buyer] = true; 
    }
    
	ticketBalance[buyer] += 1; 

	
	
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
	    ticketBalance[winners[0]] = 0; 
	    hasTickets[buyer] = false; 
	    remove(0);
	    winners.push(buyer);
	}
	

    //	token.transfer(buyer, address(this), amount);
    potValue += amount; 
}

function startGame() public {
    isGameActive = true; 
    timer = block.timestamp; 
    
    if (timer >= block.timestamp + maxTimeLeft) {
        endGame(); 
    }
}

function endGame() public {
    require(block.timestamp >= block.timestamp + maxTimeLeft);
    getPayoutAmount(); 
    // sendProfits(); 
    
    isGameActive = false; 
    timer = 0; 
    for (uint i = 0; i <= winners.length; i++) {
        ticketBalance[winners[i]] = 0; 
    }
    startGame(); 
}

function getPayoutAmount() public returns(uint, uint, uint, uint, uint) {
  //get number of tickets held by each winner in the array 
        for (uint i = 0; i < winners.length; i++) {
           totalTickets += ticketBalance[winners[i]];
        }
    
    
        uint perTicketPrice = totalToPay / totalTickets;
        
        //calculate the winnings based on how many tickets held by each winner 
        uint winner1Profits = perTicketPrice * ticketBalance[winners[0]];
        uint winner2Profits = perTicketPrice * ticketBalance[winners[1]];
        uint winner3Profits = perTicketPrice * ticketBalance[winners[2]]; 
        uint winner4Profits = perTicketPrice * ticketBalance[winners[3]];
        uint winner5Profits = perTicketPrice * ticketBalance[winners[4]];
    
        
        return (winner1Profits, winner2Profits, winner3Profits, winner4Profits, winner5Profits);
}



//uncomment this function once you put your token address in the constructor
/*function sendProfits() public {
    token.transfer(winners[0], winner1Profits);
    token.transfer(winners[1], winner2Profits);
    token.transfer(winners[2], winner3Profits);
    token.transfer(winners[4], winner4Profits); 
    token.transfer(winners[5], winner5Profits);
}*/

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