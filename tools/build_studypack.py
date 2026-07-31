#!/usr/bin/env python3
"""Build the BankPrep study pack PDF (reasoning + arithmetic)."""
import os
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (BaseDocTemplate, Frame, KeepTogether, PageBreak,
                                PageTemplate, Paragraph, Spacer, Table, TableStyle)

OUT = os.environ.get("OUT", "BankPrep-StudyPack.pdf")

INK = colors.HexColor("#1A2230")
MUTED = colors.HexColor("#5B6676")
ACCENT = colors.HexColor("#0D7D72")
VIOLET = colors.HexColor("#4F46E5")
WARN = colors.HexColor("#B4700F")
LINE = colors.HexColor("#D8DEE7")
RAISED = colors.HexColor("#F1F4F8")
TEAL_BG = colors.HexColor("#E6F4F2")

ss = getSampleStyleSheet()

def S(name, **kw):
    base = dict(fontName="Helvetica", fontSize=9.6, leading=14, textColor=INK,
                spaceBefore=0, spaceAfter=0, alignment=TA_LEFT)
    base.update(kw)
    return ParagraphStyle(name, **base)

st = {
    "h1": S("h1", fontName="Helvetica-Bold", fontSize=19, leading=23,
            textColor=ACCENT, spaceBefore=6, spaceAfter=10),
    "h2": S("h2", fontName="Helvetica-Bold", fontSize=13.5, leading=17,
            textColor=INK, spaceBefore=12, spaceAfter=6),
    "h3": S("h3", fontName="Helvetica-Bold", fontSize=10.8, leading=14,
            textColor=VIOLET, spaceBefore=9, spaceAfter=4),
    "p": S("p", spaceAfter=5),
    "small": S("small", fontSize=8.8, leading=12.5, textColor=MUTED, spaceAfter=4),
    "q": S("q", spaceAfter=4, leftIndent=13, firstLineIndent=-13),
    "bul": S("bul", spaceAfter=3, leftIndent=13, firstLineIndent=-9),
    "boxp": S("boxp", fontSize=9.4, leading=13.5, spaceAfter=3),
    "cell": S("cell", fontSize=8.9, leading=12),
    "cellb": S("cellb", fontSize=8.9, leading=12, fontName="Helvetica-Bold"),
    "cover_t": S("cover_t", fontName="Helvetica-Bold", fontSize=30, leading=34,
                 textColor=ACCENT, spaceAfter=8),
    "cover_s": S("cover_s", fontSize=12.5, leading=17, textColor=MUTED, spaceAfter=4),
}

story = []

def h1(t): story.append(Paragraph(t, st["h1"]))
def h2(t): story.append(Paragraph(t, st["h2"]))
def h3(t): story.append(Paragraph(t, st["h3"]))
def p(t): story.append(Paragraph(t, st["p"]))
def small(t): story.append(Paragraph(t, st["small"]))
def sp(h=5): story.append(Spacer(1, h))
def pb(): story.append(PageBreak())

def bullets(items):
    for it in items:
        story.append(Paragraph("&bull;&nbsp; " + it, st["bul"]))
    sp(3)

def qlist(items, start=1):
    for i, it in enumerate(items, start):
        story.append(Paragraph(f"<b>{i}.</b>&nbsp; {it}", st["q"]))
    sp(4)

def box(lines, tint=TEAL_BG, edge=ACCENT):
    """Highlighted method/formula box."""
    inner = [[Paragraph(l, st["boxp"])] for l in lines]
    t = Table(inner, colWidths=[163 * mm])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), tint),
        ("LINEBEFORE", (0, 0), (0, -1), 2.2, edge),
        ("LEFTPADDING", (0, 0), (-1, -1), 9),
        ("RIGHTPADDING", (0, 0), (-1, -1), 9),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ]))
    story.append(KeepTogether(t))
    sp(7)

def table(rows, widths=None, head=True):
    data = []
    for r_i, row in enumerate(rows):
        style = st["cellb"] if (head and r_i == 0) else st["cell"]
        data.append([Paragraph(str(c), style) for c in row])
    n = len(rows[0])
    widths = widths or [163 * mm / n] * n
    t = Table(data, colWidths=widths, repeatRows=1 if head else 0)
    cmds = [
        ("GRID", (0, 0), (-1, -1), 0.5, LINE),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]
    if head:
        cmds.append(("BACKGROUND", (0, 0), (-1, 0), RAISED))
    t.setStyle(TableStyle(cmds))
    story.append(t)
    sp(8)

# ===========================================================================
# COVER
# ===========================================================================
sp(58)
story.append(Paragraph("BankPrep", st["cover_t"]))
story.append(Paragraph("SBI PO Prelims - Reasoning &amp; Arithmetic Study Pack",
                       st["cover_s"]))
sp(12)
box([
    "<b>Part 1</b> - Seating Arrangement: 7 hard types, methods and solved puzzles",
    "<b>Part 2</b> - Seating practice sets A to G (unsolved)",
    "<b>Part 3</b> - Syllogism: method + 20 questions",
    "<b>Part 4</b> - Coding-Decoding: 6 types + 12 questions",
    "<b>Part 5</b> - Order &amp; Ranking: formulas + 8 questions",
    "<b>Part 6</b> - Arithmetic: Profit &amp; Loss, SI/CI, Time &amp; Work, Partnership, "
    "Mixtures, Pipes &amp; Cisterns",
    "<b>Part 7</b> - Answer keys for everything",
])
small("Every method here was built and tested during the prep sessions. "
      "Work the questions on paper, then self-check against Part 7.")
sp(10)
box([
    "<b>Exam:</b> 1 August &nbsp;|&nbsp; English 40Q/20min &nbsp;|&nbsp; "
    "Quant 30Q/20min &nbsp;|&nbsp; Reasoning 30Q/20min",
    "<b>Negative marking:</b> 0.25 per wrong answer. A rushed wrong answer swings 1.25 marks.",
    "<b>Attempt order:</b> English, then Reasoning, then Quant. Skip any set that will "
    "not crack in about a minute.",
], tint=colors.HexColor("#FFF6E6"), edge=WARN)
pb()

# ===========================================================================
# PART 1 - SEATING TYPES
# ===========================================================================
h1("Part 1 - Seating Arrangement: the 7 hard types")

p("Every seating puzzle is the same skill: <b>turn words into a fixed frame, then place "
  "people by certainty</b> - locked clues first, floating clues last. What changes between "
  "types is only the frame and the left/right rule.")

box([
    "<b>THE TWO COUNTING RULES - the most common source of lost marks</b>",
    "<b>&quot;Nth to the left/right of X&quot;</b> = move <b>exactly N seats</b>. "
    "2nd = 2 seats over.",
    "<b>&quot;K persons sit between X and Y&quot;</b> = they are <b>K+1 seats apart</b>.",
    "Start counting at the <b>neighbour</b>, never at the person themselves. "
    "Say it out loud: &quot;B one, D two, A three.&quot;",
], tint=colors.HexColor("#FFF6E6"), edge=WARN)

h2("Type 1 - Linear with mixed facing (North / South)")
box([
    "Facing <b>NORTH</b> -&gt; their right = <b>higher</b> position numbers.",
    "Facing <b>SOUTH</b> -&gt; their right = <b>lower</b> position numbers (flipped).",
    "The direction is decided by the <b>reference person's</b> facing, not the subject's.",
])
p("<b>The impossibility trick:</b> when a clue would push someone off the row, that "
  "impossibility <i>forces</i> the facing. If Y is at seat 7 of 7 and &quot;C is 2nd to the "
  "right of Y&quot;, then Y facing North puts C at seat 9 - impossible. So Y faces South and "
  "C is at 5. You gain Y's direction for free.")
p("<b>Method:</b> write positions 1-N with <b>L</b> and <b>R</b> marked at the ends. Test both "
  "facings on each direction clue; one usually dies instantly. Keep facings in a second row "
  "under the names.")

h2("Type 2 - Double row (parallel rows facing each other)")
box([
    "Two rows, equal numbers, facing each other. Person in column <i>i</i> of row 1 faces "
    "the person in column <i>i</i> of row 2.",
    "The rows have <b>mirrored</b> left/right. The row facing <b>North</b> -&gt; right = our "
    "right. The row facing <b>South</b> -&gt; right = our left.",
    "<b>Bridge clue = &quot;X faces Y&quot;</b> - it welds the two rows together by locking a "
    "column across both.",
])
p("Draw them stacked with columns aligned and mark each row's arrow once. Solve one row "
  "fully, then use a &quot;faces&quot; clue to anchor the second.")

h2("Type 3 - Circular with mixed facing (some in, some out)")
box([
    "Facing <b>CENTRE</b> -&gt; left = <b>clockwise</b>, right = anti-clockwise.",
    "Facing <b>OUTSIDE</b> -&gt; <b>flipped</b>: left = anti-clockwise, right = clockwise.",
    "<b>Opposite</b> in a circle of 8 = <b>+4 seats</b>.",
])
bullets([
    "Fix anyone at seat 1 and number seats 1-8 clockwise. Only relative positions matter, "
    "so this costs nothing.",
    "Write <b>I</b> or <b>O</b> beside every name the moment you learn a facing.",
    "The impossibility trick still works, but instead of falling off the row, a bad facing "
    "lands someone on an <b>already-occupied seat</b>.",
])

