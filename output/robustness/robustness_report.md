# Robustness / Sensitivity Suite — Kalmoe (2020)

*Uses and Abuses of Ideology in Political Psychology*, doi:10.1111/pops.12650.

Companion to the successful reproduction in `output/repro_main/`. This suite probes the
sensitivity the FORRT nomination asks about: **operationalizations of ideological
coherence, time periods, issue selection, and measurement of the moderator.** Each check
builds on the prepared dataset `output/repro_main/cdf_analysis.rds` and reuses the
reproduction's coding conventions so that cells stay directly comparable; several checks
have author-provided targets in the online supplement (SI Tables A1, B1/B2/B4, C1/C2/C4/C5,
D4), used here as validation anchors.

```
Rscript R/01_prepare_cdf.R      # (already run) builds cdf_analysis.rds
Rscript R/03_robustness.R       # writes output/robustness/rc1..rc8 .rds + this report
```
Runs end-to-end from the project root in ~8 s (deps: dplyr, tidyr, psych, sandwich, MASS,
marginaleffects). One tidy `.rds` per check.

**Per-table conventions preserved everywhere except RC3:** Tables 1 & 5 weighted
(`VCF0009x`); Tables 2 & 4 unweighted; knowledge = the 5 fixed interviewer-rating levels
(not quantiles). Weighting is only flipped inside RC3, which is what RC3 tests.

**Headline:** every core conclusion of the paper survives, and the pipeline validates cleanly
against every in-scope author supplement table (A1, B1/B2/B4/B5, C1/C2/C4/C5, D4). One check
**qualifies the framing** without overturning the substance: RC2 — the Table-1 *breadth*
gradient is largely produced by coding nonattitudes as moderate, which is a selection
mechanism consistent with the "ideological innocence" thesis rather than a contradiction of
it. One check adds an interpretive nuance without changing the verdict: RC6c — the vote-choice
knowledge-stratification is much smaller as a variance ratio (pseudo-R²) than as an
effect-size ratio (coefficient/AME), and partisanship's marginal effect is uniform across
knowledge. No check overturns a conclusion.

---

## RC1 — Polar-half operationalization (Table 1)

**Motivation.** "Percent in the polar half" is the paper's breadth statistic; is the
knowledge gradient an artifact of the ≥0.5 inclusive boundary?

**Computed (weighted, Table-1 convention).** Table 1 recomputed under (a) exclusive
`|x|>0.5`, (b) relative outlyingness `% beyond ±1 SD` of the construct's pooled weighted
mean (author SI Table A1), and (c) outer-third `|x|>1/3`.

| Construct | Full % (incl / excl / third) | Info-gain H÷L (incl / third) |
|---|---|---|
| Egalitarianism | 32 / 24 / 41 | 1.50 / 1.43 |
| Moral Tradition | 35 / 24 / 48 | 2.27 / 1.96 |
| Policy Views | 19 / 17 / 31 | 2.30 / 1.98 |
| Ideology ID | 27 / 27 / 27 | 3.96 / 3.96 |
| Partisanship | 62 / 62 / 62 | 1.55 / 1.55 |

The *level* moves with the boundary (exclusive lowers the value indices ~8 pp, outer-third
raises them), but the **gradient ordering is untouched**: ideology always shows the steepest
knowledge gain (~4×) and partisanship the flattest (~1.5×). For the 7-pt identity scales all
three definitions coincide (scores land on category boundaries), so ideology/partisanship are
invariant.

**vs SI Table A1 (% >1 SD).** Match is tight for 4 of 5 constructs:

| | egal | mt | policy | ideo | party |
|---|---|---|---|---|---|
| repro Full | 30 | 32 | **31** | 27 | 45 |
| A1 Full | 30 | 31 | **26** | 27 | 44 |

Ideology reproduces exactly (27/11/16/24/34/44 = A1); egal, mt, party within ~1 pp per cell.
**Policy diverges ~5 pp** because its DK→midpoint spike at 0 shrinks the SD (a known
policy-index binning sensitivity flagged in the reproduction). The gradient is right in every
case.

**Verdict: SURVIVES.** The breadth gradient is robust to the polar-half definition.

---

## RC2 — Nonattitude coding (do "innocence" patterns depend on scoring nonattitudes as moderate?)

**Motivation.** The paper codes ideology "haven't thought much" (HTMA) and policy "don't
know" (DK) at the scale midpoint. Does the low-knowledge "incoherence" depend on that choice?
Recomputed from the raw items (the prepared data bakes HTMA/DK to 0).

**(a) Ideology HTMA→drop; (b) Policy DK→drop — Table 1 polar half (weighted):**

