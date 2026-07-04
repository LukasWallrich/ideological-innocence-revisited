# Reproduction Specification — Kalmoe (2020), "Uses and Abuses of Ideology in Political Psychology"

*Political Psychology*, Vol. 41(4), 2020. doi: 10.1111/pops.12650. Sole author: Nathan P. Kalmoe (LSU).

This document is the blueprint for computationally reproducing every empirical result in the paper. It records each dataset, variable, table/figure, in-text number, method, and ambiguity, with recommended resolutions. All cell values below were transcribed from **visual renders of the PDF tables** (the plain-text extraction scrambles table layout and must not be trusted for numbers).

---

## 0. Reproduction scope — read this first

The paper's empirical content splits sharply into two tiers:

**TIER A — Reproducible from public data (the core of any reproduction).** All results use the **ANES Time Series Cumulative Data File** plus three **ANES panel studies** (1990–92, 1992–96, 2000–02). These cover Figure 1, Tables 1–5, footnote 5 (abortion probit), and the in-text `.49` ideology–vote and `.68` party–vote recomputations. Everything here can be regenerated from freely downloadable ANES data.

**TIER B — NOT reproducible from public data (report as-is, do not attempt to regenerate).**
- The entire **"Inconvenient Truths About Samples"** section: Kalmoe's own **Knowledge Networks/GfK** survey (2010), three **MTurk** studies (2012, 2013, 2015), and four **student** samples (2010–2017). These are proprietary/unarchived datasets; their knowledge means/SDs/Ns and the ideology–party correlations (.62/.82/.77/.75) cannot be recomputed.
- The **Clifford, Jewell & Waggoner (2015)** correlations (Authoritarianism .18/.23/.36, etc.) are **quoted from that paper**, not computed by Kalmoe — verify against Clifford et al., do not recompute.
- Comparisons to **Jost (2006)** (the `.90` vote–ideology figure, the 28%/80% figures, the F-statistics in footnote 1) are Kalmoe's characterizations of Jost's *American Psychologist* article.

A faithful reproduction therefore targets **Tier A**. The summary at the end lists Tier-A components and their risks.

---

## 1. Datasets

### 1.1 ANES Time Series Cumulative Data File (primary source, Tables 1, 2, 4, 5; Figure 1; footnote 5)
- **What:** Nationally representative face-to-face (and, in some years, telephone) surveys of age-eligible U.S. adults, presidential + most midterm years since 1948. Response rates >50%. Kalmoe limits attention to FTF and telephone interviews by trained interviewers.
- **Years actually used** (per table row labels — availability differs by construct):
  - **Ideology ID / Partisanship:** 1984, 1986, ... 2004, 2008, 2012, 2016 (label reads "1984–2004, 2008, 2012, 2016" — i.e., every ANES year 1984–2004 then the four-year presidential years; 2006/2010/2014 midterms not listed for these).

    NOTE the label discrepancy across constructs (see below) — the paper reports "from 1984 to the present for comparability," but each construct's row lists its own available years.
  - **Egalitarianism:** "1984–2000, 2004, 2008, 2012, 2016" (battery begins 1984).
  - **Moral Traditionalism:** "1986–2000, 2004, 2008, 2012, 2016" (battery begins 1986).
  - **Policy Views index:** "1984–2000, 2004, 2008, 2012, 2016."
- **Sample sizes (Table 1, by construct):** Egalitarianism N = 21,579; Moral Tradition N = 19,306; Policy Views N = 23,134; Ideology ID N = 25,332; Partisanship N = 24,307. (Abstract summarizes overall "Ns ~ 13k–37k".)
- **Weights:** Table 1 and Table 5 are **weighted** ("Weighted percentages" / "Weighted bivariate probit"). Figure 1, Table 2, Table 3, Table 4 are **unweighted** (stated in each note). *Weighting differs by table — this is a genuine trap; apply per-table.*

### 1.2 ANES Panel Studies (Table 3, stability)
- **1990–1992 ANES panel:** all relevant measures. Full-sample N ~ 625 (values), Policy Views N ~ 1,359, Ideology ID N ~ 1,359, Partisanship N = 1,334.
- **1992–1996 ANES panel:** all relevant measures. Full-sample N ~ 585 (values), Policy/Ideology N per cell, Partisanship as labeled.
- **2000–2002 ANES panel:** all measures **except values** (no egalitarianism/moral traditionalism rows). Policy Views N = 1,016, Ideology ID N = 564, Partisanship N = 1,165.
- Panels are **unweighted**; two lowest knowledge groups merged due to small samples + knowledge-linked attrition.

