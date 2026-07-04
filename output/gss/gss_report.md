# GSS Conceptual Replication — Kalmoe (2020), *Uses and Abuses of Ideology in Political Psychology*

*Political Psychology* 41(4):771–793, doi:10.1111/pops.12650.

This module asks whether Kalmoe's central finding — that **polar, coherent, and
electorally potent ideology characterises only the politically knowledgeable minority,
while partisanship is strong for everyone** — reappears in a **different survey** (the GSS)
measured with a **different knowledge proxy** (WORDSUM verbal ability). It is a *conceptual*
replication addressing the FORRT nomination's "comparing results across datasets" priority,
not a re-run of Kalmoe's ANES pipeline. Kalmoe himself reports that substituting a
multiple-choice knowledge quiz for his interviewer rating makes the stratification "slightly
less distinct"; WORDSUM is a still-weaker proxy for *political* knowledge, so the interesting
question is how much of the pattern survives the change of instrument and dataset.

Pipeline: `data/raw/gss_subset.csv` → `R/05_gss.R` → `output/gss/*.rds` + this report.
Runs end-to-end via `Rscript R/05_gss.R` from the project root (R 4.5.3; deps: dplyr, tidyr,
psych, sandwich). Deterministic; no randomness.

---

## 1. Data provenance

**Source.** GSS 1972–2024 Cumulative Datafile — Release 3 (`gss24rel3`), downloaded as a
custom subset from SDA Berkeley (public, no login). 75,699 respondents × 35 variables, all
survey years 1972–2024, no case filtering. Acquisition steps, the `WTSSCOMP → WTSSNRPS`
substitution, and verification are logged in `notes/sda_download_log.md` (§ "GSS subset").
Files: `data/raw/gss_subset.csv` (75,699 rows), `data/raw/gss_subset_codebook.txt`.

**Missing-data handling.** SDA writes missing values as period-prefixed tokens (`.d` don't
know, `.i` inapplicable/not-asked, `.n` no answer, `.y` not-in-year, …); the loader maps any
`^\.` token to `NA`, then applies the DK→midpoint rule below where it is `.d` specifically.

---

## 2. Variable choices and justification

All constructs are on **−1..+1** with Kalmoe's polarity (high = conservative / Republican /
policy-liberal), so the GSS numbers are directly comparable to the ANES reproduction
(`output/repro_main/reproduction_report.md`).

| Construct | GSS variable(s) | Coding | Notes vs. Kalmoe |
|---|---|---|---|
| **Ideology ID** | `POLVIEWS` (1 ext. lib … 7 ext. cons) | `(code−4)/3`, high=conservative; **DK (`.d`) → 0** | Direct analogue of POLVIEWS to ANES `VCF0803`; DK→0 mirrors Kalmoe's HTMA→0. GSS DK rate is only **3.4%** (vs ANES's large non-opinion mass), and GSS offers no "haven't thought much" option — the scale midpoint (code 4, "moderate") is a *substantive* response held by **37.8%**. |
| **Partisanship** | `PARTYID` (0 strong Dem … 6 strong Rep) | `(code−3)/3`, high=Republican; **code 7 "other party" → NA** | Analogue to ANES `VCF0301`. |
| **Policy index** | `EQWLTH` (1–7) + `HELPPOOR` `HELPNOT` `HELPSICK` `HELPBLK` (1–5) | each rescaled to −1..+1, **high = liberal**; item DK (`.d`) → 0; **mean of available items** | See below. |
| **Republican vote** | `PRES84 … PRES20` | each respondent's **most-recent** presidential vote: Rep(2)=1, Dem(1)=0, other/refused/no-vote → NA; election year retained for clustering | GSS asks *retrospective recall* of the two most recent elections (the `PRES*` items are **not** mutually exclusive), so the most-recent vote is used, analogous to Kalmoe's contemporaneous ANES vote. |

**Why these five policy items.** The brief's candidate set — `EQWLTH` plus the four `HELP*`
government-role items — is the right choice on **consistency** grounds, which matter more than
breadth for a knowledge-stratified reliability/correlation analysis: all five are 7-pt/5-pt
government-role items coded in the same low=liberal direction and run continuously through
**2024**. Per-item first years: the four `HELP*` items begin in **1975**, `EQWLTH` in **1978**
(a small split in 1978, then 1980); all five are **jointly available from 1983 onward** (1983,
1984, 1986, 1987, …, 2024). (The `NAT*` spending items were downloaded but not used in
the index: `NATARMS`/`NATFARE` do not share a clean liberal–conservative polarity with the
others, and the 3-point "too much/too little" format is coarser.) Item-level DK (`.d`) rates
are low (EQWLTH 1.4%, HELPPOOR 2.5%, HELPNOT 4.4%, HELPSICK 2.2%, HELPBLK 3.0%), so DK→midpoint
vs. DK→NA barely moves the index; DK→midpoint is used to mirror Kalmoe's policy rule.

