# Reasoning Multi-Method (pick the fastest) — Practice

SBI PO Prelims level. Each problem is solved by two or three methods, ranked so **Method 1 is the one to reach for in the exam**. Slower methods are shown because they are more reliable when you are unsure or when the problem is unusual — know both, default to the fast one, fall back to the safe one under doubt.

General rule of thumb for the section: use the fast method when the structure is clean and standard; drop to the full/slow method the moment there is ambiguity, a negative term, "either-or", or you have already spent 15 seconds staring.

---

## Problems

### Problem 1 — Syllogism (basic)

**Statements:** All cats are dogs. Some dogs are pets.
**Conclusions:** I. Some cats are pets. II. Some pets are dogs.
*Which conclusion(s) follow?*

**Answer: Only Conclusion II follows.**

**Method 1 (fastest) — Conversion + "no link" check.**
1. "Some dogs are pets" reverses (converts) directly to "Some pets are dogs." That is a valid immediate inference, so **II follows**.
2. For I, ask: is there a *definite* path from cats to pets? Cats sit inside dogs; only *some* dogs are pets. The "some" part need not include the cats. No definite link, so **I does not follow.**
*Use this when:* only 2 statements and the conclusions are simple A-B links. Conversion of a "Some X are Y" statement always gives "Some Y are X" for free — spot it instantly.

**Method 2 — Venn diagram.**
1. Draw circle Cats fully inside circle Dogs (All cats are dogs).
2. Draw circle Pets overlapping Dogs (Some dogs are pets) — but place the overlap on the part of Dogs *outside* Cats, which is allowed.
3. Read: a picture exists where no cat is a pet → I is not necessary. Pets and Dogs always share the overlap region → II is always true.
*Use this when:* three or more statements, or the "some/no" placements are tricky. Slower but never lies — the trick is to draw the arrangement that tries to make the conclusion FALSE.

---

### Problem 2 — Syllogism with a negative

**Statements:** All apples are fruits. No fruit is a stone.
**Conclusions:** I. No apple is a stone. II. Some stones are fruits.
*Which conclusion(s) follow?*

**Answer: Only Conclusion I follows.**

**Method 1 (fastest) — Chain the definite terms (All + No = No).**
1. Apples are entirely inside Fruits; Fruits are entirely separated from Stones. So apples, being inside fruits, are also entirely separated from stones → **"No apple is a stone" follows (I).**
2. "No fruit is a stone" converts to "No stone is a fruit," which is the *opposite* of "Some stones are fruits" → **II does not follow.** (A universal-negative can never yield a "some are" positive.)
*Use this when:* the two statements share a middle term and the pattern is All→No or No→All. "All A are B + No B are C ⇒ No A are C" is a fixed result — memorise it.

**Method 2 — Venn diagram.**
1. Cats-style: Apple circle inside Fruit circle; Stone circle drawn completely apart from Fruit.
2. Apple is inside Fruit, Fruit touches nothing of Stone → Apple touches nothing of Stone → I true.
3. Stone and Fruit never overlap in any valid drawing → "Some stones are fruits" can never be forced → II false.
*Use this when:* you distrust the memorised rule, or a third statement is added.

---

### Problem 3 — Inequality (mixed signs)

**Statement:** P ≥ Q > R = S ≤ T
**Conclusions:** I. P > S  II. T > R  III. T ≥ R
*Which conclusion(s) follow?*

**Answer: Conclusions I and III follow; II does not.**

**Method 1 (fastest) — Quick elimination on the two relevant links only.**
1. For each conclusion, look ONLY at the segment of the chain between the two letters — ignore the rest.
2. **I: P vs S.** Path P ≥ Q > R = S. A single strict `>` sits in the path, so the whole thing collapses to strict: **P > S → I follows.**
3. **II/III: T vs R.** Path is R = S ≤ T. Reading toward T: T ≥ S = R, i.e. **T ≥ R**. There is no strict `>` in this segment, so you *cannot* claim T > R. Therefore **III (T ≥ R) follows, II (T > R) does not.**
*Rule to burn in:* a combined relation is strict `>` only if at least one `>` lies in the path; a single `≥`/`=` link keeps it as `≥`. `≤` and `≥` pointing the "wrong way" break the chain.
*Use this when:* the chain is short and you only need one or two relations — don't derive everything.

**Method 2 — Full chain evaluation.**
1. Rewrite the whole line and mark the strongest achievable sign between every pair, left to right, then read off each conclusion.
2. P≥Q, Q>R so P>R, R=S so P>S, and P vs T is indeterminate (chain reverses at `≤`). T≥S=R gives T≥R.
3. Cross-check each printed conclusion against this table.
*Use this when:* there are 3+ conclusions or an "either-or" pair is suspected — building the full picture prevents missed cases.

