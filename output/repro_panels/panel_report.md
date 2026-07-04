# Reproduction of Table 3 (Stability of CPV, Policy Views, and Identifications)

Kalmoe (2020), *Political Psychology*, doi:10.1111/pops.12650. Statistic: **unweighted
squared test–retest ("continuity") Pearson correlations** between the two waves of each
ANES panel, full sample and by 5-level interviewer-rated political knowledge with the two
lowest rating levels merged (per the paper's Table 3 note and text).

Script: `R/04_panels.R` (run via `Rscript R/04_panels.R` from project root).
Outputs: `output/repro_panels/table3.rds`, `output/repro_panels/comparison.csv`.

**Headline match rates** (65 cells total; "exact" = identical after rounding to 2 dp):

| Panel   | Exact | Within ±.01 | Cells |
|---------|-------|-------------|-------|
| 1990–92 | 23    | 23          | 25    |
| 1992–96 | 6     | 16          | 25    |
| 2000–02 | 6     | 9           | 15    |

Policy Views and Ideology ID reproduce essentially perfectly in **all three panels**
(every cell within ±.01) — with the single, large exception of the 2000–02 Policy row,
whose item set is undocumented in the paper (see §4.3). Partisanship reproduces within
±.01 in 12 of 15 cells. The values rows (egalitarianism, moral traditionalism) reproduce
almost perfectly for 1990–92 but only approximately for 1992–96.

---

## 1. Data and merges

- **1990–92**: `timeseries_1992.rda` alone. This is the ANES 1990–1992 Full Panel File
  (N = 2,485 = the 1992 sample): panel respondents (`V923005` = 1, **N = 1,359** —
  matching the paper's "N ~ 1,359") carry 1990 variables (`V90*`) on the same row.
- **1992–96**: `timeseries_1996.rda` (N = 1,714). Panel cases that originated in the
  1992 time series carry the 1992 case ID (`V960009` > 0, N = 597); merged to
  `timeseries_1992` on its 1992 case ID `V923004` (**597/597 matched**). The other 1996
  "panel" cases entered the panel via the 1994 study and have no 1992 interview.
  597 is consistent with the paper's full-sample "N ~ 585" (which our partisanship row
  reproduces exactly: N = 585).
- **2000–02**: `timeseries_2002.rda` (N = 1,511; panel cases `V021001` = 1, N = 1,187)
  merged to `timeseries_2000.rda` (N = 1,807) on the 2000 case ID
  (`V020002` → `V000001`; **1,187/1,187 matched**).

## 2. Knowledge moderator — resolved empirically

The paper does not say which wave's interviewer rating is used. Resolution (by matching
the printed group-share headers *and* the cell values):

| Panel   | Variable used | Label | Shares in analysis sample (L/M/H/Hi) | Printed header |
|---------|--------------|-------|--------------------------------------|----------------|
| 1990–92 | `V924205` (1992 **pre**) | "92PRE: Z5." IWR: R's general level of information | 18.2 / 38.9 / 29.1 / 13.8 | 18 / 38 / 30 / 14 |
| 1992–96 | `V924205` (1992 **pre**, via merge) | same | 16.2 / 30.3 / 34.5 / 18.9 (panel subset) | 20 / 35 / 31* / 14 |
| 2000–02 | `V001033` (2000 **pre**) | "ZZ5. IWR obs: R informed about politics" | 18.7 / 33.0 / 27.1 / 21.2 | 17 / 31 / 31 / 22 |

Ratings are 1 = very high … 5 = very low; groups: Highest = 1, High = 2, Middle = 3,
Lowest = merged {4, 5}.

- In every panel Kalmoe appears to use the **presidential-year pre-election rating**
  (1992, 1992, 2000) — i.e., the rating that feeds VCF0050a in the cumulative file —
  not necessarily the first or second panel wave. For 1990–92 this is the *second* wave;
  for 1992–96 and 2000–02 the *first*.
- Evidence: with this variable the Ideology ID row reproduces exactly in all three panels
  (e.g., 1992–96: .37/.03/.26/.47/.71 vs. printed .37/.03/.26/.48/.71), as does Policy
  Views in 1990–92 and 1992–96. Alternatives tested and rejected: the 1990 rating
  (`V900688`), 1992 post (`V926250`), 1996 pre/post (`V960070`/`V960940`), 2000 post
  (`V001745`), 2002 pre/post (`V023155`/`V025192`), and two-wave averages
  (floor/ceiling) and pmin/pmax combinations — all fit the headers and/or the
  ideology, policy, and partisanship cells clearly worse.
- \*1992–96 header shares: the printed 20/35/31/14 (31 per SI Table E2; main table
  reads 29) matches the 1992 pre rating's distribution in the **full 1992 cross-section**
  (19.7/35.1/30.8/14.5), not the merged panel subset (16/30/35/19). Kalmoe evidently
  reports full-1992-sample shares while computing cells on the panel subset; the *cells*
  clearly follow the 1992 rating (see §4.2). The 2000–02 header (17/31/31/22) similarly
  matches the 2000 pre rating approximately (18.7/33/27.1/21.2 in the panel).