h2("Type 4 - Square / rectangular table")
p("Eight people: four at the <b>corners</b> facing the <b>centre</b>, four at the "
  "<b>middle of the sides</b> facing <b>outside</b>. Some papers reverse it - always read which.")
p("<b>Why it is nasty:</b> the facing alternates every seat, so left/right <b>zigzags</b> as "
  "you go around. Write the facing strip <i>once</i> before placing anybody, then every clue "
  "becomes a lookup:")
table([
    ["seat", "1", "2", "3", "4", "5", "6", "7", "8"],
    ["type", "cor", "mid", "cor", "mid", "cor", "mid", "cor", "mid"],
    ["faces", "IN", "OUT", "IN", "OUT", "IN", "OUT", "IN", "OUT"],
    ["left =", "CW", "ACW", "CW", "ACW", "CW", "ACW", "CW", "ACW"],
], widths=[23 * mm] + [17.5 * mm] * 8, head=False)

h2("Type 5 - Uncertain count (unknown number of people)")
p("You do not know how long the row is, so nothing anchors and everything floats. "
  "The escape is to hunt for <b>absolute anchors</b> first.")
box([
    "<b>&quot;Only K persons sit to the left of X&quot;</b> -&gt; X is at seat <b>K+1</b>. Exact.",
    "<b>&quot;X sits Nth from the left end&quot;</b> -&gt; X = seat N. Exact.",
    "<b>Finding the total:</b> &quot;only K persons sit to the right of X&quot; -&gt; "
    "<b>total = position(X) + K</b>.",
    "<b>Conversion:</b> position from right = <b>total - position from left + 1</b>.",
])
p("Place the anchors, chain the relative clues off them, and <b>park any clue that floats</b> - "
  "it resolves later. Hard versions bury the anchor late in the clue list and tie the total to "
  "an attribute-holder rather than a named person.")

h2("Type 6 - Circular / linear with an attribute (compound)")
p("Position plus facing plus attribute, all at once. The clean two-pass grid does not work "
  "here because the attribute clues <i>are</i> position clues.")
box([
    "<b>Treat the attribute as a PLACEHOLDER PERSON.</b> &quot;The one who likes Blue sits "
    "opposite Q&quot; -&gt; write <b>Blue</b> on that seat like a name.",
    "Keep placing placeholders alongside real names. When a later clue lands a <b>named "
    "person on a seat that already holds a placeholder</b>, that <b>collision</b> welds the "
    "attribute to the person.",
    "Hunt for collisions - they are where the puzzle cracks open.",
])
p("<b>Two-pass grid</b> still applies when position clues and attribute clues are separate "
  "(floor puzzles, month puzzles): solve <b>all positions first</b>, ignoring the attribute "
  "entirely, then drop attributes in via <b>bridge clues</b> that tie an attribute to a position.")

h2("Type 7 - Combo (seating + blood relation)")
p("Two puzzles fused: a seating diagram <i>and</i> a family tree. The mistake is building both "
  "at once.")
box([
    "<b>SPLIT every clue into two notes.</b> &quot;B, the wife of A, sits opposite A&quot; "
    "becomes:",
    "&nbsp;&nbsp;<b>Position:</b> B is opposite A. &nbsp;&nbsp;<b>Relation:</b> B = A's wife, "
    "B is female.",
    "<b>Pass 1 - seating only.</b> Ignore every relation word.",
    "<b>Pass 2 - tree only.</b> Now use the relation halves.",
    "Mark <b>M/F</b> beside every name as gender is revealed. An unstated gender means "
    "<b>cannot be determined</b>.",
])

h3("Family terms - quick glossary")
table([
    ["Term", "Who they are", "Term", "Who they are"],
    ["Nephew", "brother's or sister's SON", "Niece", "brother's or sister's DAUGHTER"],
    ["Uncle", "parent's brother", "Aunt", "parent's sister"],
    ["Cousin", "uncle's or aunt's child", "Sibling", "brother or sister"],
    ["Son-in-law", "daughter's husband", "Daughter-in-law", "son's wife"],
    ["Brother-in-law", "spouse's brother / sister's husband", "Sister-in-law",
     "spouse's sister / brother's wife"],
], widths=[27 * mm, 55 * mm, 27 * mm, 54 * mm])

h2("Exam strategy for this block")
bullets([
    "Puzzles and seating are <b>15 to 20 of the 30 reasoning marks</b> - the deciding block.",
    "A multi-layer monster (position + attribute + gender + opposite) is a <b>strategic "
    "skip</b>. If a set is not cracking in about a minute of reading, leave it and bank the "
    "easy sets.",
    "In multi-layer sets, attack the <b>attribute layer by elimination first</b> - it is often "
    "fully forced independent of the seats.",
    "Before writing any answer, say the walk out loud: &quot;W faces out, so right is "
    "clockwise - seven, eight. V.&quot; Three seconds, and it converts build-accuracy into "
    "marks.",
])
pb()

# ===========================================================================
# PART 2 - PRACTICE SETS
# ===========================================================================
h1("Part 2 - Seating practice sets (A to G)")
small("Prelims difficulty. Sets E, F and G carry a second variable - those are the ones that "
      "decide the section. Answers in Part 7.")

h2("SET A - Linear, mixed facing (8 people)")
p("Eight people sit in a row (positions 1-8, left to right). Some face <b>North</b>, some face "
  "<b>South</b>.")
qlist([
    "P sits <b>4th from the left</b> end.",
    "<b>Two</b> persons sit between P and Q; Q is to the <b>right</b> of P.",
    "R sits <b>2nd to the right</b> of Q.",
    "S sits <b>3rd to the left</b> of R. <b>R faces the same direction as Q.</b>",
    "T sits at an <b>extreme end</b>.",
    "U sits <b>2nd to the right</b> of T.",
    "V sits <b>3rd to the right</b> of U.",
    "<b>Four</b> persons face South.",
    "W and S face the <b>same</b> direction.",
    "P and V face the <b>same</b> direction. <b>P faces North.</b>",
])
bullets([
    "<b>A1.</b> Who sits at the extreme right end?",
    "<b>A2.</b> How many persons sit between W and R?",
    "<b>A3.</b> Who sits 3rd to the right of Q?",
    "<b>A4.</b> How many persons face North?",
    "<b>A5.</b> Who sits immediately to the left of V?",
])

h2("SET B - Circular + profession (8 people, all facing centre)")
p("Eight people sit around a circular table, <b>all facing the centre</b>. Each has a different "
  "profession. H takes the one remaining seat.")
qlist([
    "A sits <b>3rd to the left</b> of D.",
    "C sits <b>2nd to the right</b> of A.",
    "B sits <b>opposite</b> C.",
    "E sits <b>immediately to the right</b> of B.",
    "F sits <b>3rd to the left</b> of E.",
    "G sits <b>3rd to the left</b> of F.",
    "<b>A is a Doctor.</b>",
    "The <b>Doctor</b> sits <b>opposite</b> the <b>Teacher</b>.",
    "The <b>Lawyer</b> sits <b>2nd to the right</b> of the Teacher.",
    "The <b>Engineer</b> sits <b>immediately to the left</b> of the Doctor.",
])
bullets([
    "<b>B1.</b> Who sits opposite D?",
    "<b>B2.</b> Who is the Teacher?",
    "<b>B3.</b> Counting <b>clockwise from B</b>, how many persons sit between B and C?",
    "<b>B4.</b> Who sits 3rd to the right of H?",
    "<b>B5.</b> Who is the Engineer?",
])

h2("SET C - Double row (12 people, 6 + 6)")
p("<b>Row 1</b> - P, Q, R, S, T, U - facing <b>South</b>. <b>Row 2</b> - A, B, C, D, E, F - "
  "facing <b>North</b>. Each row-1 person faces exactly one row-2 person.")
qlist([
    "P sits <b>3rd to the left</b> of T.",
    "T sits at an <b>extreme end</b> of row 1.",
    "Q sits <b>2nd to the right</b> of P.",
    "R sits <b>immediately to the left</b> of Q.",
    "S sits at an <b>extreme end</b> of row 1.",
    "<b>C faces P.</b>",
    "A sits <b>3rd to the left</b> of C.",
    "B sits <b>2nd to the right</b> of A.",
    "D sits <b>immediately to the right</b> of C.",
    "E does <b>not</b> sit at an extreme end.",
])
bullets([
    "<b>C1.</b> Who faces R?",
    "<b>C2.</b> Who sits at the two extreme ends of row 2?",
    "<b>C3.</b> How many persons sit between C and F?",
    "<b>C4.</b> Who sits 2nd to the left of the person who faces U?",
    "<b>C5.</b> Who faces S?",
])

h2("SET D - Square table + attribute (8 people)")
p("Eight people sit around a <b>square table</b>: four at the <b>corners</b> facing the "
  "<b>centre</b>, four at the <b>middle of the sides</b> facing <b>outside</b>. Q takes the one "
  "remaining seat.")