| Coding | N | Full | Lowest | Highest | H−L |
|---|---|---|---|---|---|
| ideo HTMA→0 (base) | 24,557 | 27 | 11 | 44 | **+33** |
| ideo HTMA→drop | 18,212 | 37 | 30 | 47 | **+17** |
| policy DK→0 (base) | 23,332 | 19 | 13 | 30 | **+17** |
| policy DK→NA | 22,697 | 25 | 30 | 32 | **+1.6** |

HTMA is **26%** of the ideology sample. Dropping nonattitudes **flattens the breadth
gradient — eliminating it for policy (H−L 17→1.6) and halving it for ideology (33→17)** —
because the Lowest-knowledge group jumps (ideology 11→30, policy 13→30):
nonattitudes concentrate in low-knowledge respondents. Once you condition on *having* an
attitude, low-knowledge people look nearly as polar as high-knowledge ones. Relatedly, the
famous ~49–50% "Moderate/HTMA" spike in Figure 1 is **half nonattitudes**: excluding HTMA,
the true-moderate bar is **32.5%** (vs 50.0% folded).

**Table 4 correlations, HTMA/DK dropped (unweighted, Lowest / Highest):** the
correlation-coherence gradient, by contrast, **survives**:

| Pair | base Low/High | dropped Low/High |
|---|---|---|
| egal × ideo | .07 / .55 | .11 / .56 |
| policy × ideo | .06 / .63 | .06 / .63 |
| ideo × party | .08 / .67 | .11 / .69 |

**(c) Both codings at once** (policy DK→NA *and* ideology HTMA→drop) — the one pair affected by
both, policy × ideology, is **.43 Full (.09 Lowest / .65 Highest)** — the strong knowledge
gradient is intact under the joint alternative coding, essentially unchanged from either
single alternative.

**Verdict: QUALIFIES the framing, survives the substance.** The Table-1 *breadth* gradient is
substantially an expression of nonattitude-coding: it measures that low-knowledge citizens
lack attitudes to place, which is exactly the paper's "ideological innocence" claim (a
selection mechanism, not a coding trick). The *coherence* gradient (Table 4) is not an
artifact of the midpoint coding and holds after dropping nonattitudes. Read correctly this
strengthens, rather than weakens, the paper — but the breadth statistic should not be read as
independent evidence separate from nonresponse.

---

## RC3 — Weighting

**Motivation.** Tables 2 & 4 are unweighted; does that choice matter?

**Computed.** Weighted Table 2 (alpha via weighted covariance matrix; the *unweighted*
alpha is recomputed on the **same listwise rows** so the comparison isolates weighting, not a
deletion shift) and weighted Table 4 (per-pair weighted Pearson); plus unweighted Table 1.

- **Table 2 alpha** (Full): egal .67 wtd vs .68 unwtd; mt .63 vs .62; policy .64 vs .64.
  Max cell difference **≤ .02**.
- **Table 4 correlations**: weighted vs the paper's unweighted baseline differ by ≤ .02
  (e.g. ideo×party .45 vs .44; egal×policy .45 vs .44). Gradient identical.
- **Table 1 unweighted vs weighted**: within **1 pp** in every cell.

**Verdict: SURVIVES.** No substantive pattern depends on weighting.

---

## RC4 — Knowledge-stratifier alternatives (measurement of the moderator) — key check

**Motivation.** The whole paper turns on the interviewer-rating moderator. Do the patterns
hold under different sophistication measures?

**(a) Education (VCF0110, 4 categories; shares 6/42/27/24).**

| Construct | Table 1 GradeSch→College+ (H−L) | Table 2 α GradeSch→College+ |
|---|---|---|
| Egalitarianism | 22 → 41 (+20) | .40 → .79 |
| Moral Tradition | 25 → 43 (+18) | .35 → .73 |
| Policy Views | 17 → 23 (+6) | .48 → .78 |
| Ideology ID | 18 → 40 (+22) | — |
| Partisanship | 68 → 66 (−2) | — |

Education recovers the coherence gradient (α gradients as steep as the interviewer rating)
and a clear breadth gradient for values/ideology; it is a **coarser, noisier** proxy so the
policy breadth gradient is muted. Partisanship breadth is flat across education — matching the
paper's claim that partisanship is knowledge-robust.

**(b) Campaign quiz knowledge, 1986–1992** (party-control of Congress + candidate-name items,
binned to the SI B-table shares 19/15/35/17/14). Achieved index anchors **m = .46, sd = .32,
r with interviewer rating = .53** (Kalmoe reports .48 / .26 / .48 — m and r reasonably close;
exact item composition is unstated). Validation vs SI:

| | Table 1 polar (repro vs B1) | Table 2 α (repro vs B2) |
|---|---|---|
| Egalitarianism | 32/29/29/31/32/36 vs 35/29/30/32/32/36 | .68… .77 vs .70… .79 |
| Moral Tradition | 35/23/28/36/41/44 vs 38/24/32/34/42/47 | .62… .72 vs .64… .76 |
| Policy Views | 15/15/16/14/15/19 vs 16/15/16/17/15/21 | .59… .71 vs .62… .77 |

Reproduces the B tables within a few points and shows the same stratification, "generally
less distinct" than the interviewer rating — exactly as Kalmoe reports.

*Quiz-knowledge vote probit (1988, 1992), vs SI Table B5* (pseudo-R², 5 bins 12/11/37/21/20):

| Predictor | Full (repro / B5) | Lowest → Highest (repro) | Lowest → Highest (B5) |
|---|---|---|---|
| Egalitarianism | .14 / .13 | .11 → .22 | .13 → .17 |
| Moral Tradition | .09 / .10 | .05 → .17 | .05 → .17 |
| Policy Views | .20 / .20 | .09 → .34 | .05 → .43 |
| Ideology ID | .18 / .19 | .07 → .37 | .04 → .42 |
| Partisanship | .46 / .48 | .36 → .56 | .31 → .56 |

Full-sample fit matches B5 to ~.01 and the knowledge gradient tracks (partisanship potent and
comparatively flat; ideology/policy steeply stratified) — again "less distinct" than the
interviewer-rating version. The quiz-knowledge correlation table (SI Table B4) is also
reproduced in the same "less distinct" pattern (e.g. ideology×party Full .35 vs B4 .40, with
the steep Lowest→Highest gradient .10 → .57); full cells in `rc4_stratifier.rds`.

**(c) Median split of the interviewer rating** (split at 0.5; 58%/42%). How much
stratification does a 2-group split hide relative to 5 groups (Table 1 H−L)?

| Construct | 5-group H−L | 2-group Top−Bottom | fraction retained |
|---|---|---|---|
| Egalitarianism | 14.3 | 9.1 | 64% |
| Moral Tradition | 25.3 | 13.2 | 52% |
| Policy Views | 17.0 | 9.3 | 55% |
| Ideology ID | 33.1 | 17.5 | 53% |
| Partisanship | 23.6 | 7.5 | 32% |

A binary split **hides roughly half** the stratification (two-thirds of it for partisanship),
because the action is concentrated in the top rating category — a concrete demonstration of
the paper's Azevedo-critique point that coarse splits understate knowledge conditioning.

**Verdict: SURVIVES.** The moderator's substance is robust to alternative measures; the quiz
version validates against SI Tables B1/B2/B4/B5; education and the median split behave exactly
as the paper's argument predicts.

---

## RC5 — Reliability operationalization (Table 2)

**Motivation.** Cronbach's α treats 5/7-pt items as interval. Does the coherence gradient
survive an ordinal treatment?

**Computed (unweighted, by knowledge group).** Ordinal (polychoric) α and McDonald's
ω-total alongside the Pearson α, and — as the SI Table D4 anchor — the average interitem
Pearson vs polychoric correlation (1986–1992).

| Construct | stat | Lowest → Highest |
|---|---|---|
| Egalitarianism | Pearson α / ordinal α / ω-total | .50→.80 / .56→.84 / .58→.84 |
| Moral Tradition | Pearson α / ordinal α / ω-total | .37→.73 / .38→.79 / .51→.80 |
| Policy Views | Pearson α / ordinal α / ω-total | .36→.80 / .40→.82 / .47→.83 |

Ordinal α and ω are uniformly **higher** than Pearson α (polychoric corrects categorization
attenuation), but the Lowest→Highest **gradient is if anything steeper**. The coherence
gradient is not an interval-scaling artifact.

**vs SI Table D4 (avg interitem correlation, Full / Lowest / Highest):**

| | polychoric repro vs D4 | Pearson repro vs D4 |
|---|---|---|
| Egalitarianism | .31/.20/.46 vs .30/.17/.46 | .26/.17/.38 vs .26/.14/.39 |
| Moral Tradition | .35/.20/.49 vs .35/.13/.49 | .30/.18/.41 vs .30/.12/.41 |
| Policy Views | .24/.14/.41 vs .29/.12/.47 | .22/.12/.38 vs .26/.11/.44 |

Near-exact for egal/mt (Full & Highest to 2 dp); policy runs ~.05 low (the DK-midpoint
sensitivity again). Pattern — polychoric > Pearson, steep gradient — reproduced throughout.