**Knowledge proxy — WORDSUM (primary).** WORDSUM (0–10 vocabulary) is binned into **5 fixed
ordinal groups** with cutpoints chosen *once* on the pooled distribution (after scores
3/4/6/8) to approximate Kalmoe's 9/20/34/25/13 population shares, then **held constant across
all analyses** (mirroring his fixed rating levels — not re-quantiled per table). Realized
shares: **Lowest (0–3) 11.7% · Low (4) 10.0% · Middle (5–6) 37.6% · High (7–8) 27.1% ·
Highest (9–10) 13.6%**. A right-skewed 11-value scale cannot hit 9/20/34/25/13 exactly; the
*monotonic gradient*, not the share split, is the result of interest.

**Knowledge proxy — DEGREE (secondary).** DEGREE (LT HS / HS / JuCo / BA / Grad;
shares 19.2 / 50.3 / 6.2 / 15.9 / 8.5%) is a clearly-labelled education-based stratifier,
reported alongside WORDSUM. It covers **every** year — including 2021, when WORDSUM was not
asked — and, being closer to political engagement than raw vocabulary, is a useful second lens.

**Weight.** `WTSSPS` (post-stratification) is used for the weighted analyses (polar-half,
vote probits); correlations and reliability are **unweighted**, as in Kalmoe. `WTSSPS` is the
**only** weight defined for the full 1972–2024 span (`WTSSALL` ends 2018; `WTSSNRPS` starts
2004); in an overlap year (2016) `WTSSPS ≈ WTSSALL` (mean ratio 0.99).

---

## 3. Year coverage

WORDSUM is a **rotating item**, absent in 1972–73, 1975, 1977, 1980, 1983, 1985–86, 2002 and
**2021**, and a subsample (~900–2,300/yr) in many years. GSS is **split-ballot**, so joint
coverage — not marginals — governs the stratified tables. The critical case is **2004**, where
WORDSUM and POLVIEWS/the policy battery sit on *disjoint* ballots (WORDSUM×POLVIEWS overlap
= 0): 2004 therefore contributes nothing to any WORDSUM-stratified ideology/policy table and
drops out automatically under listwise filtering. All other WORDSUM years overlap well.

`n` = total cases; `WS` = WORDSUM; `POLV`/`PARTY` = ideology/party non-missing;
`POL5` = all-five policy items; `WS×POLV` = joint WORDSUM ∩ POLVIEWS (the split-ballot check);
`DEG` = DEGREE. (Full table in `output/gss/coverage_by_year.rds`.)

| Year | n | WS | POLV | PARTY | POL5 | WS×POLV | DEG |
|---|---|---|---|---|---|---|---|
| 1974 | 1484 | 1449 | 1480 | 1402 | 0 | 1445 | 1483 |
| 1978 | 1532 | 1486 | 1505 | 1517 | 0 | 1464 | 1529 |
| 1983 | 1599 | 0 | 801 | 1580 | 1590 | 0 | 1597 |
| 1984 | 1473 | 1396 | 1462 | 1443 | 1440 | 1391 | 1470 |
| 1987 | 1819 | 1669 | 1777 | 1794 | 1793 | 1638 | 1809 |
| 1988 | 1481 | 912 | 1472 | 1476 | 987 | 909 | 1480 |
| 1994 | 2992 | 1851 | 2980 | 2899 | 1992 | 1851 | 2982 |
| 2000 | 2817 | 1314 | 2793 | 2757 | 1869 | 1303 | 2799 |
| 2002 | 2765 | **0** | 1367 | 2681 | 907 | 0 | 2760 |
| 2004 | 2812 | 1439 | 1335 | 2771 | 870 | **0** | 2811 |
| 2006 | 4510 | 1391 | 4487 | 4419 | 1977 | 1387 | 4507 |
| 2016 | 2867 | 1863 | 2837 | 2763 | 1937 | 1849 | 2859 |
| 2018 | 2348 | 1547 | 2326 | 2238 | 1549 | 1530 | 2348 |
| 2021 | 4032 | **0** | 3974 | 3886 | 2569 | 0 | 4009 |
| 2022 | 3544 | 2301 | 3499 | 3403 | 2310 | 2276 | 3544 |
| 2024 | 3309 | 2158 | 3259 | 3185 | 2131 | 2128 | 3306 |