qlist([
    "J sits at a <b>corner</b>.",
    "The one who likes <b>Tea</b> sits <b>2nd to the right</b> of J.",
    "K sits <b>opposite</b> the one who likes Tea.",
    "L sits <b>3rd to the left</b> of K.",
    "M sits <b>immediately to the right</b> of L.",
    "N sits <b>2nd to the right</b> of M.",
    "O sits <b>immediately to the right</b> of N.",
    "P sits <b>2nd to the left</b> of O.",
])
bullets([
    "<b>D1.</b> Who likes Tea?",
    "<b>D2.</b> Who sits opposite O?",
    "<b>D3.</b> Who sits 2nd to the left of J?",
    "<b>D4.</b> Counting <b>clockwise from P</b>, how many persons sit between P and N?",
    "<b>D5.</b> Who sits immediately to the right of Q?",
])

h2("SET E - Circular + mixed facing + month (double variable)")
p("Eight people sit around a circular table; some face the <b>centre</b>, some face "
  "<b>outside</b>. Each was born in a different month.")
qlist([
    "A sits <b>3rd to the left</b> of B. <b>A faces the centre.</b>",
    "The one born in <b>March</b> sits <b>opposite</b> B.",
    "C sits <b>2nd to the right</b> of the one born in March. <b>The March-born faces outside.</b>",
    "D sits <b>immediately to the left</b> of C. <b>C faces the centre.</b>",
    "The one born in <b>July</b> sits <b>4th to the right</b> of C.",
    "<b>E is born in July.</b>",
    "F sits <b>2nd to the left</b> of E. <b>E faces the centre.</b>",
    "G sits <b>immediately to the left</b> of F.",
    "<b>Three</b> persons face outside.",
    "D and B face the <b>same</b> direction; G and H face the <b>same</b> direction. "
    "<b>D faces outside.</b>",
    "The one born in <b>January</b> sits <b>2nd to the right</b> of E.",
    "<b>H is born in September.</b>",
    "The one born in <b>April</b> sits <b>opposite</b> the one born in September.",
    "<b>C is born in December. D is born in February.</b>",
])
bullets([
    "<b>E1.</b> Who is born in March?",
    "<b>E2.</b> Who sits 3rd to the right of the one born in January?",
    "<b>E3.</b> Counting <b>clockwise from D</b>, how many persons sit between D and H?",
    "<b>E4.</b> Who sits opposite the one born in December?",
    "<b>E5.</b> How many persons face the centre?",
])

h2("SET F - Floor + Flat grid (2D) + colour")
p("Ten persons live in a <b>5-floor building with 2 flats per floor</b> - <b>Flat-1</b> (west) "
  "and <b>Flat-2</b> (east). Floors are numbered <b>1 (bottom) to 5 (top)</b>. J takes the one "
  "remaining flat.")
qlist([
    "<b>Two</b> persons live between A and E, and both live in <b>Flat-1</b>.",
    "E lives on the <b>lowest</b> floor.",
    "G lives <b>immediately below A</b>, in the same flat.",
    "B lives <b>immediately below G</b>, in the same flat.",
    "D lives in the <b>same flat as B</b>, on the <b>topmost</b> floor.",
    "C lives in <b>Flat-2</b>, on the <b>same floor as G</b>.",
    "F lives <b>immediately above C</b>, in the same flat.",
    "I lives on the <b>topmost</b> floor in Flat-2.",
    "H lives on the <b>lowest</b> floor in Flat-2.",
    "The one who likes <b>Red</b> lives on the 3rd floor in Flat-2.",
    "The one who likes <b>Blue</b> lives <b>immediately above</b> the Red-liker, in the same flat.",
    "The one who likes <b>White</b> lives on the <b>topmost floor in Flat-1</b>.",
])
bullets([
    "<b>F1.</b> Who lives on the 2nd floor in Flat-2?",
    "<b>F2.</b> How many persons live between A and B?",
    "<b>F3.</b> Who likes Blue?",
    "<b>F4.</b> Who lives immediately above H?",
    "<b>F5.</b> Who likes White?",
])
small("Treat this as a <b>table with two columns</b>, not a line: floors down the side, "
      "Flat-1 and Flat-2 as columns.")

h2("SET G - Double row + sport (attribute across both rows)")
p("<b>Row 1</b> - A, B, C, D, E - facing <b>South</b>. <b>Row 2</b> - P, Q, R, S, T - facing "
  "<b>North</b>. Each likes a different sport.")
qlist([
    "C sits <b>3rd to the right</b> of A.",
    "A sits at an <b>extreme end</b> of row 1.",
    "B sits <b>immediately to the left</b> of C.",
    "D sits at an <b>extreme end</b> of row 1.",
    "<b>R faces B.</b>",
    "P sits <b>2nd to the left</b> of R.",
    "Q sits <b>immediately to the right</b> of R.",
    "S does <b>not</b> sit at an extreme end.",
    "The one who likes <b>Cricket</b> faces D.",
    "The one who likes <b>Tennis</b> sits <b>2nd to the right</b> of the Cricket-liker.",
    "<b>E likes Hockey.</b>",
    "The one who likes <b>Football</b> sits <b>immediately to the left</b> of the Hockey-liker, "
    "in the same row.",
])
bullets([
    "<b>G1.</b> Who faces C?",
    "<b>G2.</b> Who likes Tennis?",
    "<b>G3.</b> Who sits at the two extreme ends of row 1?",
    "<b>G4.</b> Who sits 2nd to the left of Q?",
    "<b>G5.</b> Who likes Football?",
])
pb()

h1("Part 2B - Session puzzles, worked (1 to 7)")
small("These are the puzzles used to learn each type, with the solved arrangement underneath. "
      "Re-solve them cold in a week and check against the grid.")

h2("Puzzle 1 - Linear, mixed facing")
p("Seven people A-G in a row (positions 1-7). Some face North, some face South. "
  "<i>A is 3rd from the left. Three persons sit between A and B. C is 2nd to the right of B. "
  "D is 3rd to the left of C. E is immediately to the right of D. G is 3rd to the right of E. "
  "Three persons face South. F and G face opposite directions. Both immediate neighbours of A "
  "face the same direction.</i>")
table([
    ["Pos", "1", "2", "3", "4", "5", "6", "7"],
    ["Person", "E", "D", "A", "G", "C", "F", "B"],
    ["Faces", "N", "S", "N", "S", "N", "N", "S"],
], widths=[25 * mm] + [19.7 * mm] * 7, head=False)
p("<b>Key move:</b> B is forced to seat 7; then &quot;C is 2nd to the right of B&quot; would put "
  "C at seat 9 if B faced North - impossible, so B faces South. The cascade runs from there.")

h2("Puzzle 2 - Double row")
p("Row 1 (P, Q, R, S, T) faces South; Row 2 (A, B, C, D, E) faces North. "
  "<i>P is 3rd to the right of R. R is at an extreme end. S is 2nd to the left of P. Q is at an "
  "extreme end. A faces T. B is 2nd to the right of A. D is 3rd to the left of B. E is not at an "
  "extreme end.</i>")
table([
    ["Column", "1", "2", "3", "4", "5"],
    ["Row 2 (North)", "C", "D", "A", "E", "B"],
    ["Row 1 (South)", "Q", "P", "T", "S", "R"],
], widths=[43 * mm] + [24 * mm] * 5, head=False)
p("<b>Answers:</b> faces P = D; ends of row 1 = Q and R; immediately right of the one facing S "
  "= B; between D and B = 2; faces Q = C.")

h2("Puzzle 3 - Circular, mixed facing")
p("Eight people A-H around a circle; some face the centre, some outside. "
  "<i>A is 2nd to the left of B (B faces centre). C is opposite A. D is 3rd to the right of C "
  "(C faces outside). E is 2nd to the right of D (D faces centre). F is opposite E. G is "
  "immediately to the right of F. Both neighbours of G face the same direction. E and H face "
  "opposite directions. Four face outside. A faces the same direction as B.</i>")
table([
    ["Seat", "1", "2", "3", "4", "5", "6", "7", "8"],
    ["Person", "B", "D", "A", "F", "G", "H", "C", "E"],
    ["Faces", "IN", "IN", "IN", "OUT", "OUT", "OUT", "OUT", "IN"],
], widths=[21 * mm] + [17.75 * mm] * 8, head=False)
p("<b>Key move:</b> clue 6 - if F faced the centre, G would land on seat 3 which is already A. "
  "So F faces outside. That is the circular version of the impossibility trick.")

h2("Puzzle 4 - Square table")
p("Eight people P-W: corners face the centre, mid-sides face outside. "
  "<i>P is at a corner. T is immediately to the left of P. R is 3rd to the right of T. Q is 2nd "
  "to the left of R. S is opposite Q. V is 3rd to the right of S. W is 2nd to the left of V.</i>")
table([
    ["Seat", "1", "2", "3", "4", "5", "6", "7", "8"],
    ["Type", "cor", "mid", "cor", "mid", "cor", "mid", "cor", "mid"],
    ["Person", "P", "T", "S", "U", "R", "W", "Q", "V"],
], widths=[21 * mm] + [17.75 * mm] * 8, head=False)
p("<b>Answers:</b> opposite P = R; 2nd to the right of W = V; between U and Q clockwise = 2; "
  "immediately left of S = U; T with respect to R = 3rd to the right.")