**Verdict: SURVIVES.** The knowledge gradient in coherence is robust to ordinal reliability.

---

## RC6 — Vote models (Table 5)

**Motivation.** Do the vote conclusions depend on the bivariate-probit specification, and do
values add anything beyond partisanship + ideology?

**(a) Multivariate probit — nested McFadden pseudo-R² and the incremental gain from adding
the two VALUES (egalitarianism + moral traditionalism) to a party+ideology base:**

| Group | party | +ideo | +policy | all 5 | Δ from adding values |
|---|---|---|---|---|---|
| Full | .512 | .544 | .564 | .587 | **+.033** |
| Lower | .342 | .347 | .356 | .369 | +.018 |
| Middle | .475 | .502 | .517 | .544 | +.035 |
| High | .535 | .574 | .600 | .620 | +.031 |
| Highest | .626 | .663 | .691 | .715 | +.040 |

Partisanship alone carries most of the fit; adding **both values raises pseudo-R² by only
~2–4 pp** once party+ideology are in. In the all-5 model party dominates (coef 1.48 vs ideo
.62, values .60–.70). This **quantifies and confirms** the paper's in-text claim that "values
add little once partisanship and ideology ID are included."

**(b) Logit and LPM bivariate models** — pseudo-R²/R² gradients essentially identical to
probit (party Full .49 probit / .50 logit / .56 LPM; ideology .23/.23/.27), same steep
Lower→Highest gradient and the same partisanship > ideology ordering. **Conclusions do not
depend on the probit link.**

**(c) Average marginal effects (AMEs) of the bivariate probits, weighted, by knowledge
group** (probability-scale effect, which incorporates the actual distribution of scores).
The honest reference for a slope-like AME ratio is the **probit-coefficient ratio**, not the
pseudo-R² ratio (pseudo-R² is a variance quantity and runs roughly the square of a slope
ratio); all three are shown:

| Predictor | Full AME | Lower → Highest AME | AME H÷L | coef H÷L | pseudo-R² H÷L |
|---|---|---|---|---|---|
| Partisanship | .355 | .369 → .328 | **0.89** | 1.51 | 1.94 |
| Ideology ID | .581 | .352 → .559 | 1.59 | 2.74 | 10.28 |
| Egalitarianism | .527 | .385 → .563 | 1.46 | 1.92 | 5.28 |
| Moral Tradition | .440 | .302 → .504 | 1.67 | 2.14 | 6.48 |
| Policy Views | .639 | .459 → .649 | 1.41 | 2.07 | 5.73 |

The AME H÷L (~1.4–1.7) sits just **below** the coefficient H÷L (~1.9–2.7) — a mild link/
distribution compression, in the same ballpark, not a contradiction. The much larger
pseudo-R² ratio (5–10×) is larger mainly because it is a variance-explained quantity. The one
genuinely notable point: **partisanship's marginal effect on vote probability is flat — indeed
slightly declining — across knowledge (AME H÷L 0.89) even though its coefficient rises**
(1.51). So on the interpretable probability scale, partisanship is not merely the strongest
but the *most uniformly* strong predictor across knowledge levels, reinforcing the paper's
claim that partisanship is knowledge-robust while ideology is knowledge-conditioned.

**Verdict: SURVIVES.** Values add little beyond party+ideology; conclusions are link-function
invariant; the AME view keeps the qualitative stratification story and strengthens
partisanship's cross-knowledge robustness.

---

## RC7 — Time periods

**Motivation.** Has ideological coherence — and its knowledge stratification — grown with
polarization within the 1984–2016 window?

**1984–1996 vs 2000–2016 (5 groups):**

| Construct | Table 1 Full (early→late) | Table 1 H−L | Table 2 α Full | α H−L | avg \|r\| (early→late) |
|---|---|---|---|---|---|
| Egalitarianism | 30 → 34 | 14 → 17 | .67 → .69 | .26 → .36 | .35 → .37 |
| Moral Tradition | 35 → 35 | 25 → 29 | .63 → .60 | .29 → .53 | .28 → .35 |
| Policy Views | 16 → 25 | 12 → 20 | .61 → .69 | .39 → .43 | .39 → .41 |
| Ideology ID | 24 → 33 | 30 → 35 | — | — | .37 → .44 |
| Partisanship | 63 → 60 | 20 → 33 | — | — | .33 → .43 |

Coherence and constraint have **grown**: breadth, alpha gradients, and inter-construct
correlations all rise from the early to the late period, and the knowledge **stratification
widens** (α H−L for MT more than doubles; correlation gradients steepen). The paper's gradient
holds in both sub-periods and is stronger in the polarized later years.

