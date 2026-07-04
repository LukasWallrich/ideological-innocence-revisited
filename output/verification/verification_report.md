# Adversarial Verification Report — Kalmoe (2020) reproduction + replication

Reviewer: independent verification pass. Goal: try to break the five pipelines before
their numbers enter the manuscript. All checks below were recomputed **independently**
(hand-rolled coders, raw data loaded directly — not by re-running the original functions),
except where noted. Scratch scripts: `output/verification/v_*.R`.

Bottom line: the substantive numbers are **overwhelmingly confirmed**. One real defect (a
mislabeled/miscomputed ratio in the replication's vote-stratification headline) needs
correction before the manuscript; two labeling risks need careful wording; everything else
is safe.

---

## V1 — Replication headline claims (highest stakes). Verdict: CONFIRMED with 1 BUG + 2 labeling risks.

Scratch: `output/verification/v_replication.R` (independent recompute of every headline number).

### V1(a) Vote-potency stratification "collapse"

**B5 transcription — CONFIRMED.** Read directly from `paper/kalmoe2020_online_supplement.txt`
(Table B5, lines 579–758). Ideology quiz block: Full pseudo-R² **.19**, Lowest **.04**,
Highest **.42**, Highest÷Lowest **10.50**. Policy 8.60, Moral Trad 3.40, Egal 1.31,
Partisanship 1.81. Every value in the script's `vote_R2_HdivL_quiz8892 = c(1.31,3.40,8.60,10.50,1.81)`
and the `.04` lowest-group figure is correctly transcribed. The comparison base (1988+1992
pooled, quiz-binned) is the fair measure-matched benchmark.

**Quiz index construction — CONFIRMED.** Answer keys verified against the 2024 codebook and
2020 data distributions:
- 2020 pre: V201644==6 (Senate term), V201645==1 (foreign aid), V201646==1 (House=Democrats,
  correct pre-2020), V201647==2 (Senate=Republicans, correct pre-2020). All correct.
- 2024 pre: V241612==6, V241613==1 (foreign aid), V241614==2 (House=Republicans, correct
  pre-2024), V241615==1 (Senate=Democrats, correct pre-2024). All correct — and correctly
  *reversed* from 2020 to match the real chamber control, a good sign the keys were checked.
- DK/refused/breakoff counted incorrect; administered = not {-6,-7}. Sensible.
- Achieved group shares recomputed: 2020 **9.6/19.5/28.1/26.8/16.0**, 2024 **16.5/26.2/27.4/19.3/10.6**,
  mean knowledge 2020 **.55** / 2024 **.45** — all match the report.

**2020 lowest-group ideology vote pseudo-R² — CONFIRMED at .25.** Independent recompute:
merged-Lower (4-group) = **.247** (N=1477); unmerged-Lowest (5-group) = **.234** (N=467).
Either way ".04→.25" holds. Full=.418, Highest=.616 — match the rds.

**⚠ BUG (MEDIUM severity) — the "10.5 → 1.7" ratio is wrong on two counts.**
- File `R/06_replication_anes.R` line **295**: `H_div_L_R2 = c(NA, NA, rf$r2/rg$Lower$r2)`.
  `rf` is the **full-sample** fit (line 284), so this column is **Full ÷ Lower**, not
  Highest ÷ Lowest. For 2020 ideology it yields .4175/.2468 = **1.69** — the "1.7" in the
  report. This value is baked into `table5_vote.rds` and flows into report §3 (line 189),
  which explicitly labels the column "Vote-R² **Highest÷Lowest** ratios" (line 182) and into
  verdict 3 ("ideology 10.5→1.7", line 267).
- The genuine, measure-matched **Highest÷Lowest** for 2020 ideology is **2.63** (5-group,
  same definition as B5's 10.50) or **2.49** (4-group merged). So the correct statement is
  **10.5 → 2.6**, not 10.5 → 1.7. All five constructs' "2020 quiz" ratios in that table are
  Full÷Lower and share the defect (egal 1.33, MT 1.75, policy 1.46, party 1.04).
- **Impact:** the *direction* survives, but the strength must be restated. The lowest-group
  *level* .04→.25 is clean and independent of this ratio; the ratio itself falls 10.5→**2.6**,
  a sharp reduction but **not** an elimination — a residual ~2.6× gradient remains. (For
  internal consistency: this same 2.6 is *larger* than the ideology breadth ratio 1.55 that
  V4/RC2 correctly says "does not vanish," so "collapsed / no longer holds" over-reads it.)
  **Recommendation:** lead on the level — "ideological voting is no longer confined to the
  knowledgeable: the low-knowledge floor rose from negligible (.04) to substantial (.23-.25),
  compressing the gap from 10.5× to ~2.6×" — and describe the stratification as **sharply
  reduced but not eliminated**, not collapsed. Do not quote 1.7.
- Secondary asymmetry (even after the fix): B5's 10.50 is an *unmerged 5-group* Highest÷Lowest,
  while the 2020 vote model merges the lowest two groups. Using the 5-group 2020 number (2.63)
  removes this; flag it if the merged number is quoted.

### V1(b) Coherence rise

**Pairwise ideology×party — CONFIRMED.** Independent recompute (signed, no abs): 2020 Full
**+.700**, Lowest **+.585**, Highest **+.812**; 2024 Full +.709, Lowest +.656. The lowest-group
value is genuinely positive — `abs(cor())` (R/06 line 252) did **not** manufacture the floor
by flipping a negative. Original Table 4 pairwise ideology×party = .44. So the pairwise story
is **.44 → .70**, lowest **.06 → .59** — the report's "lowest .06→.59" is correct.

**⚠ LABELING RISK (MEDIUM).** The report's headline "coherence rose: ideology×party **.39→.64**"
is **not** the pairwise ideology×party correlation. .39→.64 is the **average of ideology's
correlations with the other four constructs** (`avgcorr_2020["Ideology ID"] = .639`, vs
`avgcorr_8416 = .39`). The report's §3 Table-4 analogue *correctly* labels this as "average per
construct," but the one-line headline and the task brief call it "ideology×party," which
mislabels the average as a pairwise correlation. **Recommendation:** in the manuscript either
say "ideology's average inter-construct correlation rose .39→.64" (average) **or** "the
ideology×party correlation rose .44→.70" (pairwise) — do not attach .39→.64 to "ideology×party."

### V1(c) Stability 2020→2024 — CONFIRMED.

Panel join verified independently: `panel$V200001` (2020 id) and `V240001` (2024 id) match the
CDF `VCF0006` at a **100% rate** (2171/2171 both waves); VCF0006 is **unique within** 2020 and
within 2024, so `match()` cannot silently mis-join. Party stability .78 is sane, corroborating
that VCF0006 = native case id for these years. Independent recompute: ideology full r²=**.642**,
by 2020-knowledge group **.45/.60/.71/.80** (N 564/613/627/361); party .78; egal .48, mt .48,
policy .64 — all match the report and rds exactly. Panel group shares 26/28/29/17 confirmed.
The report honestly caveats the 2016-20-24 two-wave attrition/selection (note: the original
1992-96 comparison is also a panel, partly offsetting this).

### V1(d) Construct-coding consistency (2020/24 vs 1984-2016) — CONFIRMED.

Diffed the coders across `R/01`, `R/02`, and R/06's `matched_baseline`:
- Egalitarianism: R/06 uses the 4 items present in 2020/24 (VCF9013/9018 pro, VCF9016/9017
  anti). R/01 codes those same four with identical directions (its full battery adds
  VCF9015 pro / VCF9014 anti). The matched-item 1984-2016 baseline uses exactly the 4-item
  subset → egal breadth **43**, cov **.085**; 2020 = 53 / .162. Item-fair.
- Moral traditionalism: R/06 uses VCF0853(+1)/VCF0852(−1); R/01's full battery is
  VCF0851/0853 pro, VCF0852/0854 rev — same directions. Matched baseline (2 items) → breadth
  49, cov .076; 2020 = 50/51, .148. The MT breadth "rise" **dissolves** under item-matching
  (49→50/51), exactly as the report states; the covariance rise survives.
- sc5/pol7/HTMA(9→0)/policyDK(9→midpoint)/year≥1984/mode∈0:3 identical across scripts.
- `matched_baseline` restricts to FTF/phone (VCF0017∈0:3) and 1984+, mirroring the reproduction.
No silent divergence that could manufacture the rise. The reduced-battery confound is handled
correctly (covariance-led + matched baseline).

**2024 two-party vote (VCF0704):** raw 2020 {Dem=1: 3537, Rep=2: 2582}; 2024 {Dem=1: 2201,
Rep=2: 1747}. Rep=2→1, Dem=1→0 correct; VCF0704a genuinely empty for 2024 as documented.

---

## V2 — Reproduction scripts (R/01, R/02). Verdict: CONFIRMED (faithful).

Scratch: `output/verification/v_reproduction.R`.

- **haven_labelled "silent killer" — NOT present.** timeseries_cum columns are `haven_labelled`
  (VCF0009x plain numeric); `as.numeric()` returns the **underlying codes**, not factor levels.
  Verified on VCF0803/0301/0050a/9013/0704a/0017. (Note: newer-vintage `.rda` files —
  timeseries_2020 — DO require `unclass()` first, and R/06 handles that with its `num()`; plain
  `as.numeric` *errors* there rather than corrupting, so no silent damage anywhere.)
- **Spot-recompute (independent, from raw rda):**
  - Table 1 partisanship Full (weighted) = **61.9** (target repro 62 / paper 61). ✓
  - Table 2 egalitarianism α Full (6 items) = **.675** (target .68); cov .102 (target .10). ✓
  - Table 4 ideology×party Full = **.442** (target .44); Lowest .078, Highest .672. ✓
- **comparison.csv audit:** 176 table cells; Table1 max|diff| 2.9pp (the 4 Lowest-stratum
  cells: egal +2.7, mt +2.9, policy +2.0, party +2.2 — the documented small/noisy-group gaps),
  Table2 max .015, Table4 max .018, Table5 max coef .117. Matches the report's 154/17/5 banding
  and its honest §5 discrepancy list (knowledge shares 6/18/34/26/15 vs paper 9/20/34/25/13;
  party×vote .76 vs .68 resolved by leaner-fold to .69; voter-vs-fullsample polar shares).
- **Item polarity / DK rules** verified: policy DK→midpoint confirmed independently by Table 2
  (α .641 with midpoint vs .668 with DK→NA); egal reverse trio and policy directions correct.

---

## V5 — Cross-cutting checks.

- **(a) Report-vs-rds transcription (replication):** every spot-checked number in
  `replication_report.md` matches its `.rds` exactly — opinionation (HTMA .387/.601, DK3+
  .390/.602, %all5 .696, by-mode web/video/phone .147/.125/.151), Figure-1 %HTMA 14.6/13.2 and
  moderate bar 36.6/35, stability full and by-group, weighted stability .45/.44/.57/.58/.73.
  Reproduction report matches its comparison.csv. **No report-vs-output mismatches found** other
  than the H_div_L_R2 label issue (V1a), which is an output *definition* problem, not a
  transcription error.
- **(b) Determinism / regeneration:** re-ran every pipeline end-to-end from the project root
  and md5-compared before/after. **All byte-identical:** R/06 (10 replication rds), R/01→R/02
  (8 repro_main rds incl. cdf_analysis.rds), R/04 (panels), R/03 (robustness), R/05 (GSS) all
  regenerate exactly and exit 0. Fully reproducible.
- **(c) D6 (Table 1 N transposition):** independent construct Ns — Ideology **24,653**, Party
  **25,536** (party > ideology). Paper prints Ideology 25,332 > Party 24,307 (party smaller). The
  crosswise match (paper-ideology↔our-party within 0.8%; paper-party↔our-ideology within 1.4%)
  is far tighter than the printed assignment, and party ID has near-zero item nonresponse while
  the ideology item loses more non-placers — so party *should* carry the larger N. **The
  transposition inference is sound.** Correctly flagged as an erratum candidate, not silently
  "corrected."

---

## V3 — Panels (R/04). Verdict: CONFIRMED (script correct; paper-gaps are honest irreproducibilities).

Scratch: `output/verification/v_panels.R` (independent, hand-rolled coders).

- **1992-96 merge — CONFIRMED clean.** Link is `V960009` (1992 case id for panel cases) →
  `V923004` (92-pre case id). `V923004` has **0 duplicate keys**, **597/597** link>0 cases
  match, **0** many-to-one collisions; matched N per construct sane (ideology 596, party 585,
  egal 543). No mismatched/duplicate joins.
- **Spot-recompute (independent):** 1992-96 ideology full r² **.372** (target .37), party
  **.595** (.59); ideology by group .03/.26/.48/.71 — all reproduce. 1990-92 ideology **.287**
  (.29), party **.614** (.61). 2000-02 ideology **N=564 exact**, r² **.385** (.38).
- **2000-02 half-sample — CONFIRMED genuine split-ballot**, not accidental loss: only the
  7-pt scale-format instrument (V000439/V000439a) is used; the other random half got the
  branching version. Partisanship (asked of everyone) retains 1152. Filter applied correctly.
- **Report↔rds — zero mismatches** (~50 cells across three panels checked); pipeline re-runs
  clean (`Rscript R/04_panels.R`, exit 0).
- **DOC ERROR (cosmetic):** `notes/decisions_log.md` D3 line 36 names `V960005` as the 1992
  link, but V960005 is the 96-pre time-series *weight*. The script correctly uses V960009;
  only the log is wrong. Fix the log, not the script.
- **Paper-vs-repro gaps (correctly flagged in the report, NOT script bugs — hand-recompute
  equals the rds):** 1992-96 egalitarianism runs high in all cells (Full .348 vs paper .31);
  **2000-02 Policy Views runs uniformly +.12 to +.20 high** because it is a reconstructed
  9-item spending proxy, not the paper's (undocumented) item set. **Consumer caveat for the
  manuscript:** treat the 2000-02 Policy row as an approximation, not a validated reproduction.

## V4 — Robustness (R/03) & GSS (R/05). Verdict: CONFIRMED (all flagged findings exact).

Scratch: `output/verification/v_robustness.R`, `output/verification/v_gss.R`.

- **RC2 (drop HTMA/DK) — CONFIRMED, one wording flag.** Independent recompute matches the rds
  to the decimal: ideology polar-half H÷L **3.96 → 1.55** when HTMA→NA (vs →0 baseline);
  policy **2.30 → 1.05** when DK→NA. HTMA share 25.9%. **Wording flag:** "collapse" is accurate
  for *policy* (→1.05, flat) but over-reads *ideology*, where a substantial +16.8pp / 1.55×
  gradient survives (a halving, not a collapse). Manuscript should not imply the ideology
  breadth gradient vanishes.
- **RC6c (AME vs coef ratio) — CONFIRMED.** Independent AMEs (`marginaleffects`): ideology AME
  H÷L **1.59** vs coef **2.74**; egal 1.46/1.92, mt 1.67/2.14, policy 1.41/2.07, party 0.89/1.51.
  The AME-vs-coefficient gap ("~1.4-1.7 vs ~1.9-2.7") is real; partisanship's AME ratio 0.89
  (flat on the probability scale) reproduces.
- **GSS ideology×party by WORDSUM — CONFIRMED (fully independent).** POLVIEWS×PARTYID recomputed
  from raw `gss_subset.csv`: Lowest **.095 → Highest .713**, Full .438 (rds/report .10→.71).
  Robust to the DK rule (DK→NA gives .098→.714; GSS DK only 3.4%). **Note for manuscript:**
  this **pools 20 survey years (1984-2024)**, mixing cross-sectional with cohort/period
  variation — worth stating.
- **Other RC / GSS numbers vs rds — all confirmed** (RC1 info-gain, RC4 quiz anchors, RC6a
  multivariate R², RC7/RC8, GSS reliability/probit/DK). No report-vs-rds mismatches. Both
  pipelines re-run clean (`Rscript R/03_robustness.R`, `R/05_gss.R`, exit 0).

---

## VERDICT TABLE — manuscript-bound claims

| Claim | Status | Note |
|---|---|---|
| Reproduction of Tables 1,2,4,5, Fig 1, footnote 5, in-text (R/01,02) | **SAFE** | Independently confirmed; honest about the ~2-3pp Lowest-cell gaps and the leaner-fold party×vote issue |
| D6 Table-1 N transposition (erratum candidate) | **SAFE** | Logic verified; flag, don't correct |
| Replication (a): coherence/polarity/potency/stability rose 2020/24 | **SAFE (direction & rough magnitude)** | All full-sample rises independently reproduced; caveat single-vs-pooled year & web mode as the report does |
| "ideology×party rose .39→.64" | **NEEDS RELABEL** | .39→.64 is the *average* inter-construct corr; pairwise ideology×party is **.44→.70**. Pick one framing. |
| Coherence floor rose (lowest-group ideology×party .06→.59) | **SAFE** | Genuinely positive, not an abs() artifact |
| Vote-potency stratification "collapsed 10.5→1.7", lowest .04→.25 | **NEEDS CORRECTION + WORDING** | ".04→.25" level is SAFE. Ratio is Full÷Lower, mislabeled Highest÷Lowest; true measure-matched value is **10.5→2.6** — a **sharp reduction, not a collapse** (2.6× residual > the 1.55× RC2 calls "surviving"). Lead on the level; do not quote 1.7 or "collapsed/no longer holds." |
| Ideology stability .37→.64; panel join | **SAFE** | Join is 100% clean; r² reproduced exactly |
| Partisanship still dominates but gap narrowed (party÷ideology vote-R² 2.1×→1.4×) | **SAFE** | .49/.23→.587/.418 = 2.13→1.40 reproduced |
| Table 3 stability reproduction (1990-92, 1992-96) | **SAFE** | Merge clean; ideology/party reproduce; report honest about paper-gaps |
| Table 3 **2000-02 Policy Views** row | **SAFE WITH CAVEAT** | Reconstructed 9-item proxy, runs +.12-.20 high vs paper; treat as approximation, not validated reproduction |
| RC2: dropping HTMA/DK collapses the breadth gradient | **NEEDS WORDING FIX** | True for **policy** (2.30→1.05); for **ideology** it halves (3.96→1.55), does not vanish |
| RC6c: AME ratios (1.4-1.7) below coefficient ratios (1.9-2.7) | **SAFE** | Independently reproduced |
| GSS ideology×party .10→.71 by WORDSUM | **SAFE** | Fully independent recompute; state it pools 1984-2024 |
| decisions_log D3 "1992 link = V960005" | **DOC ERROR** | Actual link is V960009; V960005 is a weight. Script is correct; fix the log |