h2("Puzzle 5 - Uncertain count")
p("<i>Only five persons sit to the left of P. Q is 4th to the right of P. Three persons sit "
  "between Q and R. S is 2nd to the left of R. T is exactly midway between P and Q. Only two "
  "persons sit to the right of R. U is 3rd to the left of T. V is immediately to the left of "
  "U.</i>")
p("<b>Positions:</b> V = 4, U = 5, P = 6, T = 8, Q = 10, S = 12, R = 14. "
  "<b>Total = 14 + 2 = 16.</b>")
p("<b>Answers:</b> 16 in the row; between T and S = 3; Q is 7th from the right; 2nd to the right "
  "of V = P; between U and Q = 4.")

h2("Puzzle 5B - Uncertain count, hard (with an attribute)")
p("<i>Only three persons sit to the left of A. The Guava-liker is 6th to the right of A. B is "
  "2nd to the left of the Guava-liker. Three persons sit between B and C. Only two persons sit "
  "to the right of C. The Litchi-liker is 3rd to the left of C. G is immediately to the left of "
  "the Guava-liker. D likes Guava. E is 4th to the left of D. F is exactly midway between E and "
  "B. The Papaya-liker is 3rd from the right end.</i>")
p("<b>Positions:</b> A = 4, E = 6, F = 7, B = 8, G = 9 (Litchi), D = 10 (Guava), "
  "C = 12 (Papaya). <b>Total = 12 + 2 = 14.</b>")
p("<b>Answers:</b> 14 in the row; Litchi = G; E is 9th from the right; between F and D = 2; "
  "3rd to the right of A = F.")
p("<b>Key move:</b> clues 6 and 7 point at the <i>same seat</i> - that cross-link is how G "
  "gets a fruit without any clue naming it.")

h2("Puzzle 6 - Circular + attribute (compound)")
p("Eight friends P-W, some facing centre, some outside, each liking a different colour. "
  "<i>Q is 3rd to the left of P (P faces centre). The Blue-liker is opposite Q. R is 2nd to the "
  "right of the Blue-liker (who faces outside). S is immediately to the left of R (R faces "
  "centre). The Green-liker is 3rd to the right of S (S faces outside). T likes Green. U is 2nd "
  "to the left of T (T faces centre). V is immediately to the left of U. Four face outside. Q "
  "and V face the same direction. W faces the same direction as T.</i>")
table([
    ["Seat", "1", "2", "3", "4", "5", "6", "7", "8"],
    ["Person", "P", "R", "S", "Q", "W", "T", "V", "U"],
    ["Faces", "IN", "IN", "OUT", "OUT", "IN", "IN", "OUT", "OUT"],
    ["Colour", "-", "-", "-", "-", "-", "Green", "-", "Blue"],
], widths=[21 * mm] + [17.75 * mm] * 8, head=False)
p("<b>The collision:</b> the Blue placeholder goes on seat 8 early; much later U lands on seat "
  "8, which is what makes U the Blue-liker.")

h2("Puzzle 7 - Combo (seating + blood relation)")
p("Eight family members around a circular table, all facing the centre. "
  "<i>A is 2nd to the left of his daughter-in-law D. F sits between A and D. B, the wife of A, "
  "sits opposite A. C, the only son of A, is 2nd to the left of B. E is immediately to the left "
  "of C. H, the son of E, sits opposite E. G is immediately to the right of C. F and G are the "
  "children of C and D. E is the daughter of B.</i>")
table([
    ["Seat", "1", "2", "3", "4", "5", "6", "7", "8"],
    ["Person", "A", "F", "D", "H", "B", "G", "C", "E"],
], widths=[21 * mm] + [17.75 * mm] * 8, head=False)
p("<b>Family tree:</b> A (M) is married to B (F). Their children are C (M) and E (F). "
  "D (F) is C's wife. F and G are the children of C and D. H (M) is E's son.")
p("<b>Answers:</b> H is C's <b>nephew</b> (E is C's sister); opposite G = <b>F</b>; D is E's "
  "<b>sister-in-law</b>; 3rd to the left of B = <b>E</b>; clockwise between H and C = <b>2</b>.")
pb()

# ===========================================================================
# PART 3 - SYLLOGISM
# ===========================================================================
h1("Part 3 - Syllogism")

box([
    "<b>THE ALGORITHM - run it in this order, every time</b>",
    "<b>1.</b> Is conclusion I forced? Is II forced? &nbsp; Both -&gt; <b>(e)</b>. "
    "Exactly one -&gt; <b>(a)</b> or <b>(b)</b>.",
    "<b>2.</b> Neither forced -&gt; are I and II an <b>exact opposite pair</b>? "
    "<b>Yes -&gt; (c) Either/Or. No -&gt; (d) Neither.</b>",
    "The only two complementary pairs: <b>Some &lt;-&gt; No</b>, and "
    "<b>All &lt;-&gt; Some-not</b>.",
])
p("<b>Why the pair test works:</b> &quot;Some X are Y&quot; means at least one; &quot;No X is "
  "Y&quot; means zero. Between them they cover every case with no gap, so one must be true even "
  "when you cannot tell which. &quot;Some X are Y&quot; vs &quot;All X are Y&quot; are both "
  "positive claims - they leave a gap, so that is Neither.")

h3("The 6 forced pairs - memorise these")
table([
    ["Statements", "Forced conclusion"],
    ["All + All", "All A are C"],
    ["All + No", "No A is C"],
    ["Some + All", "Some A are C"],
    ["Some + No", "Some A are not C"],
    ["No + All", "Some C are not A"],
    ["No + Some", "Some C are not A"],
], widths=[60 * mm, 103 * mm])
box([
    "<b>Special case:</b> <b>All + Some</b> -&gt; <b>Either/Or</b> "
    "(&quot;Some A are C&quot; / &quot;No A is C&quot;).",
    "<b>Free conversions:</b> All A are B -&gt; <b>Some B are A</b>. "
    "No A is B -&gt; <b>No B is A</b>. Missing these turns a correct &quot;Both&quot; into "
    "&quot;Only I&quot;.",
    "<b>&quot;Only a few X are Y&quot;</b> = Some X are Y <b>and</b> Some X are not Y.",
    "<b>&quot;All A are C&quot; implies &quot;Some A are C&quot;</b> - All always contains Some.",
    "A flat conclusion must be <b>forced</b>. Check <i>possibility</i> only when the conclusion "
    "literally says &quot;is a possibility&quot;.",
])

h2("Practice - 20 questions")
small("Options for all: <b>(a)</b> Only I &nbsp; <b>(b)</b> Only II &nbsp; <b>(c)</b> Either I "
      "or II &nbsp; <b>(d)</b> Neither I nor II &nbsp; <b>(e)</b> Both I and II. "
      "Target: under 12 minutes for all 20.")
qlist([
    "All pens are books. All books are papers.<br/>I: All pens are papers &nbsp;|&nbsp; "
    "II: Some papers are pens",
    "All cats are dogs. No dog is a rat.<br/>I: No cat is a rat &nbsp;|&nbsp; "
    "II: Some cats are rats",
    "Some tables are chairs. All chairs are wooden.<br/>I: Some tables are wooden &nbsp;|&nbsp; "
    "II: All tables are wooden",
    "Some rings are gold. No gold is silver.<br/>I: Some rings are not silver &nbsp;|&nbsp; "
    "II: All rings are silver",
    "No apple is a mango. All mangoes are fruits.<br/>I: Some fruits are not apples &nbsp;|&nbsp; "
    "II: No fruit is an apple",
    "All roads are paths. Some paths are lanes.<br/>I: Some roads are lanes &nbsp;|&nbsp; "
    "II: No road is a lane",
    "All keys are locks. Some locks are doors.<br/>I: All keys are doors &nbsp;|&nbsp; "
    "II: Some keys are not doors",
    "Some birds are crows. Some crows are black.<br/>I: Some birds are black &nbsp;|&nbsp; "
    "II: Some black are birds",
    "Only a few pens are red. All red are bright.<br/>I: Some pens are bright &nbsp;|&nbsp; "
    "II: All pens are bright",
    "All flowers are roses. No rose is a lily.<br/>I: No flower is a lily &nbsp;|&nbsp; "
    "II: Some lilies are flowers",
    "Some books are novels. All novels are stories.<br/>I: Some books are stories &nbsp;|&nbsp; "
    "II: Some stories are books",
    "No stone is a rock. Some rocks are hard.<br/>I: Some hard things are not stones "
    "&nbsp;|&nbsp; II: All hard things are stones",
    "All cups are glasses. All glasses are plates.<br/>I: All cups are plates &nbsp;|&nbsp; "
    "II: All plates are cups",
    "Some pens are pencils. No pencil is an eraser.<br/>I: Some pens are not erasers "
    "&nbsp;|&nbsp; II: All pens are erasers",
    "All doctors are engineers. Some engineers are teachers.<br/>I: All doctors being teachers "
    "is a possibility &nbsp;|&nbsp; II: Some teachers are doctors",
    "Some fruits are vegetables. All vegetables are green.<br/>I: All fruits being green is a "
    "possibility &nbsp;|&nbsp; II: Some fruits are green",
    "All A are B. All B are C. Some C are D.<br/>I: Some A are D &nbsp;|&nbsp; II: No A is D",
    "Some P are Q. All Q are R. No R is S.<br/>I: Some P are not S &nbsp;|&nbsp; "
    "II: All P are S",
    "Only a few students are teachers. All teachers are graduates.<br/>I: Some students are "
    "graduates &nbsp;|&nbsp; II: Some students are not graduates",
    "No car is a bus. All buses are vehicles. Some vehicles are trucks.<br/>I: Some vehicles "
    "are not cars &nbsp;|&nbsp; II: All trucks being cars is a possibility",
])
pb()

