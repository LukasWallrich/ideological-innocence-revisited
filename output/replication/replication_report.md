# Replication with new data — Kalmoe (2020) in ANES 2020 and 2024

*Uses and Abuses of Ideology in Political Psychology*, **Political Psychology** 41(4):771–793,
doi:10.1111/pops.12650. The original used ANES data through 2016. This module asks whether
its conclusions hold in the hyper-polarized 2020s, using ANES 2020 (n=8,280) and 2024
(n=5,521), data unavailable to the author (published Feb 2020).

Two questions: **(a)** has mass ideological coherence / polarity / stability / potency risen
relative to 1984–2016; **(b)** does the enormous knowledge stratification — the basis of the
paper's headline claim that ideology is "meaningful for a knowledgeable minority only" — persist?

Pipeline: single entry point `R/06_replication_anes.R`, run end-to-end from the project root
(`Rscript R/06_replication_anes.R`); tidy outputs in `output/replication/*.rds`; this report.
Construct coding mirrors the reproduction (`output/repro_main/reproduction_report.md`) exactly.

---

## 1. Data and measures — decisions and justifications

### 1.1 Knowledge stratifier: quiz index (forced deviation)
Kalmoe's stratifier — the 5-point interviewer rating of the respondent's political information
(VCF0050a) — was **discontinued**: it is empty for every 2020 and 2024 CDF case. Following the
author's own robustness method (Online Appendix Tables B1–B5; decisions-log D5), knowledge is a
**proportion-correct quiz index**.

- **Primary index = the 4 PRE-election civics items**, scored proportion correct (2020: V201644
  Senate term=6, V201645 spend-least=foreign-aid, V201646 House majority=Democrats, V201647
  Senate majority=Republicans — all correct answers verified against the variable labels; 2024:
  V241612–V241615 analogues). DK / refused / breakoff count as **incorrect** (standard). The
  index takes 5 natural values {0,.25,.5,.75,1}, which serve **directly as the 5 knowledge
  groups** — mirroring Kalmoe's design (5 fixed levels, *not* quantiles) rather than imposing
  cutpoints. This index is universal (asked of everyone), coherent with the pre-election weight
  and with the panel, and needs no arbitrary binning.
- **Achieved group shares** (target from the interviewer rating = 9/20/34/25/13):
  - 2020: **10 / 20 / 28 / 27 / 16** — a close match.
  - 2024: **16 / 26 / 27 / 19 / 11** — shifted lower, because 2024 respondents genuinely scored
    worse on the civics items (mean quiz knowledge 2020 = .55, 2024 = .45; the 2024 foreign-aid
    item was answered correctly by only 27%). This is a substantive fact, reported as-is.
- **Merged voter groups** for the vote models combine the lowest two levels (Lower / Middle /
  High / Highest), as in the original Table 5.
- A **pre+post index** (adding the post-election office-recall battery, proportion of administered
  items) is computed and its share-targeted bins are stored as a sensitivity; it does not change
  the substantive picture and introduces post-interview selection, so pre-only is primary.

**Caveat carried throughout:** Kalmoe's SI shows quiz stratification yields "slightly less
distinct" gradients than the interviewer rating. A flatter 2020/2024 gradient may therefore
partly reflect the measure, not real change. This is flagged against every stratification verdict.

### 1.2 Constructs (identical coding to the reproduction)
All on −1..+1; high = conservative / Republican / policy-liberal / egalitarian / traditional.
Ideology `VCF0803` (HTMA code 9 → 0 with moderates); party `VCF0301`; policy = 5 classic 7-pt
items (`VCF0843/0809/0830/0806/0839`, DK → midpoint); polar half = |score| ≥ 0.5 (inclusive);
indices = mean of available items.

**Reduced value batteries (binding constraint).** In the 2020/2024 cumulative file, egalitarianism
carries **4 of its 6 items** (VCF9013/9018 pro, VCF9016/9017 anti; VCF9014/9015 empty) and moral
traditionalism **2 of its 4** (VCF0853 pro, VCF0852 reverse; VCF0851/0854 empty). Because the 2024
attitudes exist only in the harmonized cumulative file, the same reduced item sets must be used in
both years and in the panel. Fewer items mechanically inflate the "polar half" share and depress
Cronbach's α, so:
- The egalitarianism / moral-traditionalism comparisons are anchored to a **matched-item 1984–2016
  baseline** — the identical 4 egal / 2 MT items recomputed from the reproduction's item columns —
  not to Kalmoe's published full-battery values.
- Reliability leads with **average inter-item covariance** (invariant to item count); α is reported
  but flagged as not comparable across different item counts.