Pooled per-group Ns are healthy for every WORDSUM stratum (Lowest ≥ 1,600 even for the
5-item reliability table), so **no groups were merged** — unlike Kalmoe's panel/probit tables.

---

## 4. Results

All WORDSUM tables use survey years **1984+** (for comparability with Kalmoe's window and the
ANES reproduction); 2004 auto-drops. ANES reproduction values are shown in *(italics)* for the
metrics with a direct analogue.

### 4.1 Analysis 1 — Percent in polar half, weighted (Table 1 analogue)

Outer half of the −1..+1 scale, `|score| ≥ 0.5` (inclusive), weighted by WTSSPS.

**By WORDSUM (1984+):**

| Construct | Full | Lowest | Low | Middle | High | Highest | H−L | H÷L |
|---|---|---|---|---|---|---|---|---|
| Ideology | 33.6 | 33.0 | 30.4 | 30.9 | 34.6 | 42.7 | +9.7 | 1.29 |
| Partisanship | 59.7 | 53.2 | 56.3 | 61.1 | 61.4 | 61.1 | +7.9 | 1.15 |
| Policy | 28.9 | 31.0 | 27.3 | 26.1 | 29.4 | 34.6 | +3.6 | 1.12 |

*(ANES: Ideology 27 | 11 16 24 34 44, ratio 4.0; Partisanship 61 | 41 55 63 66 67, ratio 1.6.)*

**By DEGREE (1984+):** Ideology 33.8 | 31.0 31.9 32.7 38.1 43.5 (ratio 1.40); Partisanship
59.9 | 55.3 59.3 59.9 64.4 64.2 (1.16); Policy 30.4 | 30.6 28.5 29.6 33.0 37.2 (1.22).