# ===========================================================================
# PART 4 - CODING
# ===========================================================================
h1("Part 4 - Coding-Decoding")

h3("Type 1 - Letter shift (Caesar)")
p("Every letter moves by a fixed amount. Find the shift from one letter, confirm on a second, "
  "then apply.")
bullets([
    "<b>Ex 1:</b> CAT -&gt; DBU. C to D is <b>+1</b>, A to B is +1. So <b>DOG -&gt; EPH</b>.",
    "<b>Ex 2:</b> MOUSE -&gt; LNTRD. M to L is <b>-1</b>. So <b>TIGER -&gt; SHFDQ</b>.",
    "<b>Growing shift variant:</b> FRIEND -&gt; GTLISJ. F+1=G, R+2=T, I+3=L, E+4=I, N+5=S, D+6=J.",
])

h3("Type 2 - Opposite letters (positions sum to 27)")
p("A-Z, B-Y, C-X and so on. Landmarks <b>EJOTY</b>: E=5, J=10, O=15, T=20, Y=25. Count from the "
  "nearest one.")
bullets([
    "<b>Ex 1:</b> Opposite of G. G=7, so 27-7 = 20 = <b>T</b>.",
    "<b>Ex 2:</b> BAD -&gt; B(2) to 25=Y, A(1) to 26=Z, D(4) to 23=W = <b>YZW</b>.",
])

h3("Type 3 - Number coding (position values)")
p("A=1 through Z=26. The code may be a sum, a list, or a product of positions.")
bullets([
    "<b>Ex 1:</b> CAT = 24, since 3+1+20 = 24. So DOG = 4+15+7 = <b>26</b>.",
    "<b>Ex 2:</b> PEN = 16-5-14. So INK = <b>9-14-11</b>.",
])

h3("Type 4 - Coded sentence (substitution)")
box([
    "<b>Find two sentences sharing exactly ONE word - their shared code is that word.</b> "
    "Triangulate; never guess.",
])
p("<b>Worked example:</b> &quot;she is nice&quot; = <b>pa lo ki</b>; &quot;he is tall&quot; = "
  "<b>lo mi da</b>; &quot;she looks tall&quot; = <b>pa zo da</b>.")
bullets([
    "S1 and S2 share only <b>is</b>, and share only the code <b>lo</b> -&gt; is = lo",
    "S1 and S3 share only <b>she</b>, code <b>pa</b> -&gt; she = pa",
    "S2 and S3 share only <b>tall</b>, code <b>da</b> -&gt; tall = da",
    "Leftover in S1: <b>ki = nice</b>",
])

h3("Type 5 - Symbol coding with a key")
p("A table gives letter to symbol; substitute directly. <b>Ex:</b> A=@, B=#, C=$ so "
  "<b>CAB = $@#</b>.")

h3("Type 6 - Conditional coding")
p("A symbol key <b>plus rules</b> that override it. Check the conditions first, apply the one "
  "that matches, then code the remaining letters normally.")
box([
    "<b>Key:</b> P=%, R=#, S=@, T=&amp;, A=*, E=$",
    "<b>(i)</b> If the word <b>begins with a vowel</b>, code the first and last letters as the "
    "<b>last letter's code</b>.",
    "<b>(ii)</b> If the word <b>ends with a vowel</b>, code the first and last letters as "
    "<b>*</b>.",
    "<b>Ex 1:</b> APT begins with vowel A -&gt; rule (i) -&gt; first and last both take T's code "
    "-&gt; <b>&amp; % &amp;</b>",
    "<b>Ex 2:</b> PSA ends with vowel A -&gt; rule (ii) -&gt; first and last both * -&gt; "
    "<b>* @ *</b>",
])

h2("Practice - 12 questions")
qlist([
    "If CAT = DBU, then DOG = ?",
    "If MOUSE = LNTRD, then TIGER = ?",
    "If FRIEND = GTLISJ, then MOTHER = ?",
    "What is the opposite letter of K?",
    "If BAD = YZW, then CAB = ?",
    "If CAT = 24, then DOG = ?",
    "If PEN = 16-5-14, then INK = ?",
])
p("<i>For 8-10 use:</i> &quot;red apple sweet&quot; = <b>ma pi ku</b>; &quot;sweet mango "
  "juice&quot; = <b>ku ta so</b>; &quot;red juice cold&quot; = <b>ma so li</b>.")
qlist([
    "What is the code for <b>juice</b>?",
    "What is the code for <b>red</b>?",
    "What is the code for <b>sweet</b>?",
], start=8)
p("<i>For 11-12 use the Type-6 key and rules above.</i>")
qlist(["Code <b>APT</b>.", "Code <b>PSA</b>."], start=11)

# ===========================================================================
# PART 5 - RANKING
# ===========================================================================
h1("Part 5 - Order &amp; Ranking")
box([
    "<b>1. Total = (rank from left) + (rank from right) - 1</b> &nbsp;&nbsp; "
    "<i>12th from left, 18th from right -&gt; 12+18-1 = 29</i>",
    "<b>2. Rank from the other end = Total - rank + 1</b> &nbsp;&nbsp; "
    "<i>Class of 45, 20th from top -&gt; 45-20+1 = 26th</i>",
    "<b>3. Persons between = |difference of positions| - 1</b> &nbsp;&nbsp; "
    "<i>5th and 11th -&gt; 11-5-1 = 5 persons</i>",
    "<b>4. Comparison ranking:</b> build a &gt; chain, then read off.",
])
p("<b>Key phrasings:</b> &quot;heavier than only S&quot; = 2nd lightest &nbsp;|&nbsp; "
  "&quot;shorter than only Y&quot; = 2nd tallest &nbsp;|&nbsp; &quot;only two are taller than "
  "X&quot; = X is 3rd tallest.")
p("<b>Worked example:</b> Five boxes P, Q, R, S, T of different weights. <i>Q is heavier than "
  "only S. R is lighter than P but heavier than T.</i> &quot;Q heavier than only S&quot; makes S "
  "lightest and Q second. The rest are P, R, T with T &lt; R &lt; P. Lightest to heaviest: "
  "<b>S, Q, T, R, P</b>.")

h2("Practice - 8 questions")
qlist([
    "Ravi is 12th from the left and 18th from the right in a row. How many students in all?",
    "In a class of 45, Sita ranks 20th from the top. What is her rank from the bottom?",
    "In a row of 40, P is 15th from the left and Q is 20th from the left. How many sit between "
    "them?",
    "Five boxes P, Q, R, S, T of different weights. Q is heavier than only S. R is lighter than "
    "P but heavier than T. Which box is the <b>heaviest</b>?",
    "(Same set) Which box is the <b>3rd heaviest</b>?",
    "In a row of 25 children, Amit is 11th from the left; Rohit is 7th to the right of Amit. "
    "What is Rohit's position from the <b>right</b> end?",
    "A is taller than B but shorter than C. D is taller than A but shorter than C. Who is the "
    "<b>tallest</b>?",
    "Meena is 16th from the top and 29th from the bottom. How many students are in the class?",
])
pb()

# ===========================================================================
# PART 6 - ARITHMETIC
# ===========================================================================
h1("Part 6 - Arithmetic")
small("Six topics, each with the method, worked examples and practice. Answers in Part 7.")

# ---- Profit & Loss
h2("6.1 Profit &amp; Loss")
table([
    ["Term", "Meaning"],
    ["CP - Cost Price", "what the seller paid"],
    ["SP - Selling Price", "what the seller sold it for"],
    ["MP - Marked Price", "the tag price before any discount"],
], widths=[45 * mm, 118 * mm])
box([
    "<b>Profit = SP - CP</b> &nbsp;|&nbsp; <b>Loss = CP - SP</b>",
    "<b>The percentage is ALWAYS on CP.</b> Profit% = (Profit / <b>CP</b>) x 100. "
    "You earned it against what you <i>spent</i>, and you spent CP.",
    "<b>Forward (CP to SP): multiply.</b> x% profit -&gt; x (1 + x/100). "
    "x% loss -&gt; x (1 - x/100).",
    "<b>Backward (SP to CP): DIVIDE.</b> CP = SP / multiplier.",
    "<b>Discount is on MP.</b> SP = MP x (1 - d/100).",
])
p("<b>Why backward is division</b> - the classic error, shown failing: CP 100 at 20% profit "
  "gives SP 120. Going back the wrong way, 120 - 20% of 120 = 96, not 100. The right way, "
  "120 / 1.2 = <b>100</b>. The 20% was of CP, so you must undo a multiplication.")