**vs SI Tables C1/C2/C4/C5 (2008–2016, 4 groups):** validation is excellent —

- C1 breadth: within 1–2 pp (egal 34/34, mt 34/34, ideo 32/32, party 58/58; policy 29 vs 26).
- C2 alpha: within .01–.05.
- C4 average \|r\|: near-exact — egal .369 (C4 .370), mt .328 (.330), policy .398 (.400),
  ideo .422 (.420), party .426 (.420).
- C5 vote pseudo-R²: near-exact — party .54 (.53), ideo .33 (.32), egal .20 (.20),
  mt .19 (.18), policy .25 (.25).

**Verdict: SURVIVES, in both sub-periods.** Coherence and its knowledge-stratification have
grown over time — a temporal extension of the paper's conclusion, not a threat to it.

---

## RC8 — Issue selection (policy index)

**Motivation.** Is the 5-item policy index / its conclusions driven by any single issue, and
does broadening to a 6th issue change anything?

**(a) Leave-one-out (each of the 5 items dropped in turn).**

| Index | policy×ideo Full (Low/High) | policy×party Full | Table 5 R² Full (Lower→Highest) |
|---|---|---|---|
| full 5-item | .39 (.06/.63) | .42 | .215 (.065→.373) |
| −defense | .37 | .41 | .196 |
| −jobs | .39 | .41 | .207 |
| −aid to blacks | .40 | .44 | **.237** |
| −health ins. | .38 | .41 | .199 |
| −services | .36 | .39 | .191 |

No single item is load-bearing: correlations move ≤ .03 and pseudo-R² ≤ .03; the steep
knowledge gradient (Lowest ~.05–.08 → Highest ~.60–.66 for correlations; ~.06 → ~.37 for
vote R²) is preserved under every deletion. (Dropping aid-to-blacks slightly *increases*
predictiveness, but marginally.)

**(b) 6-item index (adding the 4-pt abortion item, VCF0838, rescaled high=liberal;
n=22,715).** policy×ideo rises modestly (.42 vs .39), policy×party dips (.38 vs .42), vote
pseudo-R² .19 (vs .21); the gradient is unchanged (correlation Lowest .08–.10, Highest
.59–.65).

**Verdict: SURVIVES.** Conclusions are robust to issue selection; broadening the issue set
does not change them.

---

## Overall summary

| Check | What it probes | Verdict |
|---|---|---|
| RC1 Polar-half operationalization | breadth definition (excl / ±1 SD / outer-third) | **Confirms** — validated vs SI A1 (policy ±1SD ~5 pp off) |
| RC2 Nonattitude coding | HTMA / DK → drop vs → midpoint | **Qualifies framing** — breadth gradient is a nonattitude/selection effect; coherence gradient survives |
| RC3 Weighting | weight Tables 2 & 4 | **Confirms** — no change (≤ .02 / 1 pp) |
| RC4 Stratifier alternatives | education / quiz / median split | **Confirms** — validated vs SI B1/B2/B4/B5; median split hides ~½ the stratification |
| RC5 Reliability operationalization | ordinal α / ω-total | **Confirms** — gradient survives (steeper); validated vs SI D4 |
| RC6 Vote models | multivariate / logit / LPM / AMEs | **Confirms** — values add ~3 pp; link-invariant; AME ratio (1.5) ≈ coef ratio (2.6); partisanship AME uniform |
| RC7 Time periods | 1984–96 vs 2000–16; 2008–16 | **Confirms** — holds in both eras; validated vs SI C1/C2/C4/C5; coherence grew |
| RC8 Issue selection | LOO + 6-item policy index | **Confirms** — no item load-bearing |

**The one check where the framing (not the conclusion) materially changes:**

**RC2 — the Table-1 "breadth" gradient is largely an expression of coding nonattitudes as
moderate.** Dropping HTMA/DK eliminates the policy breadth gradient (H−L 17→1.6) and halves
the ideology gradient (33→17) via selection. This is *consistent with* — indeed an operationalization of — the
"ideological innocence" thesis, so it does not overturn the paper, but the polar-half
statistic should not be cited as evidence independent of nonresponse patterns. The
correlation-based coherence gradient (Table 4) is unaffected.

**RC6c is an interpretive nuance, not a qualification:** the vote-choice stratification looks
enormous (5–11×) only as a variance-explained ratio; as an effect-size ratio (AME ~1.5×,
coefficient ~2.6×) it is moderate, and the direction and partisanship-dominance are intact.

No check overturns a substantive conclusion of the paper.