This is the **one metric that does not replicate**. The knowledge gradient in raw polarization
is shallow (ideology ratio 1.29 with WORDSUM, 1.40 with DEGREE, vs. Kalmoe's 4.0): the
low-knowledge GSS majority is nearly as likely to place itself in a polar ideology category as
the sophisticates. Two things drive this — see §5.

### 4.2 Analysis 2 — Policy-index reliability, unweighted (Table 2 analogue)

Cronbach's α and average interitem covariance (items on the −1..+1 scaling), by group.

**By WORDSUM (1984+):**

| Stat | Full | Lowest | Low | Middle | High | Highest |
|---|---|---|---|---|---|---|
| α | .763 | .654 | .668 | .735 | .800 | .863 |
| avg interitem cov | .151 | .115 | .114 | .135 | .162 | .206 |

**By DEGREE:** α .774 | .655 .751 .769 .846 .873.

Coherence **rises steeply and monotonically** with knowledge (α +.21 across WORDSUM groups;
covariance nearly doubles) — the same pattern Kalmoe reports (his policy α .38 → .80). GSS
policy α overall (.76) exceeds Kalmoe's (.64), reflecting the different, more homogeneous
government-role battery.

### 4.3 Analysis 3 — Correlations among constructs, unweighted Pearson (Table 4 analogue)

Direction-aligned (positive = agreeing liberal/conservative directions).

**By WORDSUM (1984+):**

| Pair | Full | Lowest | Low | Middle | High | Highest | H−L |
|---|---|---|---|---|---|---|---|
| Ideology × Party | .438 | .095 | .218 | .388 | .570 | .713 | +.618 |
| Ideology × Policy | .373 | .096 | .167 | .312 | .488 | .655 | +.559 |
| Party × Policy | .419 | .180 | .274 | .380 | .489 | .608 | +.428 |

*(ANES Ideology × Party: .44 | .06 .17 .35 .54 .68.)*

**By DEGREE:** Ideology × Party .449 | .147 .393 .486 .650 .711; Ideology × Policy .399 | .178
.329 .414 .588 .658; Party × Policy .444 | .208 .394 .494 .591 .637.

**Clean, strong replication.** The GSS WORDSUM Ideology × Party gradient (.095 → .713,
Full .438) tracks Kalmoe's ANES interviewer-rating gradient (.06 → .68, Full .44) almost
exactly. Constraint among ideology, party and policy exists **only for the knowledgeable**;
at the bottom the constructs are essentially unrelated (r ≈ .10).

### 4.4 Analysis 4 — Republican-vote probit, weighted, clustered by election year (Table 5 analogue)

Bivariate probit (one predictor), WTSSPS-weighted, robust SEs clustered by election year,
McFadden pseudo-R². Predictors point toward Republican vote (policy reversed).

| Predictor / stat | Full | Lowest | Low | Middle | High | Highest |
|---|---|---|---|---|---|---|
| Ideology coef | 1.55 | 0.53 | 0.92 | 1.37 | 1.90 | 2.51 |
| Ideology pseudo-R² | **.204** | .030 | .076 | .148 | .284 | .445 |
| Partisanship coef | 1.77 | 1.36 | 1.66 | 1.67 | 1.90 | 2.24 |
| Partisanship pseudo-R² | **.468** | .340 | .429 | .439 | .495 | .588 |
| Policy coef | 1.51 | 0.82 | 1.08 | 1.34 | 1.73 | 2.17 |
| Policy pseudo-R² | **.175** | .054 | .090 | .137 | .215 | .320 |

*(ANES: Ideology R² .23 | .04 … .43; Partisanship R² .49 | .32 … .60.)*

**Strong replication.** Ideology's electoral bite is **15× larger** for the top group than the
bottom (R² .030 → .445), while **partisanship dominates and is knowledge-robust**: it predicts
the vote better than ideology in *every* group and overwhelmingly so at the bottom (R² .340 vs
ideology's .030 — a ~11× gap). Full-sample partisanship R² (.468) ≈ Kalmoe's .49.

### 4.5 Analysis 5 — Time trend (has sorting changed the picture?)

Ideology × party and ideology × policy Pearson correlations by decade — full sample and top
(High+Highest WORDSUM) vs. bottom (Lowest+Low).

| Pair | Decade | r full | r bottom-K | r top-K | N full |
|---|---|---|---|---|---|
| Ideology × Party | 1970s | .206 | .139 | .281 | 7,349 |
| Ideology × Party | 1980s | .263 | .075 | .443 | 13,196 |
| Ideology × Party | 1990s | .355 | .087 | .541 | 12,925 |
| Ideology × Party | 2000s | .429 | .147 | .612 | 11,752 |
| Ideology × Party | 2010s | .505 | .194 | .673 | 11,267 |
| Ideology × Party | 2020s | .642 | .299 | .774 | 10,372 |
| Ideology × Policy | 1980s | .234 | .148 | .441 | 8,973 |
| Ideology × Policy | 1990s | .287 | .088 | .435 | 9,260 |
| Ideology × Policy | 2000s | .343 | .110 | .485 | 6,999 |
| Ideology × Policy | 2010s | .445 | .123 | .666 | 7,852 |
| Ideology × Policy | 2020s | .582 | .228 | .692 | 7,142 |

**Both things are true at once.** Full-sample ideology–party constraint has **tripled** since
the 1970s (.21 → .64) — the well-documented partisan "sorting" of the electorate. But the
**knowledge gap persists in every decade**: even in the 2020s the bottom-knowledge ideology ×
party correlation (.30) sits far below the top's (.77), and the same holds for ideology ×
policy (.23 vs .69). Sorting has raised the *average* without erasing knowledge stratification,
so an unstratified 2020s snapshot still overstates ideological constraint for most citizens.

### 4.6 POLVIEWS non-opinion rate by knowledge (opinionation analogue)

| WORDSUM group | Lowest | Low | Middle | High | Highest | Full |
|---|---|---|---|---|---|---|
| POLVIEWS DK (`.d`) rate | .091 | .057 | .027 | .013 | .009 | .034 |

DK on ideology falls monotonically with knowledge (10× from bottom to top), echoing Kalmoe's
opinionation finding — but the **absolute** rate is tiny (max 9%), because GSS forces a
7-point placement with no "haven't thought much" escape. The GSS "huge middle" is the
substantive **moderate** category (37.8%), not non-opinion.

---

## 5. Verdict — does the knowledge-stratification pattern conceptually replicate?

**Yes, on the substance; with one instructive exception.** Across a different survey and a
knowledge proxy (vocabulary) far removed from Kalmoe's interviewer rating, the core claim holds:

1. **Coherence (reliability) — replicates.** Policy-index α rises .65 → .86 across WORDSUM
   groups; covariance doubles.
2. **Constraint (inter-construct correlations) — replicates, strikingly.** Ideology × party
   .10 → .71 (Full .44), essentially identical to Kalmoe's ANES gradient. Ideology and policy
   cohere with party only among the knowledgeable.
3. **Electoral potency (vote probit) — replicates.** Ideology's pseudo-R² is 15× larger at the
   top than the bottom; **partisanship dominates ideology in every knowledge group** and is
   near-flat across them — Kalmoe's headline contrast, reproduced.
4. **Persistence over time — replicates.** The knowledge gap survives six decades of partisan
   sorting; the 2020s bottom-knowledge correlations remain far below the top's.
5. **Breadth / polarization (Table 1) — does NOT replicate.** The gradient in raw polarization
   is shallow (ideology ratio 1.29 with WORDSUM, 1.40 with DEGREE, vs Kalmoe's 4.0); the
   low-knowledge majority is nearly as "polar" in self-placement as the sophisticates.

**The stratifier is sound — the flatness is real.** The decisive evidence is internal: the
*same* WORDSUM bins, applied to essentially the *same* respondents, produce a clean 7×
ideology×party correlation gradient (.10 → .71) and a 15× vote-potency gradient yet an almost
flat polar-half gradient (33 → 43). A noisy or invalid knowledge stratifier could not
discriminate that sharply on the depth metrics, so the breadth flatness is a genuine property
of ideological self-placement in the GSS, not an artifact of a weak moderator. What breadth
and depth measure comes apart (see below).

**Why breadth diverges.** Two forces push the breadth gradient flat, both stemming from the
study design:

- **The proxy.** WORDSUM measures *verbal ability*, which is only a partial proxy for
  *political knowledge*. Low-vocabulary
  respondents still readily pick "liberal" or "conservative" labels, so the outer-half share
  barely tracks WORDSUM. This is exactly the direction of Kalmoe's own caveat that a knowledge
  *quiz* yields "slightly less distinct" results — WORDSUM, a weaker political-knowledge proxy,
  yields a *much* less distinct breadth gradient. DEGREE, being nearer to political engagement,
  gives a marginally steeper gradient (1.40) but still nothing like the interviewer rating.
- **The instrument.** GSS POLVIEWS offers no "haven't thought much about it" option and elicits
  only 3.4% DK, versus the large non-opinion mass ANES interviewers can flag. With almost
  everyone forced onto the 7-point scale, self-placement polarization is high and flat across
  knowledge — even though, as §4.3–4.4 show, those same low-knowledge placements carry little
  *constraint* or *electoral meaning*.

The reconciliation is coherent: **breadth (does a label get chosen) separates from depth (does
the label cohere and predict).** GSS low-knowledge respondents choose polar labels almost as
often as sophisticates, but only among the knowledgeable do those labels align with party,
with policy, and with the vote. The deeper, more consequential half of Kalmoe's thesis —
that ideology is coherent and potent only for the knowledgeable minority while partisanship is
strong for all — **replicates cleanly** in the GSS.

### Divergences from the ANES picture (summary)

| Metric | ANES (Kalmoe / repro) | GSS (WORDSUM) | Replicates? |
|---|---|---|---|
| Ideology polar-half gradient (H÷L) | 4.0 | 1.29 | **No** (proxy + no-HTMA) |
| Policy α, bottom → top | .38 → .80 | .65 → .86 | Yes |
| Ideology × party r, bottom → top | .06 → .68 | .10 → .71 | Yes (near-identical) |
| Ideology vote pseudo-R², bottom → top | .04 → .43 | .03 → .45 | Yes |
| Partisanship vote pseudo-R² (Full) | .49 | .47 | Yes |
| Ideology non-opinion by knowledge | large, steep | small (.09→.01), steep | Directionally yes |

---

## 6. Outputs

`R/05_gss.R` writes to `output/gss/`:

```
gss_analysis.rds            # prepared respondent-level file (constructs, groups, weights)
coverage_by_year.rds        # marginal + joint coverage per year
analysis1_polar.rds         # polar-half by WORDSUM & DEGREE (+ group shares)
analysis2_reliability.rds   # policy-index alpha + interitem covariance; per-item DK rates
analysis3_correlations.rds  # construct correlations by WORDSUM & DEGREE
analysis4_probit.rds        # vote probits by WORDSUM group
analysis5_timetrend.rds     # correlations by decade, full / top-K / bottom-K
analysis6_polviews_dk.rds   # POLVIEWS DK by knowledge; moderate-category share
```

### Design caveats (properties of the chosen data and measures)

- **WORDSUM indexes verbal ability**, a weaker political-knowledge proxy than Kalmoe's
  interviewer rating; the attenuated breadth gradient follows from that choice.
- **GSS vote is retrospective recall** (1–4 years post-election, with the usual winner-recall
  bias), where ANES reports the contemporaneous vote; the most-recent-vote + cluster-by-election-year
  design handles the pooling, and the recall property should be kept in view when reading Table 5.
- **DEGREE stratification is education**, reported as a second lens and the only stratifier
  available for 2021.