h3("The three shortcuts that do the real work")
box([
    "<b>A. Markup then discount:</b> net% = <b>a - b - ab/100</b>. "
    "<i>+40% then -25% -&gt; 40-25-10 = +5% profit.</i>",
    "<b>B. Same SP, one at +x%, one at -x%: ALWAYS a loss of x&#178;/100 %.</b> "
    "<i>Both at 960: the +20% article has CP 800 (profit 160); the -20% article has CP 1200 "
    "(loss 240). The loss sits on a bigger base, so net loss 80 on CP 2000 = 4%.</i>",
    "<b>C. &quot;CP of m articles = SP of n articles&quot;:</b> profit% = "
    "<b>(m - n)/n x 100</b>. <i>CP of 15 = SP of 12 -&gt; 3/12 = 25% profit.</i>",
])
h3("Practice")
qlist([
    "CP = Rs 840, sold at 25% profit. Find SP.",
    "SP = Rs 918 at a 15% loss. Find CP.",
    "An article marked Rs 1,600 is sold at 25% discount, still giving 20% profit. Find CP.",
    "Two articles are sold at Rs 960 each - 20% gain on one, 20% loss on the other. Overall "
    "profit or loss %?",
    "The CP of 15 articles equals the SP of 12 articles. Find profit %.",
    "Goods are marked 40% above cost and sold at 25% discount. Find profit %.",
    "Selling at Rs 720 gives a 10% loss. What SP gives a 20% gain?",
    "A trader gives 20% discount on MP and still earns 25% profit. If CP = Rs 600, find MP.",
])

# ---- SI / CI
h2("6.2 Simple &amp; Compound Interest")
box([
    "<b>SI = P x R x T / 100.</b> Think in steps, not formula: <b>one year's interest = R% of "
    "P; multiply by T.</b>",
    "<b>Amount = P + SI.</b>",
    "<b>Doubling:</b> interest earned = 100% of P, so <b>R x T = 100</b>.",
    "<b>Tripling:</b> interest = 200%, so <b>R x T = 200</b>. (Four times -&gt; 300.)",
])
bullets([
    "<b>Ex 1:</b> Rs 6,000 at 10% for 4 years. 10% of 6000 = 600 per year, x4 = <b>Rs 2,400</b>.",
    "<b>Ex 2:</b> A sum doubles in 8 years at SI. R = 100/8 = <b>12.5%</b>.",
    "<b>Ex 3:</b> At 25%, time to triple: 25 x T = 200, so T = <b>8 years</b>.",
])
box([
    "<b>CI for 2 years - net rate = 2R + R&#178;/100 %.</b> "
    "<i>10% for 2 years = 21%. 20% for 2 years = 44%.</i>",
    "<b>CI - SI over 2 years = P x (R/100)&#178;.</b> Works backwards too, to find P.",
    "<b>Amount under CI = P (1 + R/100)<super>n</super>.</b>",
])
bullets([
    "<b>Ex 1:</b> CI on Rs 4,000 at 10% for 2 years -&gt; 21% of 4000 = <b>Rs 840</b>.",
    "<b>Ex 2:</b> CI-SI on Rs 8,000 at 5% for 2 years -&gt; 8000 x (0.05)&#178; = <b>Rs 20</b>.",
    "<b>Ex 3 (reverse):</b> CI-SI difference is Rs 40 at 10% for 2 years. "
    "40 = P x 0.01, so P = <b>Rs 4,000</b>.",
])
h3("Practice")
qlist([
    "Find the SI on Rs 6,000 at 8% per annum for 3 years.",
    "A sum doubles in 8 years at SI. Find the rate.",
    "A sum triples in 12 years at SI. Find the rate.",
    "Find the CI on Rs 5,000 at 10% per annum for 2 years.",
    "Find the difference between CI and SI on Rs 8,000 at 5% for 2 years.",
    "The difference between CI and SI on a sum for 2 years at 10% is Rs 60. Find the sum.",
    "Find the amount on Rs 4,000 at 10% compound interest for 2 years.",
    "At what rate will Rs 2,500 amount to Rs 3,000 in 4 years at SI?",
    "In how many years will a sum double at 12.5% SI?",
    "Find the CI on Rs 1,000 at 20% per annum for 2 years.",
])

# ---- Time & Work
h2("6.3 Time &amp; Work")
box([
    "<b>The LCM method - kills all fractions.</b> Total work = <b>LCM of the given days</b>. "
    "Each person's efficiency = total / their days. Add efficiencies to combine.",
    "<b>Two-person shortcut:</b> together = <b>a x b / (a + b)</b>.",
    "<b>Wages are shared in the ratio of efficiency</b> (that is, of work actually done).",
    "<b>Man-days:</b> M1 x D1 = M2 x D2 when the work is the same.",
])
bullets([
    "<b>Ex 1:</b> A in 10 days, B in 15 days. LCM = 30. A = 3/day, B = 2/day, together 5/day "
    "-&gt; 30/5 = <b>6 days</b>.",
    "<b>Ex 2:</b> A in 12, B in 6 -&gt; (12x6)/(12+6) = 72/18 = <b>4 days</b>.",
    "<b>Ex 3 (alternate days):</b> A in 20, B in 30, working alternately from A. LCM = 60, "
    "A = 3, B = 2, so a pair of days does 5 units. 60/5 = 12 pairs = <b>24 days</b>.",
])
h3("Practice")
qlist([
    "A does a job in 12 days and B in 18 days. How long together?",
    "A does a job in 10 days and B in 15 days. How long together?",
    "A and B together finish in 8 days; A alone in 12 days. How long does B alone take?",
    "A is twice as efficient as B, and together they finish in 8 days. How long does A alone "
    "take?",
    "10 men complete a work in 15 days. How many days will 25 men take?",
    "A does a work in 20 days, B in 30 days. They work on alternate days starting with A. "
    "In how many days is the work finished?",
    "A, B and C can do a work in 10, 15 and 30 days. How long do all three take together?",
    "A and B complete a work in 12 days and are paid Rs 600. A alone would take 20 days. "
    "Find A's share.",
])

# ---- Partnership
h2("6.4 Partnership")
box([
    "<b>Simple partnership</b> (all invest for the same period): "
    "profit ratio = <b>ratio of capitals</b>.",
    "<b>Compound partnership</b> (different periods): profit ratio = "
    "<b>ratio of (Capital x Time)</b>.",
    "&nbsp;&nbsp;A : B = (C<sub>A</sub> x T<sub>A</sub>) : (C<sub>B</sub> x T<sub>B</sub>)",
    "<b>Working partner:</b> take out the salary or commission <b>first</b>, then divide what "
    "is left in the capital-time ratio.",
    "If capital <b>changes mid-year</b>, add each stretch separately: "
    "(first capital x months) + (new capital x months).",
])
bullets([
    "<b>Ex 1:</b> A invests Rs 5,000 and B Rs 8,000 for the same period; profit Rs 2,600. "
    "Ratio 5:8 -&gt; A = <b>Rs 1,000</b>, B = <b>Rs 1,600</b>.",
    "<b>Ex 2:</b> A invests Rs 6,000 for 8 months, B Rs 9,000 for 6 months. "
    "Ratio = 48,000 : 54,000 = <b>8 : 9</b>.",
    "<b>Ex 3 (mid-year change):</b> A puts in Rs 20,000, and after 6 months adds Rs 10,000; "
    "B puts in Rs 30,000 for the year. A = 20000x6 + 30000x6 = 3,00,000; B = 30000x12 = "
    "3,60,000 -&gt; <b>5 : 6</b>.",
])
h3("Practice")
qlist([
    "A invests Rs 4,000 and B Rs 6,000 for the same period. Profit is Rs 5,000. Find B's share.",
    "A invests Rs 8,000 for 6 months and B Rs 6,000 for 8 months. Find the profit ratio.",
    "A invests Rs 12,000 for a year, B Rs 15,000 for 8 months. Profit is Rs 11,000. "
    "Find A's share.",
    "A, B and C invest Rs 3,000, Rs 4,000 and Rs 5,000 for the same period. Profit Rs 2,400. "
    "Find C's share.",
    "A and B start with Rs 20,000 and Rs 30,000. After 6 months A adds Rs 10,000. Find the "
    "profit ratio at the end of the year.",
    "A is a working partner and gets 10% of the profit as salary; the rest is divided in the "
    "capital ratio 2:3 (A:B). Total profit is Rs 11,000. Find A's total earning.",
])

# ---- Mixtures
h2("6.5 Mixtures &amp; Alligation")
box([
    "<b>The alligation cross:</b> Cheaper : Dearer = "
    "<b>(Dearer - Mean) : (Mean - Cheaper)</b>.",
    "Works for price, concentration, speed, marks - anything with <b>two sources and one "
    "average</b>.",
    "<b>Repeated replacement:</b> if r litres are removed from v litres and replaced with "
    "water, n times, the pure liquid left = <b>v x (1 - r/v)<super>n</super></b>.",
])
bullets([
    "<b>Ex 1:</b> Mix rice at Rs 15/kg and Rs 20/kg to get Rs 18/kg. "
    "(20-18) : (18-15) = <b>2 : 3</b>.",
    "<b>Ex 2:</b> Mix 30% acid and 60% acid to get 50%. (60-50) : (50-30) = 10 : 20 = "
    "<b>1 : 2</b>.",
    "<b>Ex 3:</b> From 60 L of milk, 12 L is removed and replaced with water, twice. "
    "Milk left = 60 x (1 - 12/60)&#178; = 60 x 0.64 = <b>38.4 L</b>.",
])
h3("Practice")
qlist([
    "In what ratio must rice at Rs 20/kg be mixed with rice at Rs 30/kg to get a mixture worth "
    "Rs 24/kg?",
    "In what ratio must water (free) be mixed with milk costing Rs 32 per litre so that the "
    "mixture is worth Rs 24 per litre?",
    "A 40 litre mixture has milk and water in the ratio 3:1. How much water must be added to "
    "make the ratio 3:2?",
    "From a vessel holding 60 litres of milk, 12 litres is removed and replaced with water. "
    "This is done twice. How much milk remains?",
    "Two vessels contain milk and water in the ratios 3:1 and 5:3. Equal quantities are mixed. "
    "Find the ratio in the final mixture.",
    "The average age of a class of 30 students is 12 years. Some new students of average age 15 "
    "join, and the average becomes 13. How many joined?",
])

