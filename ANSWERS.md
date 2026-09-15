# Written section, mock

Answer all five questions. **Maximum 120 words each.**

---

## Question 1 (5 marks)

State your `poolId` and list the exact values that produced it. Then explain what would have
happened if you had deployed `Task3Liquidity` with a tick spacing of 60 instead of 200, everything
else unchanged. Say what `poolId` would have done, and what the first failure would have been.

**Answer:** `poolId` is 0x83359a3b45fce08300f021f791bcf96bbcc33aed2eed611ac05fc50f4788931d. Its PoolKey contained currency0 (tokenA), 
currency1 (tokenB), tick spacing 200, and hooks 0x0000000000000000000000000000000000000000. Deploying Task3Liquidity with spacing
60 would create a different key and therefore a different poolId. Because that pool was never opened, addLiquidity would first 
fail at poolExists() with: “the pool is not open, run Task 2 first and check your constructor values match”.

---

## Question 2 (5 marks)

You put in 5 whole tokens of currency1. State which of your two tokens became currency0 and how you
knew, the output you predicted, the output you actually received, and the arithmetic that got you
from 5 to your prediction. Then split the difference between prediction and actual into the part
that is fee and the part that is not, with numbers.

**Answer:** TokenA became currency0 since since its address was lower than TokenB's. I predicted the output to be 309375000000000000, 
but it was actually 309367343158256833. 

My prediction calculation was based on the following:
TokenA (TUT) was currency0 and tokenB (CAFE) was currency1. 
So 5 CAFE was exchanged for 1 TUT.
After the 1% fee: 0.99 * 5 = 4.95
1 TUT = 16 CAFE. 
So 4.95/16 = 0.309375.
Then this is converted to be consistent with everything else.
So 0.309375 * 100000000000000000 = 309375000000000000

The difference is 0.000007656841743167. 
Without fees, 5 CAFE would get 5/16 = 0.3125 TUT.
With fees, 5 CAFE gets 0.309375 TUT.

So the part that is fees is 0.05/16 = 0.003125 TUT.
The part that is not is: 0.000007656841743167 TUT.
---

## Question 3 (5 marks)

`Task3Liquidity` has to be holding your tokens and it also has to have approved the liquidity
router. Explain why both are needed and what each one does. Then call `addLiquidity` from a freshly
deployed `Task3Liquidity` that you have not sent any tokens to, quote the error message exactly,
and say which of the two requirements it was complaining about.

**Answer:** 
Task3Liquidity must hold the tokens because it is the account paying them into the pool. Approval is separately required 
because the liquidity router performs the transfer. Approval gives it an allowance to call transferFrom against the contract’s 
balances. The constructor grants the router maximum allowance for both tokens, but approval does not create a balance.

Error message:
```
transact to Task3Liquidity.addLiquidity errored: Error occurred: Error occurred: revert.

revert
	The transaction has been reverted to the initial state.
Reason provided by the contract: "ERC20: balance too small, send tokens to that contract first".
If the transaction failed for not having enough gas, try increasing the gas limit gently..

Error occurred: revert.

revert
	The transaction has been reverted to the initial state.
Reason provided by the contract: "ERC20: balance too small, send tokens to that contract first".
If the transaction failed for not having enough gas, try increasing the gas limit gently.

If the transaction failed for not having enough gas, try increasing the gas limit gently.
```
It is complaining about the first requirement of not holding any tokens since "balance is too small, send tokens to that 
contract first".

---

## Question 4 (5 marks)

State your live tick and the range you chose, and say why you chose it. Then answer this: if you
had chosen a range sitting entirely **below** the live tick, what would have happened? Name which
of your two tokens the pool would have taken, which it would have left untouched, and why that is
the way round it is.

**Answer:**
The live tick is 27727. I choose tickLower to be 23600 and tickUpper 31600. I took the nearest multiple of 200 below 27727, which
is 27600 and then moved it 4000 (20*200) ticks below and 4000 (20*200) ticks above. 

My contract would reject a range entirely below the live tick with “the live tick is at or above your range”. 
Without that protective check, the position would require only currency1: token B, CAFE (0x9D7f...5E99). 
Currency0, token A/TUT, would remain untouched. Above a position’s upper tick, its token0 has conceptually been converted completely 
into token1.
---

## Question 5 (5 marks)

State the number `startingSqrtPriceX96` returned for your run. Show how that number relates to your
starting price of 16, or one sixteenth, and to two to the power of ninety six. Then explain why the
protocol stores the square root of the price rather than the price itself, and why your tick came
out at roughly plus or minus 27727.

**Answer:**
The `startingSqrtPriceX96` returned was 316912650057057350374175801344. 
Since TUT was currency0, the protocol price was currency1/currency0, or 16. Also, 2^96 = 79228162514264337593543950336; 
therefore sqrt(16) × 2^96 = 4 × 2^96 = 316912650057057350374175801344. With the opposite token order, the price would be 1/16, 
giving (1/4) × 2^96 = 19807040628566084398385987584. Uniswap stores square-root price because its liquidity and token-amount 
calculations are linear in either sqrt(P) or its reciprocal, enabling efficient, precise fixed-point arithmetic. 
Since P = 1.0001^tick, ln(16)/ln(1.0001) ≈ 27727; reversing the price gives approximately -27727.
---
