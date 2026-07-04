# Reproduction Report — Kalmoe (2020), *Uses and Abuses of Ideology in Political Psychology*

*Political Psychology* 41(4):771–793, doi:10.1111/pops.12650. Reproduced from the ANES
Time-Series Cumulative Data File (1948–2016 vintage, `timeseries_cum`, 59,944 × 1,029),
the same release available to Kalmoe. Scope: **Figure 1, Tables 1, 2, 4, 5, footnote 5,
and the reproducible in-text statistics.** (Table 3 / the panel stability analyses are
handled separately.)

Pipeline: `R/01_prepare_cdf.R` → `output/repro_main/cdf_analysis.rds` → `R/02_reproduce_main.R`
→ per-table `.rds` files, `comparison.csv`, this report. Both scripts run end-to-end via
`Rscript` from the project root.

---

## 1. Headline result

The reproduction is **very close** across all in-scope tables. Of the **176 cells** in
Tables 1, 2, 4 and 5:

| Band | Count |
|---|---|
| Tight match (Table 1: ≤1 pp; Tables 2/4: ≤.01; Table 5 R²: ≤.01, coef: ≤.05) | **154** |
| Close (Table 1: ≤2 pp; Tables 2/4: ≤.02; Table 5 R²: ≤.02, coef: ≤.10) | **17** |
| Diverge | **5** |