# ---- Pipes
h2("6.6 Pipes &amp; Cisterns")
box([
    "<b>Identical to Time &amp; Work, with signs.</b> An inlet is <b>positive</b> work, "
    "an outlet or leak is <b>negative</b>.",
    "Use the <b>LCM method</b>: tank capacity = LCM of the times; each pipe's rate = capacity "
    "/ its time; add rates, subtracting for leaks.",
    "If a tank fills in <i>a</i> hours alone but takes <i>b</i> hours with a leak, "
    "the <b>leak alone empties it in ab / (b - a) hours</b>.",
])
bullets([
    "<b>Ex 1:</b> A fills in 12 h, B in 18 h. LCM 36: A = 3, B = 2, net 5 -&gt; 36/5 = "
    "<b>7.2 hours</b>.",
    "<b>Ex 2:</b> A fills in 10 h, B empties in 15 h. LCM 30: A = +3, B = -2, net +1 -&gt; "
    "<b>30 hours</b>.",
    "<b>Ex 3:</b> A fills in 6 h but takes 8 h with a leak. LCM 24: A = 4, net = 3, so the leak "
    "= 1 -&gt; leak empties the full tank in <b>24 hours</b>.",
])
h3("Practice")
qlist([
    "Pipe A fills a tank in 12 hours and pipe B in 18 hours. How long if both are open?",
    "Pipe A fills a tank in 10 hours; pipe B empties it in 15 hours. If both are open, how long "
    "to fill?",
    "A pipe fills a tank in 6 hours, but with a leak it takes 8 hours. How long would the leak "
    "alone take to empty a full tank?",
    "Two pipes fill a tank in 20 and 30 minutes. Both are opened together; after how long should "
    "the second be closed so that the tank fills in 18 minutes?",
    "Three pipes fill a tank in 10, 15 and 30 hours. How long if all three are open?",
    "A cistern has a leak that would empty it in 20 hours. An inlet admits 4 litres per minute, "
    "and with both working the cistern empties in 24 hours. Find the capacity of the cistern.",
])
pb()

# ===========================================================================
# PART 7 - ANSWER KEYS
# ===========================================================================
h1("Part 7 - Answer keys")

h2("Seating sets A to G")

h3("SET A")
table([
    ["Pos", "1", "2", "3", "4", "5", "6", "7", "8"],
    ["Person", "T", "W", "U", "P", "R", "V", "Q", "S"],
    ["Faces", "N", "S", "N", "N", "S", "N", "S", "S"],
], widths=[23 * mm] + [17.5 * mm] * 8, head=False)
p("<b>A1.</b> S &nbsp;&nbsp; <b>A2.</b> 2 (U and P) &nbsp;&nbsp; <b>A3.</b> P &nbsp;&nbsp; "
  "<b>A4.</b> 4 &nbsp;&nbsp; <b>A5.</b> R")

h3("SET B")
p("Clockwise: <b>A(1), E(2), B(3), D(4), F(5), H(6), C(7), G(8)</b>. "
  "A = Doctor, F = Teacher, B = Lawyer, E = Engineer.")
p("<b>B1.</b> G &nbsp;&nbsp; <b>B2.</b> F &nbsp;&nbsp; <b>B3.</b> 3 (D, F, H) &nbsp;&nbsp; "
  "<b>B4.</b> B &nbsp;&nbsp; <b>B5.</b> E")

h3("SET C")
table([
    ["Column", "1", "2", "3", "4", "5", "6"],
    ["Row 2 (North)", "A", "E", "B", "C", "D", "F"],
    ["Row 1 (South)", "T", "Q", "R", "P", "U", "S"],
], widths=[38 * mm] + [20.8 * mm] * 6, head=False)
p("<b>C1.</b> B &nbsp;&nbsp; <b>C2.</b> A and F &nbsp;&nbsp; <b>C3.</b> 1 (D) &nbsp;&nbsp; "
  "<b>C4.</b> B &nbsp;&nbsp; <b>C5.</b> F")

h3("SET D")
p("Clockwise: <b>J(1, corner), P(2, mid), K(3, corner), O(4, mid), N(5, corner), L(6, mid), "
  "M(7, corner), Q(8, mid)</b>. M likes Tea.")
p("<b>D1.</b> M &nbsp;&nbsp; <b>D2.</b> Q &nbsp;&nbsp; <b>D3.</b> K &nbsp;&nbsp; "
  "<b>D4.</b> 2 (K and O) &nbsp;&nbsp; <b>D5.</b> J")

h3("SET E")
table([
    ["Seat", "1", "2", "3", "4", "5", "6", "7", "8"],
    ["Person", "A", "C", "D", "B", "H", "E", "G", "F"],
    ["Faces", "IN", "IN", "OUT", "OUT", "IN", "IN", "IN", "OUT"],
    ["Month", "Apr", "Dec", "Feb", "Jan", "Sep", "Jul", "Oct", "Mar"],
], widths=[21 * mm] + [17.75 * mm] * 8, head=False)
p("<b>E1.</b> F &nbsp;&nbsp; <b>E2.</b> G &nbsp;&nbsp; <b>E3.</b> 1 (B) &nbsp;&nbsp; "
  "<b>E4.</b> E &nbsp;&nbsp; <b>E5.</b> 5")

h3("SET F")
table([
    ["Floor", "Flat-1", "Flat-2"],
    ["5", "D (White)", "I"],
    ["4", "A", "F (Blue)"],
    ["3", "G", "C (Red)"],
    ["2", "B", "J"],
    ["1", "E", "H"],
], widths=[30 * mm, 66 * mm, 67 * mm])
p("<b>F1.</b> J &nbsp;&nbsp; <b>F2.</b> 1 (G) &nbsp;&nbsp; <b>F3.</b> F &nbsp;&nbsp; "
  "<b>F4.</b> J &nbsp;&nbsp; <b>F5.</b> D")

h3("SET G")
table([
    ["Column", "1", "2", "3", "4", "5"],
    ["Row 2 (North)", "P", "S", "R", "Q", "T"],
    ["Row 1 (South)", "D", "C", "B", "E", "A"],
], widths=[43 * mm] + [24 * mm] * 5, head=False)
p("Sports: P = Cricket, R = Tennis, E = Hockey, A = Football.")
p("<b>G1.</b> S &nbsp;&nbsp; <b>G2.</b> R &nbsp;&nbsp; <b>G3.</b> D and A &nbsp;&nbsp; "
  "<b>G4.</b> S &nbsp;&nbsp; <b>G5.</b> A")

