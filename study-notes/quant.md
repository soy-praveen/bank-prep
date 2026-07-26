# Quant Toolkit

Status: **basics fully covered.** Needs paper-volume grind (see progress-and-leaks.md).

---

## 1. The Speed Engine (underlies everything)

**Fraction ↔ Percentage — recognize, don't divide:**
| % | Frac | % | Frac | % | Frac |
|---|---|---|---|---|---|
| 50 | 1/2 | 25 | 1/4 | 20 | 1/5 |
| 33.33 | 1/3 | 12.5 | 1/8 | 16.67 | 1/6 |
| 66.67 | 2/3 | 37.5 | 3/8 | 14.28 | 1/7 |
| 62.5 | 5/8 | 11.11 | 1/9 | 9.09 | 1/11 |

**Squares to 30, cubes to 15** — must be instant (13²=169 … 29²=841; 12³=1728, 13³=2197, 14³=2744, 15³=3375).

**Percentages — build from atoms:** 10% (shift decimal) · 5% (half of 10%) · 1% (shift twice). Assemble: 45% = 40% + 5%.

**Multiply:** ×11 (add neighbours) · ×5 (÷2 ×10) · ×25 (÷4 ×100) · ×9 (×10 − itself).

**Approximation:** round each number FIRST, write the rounded numbers down, then combine.

---

## 2. Number Series

**Write the differences/ratios row underneath — always.** Then run the checklist:
1. Constant difference (AP) 2. Constant ratio (GP) 3. Growing difference 4. **Growing multiplier** (×2,×3,×4…) 5. **Squares/cubes ± offset** — *check the ROOTS' pattern (primes? evens?)* 6. Alternating 7. Fibonacci.

---

## 3. Quadratic Comparison

Factor (product = c, sum = b, then **flip signs** for roots), then compare ranges.
- Every x ≥ every y → x ≥ y. Ranges **overlap** → **no relation**.
- Sign shortcut: c+ b− → both roots +; c+ b+ → both −; c− → one +, one −.

---

## 4. Percentages — the phrasing family (KEY)

| Phrase | Formula |
|---|---|
| "A is what **% of** B" | **A ÷ B × 100** (direct ratio, no subtraction) |
| "A is what **% more than** B" | **(A − B) ÷ B × 100** |
| "A is what **% less than** B" | **(B − A) ÷ B × 100** |

**The base is ALWAYS the number after "than."** Same as direction's "with respect to" — the word after *than / of / w.r.t* is your denominator.

---

## 5. Data Interpretation (10–15 marks, biggest block)

**Workflow:** read title + units first → answer only what's asked → use the speed tools.
**5 question types:** total/difference · average (÷count) · % of · ratio · % more/less.

**Accuracy rules (these cost marks):**
- **Read the LAST word** — total vs average vs ratio. Answer in the exact form asked (%, ratio, number).
- **Trace row AND column** to the exact cell before pulling a number.
- Combined/weighted average **always lies between** the two group averages (sanity check).

**Caselet DI:** data hidden in a paragraph → **build the table first** (sentence by sentence), then answer. Watch "% more/less" and "ratio splits" (e.g. "boys:girls = 3:2" means split the total).

---

## 6. Arithmetic Toolkit

### Simple Interest
- **SI = one year's interest (R% of P) × T.** Amount = P + SI.
- **Doubling → R×T = 100. Tripling → R×T = 200.** (Interest as % of P = R×T.)

### Compound Interest
- **2 years: net % = 2R + R²/100.** (e.g. 10% 2yr = 21%.)
- **CI − SI (2 yr) = P × (R/100)².** (Works backward to find P too.)

### Profit & Loss (base is always CP)
- Profit% = (Profit / **CP**) × 100. Discount% is on **MP**.
- Forward: SP = CP × (1 ± %/100). Backward: **CP = SP ÷ multiplier** (divide, don't take % of SP).
- Successive markup+discount net % = a + b + ab/100 (− for discount).

### Averages
- **Sum = Average × Count** (use this constantly).
- **Replacement:** new item = old item ± (Count × change in average).
- Evenly-spaced numbers: avg = (first + last) / 2.
- Combined avg = (n₁a₁ + n₂a₂)/(n₁+n₂) — always between the two.

### Time & Work
- **LCM method:** total work = LCM of days; efficiency = total ÷ days; add efficiencies.
- 2-person shortcut: together = (a×b)/(a+b). Wages split in efficiency ratio.

### Speed–Time–Distance
- D = S × T. **km/hr → m/s: ×5/18. m/s → km/hr: ×18/5.**
- **Average speed (equal distance) = 2xy/(x+y)** — NOT the simple average.
- Trains: cross a pole → distance = train length; cross a platform → train + platform length. Opposite dirs → add speeds; same → subtract.

### Ages
- Ratio type: ages = ratio × k, use 2nd condition for k. Difference type: the **age difference is constant** forever — use it as anchor.

### Mixtures (Alligation)
- **Cheaper : Dearer = (Dearer − Mean) : (Mean − Cheaper).**