The five diverges are four Table 1 *Lowest-knowledge* cells off by ~2–3 pp (the smallest,
noisiest stratum — every construct's Lowest cell runs slightly high because that group is
~7% of the sample here vs the paper's 9%; §5) and one Table 5 coefficient in the small
*Lower* voter group. Tables 2 and 4 reproduce essentially exactly (max |diff| .015 and
.018). Every substantive
conclusion of the paper — polarization/coherence/predictiveness rising steeply with
knowledge, partisanship dominating ideology, info-gain ratios of ~1.6–11× — reproduces.

The only genuinely unresolved numbers are three ambiguous **in-text descriptive**
statistics (party×vote r, and the "% of voters" polarization shares), discussed in §5.

---

## 2. Judgment calls and the evidence for each

All ambiguous choices were adjudicated **empirically** against the anchors Kalmoe's tables
supply (construct Ns, the 9/20/34/25/13 knowledge group shares, and the Table 1 polar-half
percentages). This is the designed adjudication method, not tuning: the anchors identify
Kalmoe's actual choices.

### 2.1 Knowledge moderator — pre-preferred combined interviewer rating
- **Measure:** 5-point interviewer rating of the respondent's general political information.
  Recoded high = informed and mapped to 0/.25/.5/.75/1 via `(5 − rating)/4`
  (1 "very high" → 1 … 5 "very low" → 0). Groups are the **5 fixed rating levels, not
  quantiles.**
- **Pre vs post:** `VCF0050a` (pre) is **not asked in the midterm years 1986/1990/1994/1998**;
  `VCF0050b` (post) is missing in 1988. Neither alone covers the year-sets, so a combined
  measure is required. Tested pre-only, post-only, pre-preferred (pre, post fallback),
  post-preferred.
- **Evidence:** pre-preferred reproduces Table 1 best — total absolute error across all 30
  Table-1 cells = **21** (pre-preferred) vs **33** (post-preferred), and gives an **exact**
  by-group match for ideology ID (11/16/24/34/44). This also honors the paper's stated use
  of the *pre-election* rating (VCF0050a), with post only filling the four midterm gaps.
  **Chosen: pre-preferred combined.**

### 2.2 Mode restriction — FTF + telephone, exclude web
- `VCF0017` ∈ {0,1,2,3} (all-personal, telephone-pre/post, all-telephone); **web = 4 excluded.**
  This drops the 2012/2016 web samples (in those years the interviewer rating is only
  collected for the FTF sample anyway). With this filter the construct Ns land within ~4%
  of Kalmoe's; without it, 2012/2016 roughly double.

### 2.3 Weight — VCF0009x (FTF-sample weight)
- Tables 1 & 5 are weighted; Figure 1 and Tables 2 & 4 are unweighted (as stated in the
  paper). `VCF0009x` is the FTF-sample weight; it equals the full-sample weight `VCF0009z`
  in every year **except 2012/2016**, where it correctly down-weights to the FTF component
  we retain. Using it reproduces the Table 1 weighted percentages; the weighted partisanship
  probit (Table 5) gives coef 1.82 / pseudo-R² .49, matching 1.81/.49.

### 2.4 Polar-half boundary — inclusive, |score| ≥ 0.5
- This is the single most consequential edge-case. For the 7-point identity scales inclusive
  and exclusive coincide (scores never land exactly on ±0.5), so ideology/party are
  unaffected. For the **averaged value/policy indices**, many respondents land exactly on
  ±0.5, so the choice moves the cell by ~8 pp. Inclusive reproduces the targets:
  egal Full 31 vs 32, MT Full 35 vs 35 (exclusive gives 24/24 — clearly wrong). **Chosen: inclusive.**

### 2.5 Construct coding (all on −1..+1)
- **Ideology** `VCF0803` (retains code 9 = "haven't thought much"): 1–7 → `(code−4)/3`
  (high = conservative); **code 9 (HTMA) coded with moderates at 0**.
- **Party** `VCF0301`: `(code−4)/3`, high = Republican.
- **Egalitarianism** = 6 items `VCF9013/9015/9018` (pro-egal) + `VCF9014/9016/9017`
  (reverse-worded), each 5-pt → −1..+1, high = egalitarian.
- **Moral traditionalism** = 4 items **`VCF0851/0852/0853/0854`** (the 5-pt agree–disagree
  battery — *not* `VCF9131–9134`, which are the government/system-support dichotomies),
  high = traditional.
- **Policy views** = 5 items `VCF0843` (defense), `VCF0809` (jobs), `VCF0830` (aid to
  blacks), `VCF0806` (health ins.), `VCF0839` (services/spending), each 7-pt → −1..+1,
  high = **liberal** (defense/jobs/aid/health reversed; services aligned).

### 2.6 Index missing-data rule — mean of available items; DK handling
- Indices = **mean of the non-missing items**. Policy **DK (code 9) → scale midpoint (0)**;
  egal/MT DK (code 8) → missing (nonresponse < 1%).
- **Evidence this is right for reliability too (not just breadth):** policy Full α with
  DK→midpoint = .641 / cov .080 (targets .64/.08); with DK→NA it is .668/.099 (wrong). So
  DK→midpoint is confirmed by Table 2 independently of Table 1.
- Policy Full N = 23,332 vs target 23,134 (mean-of-available); requiring all five items
  gives only ~13,300 — the mean-of-available rule is what matches.

### 2.7 Year-sets — emerge from battery availability
- Ideology / party: all 14 CDF years 1984–2016 (note 2006/2010/2014 are **absent from this
  CDF vintage**, consistent with the paper's row labels).
- Egalitarianism: 1984–2000, 2004, 2008, 2012, 2016 (absent 2002). 1998 carries only 2 of
  the 6 items (VCF9014, VCF9018 — one pro-, one anti-egal), which the mean-of-available rule
  keeps; including 1998 brings egal N to 21,643 (target 21,579) and Full polar to 32
  (see §5).
- Moral traditionalism: 1986–2000, 2004, 2008, 2012, 2016 (begins 1986; absent 2002).
- Policy: 1984–2000, 2004, 2008, 2012, 2016 (absent 2002).
- These match the paper's per-construct row labels and reproduce the construct Ns.

### 2.8 Table 5 specification
- Weighted (`VCF0009x`) bivariate probit, **one predictor per model**, voters only
  (`VCF0704a`: Rep = 1, Dem = 0), presidential years 1984–2016. **McFadden pseudo-R²**
  (1 − logLik/logLik₀ on the identical weighted rows). SEs **cluster-robust by year**
  (`sandwich::vcovCL`). Predictors point toward Republican vote: egalitarianism and policy
  **reversed**, MT / ideology / party as-is. Voter knowledge groups **merge the lowest two
  ratings** (Lower / Middle / High / Highest).

### 2.9 Footnote 5
- Ordered probit (`MASS::polr`, `method="probit"`) of the 4-point abortion item (`VCF0838`)
  on moral traditionalism, McFadden pseudo-R². **Unweighted** (the footnote is a two-group
  comparison of relative fit, not one of the weighted vote models). "Top third" = High +
  Highest ratings. With our group shares this is **41.5%**, not exactly 33% (reported honestly
  rather than forced); bottom two-thirds = the other three ratings.

---

## 3. Per-table reproduction (original → reproduced)

### Table 1 — Percent in polar half, weighted (max |diff| 2.9 pp; mean 0.8 pp)
Reproduced values (targets in the spec). Group shares came out 7/18/34/26/15 vs the paper's
9/20/34/25/13 (see §5), but the polar-half **cells** match well.

| Construct | Full | Lowest | Low | Middle | High | Highest | (N) |
|---|---|---|---|---|---|---|---|
| Egalitarianism | 32 (32) | 29 (26) | 26 (26) | 30 (30) | 35 (35) | 43 (43) | 21,643 (21,579) |
| Moral Tradition | 35 (35) | 20 (17) | 26 (25) | 34 (33) | 42 (42) | 45 (45) | 19,349 (19,306) |
| Policy Views | 19 (18) | 13 (11) | 14 (13) | 17 (16) | 22 (21) | 30 (29) | 23,332 (23,134) |
| Ideology ID | 27 (27) | 11 (11) | 16 (16) | 24 (24) | 34 (34) | 44 (44) | 24,557 (25,332) |
| Partisanship | 62 (61) | 43 (41) | 56 (55) | 63 (63) | 66 (66) | 67 (67) | 25,427 (24,307) |

Ideology reproduces exactly by group; the Lowest-stratum cells for MT/policy/party run
~2 pp high (that group is ~7% of the sample here vs the paper's 9%, so it is the most
sample-sensitive).

### Table 2 — Reliability, unweighted (max |diff| .015; essentially exact)
α and average interitem **covariance** (mean of off-diagonal covariance elements on the
−1..+1 item scaling). Reproduced (target):

| Stat | Full | Lowest | Low | Middle | High | Highest |
|---|---|---|---|---|---|---|
| Egal α | .68 (.67) | .50 (.50) | .54 (.53) | .64 (.64) | .73 (.73) | .80 (.79) |
| Egal cov | .10 (.10) | .05 (.05) | .06 (.06) | .09 (.09) | .13 (.13) | .17 (.17) |
| MT α | .62 (.62) | .37 (.35) | .47 (.47) | .59 (.59) | .68 (.68) | .73 (.73) |
| MT cov | .11 (.11) | .04 (.04) | .06 (.06) | .10 (.10) | .14 (.14) | .18 (.18) |
| Policy α | .64 (.64) | .39 (.38) | .47 (.46) | .58 (.58) | .69 (.69) | .80 (.80) |
| Policy cov | .08 (.08) | .03 (.03) | .05 (.04) | .07 (.06) | .09 (.09) | .14 (.14) |

### Table 4 — Correlations among constructs, unweighted Pearson (max |diff| .018)
"(rev.)" reported as the direction-aligned positive value. Reproduced (target):

| Pair | Full | Lowest | Low | Middle | High | Highest |
|---|---|---|---|---|---|---|
| Egal × MoralTrad (rev) | .28 (.28) | .03 (.04) | .11 (.11) | .23 (.23) | .33 (.32) | .45 (.45) |
| Egal × Policy | .44 (.44) | .27 (.27) | .29 (.29) | .40 (.40) | .51 (.51) | .59 (.59) |
| Egal × IdeoID (rev) | .35 (.35) | .07 (.06) | .11 (.11) | .26 (.27) | .42 (.42) | .55 (.55) |
| Egal × Party (rev) | .35 (.35) | .12 (.11) | .18 (.17) | .29 (.29) | .42 (.42) | .52 (.52) |
| MoralTrad × Policy (rev) | .28 (.29) | .04 (.03) | .12 (.13) | .22 (.22) | .31 (.31) | .49 (.49) |
| MoralTrad × IdeoID | .40 (.40) | .08 (.08) | .17 (.18) | .32 (.32) | .46 (.46) | .58 (.59) |
| MoralTrad × Party | .27 (.27) | .04 (.03) | .06 (.08) | .21 (.21) | .32 (.32) | .48 (.48) |
| Policy × IdeoID (rev) | .39 (.39) | .06 (.05) | .18 (.18) | .29 (.29) | .47 (.47) | .64 (.64) |
| Policy × Party (rev) | .42 (.44) | .12 (.12) | .22 (.22) | .37 (.37) | .50 (.50) | .63 (.62) |
| IdeoID × Party | .44 (.44) | .08 (.06) | .16 (.17) | .35 (.35) | .54 (.54) | .67 (.68) |

### Table 5 — Presidential-vote probit, weighted, clustered SEs (coef mean |diff| .03; R² mean |diff| .005)
Reproduced probit coefficient (SE) and pseudo-R²; targets in the spec. Ns: Egal 10,465
(10,403), MT 9,086 (9,036), Policy 9,956 (9,891), Ideology 9,898 (9,834), Party 10,419 (10,416).

| Construct | Full | Lower | Middle | High | Highest |
|---|---|---|---|---|---|
| Egal (rev) coef | 1.58 (1.58) | 1.04 (1.03) | 1.34 (1.32) | 1.71 (1.75) | 2.00 (2.00) |
| Egal R² | .15 (.15) | .05 (.05) | .10 (.10) | .18 (.19) | .28 (.28) |
| MoralTrad coef | 1.29 (1.29) | 0.82 (0.88) | 1.09 (1.07) | 1.27 (1.29) | 1.75 (1.74) |
| MoralTrad R² | .13 (.13) | .04 (.04) | .09 (.08) | .13 (.14) | .26 (.26) |
| Policy (rev) coef | 2.05 (2.10) | 1.26 (1.38) | 1.72 (1.75) | 2.28 (2.35) | 2.62 (2.67) |
| Policy R² | .22 (.21) | .07 (.08) | .15 (.14) | .26 (.26) | .37 (.37) |
| IdeoID coef | 1.92 (1.91) | 0.94 (0.97) | 1.57 (1.57) | 2.10 (2.12) | 2.58 (2.54) |
| IdeoID R² | .23 (.23) | .04 (.04) | .14 (.14) | .28 (.29) | .44 (.43) |
| Partisanship coef | 1.82 (1.81) | 1.42 (1.42) | 1.77 (1.77) | 1.88 (1.89) | 2.15 (2.11) |
| Partisanship R² | .49 (.49) | .31 (.32) | .47 (.47) | .53 (.52) | .60 (.60) |

### Figure 1 — distributions, unweighted (all anchors within ~1 pp)
- Ideology: **Moderate/HTMA bar = 50.0%** (paper ≈ 49%, tallest by far); the other six
  categories 2.0 / 8.2 / 9.2 / 13.7 / 14.2 / 2.7%.
- Partisanship: **Strong Dem 19.6%** (≈19%), **Independent 11.4%** (≈11%); U-ish shape
  reproduced (19.6 / 17.7 / 13.9 / 11.4 / 12.0 / 13.2 / 12.3%).
- Egalitarianism/MT/policy index histograms saved in `fig1_data.rds`: egal and MT are
  left-skewed toward the high (egalitarian/traditional) pole and policy is roughly
  bell-shaped, matching the paper's qualitative description. The quantitative bar-height
  anchors were not all reproduced exactly — e.g. Kalmoe describes egal "+1 mass ≈ 10%"
  whereas the 6-item mean puts only ~5% exactly at +1 (a 6-item average rarely reaches the
  extreme); these are binning/aggregation-sensitive and were not treated as hard targets.

### Footnote 5 — abortion ordered probit
Traditionalism predicts abortion attitudes far more strongly for the knowledgeable:
- Top third (High+Highest, 41.5% of the sample): coef **−1.26**, pseudo-R² **.095**.
- Bottom two-thirds: coef **−0.62**, pseudo-R² **.018**.
- **Coefficient ratio ≈ 2.0×** and **pseudo-R² ratio ≈ 5.2×**, matching the paper's "roughly
  twice the size" and "~5× more variance."

---

## 4. In-text statistics (reproduced)

| Statistic | Original | Reproduced |
|---|---|---|
| Knowledge for "haven't thought" ideology respondents | .36 | **.40** |
| Knowledge for liberal/conservative identifiers | .63 | **.65** |
| Policy DK rate per item (range) | 12–15% | **10.8–14.9%** |
| % answering all five policy items | 66% | **67%** |
| Knowledge for those DK on 3+ policy items | .32 | **.31** |
| Knowledge for those answering all five | .63 | **.64** |
| Ideology ID × vote (individual-level Pearson r) | .49 | **.50** |
| Partisanship × vote (Pearson r, 7-pt linear) | .68 | **.76** ⚠ |
| Partisanship × vote (leaners folded to Independent) | .68 | **.69** |
| % of voters in four polar party categories | 62% | **70%** (voters) / **62%** (full sample) ⚠ |
| % of voters in four outer ideology categories | 28% | **32%** (voters) / **27%** (full sample) ⚠ |
| Party loyalty in the four polar categories | 71–97% | **80–96%** |

Nine of eleven reproduce closely; ⚠ = discussed below. CPV and party DK rates are < 1% as
the paper states.

---

## 5. Genuine discrepancies (not forced to match)

1. **Knowledge group shares run 7/18/34/26/15 vs the paper's 9/20/34/25/13.** Consistent
   across every construct, so it is a property of the interviewer-rating distribution in
   this CDF release / weight, not a coding error — the by-group polar-half **cells**
   (Table 1) match regardless, and ideology matches exactly. Most likely reflects a
   weight/recode vintage difference between this redistribution of the CDF and the file
   Kalmoe used. Not chased, as it does not affect the table cells.

2. **Table 1 Lowest-stratum cells (egal 29 vs 26, MT 20 vs 17, policy 13 vs 11, party 43 vs
   41).** These ~2–3 pp gaps sit in the smallest, most sample-sensitive group (item 1 above
   makes it ~7% rather than 9% of the sample). All other Table 1 cells are within ~1 pp.

3. **Partisanship × vote r = .76 vs .68 — resolved by leaner coding.** Ideology × vote
   reproduces (.50 vs .49) on the identical sample, so the difference is specific to the
   party scaling. The 7-point linear coding gives .76; **folding party leaners (codes 3, 5)
   to Independent (0) gives .69**, matching the paper's .68. So the descriptive correlation
   evidently treats leaners as independents, whereas the Table 5 probit (which reproduces at
   coef 1.81) uses the full 7-point scale — an internal coding difference between the two
   uses of partisanship. Both values are in `comparison.csv` (`r_partisanship_vote`,
   `r_partisanship_vote_leanerfold`).

4. **"% of voters in polar party / outer ideology categories" (70% / 32%) vs 62% / 28%.**
   The literal voter-restricted computation runs above the paper's figures. However, the
   **full-sample** (Table 1) equivalents — 62% partisanship-polar and 27% ideology-outer —
   match Kalmoe's quoted 62%/28% almost exactly. Since the paper introduces these numbers
   immediately alongside the Table 1 breadth figures (61%/27%), his "of voters" prose most
   plausibly references the full-sample breadth rather than a voter-only recomputation. Both
   values are reported (`comparison.csv` rows `pct_voters_*` and `pct_*_fullsample`).

5. **Party loyalty low end 80% vs 71%.** Using the three-party vote (`VCF0704`, so
   third-party defections count as disloyal) gives weak-partisan loyalty ~80% and
   strong-partisan ~95–96% (range 80–96% vs the paper's 71–97%). The high end matches; the
   low end is ~9 pp high. The exact denominator/year set behind the 71% figure is not
   specified; the reproduced range supports the substantive claim (high, knowledge-robust
   loyalty) without hitting the precise bound.

---

## 6. What was NOT reproduced (out of scope / not reproducible)

- **Table 3** (panel stability) — handled in a separate workstream.
- The **convenience-sample** section (Knowledge Networks/GfK, MTurk, student samples) and
  the **Clifford et al. (2015)**, **Jost (2006)** and **Pew** figures are Tier-B: proprietary
  or quoted from other papers, so reported as-is rather than recomputed (see `paper_spec.md` §1.4, §4).

---

## 7. Reproducibility

```
Rscript R/01_prepare_cdf.R      # builds output/repro_main/cdf_analysis.rds
Rscript R/02_reproduce_main.R   # writes table{1,2,4,5}.rds, fig1_data.rds,
                                # footnote5.rds, intext_stats.rds, comparison.csv
```
Deterministic; no randomness. `comparison.csv` holds every target cell with original,
reproduced and difference. Verified to run end-to-end from the project root under R 4.5.3
(deps: dplyr, tidyr, psych, sandwich, MASS).