h2("Syllogism (20)")
table([
    ["Q", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
    ["Ans", "e", "a", "a", "a", "a", "c", "c", "d", "a", "a"],
    ["Q", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"],
    ["Ans", "e", "a", "a", "a", "a", "e", "c", "a", "a", "e"],
], widths=[18 * mm] + [14.5 * mm] * 10, head=False)
bullets([
    "<b>Q6, Q17:</b> All + Some, and the pair is Some &lt;-&gt; No -&gt; <b>Either/Or</b>.",
    "<b>Q7:</b> the pair is All &lt;-&gt; Some-not, the other complementary pair -&gt; "
    "<b>Either/Or</b>.",
    "<b>Q8:</b> Some + Some forces nothing, and &quot;Some birds are black&quot; vs &quot;Some "
    "black are birds&quot; is the <b>same claim twice</b>, not a negation pair -&gt; "
    "<b>Neither</b>.",
    "<b>Q1, Q11:</b> the conversion (All A are B -&gt; Some B are A) makes II true as well -&gt; "
    "<b>Both</b>.",
    "<b>Q5:</b> No + All is a forced mood: <b>Some C are not A</b>. II is not definite.",
    "<b>Q16, Q20:</b> the possibility conclusion holds <i>and</i> the definite one does -&gt; "
    "<b>Both</b>.",
])

h2("Coding-Decoding (12)")
table([
    ["Q", "1", "2", "3", "4", "5", "6"],
    ["Ans", "EPH", "SHFDQ", "NQWLJX", "P", "XZY", "26"],
    ["Q", "7", "8", "9", "10", "11", "12"],
    ["Ans", "9-14-11", "so", "ma", "ku", "&amp; % &amp;", "* @ *"],
], widths=[18 * mm] + [24.2 * mm] * 6, head=False)
bullets([
    "<b>Q3:</b> shift grows +1,+2,+3,+4,+5,+6: M+1=N, O+2=Q, T+3=W, H+4=L, E+5=J, R+6=X.",
    "<b>Q4:</b> K = 11, so 27-11 = 16 = P.",
    "<b>Q8-10:</b> S2 and S3 share only <i>juice</i> -&gt; <b>so</b>; S1 and S3 share only "
    "<i>red</i> -&gt; <b>ma</b>; S1 and S2 share only <i>sweet</i> -&gt; <b>ku</b>.",
    "<b>Q11:</b> APT begins with a vowel -&gt; first and last take T's code (&amp;).",
    "<b>Q12:</b> PSA ends with a vowel -&gt; first and last become *.",
])

h2("Order &amp; Ranking (8)")
table([
    ["Q", "1", "2", "3", "4", "5", "6", "7", "8"],
    ["Ans", "29", "26th", "4", "P", "T", "8th", "C", "44"],
], widths=[18 * mm] + [18.1 * mm] * 8, head=False)
bullets([
    "<b>Q1:</b> 12 + 18 - 1 = 29. &nbsp; <b>Q2:</b> 45 - 20 + 1 = 26th. &nbsp; "
    "<b>Q3:</b> 20 - 15 - 1 = 4.",
    "<b>Q4-5:</b> lightest to heaviest is S, Q, T, R, P. Heaviest = P; 3rd heaviest = T.",
    "<b>Q6:</b> Rohit is at 11 + 7 = 18 from the left, so 25 - 18 + 1 = 8th from the right.",
    "<b>Q8:</b> 16 + 29 - 1 = 44.",
])

h2("Arithmetic - answers with working")

h3("6.1 Profit &amp; Loss")
bullets([
    "<b>1.</b> 840 x 1.25 = <b>Rs 1,050</b>",
    "<b>2.</b> 918 / 0.85 = <b>Rs 1,080</b>",
    "<b>3.</b> SP = 1600 x 0.75 = 1200; CP = 1200 / 1.2 = <b>Rs 1,000</b>",
    "<b>4.</b> Shortcut B: 20&#178;/100 = <b>4% loss</b> (CPs 800 and 1200; total CP 2000, "
    "total SP 1920)",
    "<b>5.</b> Shortcut C: (15-12)/12 = <b>25% profit</b>",
    "<b>6.</b> Shortcut A: 40 - 25 - 10 = <b>5% profit</b>",
    "<b>7.</b> CP = 720 / 0.9 = 800; SP = 800 x 1.2 = <b>Rs 960</b>",
    "<b>8.</b> SP = 600 x 1.25 = 750; MP = 750 / 0.8 = <b>Rs 937.50</b>",
])

h3("6.2 SI &amp; CI")
bullets([
    "<b>1.</b> 8% of 6000 = 480/year, x3 = <b>Rs 1,440</b>",
    "<b>2.</b> R x T = 100 -&gt; 100/8 = <b>12.5%</b>",
    "<b>3.</b> R x T = 200 -&gt; 200/12 = <b>16.67%</b>",
    "<b>4.</b> net 21% of 5000 = <b>Rs 1,050</b>",
    "<b>5.</b> 8000 x (0.05)&#178; = <b>Rs 20</b>",
    "<b>6.</b> 60 = P x (0.1)&#178; = P x 0.01 -&gt; P = <b>Rs 6,000</b>",
    "<b>7.</b> 4000 x 1.21 = <b>Rs 4,840</b>",
    "<b>8.</b> SI = 500; 500 = 2500 x R x 4/100 -&gt; R = <b>5%</b>",
    "<b>9.</b> 12.5 x T = 100 -&gt; <b>8 years</b>",
    "<b>10.</b> net 44% of 1000 = <b>Rs 440</b>",
])

h3("6.3 Time &amp; Work")
bullets([
    "<b>1.</b> LCM 36: 3 + 2 = 5 -&gt; 36/5 = <b>7.2 days</b>",
    "<b>2.</b> LCM 30: 3 + 2 = 5 -&gt; <b>6 days</b>",
    "<b>3.</b> LCM 24: together 3, A = 2, so B = 1 -&gt; <b>24 days</b>",
    "<b>4.</b> A : B = 2 : 1, total 3 units/day; A alone = 8 x 3/2 = <b>12 days</b>",
    "<b>5.</b> 10 x 15 = 150 man-days -&gt; 150/25 = <b>6 days</b>",
    "<b>6.</b> LCM 60: A = 3, B = 2, a pair of days = 5 units; 60/5 = 12 pairs = <b>24 days</b>",
    "<b>7.</b> LCM 30: 3 + 2 + 1 = 6 -&gt; <b>5 days</b>",
    "<b>8.</b> LCM 60: together 5, A = 3, B = 2, ratio 3:2 -&gt; A gets <b>Rs 360</b>",
])

h3("6.4 Partnership")
bullets([
    "<b>1.</b> 4000 : 6000 = 2 : 3 -&gt; B = 5000 x 3/5 = <b>Rs 3,000</b>",
    "<b>2.</b> 8000x6 : 6000x8 = 48000 : 48000 = <b>1 : 1</b>",
    "<b>3.</b> 12000x12 : 15000x8 = 144000 : 120000 = 6 : 5 -&gt; A = 11000 x 6/11 = "
    "<b>Rs 6,000</b>",
    "<b>4.</b> 3 : 4 : 5 -&gt; C = 2400 x 5/12 = <b>Rs 1,000</b>",
    "<b>5.</b> A = 20000x6 + 30000x6 = 3,00,000; B = 30000x12 = 3,60,000 -&gt; <b>5 : 6</b>",
    "<b>6.</b> Salary = 10% of 11000 = 1100. Remaining 9900 in 2:3 -&gt; A = 3960. "
    "A's total = <b>Rs 5,060</b>",
])

h3("6.5 Mixtures &amp; Alligation")
bullets([
    "<b>1.</b> (30-24) : (24-20) = 6 : 4 = <b>3 : 2</b>",
    "<b>2.</b> Water costs 0: (32-24) : (24-0) = 8 : 24 = <b>1 : 3</b>",
    "<b>3.</b> Milk 30, water 10. For 3:2 with milk 30, water must be 20 -&gt; add "
    "<b>10 litres</b>",
    "<b>4.</b> 60 x (1 - 12/60)&#178; = 60 x 0.64 = <b>38.4 litres</b>",
    "<b>5.</b> Take 8 units each: V1 gives milk 6, water 2; V2 gives milk 5, water 3 -&gt; "
    "11 : 5 -&gt; <b>11 : 5</b>",
    "<b>6.</b> Alligation (15-13) : (13-12) = 2 : 1, so 30 : x = 2 : 1 -&gt; "
    "<b>15 students</b>",
])

h3("6.6 Pipes &amp; Cisterns")
bullets([
    "<b>1.</b> LCM 36: 3 + 2 = 5 -&gt; 36/5 = <b>7.2 hours</b>",
    "<b>2.</b> LCM 30: +3 - 2 = +1 -&gt; <b>30 hours</b>",
    "<b>3.</b> LCM 24: pipe 4, net 3, leak = 1 -&gt; <b>24 hours</b> "
    "(or ab/(b-a) = 6x8/2 = 24)",
    "<b>4.</b> LCM 60: A = 3, B = 2. A runs all 18 min = 54 units; the remaining 6 units come "
    "from B at 2/min -&gt; B runs 3 min, so <b>close it after 3 minutes</b>",
    "<b>5.</b> LCM 30: 3 + 2 + 1 = 6 -&gt; <b>5 hours</b>",
    "<b>6.</b> Inlet = 4 L/min = 240 L/h. C/24 = C/20 - 240 -&gt; 240 = C/120 -&gt; "
    "<b>28,800 litres</b>",
])

sp(14)
box([
    "<b>Remember the one thing that decides your score.</b> Speed has never been the problem - "
    "accuracy is. Every arrangement you build tends to be right; the marks leak in the final "
    "read-off. Slow down about 20 percent, say the count out loud, and you still finish with "
    "time to spare.",
], tint=colors.HexColor("#FFF6E6"), edge=WARN)

# ===========================================================================
# RENDER
# ===========================================================================
def decorate(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 7.6)
    canvas.setFillColor(MUTED)
    canvas.drawString(24 * mm, 12 * mm, "BankPrep - SBI PO Prelims Study Pack")
    canvas.drawRightString(A4[0] - 24 * mm, 12 * mm, f"{doc.page}")
    canvas.setStrokeColor(LINE)
    canvas.setLineWidth(0.5)
    canvas.line(24 * mm, 16 * mm, A4[0] - 24 * mm, 16 * mm)
    canvas.restoreState()

doc = BaseDocTemplate(OUT, pagesize=A4,
                      leftMargin=24 * mm, rightMargin=23 * mm,
                      topMargin=18 * mm, bottomMargin=22 * mm,
                      title="BankPrep - SBI PO Prelims Study Pack",
                      author="BankPrep")
frame = Frame(doc.leftMargin, doc.bottomMargin,
              doc.width, doc.height, id="body")
doc.addPageTemplates([PageTemplate(id="main", frames=[frame], onPage=decorate)])
doc.build(story)
print("written:", OUT, os.path.getsize(OUT), "bytes")
