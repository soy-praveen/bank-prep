# Reasoning Toolkit

Status: **basics fully covered.** Needs harder-puzzle reps via mocks.

---

## 1. Inequality (fast 3–5 marks)

**Combine rules:**
| Chain | Result |
|---|---|
| A > B > C | A > C |
| A > B ≥ C | A > C (strict wins) |
| A ≥ B ≥ C | A ≥ C |
| A > B **<** C | **No relation** (direction breaks) |
| A = B > C | A > C |

- A definite relation needs an **unbroken same-direction chain** between the two letters.
- **Either/Or:** true relation is ≥ or ≤, and the two conclusions are the same pair split into > and = (e.g. "L>N" and "L=N") → Either/Or.
- Options: (a) Only I (b) Only II (c) Either (d) Neither (e) Both.

---

## 2. Syllogism (fast 3 marks)

**Solve by the 6 forced pairs — don't reason from scratch:**

| Statements | Forced conclusion |
|---|---|
| All + All | All A are C |
| All + No | No A is C |
| Some + All | Some A are C |
| Some + No | Some A are not C |
| No + All | Some C are not A |
| No + Some | Some C are not A |

**Special:** **All + Some → Either/Or** (Some A are C / No A is C).

**Conversions (always valid, free marks):**
- All A are B → **Some B are A** · No A is B → **No B is A**

**Algorithm (in order):**
1. Is I forced? Is II forced? → Both = (e); one = (a/b).
2. Neither forced → is I the **exact negation** of II? Complementary pair (Some↔No, or All↔Some-not) → **Either/Or (c)**. Else → **Neither (d)**.

**Note:** "All A are C" ⇒ "Some A are C" (All contains Some). "Only a few X are Y" = Some + Some-not.

---

## 3. Puzzles & Seating (the deciding block, 15–20 marks)

**Golden method: turn words into a fixed frame, place by certainty (locked clues first, floating clues last).**

### Linear seating
- Draw positions 1→N. Write **L** and **R** on the ends before placing anyone (kills the flip error).
- Facing North: person's right = higher position. "Nth to the right" = N−1 people between.

### Double-variable puzzles (seating/floor + attribute) — TWO-PASS GRID
The whole trick: **never hold two things per person at once.**
1. Draw a grid: a row per variable (Person, and e.g. Month).
2. **Pass 1:** solve ALL positions using position clues — ignore the attribute completely.
3. **Pass 2:** drop in the attribute via **bridge clues** (a clue that ties an attribute to a position, e.g. "the one who travelled in Jan sits at the extreme right"). Elimination cleans up leftovers.
Floor puzzles = same method, vertical. Box puzzles = same. Scheduling = same.

### Circular seating
- **Facing centre → LEFT = clockwise, RIGHT = anti-clockwise.** (Facing outward = opposite.)
- Label your clockwise arrow once. No fixed "ends" — fix one person, build relative.

### Multi-layer monster puzzles (position + attribute + gender + opposite)
- **Solve the attribute layer by elimination FIRST** (often fully forced independent of seats), then seats.
- **Exam strategy: if a puzzle isn't cracking in ~1 min of reading, SKIP it.** You don't need monsters to hit target.

---

## 4. Direction Sense (fast 2–3 marks)

- Plot on a grid (North = up). Distance via Pythagoras (memorize 3-4-5, 6-8-10, 5-12-13, 9-12-15).
- **"X with respect to Y" → Y is your origin. Stand at Y, point to X.** (Mixing this up gives the exact opposite direction — NE becomes SW.) The word after "with respect to" is your reference point.

---

## 5. Blood Relations (fast 2–3 marks)

**Always draw a generation tree. Mark M/F on everyone.**

**Terms:** Nephew = sibling's son · Niece = sibling's daughter · Uncle/Aunt = parent's sibling · Cousin = uncle/aunt's child · Grandson/daughter = child's child · Son/Daughter-in-law = child's spouse / spouse's... (see full glossary).

**Tricks:**
- Coded relations: decode one symbol at a time, build the tree.
- **Self-reference riddles:** "only daughter of my mother" = the speaker herself (if female) / "only son of my father" = himself (if male). Read the speaker's gender first.
- If a relation's answer depends on an unstated gender → "cannot be determined."

---

## 6. Coding-Decoding

- **Letter shift:** find the shift from one letter, apply. (CAT→DBU = +1.)
- **Position values:** A=1…Z=26 (landmarks EJOTY: E5, J10, O15, T20, Y25). **Opposite letters sum to 27** (A↔Z).
- **Coded sentences:** find two sentences sharing exactly ONE word → their shared code = that word. Triangulate, never guess.

---

## 7. Alphanumeric Series

A string of letters/numbers/symbols. Question types: how many numbers **followed by / preceded by** a symbol; Nth from an end; how many elements **between** two given ones. Fast scanning, no logic — easy pickups.

---

## 8. Order & Ranking

Row of N: position from left + position from right. Between two people = (difference of positions) − 1. Total = (left rank) + (right rank) − 1 for the same person.