---

### Problem 4 — Coded inequality

**Coding:** `A & B` = A > B; `A @ B` = A ≥ B; `A $ B` = A = B; `A % B` = A < B; `A # B` = A ≤ B.
**Statement:** X & Y, Y @ Z, Z $ W
*Find the relationship between X and W.*

**Answer: X > W (i.e. X & W).**

**Method 1 (fastest) — Decode inline, then collapse.**
1. Translate as you read: X > Y, Y ≥ Z, Z = W.
2. Chain X and W: X > Y ≥ Z = W. One strict `>` in the path → **X > W.** In code: `X & W`.
*Use this when:* always, for coded inequalities. Never keep the symbols; convert to real `>`,`<`,`=`,`≥`,`≤` the instant you read them.

**Method 2 — Symbol legend box.**
1. Before touching the statement, write a tiny legend: & → `>`, @ → `≥`, $ → `=`, % → `<`, # → `≤`.
2. Substitute mechanically, then apply the strict-vs-non-strict rule from Problem 3.
*Use this when:* the symbol set is unfamiliar or the paper mixes several symbols — the legend prevents a `<`/`>` slip that silently flips the answer.

---

### Problem 5 — Inequality "either-or"

**Statement:** A ≤ B = C ≥ D
**Conclusions:** I. A < C  II. A = C
*Which conclusion(s) follow?*

**Answer: Either I or II follows (neither follows on its own).**

**Method 1 (fastest) — Spot the "≤/≥ + complementary pair" signature.**
1. A vs C path: A ≤ B = C, so **A ≤ C**.
2. "A ≤ C" is exactly the union of "A < C" and "A = C." The two conclusions between the SAME pair are (a) `<` and (b) `=`, they are mutually exclusive and together cover `≤`.
3. That is the textbook **either-or** signature → answer is "Either I or II follows."
*Use this when:* neither conclusion follows individually AND the two conclusions are on the same pair of variables with complementary signs (`>`/`=` or `<`/`=`). Then the derived relation is the matching `≥` or `≤`.

**Method 2 — Test both individually, then check the pair.**
1. Check I alone: can A = C happen? Yes (A=B=C). So "A < C" is not always true → I fails.
2. Check II alone: can A < C happen? Yes (A<B=C). So "A = C" is not always true → II fails.
3. Both fail individually but one must be true → declare either-or.
*Use this when:* you are not yet fluent at spotting the signature — this brute check is safe and only takes a few seconds on two conclusions.

---

### Problem 6 — Linear seating (single row)

**Context:** Five people A, B, C, D, E sit in a row facing north.
- A is at the extreme left end.
- There are exactly two people between A and B.
- C sits immediately to the right of B.
- D is not adjacent to A.
*Who sits in the middle, and who is second from the right?*

**Answer: D is in the middle (seat 3); B is second from the right (seat 4).**

**Method 1 (fastest) — Direct sequential placement.**
1. Number seats 1–5 left to right (facing north → right hand points to higher numbers).
2. "A extreme left" → A = 1.
3. "Two between A and B" → seats 2,3 are between, so **B = 4.**
4. "C immediately right of B" → **C = 5.**
5. Left: seats 2 and 3 for D, E. "D not adjacent to A(1)" → D ≠ 2 → **D = 3, E = 2.**
6. Final order: A, E, D, B, C. Middle (3) = D; second from right (4) = B.
*Use this when:* clues pin absolute positions quickly (an end + a fixed gap). Place the most constrained person first and cascade.

**Method 2 — Full grid / elimination table.**
1. Draw a 5-column table; put an X in every cell a clue forbids and a tick where forced.
2. Row A: forced to col 1. B: only col 4 satisfies "two between A and B." C: forced col 5 by B. D: cross out col 2 (adjacent to A) and cols 1,4,5 (taken) → col 3. E takes the last cell.
3. Read the completed row.
*Use this when:* clues are relational/negative and you cannot place anyone outright — the grid stops you from holding cases in your head.

---

### Problem 7 — Square-table seating (case-split)

**Context:** Four people A, B, C, D sit around a square table, one per side, all facing the centre.
- B sits directly opposite A.
- C sits immediately to the right of A.
*Who sits opposite C, and where is D?*

**Answer: D sits opposite C (D is immediately to the left of A).**

**Method 1 (fastest) — Case-split on the one free choice.**
1. Fix A on one side facing centre. Opposite side = B (given).
2. That leaves the two remaining sides (A's left and A's right) for C and D.
3. C is A's *right*, so D must take the only seat left: A's *left*.
4. A's left and A's right are opposite sides of the square → **C and D are opposite each other.**
*Use this when:* only a couple of seats are unassigned — enumerate the tiny number of ways to fill them instead of building full geometry.