- Cross-check: SI Table E2's 1992–96 "No Follow-up" ideology row (.37/.03/.26/.48/.71,
  N ~ 585) reproduces with our coding (.372/.028/.256/.473/.708, N = 596).

## 3. Constructs (identical coding in both waves of each panel)

All scales −1…+1. Squared Pearson r computed pairwise on respondents with both-wave
values within the panel sample.

### Ideological identification (high = conservative)
7-pt lib–con self-placement; "haven't thought much", DK, and moderate → 0; refusal/NA → missing.

| Wave | Variable | Label |
|------|----------|-------|
| 1990 | `V900406` | R SELF-LIB/CONS SCALE |
| 1992 | `V923509` | 92PRE: G3a. LIB/CON 7PT |
| 1996 | `V960365` | 96PR: R SCALE LIB-CON |
| 2000 | `V000439` + `V000439a` | G1a self placement lib-con scale (FTF / phone) — the 7-pt **scale format**, asked of the random half (form 1, n = 868) of the 2000 sample; the other half got the branching version, which is not the same instrument |
| 2002 | `V023022` | F1. R 7Pt Scale Lib-Con Self-Placement (HTMA code 90) |

Using the scale-format-only 2000 measure reproduces the printed N = 564 exactly.

### Partisanship (high = Republican)
7-pt party ID summary (0 = Strong Dem … 6 = Strong Rep); other/refused (7), apolitical
(8), NA (9) → missing.

| Wave | Variable | Label |
|------|----------|-------|
| 1990 | `V900320` | R'S PARTY ID: SUMMARY |
| 1992 | `V923634` | 92PRE: K1z. PARTY ID |
| 1996 | `V960420` | 96PR: SUMMARY R PARTY ID |
| 2000 | `V000523` | K1x. Party ID summary |
| 2002 | `V023038x` | J1x. Party Identification Summary |

### Policy Views index (high = liberal)
7-pt items; DK (8) **and** "haven't thought much" (0) → scale midpoint (this, rather
than HTMA → missing, reproduces both the printed N ~ 1,359 and the 1990–92 cells);
index = mean of available items.

- **1990–92 — 4 items** (the paper's five minus government health insurance, which the
  1990 study did not carry):
  services/spending (`V900452`/`V923701`), defense (`V900439`/`V923707`),
  guaranteed jobs (`V900446`/`V923718`), aid to blacks (`V900447`/`V923724`).
- **1992–96 — all 5 items**: services/spending (`V923701`/`V960450`), defense
  (`V923707`/`V960463`), government health insurance (`V923716`/`V960479`),
  guaranteed jobs (`V923718`/`V960483`), aid to blacks (`V923724`/`V960487`).
- **2000–02**: none of the five classic scales exists in the 2002 study. See §4.3.

### Egalitarianism (high = egalitarian; 6 items, 5-pt agree–disagree)
DK → missing (≤1% per paper); mean of available items; items reversed so agreement with
pro-egalitarian statements scores high.

| Item | 1990 | 1992 | 1996 |
|------|------|------|------|
| society should ensure equal opportunity (pro) | `V900426` | `V926024` | `V961229` |
| gone too far pushing equal rights (anti) | `V900427` | `V926025` | `V961230` |
| big problem: don't give everyone an equal chance (pro) | `V900428` | `V926029` | `V961231` |
| worry less about equality (anti) | `V900429` | `V926026` | `V961232` |
| not a big problem if some have more chance (anti) | `V900430` | `V926027` | `V961233` |
| fewer problems if people treated more equally (pro) | `V900431` | `V926028` | `V961234` |

(1990: form-split — battery asked of roughly half the panel, hence values N ~ 625.)

### Moral traditionalism (high = traditional; 4 items, 5-pt agree–disagree)

| Item | 1990 | 1992 | 1996 |
|------|------|------|------|
| newer lifestyles → breakdown of society (pro) | `V900500` | `V926118` | `V961247` |
| world changing, should adjust morals (anti) | `V900501` | `V926115` | `V961248` |
| more emphasis on traditional family ties (pro) | `V900502` | `V926117` | `V961249` |
| more tolerant of other moral standards (anti) | `V900503` | `V926116` | `V961250` |

## 4. Results and discrepancies

Full cell-by-cell comparison: `output/repro_panels/comparison.csv`.

### 4.1 1990–92 panel — 23/25 cells exact

All five constructs reproduce exactly except two cells:

- **Egalitarianism, Middle group: .14 reproduced vs. .26 printed.** All four other
  egalitarianism cells are exact (.24/.14/—/.32/.38), as are all MT/policy/ideology
  cells on the same subsample and grouping, so neither the items, the sample, nor the
  grouping can be far off. Systematic checks that did **not** produce .26: DK → midpoint;
  complete-case indices; dropping each of the six item pairs in turn (leave-one-out range
  .10–.17); item-level cross-wave correlations show no mis-paired item. The reproduced
  scale-level r in this group is .37 (r² = .14) vs. an implied printed r of .51. We
  cannot reproduce this cell and flag it as a likely erratum or an undocumented
  idiosyncrasy in the original.