### 1.3 Vote, weights, SEs, mode
- **Two-party vote** from `VCF0704` (Rep=1 [code 2], Dem=0 [code 1], else missing); VCF0704a is
  empty for 2024, so it cannot be used.
- **Weights** (year-specific final raked weights, since the CDF FTF weight VCF0009x is empty for
  2020): Table 1 uses the **pre** weight (2020 V200010a / 2024 V240107a); Table 5 uses the **post**
  weight (V200010b / V240107b). Figure 1, Tables 2 and 4 unweighted (as in the original).
- **Standard errors:** with a single year per model, Table 5 uses **HC1 heteroskedasticity-robust**
  SEs (the original's year-clustering is undefined with one year).
- **Mode:** 2020 is **94% web** (7,782 web / 359 video / 139 phone); 2024 is **~81% web** (4,234
  web + 76 web-panel + 245 web-PAPI, vs 966 FTF). Kalmoe's FTF/phone restriction cannot be applied.
  Opinionation rates are reported **by mode** to expose any web confound (§4).

---

## 2. Headline result

**(a) Yes — mass ideological coherence, polarity, potency and stability have risen sharply**, and
the rise is robust to the item-count confound. **(b) The stratification verdict splits by metric
once the knowledge measure is held constant** (comparing the 2020/2024 quiz index to Kalmoe's own
quiz-stratified 1986–92 tables B1/B5, not only to his interviewer-rated tables): the gradient in
ideological *breadth* was always modest on a quiz and is broadly unchanged, whereas the gradient in
ideological *potency* — how strongly ideology structures the vote — is **sharply reduced, though
not eliminated** (ideology vote-R² Highest÷Lowest 10.5 on the 1988–92 quiz → ~2.5 in 2020 / ~2.0 in
2024; the lowest-knowledge voter group's ideology pseudo-R² rose from .04 to .25). Low-knowledge
citizens now carry real ideological structure, so the paper's "meaningful for a knowledgeable
minority only" framing no longer holds in its strong form.
The already-rising trend the author documented for 2008–16 (SI Tables C1–C5) accelerated.

---

## 3. Cross-sectional analogues (M2), side-by-side with 1984–2016 and 2008–16

### Table 1 analogue — Breadth (% in polar half), full sample and info-gain
Full-sample % polar half. Egal/MT compared to the **matched-item** 1984–2016 baseline (bracketed),
because their published values use more items.

| Construct | 1984–2016 | 2008–16 (C1) | **2020** | **2024** |
|---|---|---|---|---|
| Egalitarianism | 32 *(matched 43)* | 34 | **53** | **47** |
| Moral Tradition | 35 *(matched 49)* | 34 | **50** | **51** |
| Policy Views | 18 | 26 | **32** | **27** |
| Ideology ID | 27 | 32 | **40** | **41** |
| Partisanship | 61 | 58 | **66** | **66** |

Reading: egalitarianism rises even against its matched baseline (43→53/47); **moral traditionalism
is flat once items are held constant** (49→50/51 — its apparent rise is entirely the item-count
artifact); policy, ideology and partisanship rise on unchanged scales. Ideology's polar share
(40–41%) exceeds both the 1984–2016 (27) and 2008–16 (32) values — the ideological poles are more
populated than at any point the author observed.

Info-gain (**Highest ÷ Lowest** breadth ratio), the stratification metric. The measure-matched
column is **quiz** knowledge in 1986–92 (SI Table B1) — the fair benchmark for the 2020/2024 quiz
index, since the interviewer rating produces steeper gradients than a quiz.

| Construct | 1984–2016 (interviewer) | **quiz 1986–92 (B1)** | **quiz 2020** | **quiz 2024** |
|---|---|---|---|---|
| Egalitarianism | 1.65 | 1.24 | **1.28** | **1.33** |
| Moral Tradition | 2.65 | 1.96 | **1.60** | **1.20** |
| Policy Views | 2.64 | 1.31 | **1.71** | **1.39** |
| Ideology ID | 4.00 | 2.29 | **1.90** | **1.53** |
| Partisanship | 1.63 | 1.08 | **1.04** | **1.08** |

Against the interviewer-rated column the breadth gradient looks collapsed, but **most of that is
the measure**: the quiz gradient was already shallow in 1986–92 (ideology 2.29, not 4.00). On the
quiz-matched basis the 2020/2024 breadth gradients are broadly comparable to 1986–92 — flat for
partisanship, up slightly for egalitarianism/policy, down modestly for ideology (2.29→1.90) and
moral traditionalism (1.96→1.20/1.60). **Breadth stratification did not meaningfully collapse; it
was always modest when measured by a quiz.** (Full by-group cells in `table1_breadth.rds`.)

### Table 2 analogue — Reliability, unweighted (full sample)
Average inter-item **covariance** (item-count invariant) is the primary metric; α flagged.

| Construct | metric | matched 1984–2016 | **2020** | **2024** |
|---|---|---|---|---|
| Egalitarianism | cov | .085 | **.162** | **.150** |
| | α | .550 | .754 | .720 |
| Moral Tradition | cov | .076 | **.148** | **.131** |
| | α | .326 | .500 | .455 |
| Policy Views | cov | .08 *(published, 5 items)* | **.176** | **.153** |
| | α | .64 *(published)* | .823 | .789 |

Coherence rises on the invariant covariance metric for all three constructs, holding items constant.
By knowledge, the low-knowledge floor is high: 2020 egalitarianism α runs .70 (Lowest) → .79
(Highest), so even the least knowledgeable reach a reliability the original found only near the top
(`table2_reliability.rds`; the quiz-vs-interviewer measure difference applies to the gradient here too).

### Table 4 analogue — Correlations among constructs (average per construct), unweighted
The C4-style grouping-robust summary (mean of a construct's correlations with the other four):

| Construct | 1984–2016 | 2008–16 (C4) | **2020** | **2024** |
|---|---|---|---|---|
| Egalitarianism | .36 | .37 | **.54** | **.52** |
| Moral Tradition | .31 | .33 | **.53** | **.52** |
| Policy Views | .39 | .40 | **.65** | **.62** |
| Ideology ID | .39 | .42 | **.64** | **.62** |
| Partisanship | .37 | .42 | **.60** | **.59** |

Every construct is ~**+0.20** more inter-correlated than in 1984–2016 — a large jump in ideological
constraint. Correlations are far less item-count-sensitive than α, so the egal/MT rise is credible.
The knowledge gradient persists but the floor rose enormously: e.g. Ideology ID × Party runs
**.59 (Lowest) → .81 (Highest)** in 2020, where the original ran **.06 → .68** — the least
knowledgeable now show the constraint the original found only at the top (all 10 pairs in
`table4_correlations.rds`).

### Table 5 analogue — Presidential-vote probit, weighted, HC1 SEs (pseudo-R²)
Full-sample McFadden pseudo-R²:

| Construct | 1984–2016 | 2008–16 (C5) | **2020** | **2024** |
|---|---|---|---|---|
| Egalitarianism (rev.) | .15 | .20 | **.31** | **.27** |
| Moral Tradition | .13 | .18 | **.29** | **.25** |
| Policy Views (rev.) | .21 | .25 | **.46** | **.37** |
| Ideology ID | .23 | .32 | **.42** | **.40** |
| Partisanship | .49 | .53 | **.59** | **.70** |

Predictiveness rose for every construct. The gradient flattened, and here — unlike breadth — the
**measure-matched quiz benchmark confirms the collapse is real**. Vote-R² Highest÷Lowest ratios:

| Construct | 1984–2016 (interviewer) | **quiz 1988–92 (B5)** | **quiz 2020** | **quiz 2024** |
|---|---|---|---|---|
| Egalitarianism | 5.60 | 1.31 | **1.99** | **2.05** |
| Moral Tradition | 6.50 | 3.40 | **2.91** | **2.05** |
| Policy Views | 4.63 | 8.60 | **2.13** | **2.28** |
| Ideology ID | 10.75 | **10.50** | **2.49** | **1.99** |
| Partisanship | 1.88 | 1.81 | **1.14** | **1.13** |

*Correction note: an earlier version reported the 2020 ratios as Full÷Lowest due to a computation
error in `R/06_replication_anes.R` (e.g. ideology 1.69); the values above are the corrected
Highest÷Lowest from the re-run pipeline, independently verified (`output/verification/verification_report.md`, V1a).
2020/2024 ratios use the merged voter knowledge groups (lowest two combined), which is conservative.*

For **ideology**, the quiz-stratified gradient in 1988–92 was **10.50** — essentially identical to
the interviewer-rated 10.75, with the lowest-knowledge voter group at pseudo-R² **.04**. In 2020 the
same quiz-based ideology gradient is **2.49** (2024: **1.99**), and the lowest-knowledge voter
group's ideology pseudo-R² is **.25 (2020) / .31 (2024)**. Low-knowledge voters, whose ballots
barely tracked their ideology in 1988–92 even on the quiz, now cast substantially ideologically
structured votes. The knowledge stratification of ideological voting is sharply reduced, though not
eliminated — a residual ~2–2.5× gradient remains (full coef/SE/R² in `table5_vote.rds`).

### Figure 1 analogue — distributions and %HTMA
The ideological middle shrank: the **Moderate/HTMA bar fell from ≈49% (original) to 37% (2020) /
35% (2024)**, while the conservative and liberal categories grew. "Haven't thought much about it"
persists on web at **14.6% (2020) / 13.2% (2024)**. Partisanship is more polarized (Strong Democrats
≈24%, Strong Republicans ≈21%; Independents fell to 12% [2020] / 7% [2024]). Full distributions in
`fig1_distributions.rds`.

### Opinionation
The knowledge–opinionation links the original documented **persist**:

| Statistic | 1984–2016 | **2020** | **2024** |
|---|---|---|---|
| Mean knowledge, HTMA vs lib/con identifiers | .36 vs .63 | **.39 vs .60** | **.34 vs .50** |
| Policy DK rate per item | 12–15% | 10–14% | 9–13% |
| % answering all five policy items | 66% | 70% | 70% |
| Mean knowledge, DK-on-3+ vs answered-all-five | .32 vs .63 | **.39 vs .60** | **.35 vs .52** |

HTMA and DK remain markers of low knowledge, and DK rates remain substantial even on the web.

---

## 4. Mode (the web confound)
2020/2024 are predominantly web, with no interviewer to probe DK/HTMA. Reported by mode
(`opinionation.rds`), the confound is **modest**:

- **HTMA rate** is essentially flat across modes (2020: web 14.7%, video 12.5%, phone 15.1%;
  2024: web 12.7%, FTF 15.4%) — the persistence of "haven't thought much" is not a web artifact.
- **Policy DK** is somewhat higher on web (mean DK count 2020: web 0.61 vs video 0.35; 2024: web
  0.55 vs FTF 0.49) — interviewers slightly reduce DK, as expected, but the effect is small.

Mode plausibly nudges opinionation but does not manufacture the large substantive shifts in §3.

---

## 5. Stability (M3, Table 3 analogue)
Squared continuity (test–retest) correlations **2020 → 2024** on the **2,171-case 2016-20-24 panel**
(joined V200001 ↔ 2020 VCF0006 and V240001 ↔ 2024 VCF0006). Unweighted primary; stratified by
2020-wave quiz knowledge (merged lowest two; panel group shares 26 / 28 / 29 / 17). Compared to the
original **1992–96** panel (the same 4-year gap).

| Construct | 1992–96 (orig) | **2020→2024** | Lower | Middle | High | Highest |
|---|---|---|---|---|---|---|
| Egalitarianism | .31 | **.48** | .39 | .48 | .51 | .57 |
| Moral Traditionalism | .37 | **.48** | .34 | .42 | .54 | .64 |
| Policy Views | .42 | **.64** | .47 | .60 | .71 | .78 |
| Ideology ID | .37 | **.64** | .45 | .60 | .71 | .80 |
| Partisanship | .59 | **.78** | .72 | .76 | .80 | .88 |

Stability rose for every construct; **ideological identification nearly doubled (.37 → .64)**.
Weighting by the panel post-weight (V240106b) barely moves it (.45/.44/.57/.58/.73). The reduced
egal/MT item sets add noise that *attenuates* their test–retest correlation, so those two rises are
if anything conservative. The knowledge gradient persists but the floor is high — even the
low-knowledge group's ideology stability (.45) exceeds the original full-sample value (.37).

**Bonus 2016→2020 / 2016→2024 rows are infeasible:** the 1948–2024 SDA cumulative file keys VCF0006
to the native study case id only for 2020/2024; for 2016 VCF0006 is a plain sequential index
(1..5090), not the 2016 time-series case id (300001..407791) carried in V160001_orig, so there is no
crosswalk from the panel's 2016 link to the 2016 attitude rows.

---

## 6. Verdicts (M4)

| Original headline claim | Verdict in 2020/2024 | Key evidence |
|---|---|---|
| **1. Polar, coherent, potent ideology only for the knowledgeable ~20–30%; weak but non-zero for the majority.** | **Replicated with major drift — the qualifier fails.** Ideology is now polar, coherent and potent across the board; the low-knowledge floor rose so far the "minority only" framing no longer fits. | Lowest-knowledge voters' ideology vote-R² .04 → .25/.31 (measure-matched); Ideology×Party corr Lowest group .06 → .59/.55; low-knowledge egalitarianism α floor .50 → .70. |
| **2. Partisanship dominates ideology on every metric.** | **Replicated, but the gap narrowed.** Partisanship still leads on breadth (66%), vote-R² (.59/.70), stability (.78) and correlations, yet ideology closed much of the distance. | Vote-R² party÷ideology 2.1× (.49/.23) → ~1.4× (.59/.42) in 2020; ideology stability .37 → .64 approaches party's .59 → .78. |
| **3. Knowledge stratification is enormous (info-gain 1.6–11×).** | **Splits by metric on the measure-matched (quiz-vs-quiz) test.** *Breadth:* not really reduced — the quiz gradient was already modest in 1986–92 (B1) and is comparable now. *Potency (vote):* sharply reduced, not eliminated. | Breadth H÷L quiz 1986–92 vs 2020: ideo 2.29→1.90, party 1.08→1.04 (little change). Vote-R² H÷L quiz 1988–92 vs 2020: ideology **10.5→2.5** (2024: 2.0), low-knowledge voters' ideology R² .04→.25 — sharp reduction. |
| **4. Values carry the same knowledge-dependent limits as ideology.** | **Replicated structurally.** Egalitarianism and moral traditionalism track ideology ID and policy — all rise, all flatten across knowledge. | Avg correlation egal .36→.54, MT .31→.53, parallel to ideology (average inter-construct correlation .39→.64; pairwise ideology×party .44→.70); matched-item covariance up for both values. |
| **(a) Has mass coherence/polarity/potency/stability risen?** | **Yes — robustly and substantially.** | Correlations +~.20 across all constructs; breadth up (item-matched); vote-R² up; stability up (ideology .37→.64). |
| **(b) Does the knowledge stratification persist?** | **Partly.** Breadth stratification persists (was always modest on a quiz). Potency stratification is sharply reduced on the measure-matched test (a residual ~2–2.5× gradient remains). The strong "knowledgeable minority only" framing fails. | Vote-R² H÷L quiz-matched ideology 10.5→2.5; low-knowledge floors rise to or above the original full-sample values; correlation floors rise (Ideology×Party Lowest .06→.59). |

---

## 7. Limitations
- **Knowledge measure change (addressed via the measure-matched benchmark).** 2020/2024 use a
  4-item quiz; 1984–2016 used the interviewer rating, which yields steeper gradients. Rather than
  leave this as an open confound, the stratification comparison is anchored to Kalmoe's own
  **quiz-stratified** original-era tables (B1 breadth, B5 vote), i.e. quiz-vs-quiz. That test shows
  the breadth-gradient "flattening" is largely the measure (it was already modest in 1986–92), while
  the vote-potency de-stratification is real though partial (ideology quiz H÷L 10.5→~2.5). Residual differences remain (the
  1986–92 quiz used different civics items over a two-election window), so the quiz-vs-quiz match is
  close but not exact. The full-sample *rises* (question a) do not depend on the stratifier.
- **Pooled multi-year vs single-year estimates.** The 1984–2016 and 2008–16 anchors pool many
  elections, whereas 2020 and 2024 are single elections; pooling deflates a pooled pseudo-R² and can
  dilute a pooled correlation, so part of the apparent jump in the (a) metrics is single-vs-pooled
  rather than pure secular change. The 2008–16 column (a 3-election pool including 2016) bounds this:
  the correlation step .42→.60 and the partisanship vote step .53→.59/.70 sit against a
  recent multi-year pool and remain large, so the direction and rough magnitude of (a) hold.
- **Web mode.** No interviewer to probe non-response. §4 shows the effect on HTMA/DK is modest, but
  the mode change coincides with the substantive shifts and cannot be fully separated from them.
- **Reduced value batteries.** Egalitarianism (4/6 items) and moral traditionalism (2/4) are
  measured with fewer items than the original. Handled via item-count-invariant covariance and a
  matched-item 1984–2016 baseline; moral traditionalism's breadth "rise" dissolves under matching,
  while its covariance/correlation rises survive.
- **2024 knowledge distribution** sits below the target shares (bottom group 16% vs 9%) because 2024
  respondents genuinely scored lower; the merged voter groups mitigate this for the vote models.
- **Single-year HC1 SEs** replace year-clustering; all Table-5 predictors remain significant.

## 8. Outputs
`output/replication/`: `knowledge.rds`, `table1_breadth.rds`, `table2_reliability.rds`,
`table4_correlations.rds`, `table5_vote.rds`, `fig1_distributions.rds`, `opinionation.rds`,
`table3_stability.rds`, `comparison_fullsample.rds`, `verdicts.rds`. Deterministic; runs
end-to-end via `Rscript R/06_replication_anes.R` (deps: dplyr, tidyr, psych, sandwich).