**Method 2 — Full plot with facing-direction.**
1. Place A on the North side facing centre (so A faces South). Facing South, A's right hand points West → C on the West side; A's left points East → D on East side; B opposite on South side.
2. West is opposite East → C opposite D. B opposite A.
*Use this when:* the question asks about left/right of *other* people too, so you need every seat's actual compass position. Slower but resolves all "to the right of X" follow-ups. Remember: for a person facing the centre, their left/right is the mirror of yours.

---

### Problem 8 — Coding by letter shift

**Context:** In a certain code, `CAT` is written as `DBU`.
*How is `DOG` written in that code?*

**Answer: EPH.**

**Method 1 (fastest) — Shift detection.**
1. Compare position-by-position: C→D (+1), A→B (+1), T→U (+1). Uniform shift **+1**.
2. Apply +1 to DOG: D→E, O→P, G→H → **EPH.**
*Use this when:* the code word is the same length as the plaintext and letters look "moved." Check the shift on just the first one or two letters, confirm on a third, then apply.

**Method 2 — Option elimination.**
1. If options are given, test the cheapest property: the first letter of DOG's code must be D+1 = E. Strike every option not starting with E.
2. Then check the last letter G+1 = H; strike the rest. One survivor.
*Use this when:* the shift is irregular or you want to avoid encoding all three letters — eliminate on first/last letter and you rarely need the middle.

---

### Problem 9 — Substitution coding (word ↔ word)

**Context:** In a code language:
- `tom fin sap` = "she is nice"
- `sap rem tel` = "nice and good"
- `fin del rem` = "is not good"
*What is the code for "good"?*

**Answer: `rem`.**

**Method 1 (fastest) — Common-word / common-code overlap.**
1. Find two lines that share the target English word. "good" is in line 2 and line 3.
2. Intersect their codes: line 2 {sap, rem, tel} ∩ line 3 {fin, del, rem} = **rem**.
3. That single shared code must be the shared word → **good = rem.**
*Use this when:* the target word appears in exactly two sentences — one intersection nails it, no need to decode everything.

**Method 2 — Full elimination grid.**
1. "nice" is in lines 1 & 2 → common code `sap` → nice = sap.
2. "is" is in lines 1 & 3 → common code `fin` → is = fin.
3. In line 2, remove `sap` (nice); remaining {rem, tel} map to {and, good}. In line 3 remove `fin` (is); remaining {del, rem} map to {not, good}. The code common to both remainders is `rem` → good = rem (and: tel, not: del).
*Use this when:* you also need the other words, or the target appears in all three lines so a single pair-intersection is ambiguous. Cross-checking every word guards against a coincidence.

---

### Problem 10 — Number/positional coding

**Context:** In a code, `FACE` is written as `6-1-3-5`.
*How is `HEAD` written?*

**Answer: 8-5-1-4.**

**Method 1 (fastest) — Recognise "letter = alphabet position."**
1. F=6, A=1, C=3, E=5 → each letter is just its rank in the alphabet (A=1 … Z=26).
2. HEAD → H=8, E=5, A=1, D=4 → **8-5-1-4.**
*Use this when:* the given numbers match A1–Z26 directly. Confirm with two letters, then read positions straight off (memorise the anchors A1, E5, J10, O15, T20, Z26 for speed).

**Method 2 — Difference / elimination check.**
1. If unsure the rule is "plain position," verify no offset: 6−F(6)=0, so no shift. Rule confirmed = position itself.
2. With options, match one letter (say H must be 8) and eliminate.
*Use this when:* the numbers might be position ± constant, or reversed (A=26). Testing for an offset on one letter tells you which scheme is in play.

---

### Problem 11 — Blood relation (statement)

**Context:** Pointing to a photograph, a man says, "She is the daughter of my grandfather's only son."
*How is the woman in the photo related to the man?*

**Answer: She is his sister.**

**Method 1 (fastest) — Direct deduction, inside-out.**
1. Resolve the innermost phrase first: "my grandfather's only son" = the man's father (a grandfather's only son must be the speaker's own father).
2. "Daughter of my father" = the man's sister.
*Use this when:* the sentence is a single nested chain of "X of Y of Z." Collapse from the innermost bracket outward; each phrase becomes one plain relation.

**Method 2 — Full family tree.**
1. Draw Grandfather at top. His "only son" is one node below = Father.
2. Under Father, add his daughter = the girl. The speaker (man) is also Father's child.
3. Same parents → the girl and the man are siblings → sister.
*Use this when:* the statement has multiple people or in-laws and the nesting is hard to read. The diagram makes gender and generation explicit and prevents "father vs grandfather" slips.