### 1.3 Online Supporting Information (not in the main PDF; note for completeness)
The SI (referenced repeatedly) contains, per the Supporting Information list:
- **S1** Breadth by knowledge (companion to Table 1)
- **S2** Breadth by **quiz** knowledge (1986–92)
- **S3** Reliability by quiz knowledge (1986–92)
- **S4** (note that quiz items are hard to use in panels; stability not replicated with quiz)
- **S5** Relating constructs by quiz knowledge (1986–92)
- **S6** Predicting presidential votes (1988, 1992), bivariate probit, quiz knowledge
- **S7** Breadth by knowledge, **2008–16**
- **S8** Reliability, 2008–16
- **S9** Relating constructs, 2008–16
- **S10** Presidential vote choice, 2008–16 (probit, 1 predictor)
- **S11** Average Pearson vs. polychoric interitem correlations (1986–92) — supports interval assumptions for alphas
- **S12** Stability of ideological ID: follow-up for moderates vs. original question
- Also: relative-outlyingness (±1 SD) version of Table 1; ordinal correlation version of Table 2; robustness with quiz-knowledge substitution (results "slightly less distinct").

### 1.4 TIER B convenience samples (report only, cannot reproduce)
- **Knowledge Networks/GfK 2010** — two nationally representative surveys, merged: m = .59, SD = .32, n = 906.
- **MTurk:** 2012 (m = .73, SD = .29, n = 1017); 2013 (m = .76, SD = .28, n = 887); 2015 (m = .73, SD = .30, n = 835).
- **Students:** Midwest public 2010 (m = .64, SD = .31, n = 370); mid-Atlantic private 2012 (m = .81, SD = .23, n = 277); South public 2016 (m = .55, SD = .33, n = 535); South public 2017 (m = .51, SD = .39, n = 453).
- Knowledge index = 3 multiple-choice items summed to 0–1: (1) John Roberts' position in government, (2) which branch ultimately decides constitutionality, (3) proportion of Congressional votes to override a veto.

---

## 2. Variables and operationalization

> **UNVERIFIED VARIABLE CODES — verify before coding.** Only the knowledge moderator (VCF0050a, §2.2) was confirmed against ANES. Every other `VCFxxxx` id below (ideology, party, the CPV batteries, the 5 policy items, vote, abortion, weights) is a best-judgment candidate recalled from standard ANES usage. Confirm each against the ANES cumulative codebook and the Kinder & Kalmoe (2017) appendix before running anything — a wrong id silently produces garbage.

**Global coding convention (stated in Methods):** All scales coded **−1 to +1**. High values = **Republican** party ID, **conservative** ideological ID, policy **liberalism**, high **egalitarianism**, high **traditionalism**. (Note the mixed polarity: for vote-prediction and correlation tables some rows are marked "(rev.)" to align direction — see §3.)

### 2.1 Ideological self-identification
- 7-point liberal–conservative self-placement (available from 1972; used here 1984+).
- Categories in Figure 1: Extremely Liberal, Liberal, Slightly Liberal, **Moderate/HTMA**, Slightly Conservative, Conservative, Extremely Conservative.
- **"Haven't thought much about it" (HTMA):** coded **together with moderates at 0** (the scale midpoint). Explicitly: *"I code 'haven't thought' with moderates, at 0 hereafter."*
- Rescaled to −1..+1 (high = conservative).
- Candidate ANES cumulative variable: **VCF0803** (7-pt, folded/collapsed lib-con) or **VCF0801** (raw incl. HTMA/DK codes). *Confirm which retains the HTMA code needed to implement the coding rule.*

