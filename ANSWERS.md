# Written section, mock

Answer all five questions. **Maximum 120 words each.**

---

## Question 1 (5 marks)

State your `poolId` and list the exact values that produced it. Then explain what would have
happened if you had deployed `Task3Liquidity` with a tick spacing of 60 instead of 200, everything
else unchanged. Say what `poolId` would have done, and what the first failure would have been.

**Answer:** My `poolId` is `0x83359a3b45fce08300f021f791bcf96bbcc33aed2eed611ac05fc50f4788931d`, produced by the `PoolKey`:
`currency0` = `0x358AA13c52544ECCEF6B0ADD0f801012ADAD5eE3` (token A, the lower address), `currency1` =
`0x9D7f74d0C41E726EC95884E0e97Fa6129e3b5E99` (token B), `fee` = 10000, `tickSpacing` = 200, `hooks` =
`0x0000000000000000000000000000000000000000`. Deploying `Task3Liquidity` with `tickSpacing` 60 instead of 200 changes that field,
so `poolKey()` hashes to a different `poolId` than the one Task2Pool opened. That `poolId` was never initialized, so
`currentSlot0()` returns `sqrtPriceX96 = 0` and `poolExists()` is false. The first failure would be `addLiquidity`'s opening
require: "the pool is not open, run Task 2 first and check your constructor values match".

---

## Question 2 (5 marks)

You put in 5 whole tokens of currency1. State which of your two tokens became currency0 and how you
knew, the output you predicted, the output you actually received, and the arithmetic that got you
from 5 to your prediction. Then split the difference between prediction and actual into the part
that is fee and the part that is not, with numbers.

**Answer:** Token A became currency0 because its address `0x358A...` is numerically lower than token B's `0x9D7f...`. Predicted
output: 309375000000000000. Actual output: 309367343158256833.

Arithmetic: price P = 16 CAFE/TUT, so 5 CAFE ideally buys 5/16 = 0.3125 TUT. The 1% fee leaves net input 4.95 CAFE, so
4.95/16 = 0.309375 TUT = 309375000000000000 wei, my prediction.

Splitting the gap from the ideal 0.3125 TUT: the fee part is 0.3125 minus 0.309375, which is 0.003125 TUT. My prediction
already includes that fee, so the remaining gap between prediction and actual — 0.309375 minus 0.309367343158256833, which is
0.000007656841743167 TUT — is pure price impact from trading along the curve, not fee. Total shortfall from ideal:
0.003132656841743167 TUT.

---

## Question 3 (5 marks)

`Task3Liquidity` has to be holding your tokens and it also has to have approved the liquidity
router. Explain why both are needed and what each one does. Then call `addLiquidity` from a freshly
deployed `Task3Liquidity` that you have not sent any tokens to, quote the error message exactly,
and say which of the two requirements it was complaining about.

**Answer:** Task3Liquidity must hold the tokens because it is the account paying them into the pool via the router's
`transferFrom`. Approval is separate: it only grants the router an allowance to move tokens out of Task3Liquidity's balance;
the constructor gives the router max allowance for both tokens, but approval creates no balance.

Calling `addLiquidity` on a freshly deployed Task3Liquidity that has never been sent tokens reverts with:

```
ERC20: balance too small, send tokens to that contract first
```

This is the router's `transferFrom` check inside `ERC20.sol` failing on token A's `balanceOf(Task3Liquidity)`. It is
complaining about the first requirement, missing balance, not approval: the max allowance from the constructor was already
in place.

---

## Question 4 (5 marks)

State your live tick and the range you chose, and say why you chose it. Then answer this: if you
had chosen a range sitting entirely **below** the live tick, what would have happened? Name which
of your two tokens the pool would have taken, which it would have left untouched, and why that is
the way round it is.

**Answer:** My live tick is 27727. I chose `tickLower` = 23600 and `tickUpper` = 31600: I rounded 27727 down to the nearest
multiple of 200 (27600), then moved 20 spacings (4000) below and above, safely bracketing the live tick.

A range entirely below the live tick means `tickUpper` is at or below the live tick, so price has moved above the range. My
contract would reject this with "the live tick is at or above your range". Without that check, the position would be fully
converted: it would take only currency1, token B, CAFE, leaving currency0, token A, TUT, untouched, because above a position's
upper tick its token0 has been entirely converted into token1.

---

## Question 5 (5 marks)

State the number `startingSqrtPriceX96` returned for your run. Show how that number relates to your
starting price of 16, or one sixteenth, and to two to the power of ninety six. Then explain why the
protocol stores the square root of the price rather than the price itself, and why your tick came
out at roughly plus or minus 27727.

**Answer:** My `startingSqrtPriceX96` is 316912650057057350374175801344. Since TUT is currency0, the protocol price
P = currency1/currency0 = 16. With 2^96 = 79228162514264337593543950336, sqrt(16) × 2^96 = 4 × 2^96 =
316912650057057350374175801344. Had the tokens sorted the other way, P would be 1/16, giving (1/4) × 2^96 =
19807040628566084398385987584.

Uniswap stores sqrt(P) rather than P because liquidity and token-amount formulas are linear in sqrt(P) or 1/sqrt(P), letting
Q96 fixed-point arithmetic stay precise and avoid overflow across huge price ranges. Since P = 1.0001^tick,
tick = ln(16)/ln(1.0001) ≈ 27727; the opposite ordering gives roughly -27727.
---
