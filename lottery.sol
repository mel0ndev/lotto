//SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


import "https://github.com/Scott6768/LOTTOSC1/blob/main/LOTTOSC1.sol";



contract LottoGame {
    using SafeMath for uint256; 

address payable[]  public  winners; 
uint public potValue;

mapping(address => bool) public hasTickets; 
mapping(address => uint) public ticketBalance; 

bool public isGameActive = false; 

uint public payoutAmount; 

mapping(address => uint) public profits; 

uint public totalToPay = potValue.mul(potPayoutPercent.div(100));
uint public totalLeftover = potValue.mul(potLeftoverPercent.div(100)); 

uint public totalTickets; 

address public owner;

uint amountToSendToNextRound; 
uint amountToMarketingAddress;
uint amountToSendToLiquidity; 

uint public totalTime = 300;  
uint public timeLeft; 
uint public startTime; 
uint public endTime; 

address public liquidityTokenRecipient;

uint winner1Profits; 
uint winner2Profits;
uint winner3Profits; 
uint winner4Profits;
uint winner5Profits;

uint bnb1;
uint bnb2; 
uint bnb3; 
uint bnb4; 
uint bnb5; 

LSC public token;


IPancakeRouter02 public pancakeswapV2Router;
address payable public routerAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;


        uint256 minimumBuy; //minimum buy to be eligible to win share of the pot
        uint256 tokensToAddOneSecond; //number of tokens that will add one second to the timer
        uint256 maxTimeLeft; //maximum number of seconds the timer can be
        uint256 maxWinners; //number of players eligible for winning share of the pot
        uint256 potPayoutPercent; // what percent of the pot is paid out
        uint256 potLeftoverPercent; // what percent is leftover 
        uint256 maxTickets; // max amount of tickets a player can hold
        

constructor() public {
    //replace LSC token address
    token = LSC(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

    owner = msg.sender; 
    liquidityTokenRecipient = address(this); 
    
    //set initial game gameSettings
    minimumBuy = 100000; 
    tokensToAddOneSecond = 1000;
    maxTimeLeft = 300 seconds;
    maxWinners = 5; 
    potPayoutPercent = 60;
    potLeftoverPercent = 40;
    maxTickets = 5; 
}

receive() external payable {
    //to be able to receive eth/bnb
}


function getGameSettings() public view returns (uint, uint, uint, uint, uint) {
    return (minimumBuy, tokensToAddOneSecond, maxTimeLeft, maxWinners, potPayoutPercent);
}

function adjustBuyInAmount(uint newBuyInAmount) external {
    //add new buy in amount with 9 extra zeroes when calling this function (your token has 9 decimals)
    require(msg.sender == owner, "Only owner");
    minimumBuy = newBuyInAmount;
}

function transferOwnership(address newOwner) external {
    require(msg.sender == owner, "Only owner.");
    owner = newOwner; 
}

function changeLiqduidityTokenRecipient(address newRecipient) private {
    require(msg.sender == owner, "Only owner"); 
    liquidityTokenRecipient = newRecipient; 
}



function buyTicket(address payable buyer, uint amount) public {
    require(isGameActive == true, "Game is not active!");
    require(amount >= minimumBuy, "You must bet a minimum of 100,000 tokens.");
    require(ticketBalance[buyer] <= maxTickets, "You may only purchase 5 tickets per round");

    
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
    
    
    if (winners.length <= maxWinners && hasTickets[buyer]) {
        winners.push(buyer);
    }
    
    if (winners.length > maxWinners) {
        ticketBalance[winners[0]] = 0; 
        hasTickets[buyer] = false; 
        remove(0);
        winners.push(buyer);
    }
    
        uint timeToAdd = amount.div(tokensToAddOneSecond);
        addTime(timeToAdd);
    
    
    //uncomment when token address added in constructor
    
    //  token.transfer(address(this), amount);
    potValue += amount; 
}

    function getTimeLeft() public {
        timeLeft = endTime - now; 
        
        if (now >= endTime) {
            endGame(); 
        }
        
    }
    
    
    function addTime(uint timeAmount) private {
        if (timeAmount + endTime >= 300) {
        endTime = now + totalTime; 
        } else {
            endTime += timeAmount;
        }
    }

function startGame() public {
    require(msg.sender == owner, "Only owner");
    isGameActive = true; 
    startTime = now; 
    endTime = totalTime + startTime; 
    
    }


function endGame() private {
    require(msg.sender == address(this));
    require(now <= endTime, "timer is over"); 
    getPayoutAmount(); 
    sendProfitsInBNB(); 
    dealWithLeftovers(); 
    swapAndAddLiqduidity(); 
    
    isGameActive = false; 
    
    for (uint i = 0; i <= winners.length; i++) {
        ticketBalance[winners[i]] = 0; 
    }
    
    startGame(); 
}



function getPayoutAmount() private returns(uint, uint, uint, uint, uint) {
  //get number of tickets held by each winner in the array 
  //only run once per round or tickets will be incorrectly counted
  //this is handled by endGame(), do not call outside of that pls and thnx
        for (uint i = 0; i < winners.length; i++) {
           totalTickets += ticketBalance[winners[i]];
        }
    

        uint perTicketPrice = totalToPay / totalTickets;
        
        //calculate the winnings based on how many tickets held by each winner 
        winner1Profits = perTicketPrice * ticketBalance[winners[0]];
        winner2Profits = perTicketPrice * ticketBalance[winners[1]];
        winner3Profits = perTicketPrice * ticketBalance[winners[2]]; 
        winner4Profits = perTicketPrice * ticketBalance[winners[3]];
        winner5Profits = perTicketPrice * ticketBalance[winners[4]];
         
        bnb1 = swapProfitsForBNB(winner1Profits);
        bnb2 = swapProfitsForBNB(winner2Profits);
        bnb3 = swapProfitsForBNB(winner3Profits);
        bnb4 = swapProfitsForBNB(winner4Profits);
        bnb5 = swapProfitsForBNB(winner5Profits);
        
        
        return (winner1Profits, winner2Profits, winner3Profits, winner4Profits, winner5Profits);
}

function swapProfitsForBNB(uint amount) private returns (uint) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();

        token.approve(address(pancakeswapV2Router), amount);
        
        // make the swap
       pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
}



//send bnb amount
function sendProfitsInBNB() private {
    winners[0].transfer(bnb1);
    winners[1].transfer(bnb2);
    winners[2].transfer(bnb3);
    winners[3].transfer(bnb4);
    winners[4].transfer(bnb5);
}


function dealWithLeftovers() private {
    uint nextRoundPot = 25; 
    uint liquidityAmount = 5; 
    uint marketingAddress = 10; 
    
    amountToSendToNextRound = totalLeftover.mul(nextRoundPot.div(100));
    amountToSendToLiquidity = totalLeftover.mul(liquidityAmount.div(100));
    amountToMarketingAddress = totalLeftover.mul(marketingAddress.div(100));
}

//Send liquidity
function swapAndAddLiqduidity() private {
    //sell half for bnb 
    uint halfOfLiqduidityAmount = amountToSendToLiquidity.div(2);
    uint remainingHalf = amountToSendToLiquidity.sub(halfOfLiqduidityAmount); 
    
    //first swap half for BNB
    address[] memory path = new address[](2);
        //path[0] = ; //ADD TOKEN ADDRESS HERE and uncomment 
        path[1] = pancakeswapV2Router.WETH();
        
        
        //approve pancakeswap to spend tokens
       token.approve(address(pancakeswapV2Router), halfOfLiqduidityAmount);
        
        //swap
         pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            halfOfLiqduidityAmount,
            0, // accept any amount of BNB
            path,
            address(this), //tokens get swapped to this contract so it has BNB to add liquidity 
            block.timestamp + 30 seconds //30 second limit for the swap
        );
        
        //now we have BNB, we can add liquidity to the pool
               pancakeswapV2Router.addLiquidityETH(
                address(this), //token address
                remainingHalf, //amount to send
                0, // slippage is unavoidable // 
                0, // slippage is unavoidable // 
                liquidityTokenRecipient, // who to send the liqduity tokens to (this address by default but can be changed in above function)
                block.timestamp + 30 seconds //dealine 
            );
}


function remove(uint index) private {
    for(uint i = index; i < winners.length - 1; i++) {
        winners[i] = winners[i + 1];
    }
    winners.pop();
}

}