### 2.2 Political knowledge — THE moderator (used in every table)
- **Measure:** 5-point **interviewer rating** of the respondent's general level of information about politics and public affairs. "The only consistent measure across decades." **Coded 0–1** (i.e., the 5 ratings map to 0, .25, .50, .75, 1).
- ANES cumulative variable: **VCF0050a** = "Respondent Level of Political Info — Pre" (interviewer's rating; VCF0050b is the post-election version). **VERIFIED** against the ANES cumulative variable list — this is the load-bearing moderator, so it was confirmed rather than recalled. Kalmoe uses the pre-election rating (VCF0050a); confirm direction (recode so high = more informed) and the 5-level→0/.25/.5/.75/1 mapping.
- **CRITICAL — strata are NOT quantiles.** The knowledge groups are the **5 fixed rating categories**, whose natural population shares are uneven. Do **not** use `ntile()`/quintiles.
  - Main tables (1, 2, 4): **Lowest 9%, Low 20%, Middle 34%, High 25%, Highest 13%** (these are the population shares of the 5 rating levels; sum ≈101% by rounding).
  - The prose fractions ("most knowledgeable 20–30%", "top 38%", "top one-third", "highest 13%") are obtained by grouping these 5 fixed categories after the fact (e.g., "top 38%" = High 25% + Highest 13%).
- **Alternative (SI):** multiple-choice **quiz** knowledge (1986–92), yielding "slightly less distinct" results (Tables S2, S3, S5, S6).

### 2.3 Core Political Values — Egalitarianism
- Multi-item battery, **5-point agree–disagree** items; battery begins **1984**.
- DK rate ≤1% (nonresponse not a concern).
- Standard ANES egalitarianism battery = **6 items** (e.g., "society should do whatever necessary to make sure everyone has equal opportunity," "we have gone too far pushing equal rights," "big problem that we don't give everyone an equal chance," "would be no problems if we treated people more equally," "not really that big a problem if some have more chance," "should worry less about equality"). Candidate cumulative variables: **VCF9013–VCF9018**. *Confirm exact 6 items and per-year availability against codebook (follows Kinder & Kalmoe 2017 conventions).*
- Scored so high = high egalitarianism; averaged/summed to a −1..+1 index.

### 2.4 Core Political Values — Moral Traditionalism
- Multi-item battery, **5-point agree–disagree**; begins **1986**.
- Standard ANES moral-traditionalism battery = **4 items** (e.g., "newer lifestyles contributing to breakdown of society," "world is always changing we should adjust our view of moral behavior [rev.]," "should be more tolerant of people who live by different moral standards [rev.]," "emphasis on traditional family ties too much/not enough"). Candidate cumulative variables: **VCF9131–VCF9134**. *Confirm items + availability against codebook.*
- Scored so high = high traditionalism; −1..+1 index.

### 2.5 Policy Views index
- **Five 7-point policy items** (available from 1972; used 1984+), combined in an index:
  1. Defense spending
  2. Government services/spending trade-off
  3. Guaranteed jobs / standard of living
  4. Aid to blacks (government aid to Black Americans)
  5. Government health insurance
- Candidate ANES cumulative variables: defense **VCF0843**, services/spending **VCF0839**, jobs/std-of-living **VCF0809**, aid to blacks **VCF0830**, govt health insurance **VCF0806**. *Confirm.*
- **DK handling:** DK rates 12–15% per item; only **66%** answered all five. **DK scored as middling** (scale midpoint). Index coded −1..+1, high = policy **liberalism**.

### 2.6 Party identification
- 7-point party ID (available throughout). Categories in Figure 1: Strong Democrat, (Weak) Democrat, Lean Democrat, Independent, Lean Republican, (Weak) Republican, Strong Republican.
- DK ≤1%. Coded −1..+1, high = **Republican**.
- Candidate cumulative variable: **VCF0301** (7-pt party ID).

### 2.7 Vote choice (Table 5)
- Presidential two-party vote: **Republican = 1, Democrat = 0, others = missing**.
- Restricted to voters. Candidate cumulative variable: **VCF0704** / **VCF0704a** (major-party presidential vote). *Confirm.*

### 2.8 Abortion (footnote 5 only)
- Standard **4-point** ANES abortion item (circumstances under which abortion should be permitted/restricted). Candidate: **VCF0838**. Outcome in an **ordered probit** on moral traditionalism.

---

## 3. Tables and figures — exact reported statistics

### Figure 1 — Distributions for ideological constructs and partisanship, 1984–2016
- **Source:** ANES cumulative, **UNWEIGHTED**.
- Five histograms: (a) Ideology ID (7 categories; **Moderate/HTMA bar ≈ 49%**, the tallest by far), (b) Policy Liberalism (−1..1, roughly bell-shaped, mode near 0, peak ≈24%), (c) Moral Traditionalism (−1..1, left-skewed toward high, peak ≈21%), (d) Egalitarianism (−1..1, skewed toward high, peak ≈22%, notable mass at +1 ≈10%), (e) Partisanship (7 categories, U-ish; Strong Dem ≈19%, Independent ≈11%).
- **Reproduction point:** shows ideology ID is especially non-polar (huge middle), partisans populate the poles.

### Table 1 — The Breadth of Values, Policy Views, and Identities by Knowledge
- **Source:** ANES cumulative, **WEIGHTED percentages.**
- **Statistic:** "Percent in Polar Half" = share of respondents whose score falls in the **outer half** of the scale (upper + lower quarters, i.e., |scaled score| in the outer 50%).
- **Columns:** Full Sample | Lowest 9% | Low 20% | Middle 34% | High 25% | Highest 13% | Highest−Lowest | Highest÷Lowest ("Info Gain").

| Construct (years; N) | Full | Lowest 9% | Low 20% | Middle 34% | High 25% | Highest 13% | H−L | H÷L |
|---|---|---|---|---|---|---|---|---|
| Egalitarianism (1984–2000,04,08,12,16; N=21,579) | 32% | 26% | 26% | 30% | 35% | 43% | +17% | 1.65 |
| Moral Tradition (1986–2000,04,08,12,16; N=19,306) | 35% | 17% | 25% | 33% | 42% | 45% | +28% | 2.65 |
| Policy Views (1984–2000,04,08,12,16; N=23,134) | 18% | 11% | 13% | 16% | 21% | 29% | +18% | 2.64 |
| Ideology ID (1984–2004,08,12,16; N=25,332) | 27% | 11% | 16% | 24% | 34% | 44% | +33% | 4.00 |
| Partisanship (1984–2004,08,12,16; N=24,307) | 61% | 41% | 55% | 63% | 66% | 67% | +26% | 1.63 |

*(Verified from image: Moral Tradition full sample = 35%. SI has a ±1 SD "relative outlyingness" analogue with similar pattern.)*

### Table 2 — Reliability for Multiple Measures of CPV and Policy Views
- **Source:** ANES cumulative, **UNWEIGHTED.**
- **Statistics:** Cronbach's α and **average interitem covariance** (not correlation), by knowledge.
- Alpha benchmarks stated: ≥0.7 acceptable (**bold**), 0.6–0.7 questionable (**bold-italic**), 0.5–0.6 poor, <0.5 unacceptable.

| Construct / stat | Full | Lowest 9% | Low 20% | Middle 34% | High 25% | Highest 13% | H−L | H÷L |
|---|---|---|---|---|---|---|---|---|
| Egalitarianism α | .67 | .50 | .53 | .64 | **.73** | **.79** | +.29 | 1.58 |
| Egal. avg interitem cov. | .10 | .05 | .06 | .09 | .13 | .17 | +.12 | 3.40 |
| Moral Trad. α | .62 | .35 | .47 | .59 | .68 | **.73** | +.38 | 2.09 |
| Moral Trad. cov. | .11 | .04 | .06 | .10 | .14 | .18 | +.13 | 4.25 |
| Policy Views α | .64 | .38 | .46 | .58 | .69 | **.80** | +.42 | 2.11 |
| Policy Views cov. | .08 | .03 | .04 | .06 | .09 | .14 | +.11 | 4.67 |

- In-text summary: "top 38% have acceptable levels for egalitarianism; only the upper 13% hit the mark for traditionalism; a fair reading says 40% hold coherent values and policy views." Interitem covariance "three times stronger or more in the top than the bottom." Note S11 shows polychoric vs Pearson interitem correlations support interval assumptions.

### Table 3 — Stability of CPV, Policy Views, and Identifications
- **Source:** ANES panels, **UNWEIGHTED.** Statistic = **squared continuity correlation** (r²; variance in later wave explained by earlier wave), following Converse (2000). Two lowest knowledge groups merged.

**1990–92 ANES** (knowledge groups: Lowest 18% | Middle 38% | High 30% | Highest 14%; Full N~625):

| Construct | Full | Lowest 18% | Middle 38% | High 30% | Highest 14% | H−L | H÷L |
|---|---|---|---|---|---|---|---|
| Egalitarianism | .24 | .14 | .26 | .32 | .38 | +.24 | 2.71 |
| Moral Tradition | .34 | .13 | .26 | .40 | .55 | +.42 | 4.23 |
| Policy Views (N~1,359) | .32 | .13 | .28 | .40 | .51 | +.38 | 3.92 |
| Ideology ID (N~1,359) | .29 | .05 | .20 | .33 | .60 | +.55 | 12.00 |
| Partisanship (N=1,334) | .61 | .44 | .59 | .66 | .73 | +.29 | 1.66 |

**1992–96 ANES** (groups: Lowest 20% | Middle 35% | High 29% | Highest 14%; Full N~585):

| Construct | Full | Lowest 20% | Middle 35% | High 29% | Highest 14% | H−L | H÷L |
|---|---|---|---|---|---|---|---|
| Egalitarianism | .31 | .18 | .28 | .30 | .30 | +.12 | 1.67 |
| Moral Tradition | .37 | .16 | .42 | .46 | .37 | +.21 | 2.31 |
| Policy Views | .42 | .26 | .39 | .38 | .62 | +.36 | 2.38 |
| Ideology ID | .37 | .03 | .26 | .48 | .71 | +.68 | 23.67 |
| Partisanship | .59 | .49 | .58 | .77 | .58 | +.09 | 1.18 |

**2000–02 ANES** (groups: Lowest 17% | Middle 31% | High 31% | Highest 22%; no values):

| Construct | Full | Lowest 17% | Middle 31% | High 31% | Highest 22% | H−L | H÷L |
|---|---|---|---|---|---|---|---|
| Policy Views (N=1,016) | .27 | .19 | .22 | .30 | .30 | +.11 | 1.58 |
| Ideology ID (N=564) | .38 | .04 | .37 | .46 | .61 | +.57 | 15.25 |
| Partisanship (N=1,165) | .71 | .56 | .69 | .77 | .76 | +.20 | 1.36 |

### Table 4 — Relating Ideological Constructs and Partisanship (correlations)
- **Source:** ANES cumulative, **UNWEIGHTED Pearson's correlations.** "(rev.)" reverses a construct's sign so a positive correlation aligns the two constructs' liberal/conservative directions.
- Bold-italic = moderate (.30–.49); bold = large (≥.50).
- **Columns:** Full | Lowest 9% | Low 20% | Middle 34% | High 25% | Highest 13% | H−L | H÷L.

| Pair | Full | Lowest 9% | Low 20% | Middle 34% | High 25% | Highest 13% | H−L | H÷L |
|---|---|---|---|---|---|---|---|---|
| Egalitarianism × Moral Tradition (rev.) | .28 | .04 | .11 | .23 | .32 | .45 | +.41 | 11.25 |
| Egalitarianism × Policy Views | .44 | .27 | .29 | .40 | .51 | .59 | +.32 | 2.14 |
| Egalitarianism × Ideology ID (rev.) | .35 | .06 | .11 | .27 | .42 | .55 | +.49 | 9.17 |
| Egalitarianism × Partisanship (rev.) | .35 | .11 | .17 | .29 | .42 | .52 | +.41 | 4.73 |
| Moral Tradition × Policy Views (rev.) | .29 | .03 | .13 | .22 | .31 | .49 | +.46 | 16.33 |
| Moral Tradition × Ideology ID | .40 | .08 | .18 | .32 | .46 | .59 | +.51 | 7.38 |
| Moral Tradition × Partisanship | .27 | .03 | .08 | .21 | .32 | .48 | +.45 | 16.00 |
| Policy Views × Ideology ID (rev.) | .39 | .05 | .18 | .29 | .47 | .64 | +.59 | 12.80 |
| Policy Views × Partisanship (rev.) | .44 | .12 | .22 | .37 | .50 | .62 | +.50 | 5.17 |
| Ideology ID × Partisanship | .44 | .06 | .17 | .35 | .54 | .68 | +.62 | 10.67 |

*(Egalitarianism × Partisanship Lowest-9% cell prints ambiguously as .11/.12; .11 is used here because it alone reconciles the printed +.41 and 4.73. Some H÷L values in this table are computed on full-precision cells, so they differ slightly from ratios of the 2-decimal displayed values — e.g. Ideology ID × Partisanship shows 10.67 not .68/.06; this is expected, transcribe cells as shown.)*

- In-text: only top 13% consistently show large (≥.5) links; moderate (≥.3) for next quarter; only 2 of 8 correlations reach .3 in the middle third; moderate-or-better links appear only for the most knowledgeable **38%**. Partisanship has the strongest links to 3 of 4 constructs (exception: traditionalism, closer to ideology ID).

### Table 5 — Ideology in Presidential Vote Choice, 1984–2016
- **Source:** ANES cumulative, **WEIGHTED bivariate probit** (one predictor at a time), **robust SEs clustered by year** (in parentheses). All estimates statistically significant.
- **DV:** Republican presidential vote (1 = Rep, 0 = Dem, others missing). Voters only.
- Constructs coded so predictor points toward Republican vote: Egalitarianism **(rev.)**, Policy Views **(rev.)**, Moral Tradition (not rev.), Ideology ID, Partisanship.
- **Knowledge groups (voters, lowest 2% merged):** Lower 13% | Middle 32% | High 33% | Highest 22%.
- Two statistics per construct: probit coefficient (SE) and **pseudo-R²** (bold in original).

| Construct / stat | Full | Lower 13% | Middle 32% | High 33% | Highest 22% | H−L | H÷L |
|---|---|---|---|---|---|---|---|
| Egalitarianism (rev.) probit | 1.58 (.08) | 1.03 (.16) | 1.32 (.08) | 1.75 (.11) | 2.00 (.11) | +.97 | 1.94 |
| Egalitarianism pseudo-R² | .15 | .05 | .10 | .19 | .28 | +.23 | 5.60 |
| Moral Tradition probit | 1.29 (.10) | .88 (.09) | 1.07 (.11) | 1.29 (.10) | 1.74 (.10) | +.86 | 1.98 |
| Moral Tradition pseudo-R² | .13 | .04 | .08 | .14 | .26 | +.22 | 6.50 |
| Policy Views (rev.) probit | 2.10 (.32) | 1.38 (.21) | 1.75 (.34) | 2.35 (.38) | 2.67 (.43) | +1.29 | 1.93 |
| Policy Views pseudo-R² | .21 | .08 | .14 | .26 | .37 | +.29 | 4.63 |
| Ideology ID probit | 1.91 (.14) | .97 (.19) | 1.57 (.16) | 2.12 (.14) | 2.54 (.11) | +1.57 | 2.62 |
| Ideology ID pseudo-R² | .23 | .04 | .14 | .29 | .43 | +.39 | 10.75 |
| Partisanship probit | 1.81 (.06) | 1.42 (.08) | 1.77 (.06) | 1.89 (.07) | 2.11 (.08) | +.69 | 1.49 |
| Partisanship pseudo-R² | .49 | .32 | .47 | .52 | .60 | +.28 | 1.88 |

- Ns: Egalitarianism 10,403; Moral 9,036; Policy 9,891; Ideology ID 9,834; Partisanship 10,416. (H−L / H÷L above recomputed and verified from the cell values.)
- In-text: partisanship explains 2–4× more variance than ideological constructs; ideology explains ~5–11× more variance for top 22% than bottom 13%.

### Footnote 5 — Abortion probit
- ANES cumulative. **Ordered probit** of the 4-point abortion item on moral traditionalism. Result: traditionalism explains **~5× more variance** in abortion attitudes for the most knowledgeable **one-third** vs. the least knowledgeable **two-thirds**; probit coefficient roughly **twice** the size. (Note the two-group split here — top third vs bottom two-thirds — differs from the 5-group table strata.)

---

## 4. Key in-text empirical claims (with numbers) a reproduction must speak to

**Reproducible (Tier A):**
- **Opinionation:** Average knowledge = **.36** for "haven't thought much" ideology respondents vs **.63** for liberals/conservatives; moderates in between.
- **Policy DK:** DK rates **12–15%** per item; **66%** answered all five; knowledge **.32** for those DK on 3+ items vs **.63** for those answering all five.
- **CPV & party DK ≤1%.**
- **Vote–ideology (individual-level):** Kalmoe finds **r = .49** for ideology ID × vote in the same data where Jost reports .90 (aggregated).
- **Vote–partisanship:** partisanship × vote **r = .68**; **62%** of voters in the four polar party categories, **71–97%** loyal.

**Reproducible but comparison-anchored (Tier A recompute vs Jost quote):**
- Ideology ID: **28%** of voters in the four outer (of 7) categories; **80%** vote-aligned (Jost's figure Kalmoe endorses).

**Tier B (report, do not recompute):**
- Convenience-sample knowledge means/SDs/Ns (§1.4).
- Ideology–party correlations: national rep **.62**; two non-South student **.82** and **.77**; one MTurk **.75**. Shared variance framed as **38% vs 59%** (= .62² ≈ .38 for national; .77² ≈ .59 for student — i.e., squared correlations, not a separate statistic).
- Clifford et al. (2015) FTF/Web/MTurk correlations: Authoritarianism .18/.23/.36; Racial Resentment .34/.44/.57; Traditionalism .46/.58/.62; Egalitarianism .40/.50/.62; Economic policy .57/.59/.65; Social issues .37/.46/.53 (MTurk 48–100% larger).
- Pew (2012) knowledge: 53% link Republicans↔small government; 61% Republicans↔abortion limits; 67% Democrats↔higher taxes on wealthy.
- Student non-identification rates: Midwest 2010 **8%**, mid-Atlantic 2012 **3%**.
- Jost (2006) footnote-1 GLM: Democratic F(1,61)=352.89, adj R²=.85; Republican F(1,61)=424.19, adj R²=.87 (Kalmoe's reading of Jost's aggregated model, 63 cells − 2).

---

## 5. Methods details (consolidated)

- **Scaling:** every construct rescaled to **−1..+1** with the polarity in §2 (global convention). "Polar half" = outer 50% of the −1..+1 range.
- **Knowledge stratification:** 5 fixed interviewer-rating levels (coded 0/.25/.5/.75/1), **not quantiles**; group shares vary by table because population composition differs across the year-sets each construct uses and because voters/panelists differ (see per-table group headers).
- **Reliability:** Cronbach's α + average interitem **covariance**; interval treatment justified by S11 (polychoric ≈ Pearson).
- **Stability:** **squared** continuity (test–retest) correlations (r²).
- **Correlations (Table 4):** Pearson, unweighted; direction aligned via "(rev.)".
- **Vote models (Table 5):** bivariate (single-predictor) **probit**, weighted, robust SEs **clustered by election year**; report coefficient + pseudo-R². Multivariate models mentioned in text (values add little once partisanship + ideology ID included) but **not tabled**.
- **Missing data:** HTMA→0 (with moderates); policy DK→midpoint; vote "other"→missing; listwise within each index otherwise (e.g., only 66% answer all five policy items — confirm whether Kalmoe requires all items or uses available-item mean; see Ambiguities).

---

## 6. Ambiguities and recommended resolutions

1. **[Highest priority] Knowledge strata construction.** The 5 groups are the ANES interviewer-rating categories, NOT quintiles. **Resolution:** map VCF0050a's 5 levels directly to 0/.25/.5/.75/1 and group on the raw category; do not `ntile()`. Verify resulting shares match the table headers (9/20/34/25/13 in main tables) as a check that you have the right variable and year-set.

2. **Interviewer-rating variable id & direction.** Not named in paper. **Resolution:** VCF0050a (interviewer's assessment of R's general information level); confirm 5 categories and that high = more informed after recode. (An alternative older var is VCF0050; confirm which is populated across 1984–2016.)

3. **Exact egalitarianism (6) and moral-traditionalism (4) item sets and per-year availability.** Not listed. **Resolution:** use the standard ANES batteries (VCF9013–9018; VCF9131–9134) exactly as in Kinder & Kalmoe (2017), *Neither Liberal nor Conservative* (the book this paper follows); confirm each item's presence per year — availability shifts even though batteries "begin" 1984/1986.

4. **Ideology HTMA/DK code retention.** Need the item that still carries the "haven't thought much about it" response to implement HTMA→0. **Resolution:** use VCF0801 (or whichever cumulative var preserves HTMA) rather than a pre-folded version; place HTMA and "moderate" both at 0.

5. **Policy index missing-data rule.** Paper says DK→middling and 66% answered all five, but doesn't state whether the index requires all 5 or averages available items. **Resolution:** since DK is explicitly recoded to the midpoint (not dropped), compute the index as the **mean of all five items with DK set to midpoint** (retains the full sample) — consistent with the reported Ns (~23k) exceeding the 66%-complete subset. Confirm N reproduces 23,134.

6. **Which ANES years for ideology/partisanship.** Row label "1984–2004, 2008, 2012, 2016" implies midterm years (1986–2002) are included through 2004 but 2006/2010/2014 excluded. **Resolution:** include all ANES time-series years 1984–2004 plus 2008/2012/2016; exclude 2006/2010/2014 (and any non-FTF/non-telephone modes, e.g., 2012 had a web component — Kalmoe restricts to FTF/telephone). Confirm against the reported Ns per construct.

7. **Weighting variable.** Not named; differs by table. **Resolution:** use the ANES cumulative time-series weight (candidate **VCF0009z**/**VCF0011z**) for Tables 1 & 5; leave Tables 2–4 and Figure 1 unweighted as stated. Confirm weighted Ns/percentages against Table 1.

8. **Panel weighting/attrition and "N~".** "~" Ns and merged bottom groups imply per-item panel Ns vary. **Resolution:** use unweighted panel data, merge the two lowest interviewer-rating groups, and confirm the group-share headers (e.g., 1990–92: 18/38/30/14).

9. **"Polar half" definition edge cases.** Whether the midpoint (0) counts as non-polar and whether boundaries are inclusive. **Resolution:** "outer half" = |scaled score| > 0.5 (upper and lower quarters of a −1..+1 scale); for the 7-point scales this is the 4 outermost categories. **Built-in validation:** this definition should reproduce Table 1's full-sample partisanship = 61% and ideology ID = 27%, which in turn line up with the in-text "62% of voters in the four polar party categories" and "28% [of voters] in four [outlying] ideology categories" (voters skew more polar than the full sample, so slightly higher). If your polar-half counts miss these anchors, the definition or scaling is off.

10. **Vote-model construct polarity ("rev.").** Ensure egalitarianism and policy (coded high=liberal) are reversed so the probit predicts Republican vote with a positive coefficient. **Resolution:** reverse egalitarianism, policy, (and interpret signs accordingly); do not reverse moral traditionalism, ideology ID, partisanship (already high=conservative/Republican).

11. **Clustered probit / pseudo-R² software match.** Pseudo-R² type (McFadden) and clustered-robust SE implementation vary by package. **Resolution:** use McFadden's pseudo-R² and cluster-robust SEs by year (Stata `probit … , cluster(year)` or R `sandwich`/`estimatr`); expect small numerical differences.

---

## 7. Headline quantitative conclusions the reproduction must support

1. **Polar, coherent, stable, and potent ideology appears only for the most knowledgeable ~20–30%** of citizens; for the low-knowledge majority ideology is weak but non-zero.
2. **Partisanship dominates ideology** on every metric — broader (twice as many polar categories), stronger correlations, ~2× more stable, and 2–4× more predictive of the vote — and is robust across all knowledge levels, unlike ideology.
3. **Knowledge stratification is enormous:** highest vs lowest "info gain" ratios of ~1.6–4× (breadth/reliability) up to 10–24× (some correlations/stabilities).
4. **Values do not rescue ideology:** egalitarianism and moral traditionalism carry the same knowledge-dependent limits as ideology ID and policy views (and add little in multivariate vote models).
5. **Full-sample estimates are knowledge-conditioned:** because sophisticates populate the poles, unstratified tests overstate ideology for most people and understate it for the knowledgeable — motivating the four "best practices."
6. **Convenience samples inflate ideology** because they tend to exceed population knowledge levels (Tier B evidence).

---

## 8. Reproduction risk register (Tier A)

- **R1 (critical): Non-quantile knowledge strata.** Using quintiles instead of the 5 fixed interviewer-rating levels breaks every downstream cell. Validate by matching group-share headers.
- **R2 (high): Exact CPV item sets / years.** Wrong items or year coverage shift all alphas, covariances, correlations, and stabilities. Anchor to Kinder & Kalmoe (2017).
- **R3 (high): Per-table weighting.** Tables 1 & 5 weighted; 2–4 & Fig 1 unweighted. Easy to apply uniformly by mistake.
- **R4 (medium): Coding rules for HTMA (→0) and policy DK (→midpoint).** Getting these wrong changes distributions and Ns.
- **R5 (medium): Year selection & mode restriction (FTF/telephone only).** Confirm Ns to catch inclusion of the wrong years or modes.
- **R6 (medium): Probit specification** (clustered SEs by year, weights, pseudo-R² type) for Table 5.
- **R7 (low/out-of-scope): Tier-B convenience samples and Clifford/Jost/Pew figures** — cannot be reproduced; report as quoted.