- **Partisanship, Lowest group: .46 vs. .44** (and full-sample N 1,316 vs. printed
  1,334). Recoding apoliticals (code 8) to independents raises N to 1,344 but leaves the
  cell at .46. Direction of the difference is trivial; all other partisanship cells exact.

### 4.2 1992–96 panel — policy/ideology exact, values and one party cell off

- **Policy Views** (5 items): .42/.25/.38/.39/.62 vs. .42/.26/.39/.38/.62 — every cell
  within .01 (the L/M/H deviations are rounding-boundary effects: .2545, .3814, .3866).
- **Ideology ID**: .37/.03/.26/.47/.71 vs. .37/.03/.26/.48/.71 (H = .4735). Also matches
  SI Table E2's "No Follow-up" row.
- **Partisanship**: .60/.48/.57/.66/.57 vs. .59/.49/.58/**.77**/.58. Four cells within
  .01; the **High group is .66 vs. .77** — a genuine, isolated discrepancy (n = 206). No
  tested variant (apolitical → 0; 1996-wave or post-wave knowledge; pmin/pmax averaging)
  moves this cell to .77 without breaking the cells that currently match.
- **Moral traditionalism**: .36/.12/.41/.38/.39 vs. .37/.16/.42/.46/.37. Full, Middle
  within .01. Complete-case indices improve Lowest to .16 (exact) and Full to .37 (exact)
  but leave **High at .38 vs. .46**.
- **Egalitarianism**: .35/.23/.31/.43/.34 vs. .31/.18/.28/.30/.30 — systematically
  higher, worst in the High group (+.13). Variants tested without success: DK → midpoint;
  complete cases; every alternative knowledge wave/combination (which also breaks the
  rows that match). Since the identically-coded egalitarianism index reproduces the
  1990–92 panel almost perfectly, the 1996-wave measure or sample used by Kalmoe likely
  differs in some undocumented way.

### 4.3 2000–02 panel — ideology exact; partisanship close; policy unresolved

- **Ideology ID**: .38/.04/.37/.47/.61 vs. .38/.04/.37/.46/.61, **N = 564 exact** (H
  cell .4673 is a rounding-boundary case). This confirms the 7-pt-scale-format-only
  reading of the 2000 measure.
- **Partisanship**: .72/.59/.68/.77/.76 vs. .71/.56/.69/.77/.76; N = 1,152 vs. 1,165.
  Recoding apoliticals to 0 gives N = 1,162 and leaves cells essentially unchanged
  (Lowest .58 vs. .56). Small residual differences in the Lowest group and N unresolved
  but minor.
- **Policy Views — cannot be reproduced as printed; item set undocumented.** The 2002
  study contains none of the five 7-pt policy scales. The only policy items asked
  identically in both waves are nine federal-spending items (increase / same / decrease /
  cut out entirely): highways, welfare, AIDS research, foreign aid, social security,
  environment, crime, child care, aid to blacks
  (2000 pre `V000675–V000687`; 2002 pre/post combined summaries `V025104x` etc.).
  Coding them ordinally (+1, +1/3, −1/3, −1; DK → 0; high = more spending) with a
  complete-case index reproduces the printed **N almost exactly (1,017 vs. 1,016)** but
  yields **higher stability: .39/.29/.33/.50/.44 vs. printed .27/.19/.22/.30/.30**.
  Alternatives tested, none matching: available-case means; 3-category coding (cut
  merged with decrease); "literal" codebook-order coding in either or both years
  (2000 codes 1/3/5/7 = inc/dec/same/cut taken at face value — full sample then hits .28
  but the knowledge profile is wrong); liberal-content subsets (6 or 7 items, dropping
  highways/crime/foreign aid); 2002-pre-only items; and pairing a classic 5-item 2000
  index with the 2002 spending index (r² = .18). We report the principled
  9-common-item version and flag the row as **not reproduced** — the original item set
  and coding are not documented in the paper or supplement.

## 5. Judgment calls (documented deviations/choices)

1. **Knowledge wave**: presidential-year pre-election interviewer rating in all panels
   (empirically resolved; §2).
2. **Policy HTMA** (code 0) → scale midpoint, like DK. Choosing missing instead lowers
   1990–92 N to ~1,305 (printed ~1,359) and worsens all policy cells.
3. **CPV DK** → missing, index = mean of available items (DK ≤ 1%). Complete-case
   sensitivity noted in §4.2.
4. **Partisanship**: apolitical/other/refused → missing (standard VCF0301-style
   handling); apolitical → 0 tested and reported where relevant.
5. **1990–92 policy index uses 4 items** (no health-insurance scale in 1990). This is
   forced by the data, matches the printed N and all five printed cells.
6. **2000 ideology**: 7-pt scale-format half-sample only (validated by exact N = 564).
7. **2000–02 policy**: 9 common federal-spending items, ordinal coding, complete case
   (validated only by N; values do not match — see §4.3).