---

### Problem 12 — Blood relation (coded)

**Coding:** `P + Q` = P is the mother of Q; `P - Q` = P is the brother of Q; `P × Q` = P is the father of Q.
**Expression:** `P + Q × R`
*How is P related to R?*

**Answer: P is the grandmother of R.**

**Method 1 (fastest) — Decode each symbol, read the generation gap.**
1. `P + Q` → P is Q's mother. `Q × R` → Q is R's father.
2. P is the parent of Q, and Q is the parent of R → P is R's grandparent. P is female (a "mother") → **grandmother.**
*Use this when:* the expression is a short left-to-right chain. Translate symbols to words, then count generations (two "parent" links up = grand-).

**Method 2 — Mini family tree.**
1. Top: P. Arrow down (mother) to Q. Arrow down (father) from Q to R.
2. Two generations above R, female → grandmother.
*Use this when:* the chain mixes siblings and parents (so generation is easy to miscount) or the question asks about gender-neutral links — the tree keeps levels straight.

---

### Problem 13 — Direction (net displacement)

**Context:** A man walks 5 km North, then 3 km East, then 5 km South, then 3 km East.
*How far and in which direction is he from the starting point?*

**Answer: 6 km due East.**

**Method 1 (fastest) — Net displacement (cancel opposites).**
1. Vertical moves: 5 North and 5 South cancel → net 0.
2. Horizontal moves: 3 East + 3 East = 6 East.
3. No leftover vertical component, so answer is simply **6 km East** — no Pythagoras needed.
*Use this when:* moves are along the axes and opposite legs are equal. Sum North−South and East−West separately; if one sum is zero the answer is a straight line.

**Method 2 — Coordinate plot.**
1. Start (0,0). N5 → (0,5). E3 → (3,5). S5 → (3,0). E3 → (6,0).
2. End point (6,0): 6 units along +x, 0 along y → 6 km East.
*Use this when:* legs are unequal or leave both a North/South AND an East/West remainder (then distance = √(x²+y²) and direction is a diagonal like North-East). Plotting also catches order-of-turn mistakes.

---

### Problem 14 — Direction with turns

**Context:** A person starts facing North, walks 10 m, turns right and walks 10 m, turns right again and walks 10 m.
*In which direction is she now facing, and how far is she from the start?*

**Answer: She faces South; she is 10 m from the start (to the East of it).**

**Method 1 (fastest) — Track facing separately from position.**
1. Facing: North → (right) East → (right) South. So she ends facing **South.**
2. Position by net displacement: legs are N10, E10, S10. N and S cancel (0); East leftover = 10. So she is **10 m East** of start.
*Use this when:* the question asks about facing direction and displacement together. Update the compass heading on each "turn right/left" (right = clockwise N→E→S→W), and total the legs separately.

**Method 2 — Full coordinate plot.**
1. Start (0,0) facing N. Walk 10 N → (0,10). Turn right → face E, walk 10 → (10,10). Turn right → face S, walk 10 → (10,0).
2. End (10,0): distance = √(10²+0²) = 10 m, due East. Final heading South (last movement direction).
*Use this when:* there are several turns or unequal legs so you can lose track of both heading and coordinates — the plot fixes both at once.

---

### Problem 15 — Ranking / positions in a row

**Context:** In a row, A is 7th from the left and B is 9th from the right. A and B interchange their positions; after the swap, A is 11th from the left.
*How many people are in the row?*

**Answer: 19.**

**Method 1 (fastest) — Swap logic + the position formula.**
1. After the swap, A occupies B's original seat. A is now 11th from the left, so **B's original seat was 11th from the left.**
2. B was also 9th from the right. For one seat, total = (from left) + (from right) − 1 = 11 + 9 − 1 = **19.**
*Use this when:* two people interchange and you are given a new rank. The mover lands on the other's old seat, so that seat's two ranks pin the total with the +/−1 formula.

**Method 2 — Draw the line.**
1. Sketch positions. Mark B's seat as 11 from the left. From the right it is the 9th, so seats to its right (including itself) number 9 → seats 11 … total.
2. Positions to the left of B's seat = 10; B's seat itself = 1; to its right = 8 → 10 + 1 + 8 = 19.
*Use this when:* you distrust the formula or the wording is convoluted (overlaps, "between" clues). Drawing the actual line makes the ±1 overlap obvious and prevents off-by-one errors.

---

*15 problems, each with a fast default method and a safe fallback. Under time pressure, take Method 1; the moment the structure is odd, a negative/either-or appears, or you have hesitated, switch to Method 2.*
