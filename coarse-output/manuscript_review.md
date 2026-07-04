# Ideological Innocence, Revisited

**Date**: 07/03/2026
**Domain**: social_sciences/political_science
**Taxonomy**: academic/research_paper
**Filter**: Active comments

---

## Overall Feedback

Here are some overall reactions to the document.

**Outline**

This paper undertakes a computational reproduction, robustness analysis, and new-data replication of Kalmoe (2020), which argued that polar, coherent, stable, and electorally potent ideology characterizes only the most politically knowledgeable Americans. The reproduction is careful and largely successful. The replication extends the analysis to ANES 2020/2024 data and a GSS cross-dataset test, finding that all ideological metrics rose sharply while knowledge stratification persisted in compressed form. The paper is transparent, well-structured, and adds genuine value. However, several interpretive and methodological concerns bear on its headline claims — particularly whether the observed rise in ideological metrics reflects genuine ideological constraint or partisan identity sorting, and whether the temporal comparisons are confounded by instrument, mode, and population changes that the paper does not fully adjudicate.

The paper makes a real contribution by computationally reproducing Kalmoe (2020) from scratch — with no original code package — and honestly reporting both the close agreement and the handful of anomalies. The robustness suite is well-motivated and the GSS cross-dataset test is a welcome addition. The two-sided framing (time-bound portrait, persistent mechanism) is fair-minded and rare in replication work, which too often reads as prosecutorial or exonerative. These are genuine strengths.

**Rising ideological metrics may reflect partisan sorting, not genuine constraint — and the paper lacks the analysis to tell them apart**

The paper's headline — that the 'innocence portrait is time-bound' — rests on showing that mass ideological coherence, polarity, stability, and vote potency all rose. But the very framework the paper replicates (Kinder & Kalmoe 2017; Kalmoe 2020) warns that measured 'ideology' in mass publics often amounts to party identity in ideological clothing. If rising ideology×party correlations (.44→.70) and rising ideology vote-R² reflect citizens adopting ideological labels that track their party rather than developing genuine belief-system constraint, the innocence thesis could be fully intact — only the measurement drifted. The paper concedes the partisan-sorting literature (Levendusky 2009; Mason 2018) but doesn't engage with its implications for the replication's interpretation. Every metric driving the headline (breadth, bivariate vote-R², pairwise correlations, stability) is bivariate, and bivariate ideology potency is exactly what sorting inflates. The discriminating test would be to report ideology's vote pseudo-R² (or AME) controlling for party identification, by era, and show whether that incremental contribution rose. RC6a reports a multivariate model only for the original era and only in a narrow form; the 2020/2024 replication tables show no party-controlled ideology vote models. Without this, the paper cannot distinguish 'Americans became more ideological' from 'Americans became better sorted.' Add a table of ideology's incremental vote contribution (pseudo-R² or AME beyond party) by knowledge group for 2020 and 2024, compare it to the original-era analogue from RC6a, and revise the discussion accordingly.

**The anchor-based reproduction strategy is partly circular, and the paper does not separate anchoring cells from validation cells**

The method (§2.2–2.4) adjudicates every unstated coding choice by selecting the specification that best matches the published numbers: variable choice, weighting scheme, polar-half boundary, DK coding, and more were all fixed by fitting to the original tables. The paper argues this 'is not tuning; the anchors identify the author's actual choices,' but this means cells used to fix coding decisions cannot also serve as evidence of reproduction fidelity. The 154-of-176 tight-match rate conflates cells that anchored choices with cells that genuinely validate them. The paper occasionally distinguishes these (e.g., noting that DK-to-midpoint coding was 'independently confirmed by Table 2 reliability, not just Table 1'), but does not do so systematically. This matters for the paper's central claim that the reproduction is 'faithful.' Clearly partition the 176 cross-sectional cells into (a) those used to anchor or adjudicate coding choices and (b) those that serve as independent confirmation, and report the fidelity rate separately for each set. This will let readers assess how much of the agreement is mechanical and how much is genuinely informative.

**The knowledge moderator changed in ways that go beyond the quiz-vs-quiz benchmark**

The replication switches from an interviewer rating (original) to a four-item civics quiz (2020/2024), using the author's own quiz-stratified supplement tables (B1–B5, from 1988–92) as the benchmark. This is the right instinct, but the benchmark is over 30 years old. Educational attainment rose substantially between 1992 and 2024, the information environment transformed, and a respondent scoring 0/4 on a civics quiz in 2024 is likely a different kind of person from one scoring 0/4 in 1988 — the 'low-knowledge' stratum may have emptied of moderately informed citizens who now score higher, leaving a harder-to-reach residual. The paper treats the quiz groups as fixed population strata, but if their composition shifted, the apparent rise in low-knowledge ideological coherence could partly reflect a selection effect within the strata themselves. Report the distribution of quiz scores across 2020 and 2024 (and if available from the supplement, across the original quiz era) so readers can assess whether the strata are comparably populated. If the lowest group shrank substantially, discuss how that affects the interpretation. Additionally, note that the quiz items themselves may differ in difficulty across the two eras; if the 2024 items are available (the paper mentions a '2024 knowledge battery'), compare the item-difficulty profiles.

**Panel attrition bias in the stability analysis is unaddressed**

The 2020→2024 stability estimates use a 2,171-case panel, but the paper does not discuss differential attrition. Panel attrition is well known to be non-random with respect to political engagement: politically knowledgeable, ideologically committed, and partisan respondents are more likely to remain in multi-wave surveys. If attrition is selective in this way, the panel overrepresents exactly the respondents whose attitudes are most stable, inflating the squared continuity correlations — and inflating them differentially across knowledge groups. The paper reports that even the lowest-knowledge group's ideology stability (.45) exceeds the original full-sample value (.37), which is a striking claim, but it depends on the lowest-knowledge panelists being representative of the lowest-knowledge population. Report the 2016→2020→2024 panel retention rate by 2020 quiz-knowledge group. If retention is differential, bound the bias — e.g., by reweighting to the cross-sectional knowledge distribution or by computing stability under worst-case attrition scenarios.

**Mode effects are dismissed too quickly given the scale of the FTF-to-web shift**

The original analysis restricted the sample to face-to-face and telephone interviews. The replication is 94% web in 2020 and about 81% web in 2024. This is not a marginal mode shift; it is a near-complete change in data collection method. Web respondents tend to express more extreme attitudes (no interviewer present to moderate), produce fewer 'don't know' or 'haven't thought much' responses (different satisficing dynamics), and may self-select differently into the survey. The paper notes that opinionation is 'reported by mode to expose any confound (it proves modest)' but doesn't show the mode comparison for the key metrics — breadth, inter-construct correlations, or vote models — only for HTMA rates. Because the original's FTF/phone restriction was one of the consequential coding decisions (§2.3, item 2), the shift to web is not merely a nuisance but a threat to the comparability of every metric. For 2020, where both web and FTF/phone respondents exist (even if the latter are a small minority), compare the key metrics (polar-half shares, average inter-construct correlations, ideology vote pseudo-R²) across modes. If the FTF subsample is too small for stable estimates, acknowledge this limitation more prominently rather than treating the mode shift as resolved.

**The breadth statistic is more deeply compromised than the paper acknowledges**

RC2 shows that the Table 1 breadth gradient — one of the original paper's headline statistics — largely reflects nonattitude coding rather than ideological constraint. Dropping HTMA/DK eliminates the policy gradient entirely and halves the ideology gradient. The GSS confirms this from the other direction: when the survey forces a substantive placement (no HTMA escape), the breadth gradient vanishes even while depth gradients are steep. This is a significant finding, but the paper frames it gently: 'This does not overturn the paper; it operationalises its innocence mechanism.' A stronger reading is that one of the original paper's four core metrics was measuring nonresponse, not ideology, and the knowledge gradient in that metric was primarily a nonresponse gradient. The paper should state this more directly. More practically, when the replication reports that 'mass ideological breadth rose' from 27% to 40–41%, this rise too is partly a nonresponse story — HTMA dropped from ~25% to ~13–14%, mechanically inflating the polar-half share. The replication should report breadth both with and without nonattitudes for 2020/2024, paralleling RC2's treatment of the original era, so readers can assess how much of the temporal rise in breadth is genuine polarization versus reduced nonresponse.

**Single-election comparisons against multi-year pools may overstate the temporal shift**

The replication compares 2020 and 2024 individually against a 1984–2016 pool (8 elections) and a 2008–2016 pool (3 elections). Both 2020 and 2024 were Trump-era elections — contexts of extraordinary partisan mobilization — and 2020 occurred during a pandemic that likely affected both survey participation and political attitudes. Even the 2008–2016 anchor is a pool of three elections, averaging over variation that a single-election snapshot cannot. The paper notes this asymmetry in the limitations but does not bound its impact. A useful check: report the 2020 and 2024 metrics separately and note whether the two single-election estimates are consistent with each other (they appear to be, though some constructs move in opposite directions between 2020 and 2024, e.g., egalitarianism breadth drops from 53 to 47). If 2024 partially reverts toward the original-era values on some metrics, that would temper the 'sharp rise' framing.

**Coherence persistence claim lacks a measure-matched benchmark**

The paper's central finding that 'knowledge stratification of ideological coherence persists' compares the 2020/2024 quiz-stratified correlation gradients (Table 10) against the reproduced interviewer-rated gradients (Table 4). But the paper's own methodology insists that cross-era comparisons must be measure-matched: the vote-potency analysis in Table 8 carefully anchors 2020/2024 quiz results to the author's quiz-stratified 1988–92 supplement tables (B5), not the steeper interviewer-rated baselines. No parallel move is made for coherence. Table 4 shows the interviewer-rated ideology×party correlation rising from .08 (lowest) to .67 (highest), a roughly 8× gradient. Table 10 shows the quiz-stratified 2020 gradient running from .58 to .81 — a compressed range that looks like 'persistence' against the interviewer-rated baseline but might look different against a quiz-stratified original-era baseline if one exists in the supplement. If the author's quiz tables (B1–B5) include correlation or reliability data, the coherence comparison should use those as the benchmark, exactly as the vote-potency comparison does. If no quiz-stratified correlation tables exist in the supplement, the paper should say so explicitly and acknowledge that the coherence persistence claim rests on a cross-instrument comparison — the very kind of comparison it warns against for vote potency.

**Knowledge-group cell sizes and merged-group construction unreported**

The replication's stratified estimates — the quantities behind the paper's headline claims — depend on how the five quiz-knowledge groups are populated and how they were merged for the vote models. The paper mentions 'merged voter knowledge groups' in the caption of Table 8 and in the vote tables, but never defines the merging rule, reports the resulting cell sizes, or shows the overall quiz-score distribution for 2020 and 2024. In the original era, the five interviewer-rating groups had known and uneven population shares (~9/20/34/25/13%); the quiz groups could be distributed very differently. If the lowest quiz group (0/4 correct) is, say, 5% of the 2020 sample, that is around 300 voters after restricting to the voter subsample, and the pseudo-R² for that cell — the denominator of the headline 2.5× ratio — could be unstable. Similarly, the stability table (Table 9) reports knowledge-stratified squared correlations from a 2,171-case panel, but the cell sizes for 'Lower' and 'Highest' are never stated. Reporting the quiz-score distribution for 2020 and 2024 (and for the panel), stating the merging rule, and giving the n in each cell of the stratified tables would let readers assess the precision of every stratified estimate without requiring formal inference — consistent with the paper's descriptive approach.

**No precision measures for the headline temporal ratios**

The paper's most prominent quantitative claims are temporal comparisons of pseudo-R² ratios: ideology vote-potency stratification fell from 'roughly 10.5× in 1988–92' to 'about 2.5× in 2020 and 2.0× in 2024.' These ratios are constructed by dividing the highest-knowledge group's pseudo-R² by the lowest-knowledge group's pseudo-R², both estimated from subsamples whose sizes are never stated. A ratio of two noisy quantities can be highly unstable: if the original-era lowest-group pseudo-R² is .04, a perturbation to .03 or .05 moves the ratio from 10.5 to 14 or 8.4. The paper treats the point estimates as precise enough to support claims about 'sharp' declines, but provides no confidence intervals, bootstrap ranges, or even informal bounds. This matters especially because the 2024 ratio (2.0×) is close enough to the 2020 ratio (2.5×) that one might wonder whether the two are meaningfully different from each other, and whether the overall decline from 10.5× is as dramatic as the point estimates suggest or partly reflects noise in small cells. Computing bootstrap confidence intervals for the Highest÷Lowest pseudo-R² ratio in each era (and for the difference across eras) would be straightforward given the replication code, and would let readers assess the robustness of the headline numbers.

**Recommendation**: Major revision. The paper is well-executed, transparent, and adds genuine value to the ideological-innocence debate. The reproduction is careful, the robustness suite is thorough, and the two-sided framing is commendable. However, the headline claim that the innocence portrait is 'time-bound' cannot stand without an analysis that distinguishes genuine ideological constraint from partisan sorting — and that analysis (ideology's incremental vote contribution net of party, by era and knowledge group) is absent. The circularity in the reproduction fidelity reporting and the under-addressed mode, attrition, and knowledge-comparability confounds are secondary but collectively weaken the replication's temporal comparisons enough that revision is needed before the paper's interpretive claims are warranted.

**Key revision targets**:

1. Add a party-controlled ideology vote model (pseudo-R² or AME of ideology net of party ID) by knowledge group for 2020, 2024, and the original era, and revise the Discussion's 'time-bound' claim based on whether incremental ideology potency actually rose.
2. Partition the 176 reproduction cells into anchoring cells (used to fix coding choices) and independent-validation cells, and report the fidelity rate separately for each set.
3. Report 2020→2024 panel retention rates by quiz-knowledge group and either reweight the stability analysis to the cross-sectional knowledge distribution or bound the attrition bias.
4. Report breadth statistics both with and without nonattitudes for 2020/2024, paralleling RC2, so readers can assess how much of the temporal rise in breadth reflects reduced nonresponse rather than genuine polarization.
5. Provide a more substantive discussion of mode effects — ideally a within-2020 mode comparison on key metrics — or, if infeasible, acknowledge the confound more prominently as a limitation that bears directly on the magnitude of the temporal shift.

**Status**: [Pending]

---

## Detailed Comments (16)

### 1. Discussion claims partisanship dominance 'widened' while verdicts say gap 'narrowed'

**Status**: [Pending]

**Quote**:
> Distinguishing ideology from partisanship matters more than ever, since partisanship’s dominance widened relative to its own past even as ideology closed some distance.

**Feedback**:
The Verdicts section (Table 12) concludes that claim 2 — 'Partisanship dominates ideology on every metric' — was 'Replicated, but the gap narrowed.' If the gap narrowed, dominance by definition did not widen; it shrank. The two halves of this sentence also pull against each other: 'dominance widened' and 'ideology closed some distance' cannot both be true if dominance means the margin between the two predictors. If the intended meaning is that partisanship's absolute vote-R² rose (e.g., .49 to .59 to .70), that is not what 'dominance widened' conveys — dominance is a relational term. A cleaner formulation: 'the two are now highly correlated, partisanship still leads on every metric, and conflating them risks attributing to ideology what party identity produces.' This aligns with both the verdict ('gap narrowed') and the methodological point.

---

### 2. Temporal change described as 'level' when the evidence shows a dramatic shape change

**Status**: [Pending]

**Quote**:
> What changed is the *level* for everyone, not the *shape* of the gradient alone.

**Feedback**:
The preceding sentences describe a fivefold compression of the vote-potency ratio (from roughly 10.5x to 2-2.5x) and state that 'the low-knowledge floor rose furthest.' Both are shape changes by definition: a uniform level shift would preserve the top-to-bottom ratio, while a fivefold compression concentrated at the low end is overwhelmingly a change in gradient shape. Calling this primarily a 'level' shift understates the paper's most distinctive finding, and 'for everyone' overstates symmetry when the high-knowledge group's already-high metrics moved relatively little. The 'not ... alone' construction technically acknowledges that shape changed too, but the primary emphasis misleads. Rewrite as something like: 'The gradient compressed rather than merely shifting: ideology rose at every knowledge level, but the gains were largest at the bottom, shrinking the top-to-bottom ratio from roughly 10x to 2x.'

---

### 3. Partisanship is not the flattest gradient in the reproduced data

**Status**: [Pending]

**Quote**:
> the info-gain ordering — ideology steepest (H÷L 3.96), partisanship flattest (1.55) — is precisely the paper’s

**Feedback**:
Table 3 shows egalitarianism H÷L = 1.50, which is lower than partisanship's 1.55. In the reproduced data, egalitarianism has the flattest knowledge gradient, not partisanship. The original paper does have partisanship as flattest (1.63 vs 1.65 for egalitarianism), so the reproduction actually reversed the ordering for the two flattest constructs. The middle pair also swapped: the original has policy (2.64) marginally above moral traditionalism (2.65), while the reproduction shows the reverse (2.30 vs 2.27). Describing the ordering as 'precisely the paper's' is incorrect on at least two pairwise comparisons. A more accurate statement: 'The broad ordering is preserved — ideology remains steepest (H÷L 3.96) — though egalitarianism and partisanship swap at the flat end (1.50 vs 1.55, compared with 1.65 vs 1.63 in the original).'

---

### 4. Egalitarianism stratification increased, contradicting the blanket 'sharply reduced' header

**Status**: [Pending]

**Quote**:
> **Vote-potency stratification is sharply reduced but not eliminated**, and here the measure-matched benchmark confirms the change is real

**Feedback**:
Table 8 shows egalitarianism's quiz-based H÷L ratio went from 1.3 in 1988-92 to 1.99 in 2020 and 2.05 in 2024 — roughly a 50% increase in stratification, not a decrease. The narrative then focuses on Ideology ID (10.5 to 2.49/1.99), which does show a sharp drop, but the bold header covers all five constructs and is contradicted by one of them. For egalitarianism, the answer to 'where the stratification went' is that it went up. Scope the header to the constructs it actually describes: 'For Ideology ID, Policy Views, and Moral Tradition the quiz-matched gradient compressed sharply; Egalitarianism is an exception, where stratification roughly doubled from a low base.'

---

### 5. Paper recommends AMEs over pseudo-R² ratios but uses pseudo-R² for its own headline

**Status**: [Pending]

**Quote**:
> **prefer marginal effects to pseudo-R² ratios** when describing how strongly a predictor stratifies, since the two can differ by an order of magnitude (RC6c)

**Feedback**:
The paper's own headline finding is framed entirely as a pseudo-R² ratio: 'roughly 10.5x in 1988-92 falls to about 2.5x in 2020 and 2.0x in 2024' (abstract, section 5.3, Table 12). If pseudo-R² ratios are unreliable enough to warrant a best-practice warning, the paper's central temporal comparison rests on the very metric it discourages. No AME-based stratification ratios appear for the 2020/2024 replication, so readers cannot check whether the headline 'sharp decline' survives the recommended metric. Report the AME-based H÷L ratio for ideology alongside the pseudo-R² ratio and confirm the two converge, or acknowledge that the recommended metric may yield a different magnitude of decline — as the paper's own RC6c analysis suggests it would.

---

### 6. 'Replicated with major drift' mislabels what is actually a disconfirmation

**Status**: [Pending]

**Quote**:
> Replicated with major drift — the qualifier fails; the low-knowledge floor rose so far that 'minority only' no longer fits

**Feedback**:
The original claim is that meaningful ideology characterizes ONLY the knowledgeable 20-30%. The qualifier 'only for the knowledgeable minority' IS the claim — it distinguishes the innocence thesis from its alternatives. If the qualifier fails, the claim has been disconfirmed, not replicated. 'Replicated with major drift' sounds, in the language of replication science, like the finding held up with qualifications, when in fact the headline conclusion no longer holds. The rest of the row says this clearly ('the qualifier fails'), but the label before the dash is what readers scanning the table will absorb. A more accurate label: 'Not replicated as stated — the knowledge gradient persists but the floor rose enough that ideology is no longer confined to a minority.'

---

### 7. Pseudo-R² incorrectly described as a variance quantity with a squaring relationship

**Status**: [Pending]

**Quote**:
> far below the pseudo-R² ratio, which is larger simply because it is a variance quantity (roughly the square of a slope ratio)

**Feedback**:
The squaring relationship R²_ratio ≈ (β_ratio)² holds for OLS R² under restrictive conditions (equal predictor variance, equal residual variance), but the paper uses probit models throughout, where McFadden's pseudo-R² is a likelihood-ratio statistic (1 − LL_model / LL_null), not a variance-explained proportion. The stated numbers are also inconsistent with the squaring claim: coefficient ratios of 1.9-2.7x would square to 3.6-7.3x, but the pseudo-R² ratio reaches 10x. In probit models, pseudo-R² ratios depend on base rates, predictor variance within subgroups, and the curvature of the link function — none of which reduce to a simple square. Replace the explanation with a correct one, e.g., 'which is amplified by the nonlinear probability mapping and the log-likelihood-ratio construction — pseudo-R² in probit models inflates group differences relative to linear effect-size scales, and the exact relationship depends on base rates rather than following a simple squaring of the coefficient ratio.'

---

### 8. HTMA flatness across modes does not support the full 'shrinking middle' conclusion

**Status**: [Pending]

**Quote**:
> The shrinking middle reflects more citizens taking ideological sides, not merely a mode effect — the HTMA rate is essentially flat across modes

**Feedback**:
The Moderate/HTMA category is a composite: it includes respondents who choose 'Moderate' and those who say 'Haven't thought much about it.' HTMA flatness across modes rules out mode as a driver of HTMA rates, but says nothing about whether mode affects the rate at which respondents choose 'Moderate' versus a directional label. Web respondents may be equally likely to say HTMA yet still less likely to self-place as 'Moderate' (choosing a polar label instead), which would shrink the Moderate/HTMA bar for reasons unrelated to genuine ideological change. The evidence cited supports only a narrower conclusion than the one drawn. Either show that the Moderate self-placement rate (separated from HTMA) is also flat across modes within 2020, or weaken the claim: 'The HTMA component of the decline is not mode-driven; whether the moderate self-placement shift is mode-independent cannot be determined from HTMA rates alone.'

---

### 9. Egalitarianism is also substantially affected by item matching, not just moral traditionalism

**Status**: [Pending]

**Quote**:
> Moral traditionalism is the one apparent exception whose “rise” is an item-count artifact: against its matched 2-item baseline (breadth 49), its 2020/2024 breadth (50/51) is essentially flat, though its covariance and correlation rises survive.

**Feedback**:
Table 7 displays egalitarianism's matched-item baseline in brackets (43), and that number tells a parallel story. In 2024, egalitarianism breadth is 47 — so of the apparent +15pp rise (32 to 47), +11pp is item-count inflation and only +4pp is genuine. Even in 2020 (53), the matched comparison (43 to 53 = +10pp) is roughly half the unmatched one (32 to 53 = +21pp). Calling moral traditionalism 'the one apparent exception' is incorrect; egalitarianism is also substantially affected, especially in 2024. Since the table already presents the matched baselines, the text should cover both constructs rather than singling out MT.

---

### 10. Verification pass described in methods but absent from the reproducibility pipeline

**Status**: [Pending]

**Quote**:
> every headline result from all five pipelines was **independently recomputed** by a separate verification pass that loaded the raw data directly and hand-rolled its own coders rather than re-running the analysis functions

**Feedback**:
Section 2.4 describes a verification pass that loaded raw data, hand-rolled its own coders, and confirmed results cell-by-cell across all five analytic pipelines — catching one genuine bug in the process. That verification is presented as a key element of quality assurance, yet no corresponding script appears in the Reproducibility Statement's pipeline listing (R/01 through R/06 plus the Quarto render). A reader following the reproducibility instructions has no way to run or inspect the verification step. If the verification code lives in the repository, add its invocation to the pipeline listing (e.g., Rscript R/07_verify.R). If it was executed interactively or stored elsewhere, say so and provide its location.

---

### 11. Panel fidelity table rows do not sum to stated cell counts under any consistent scheme

**Status**: [Pending]

**Quote**:
> | Table 3 — 1990–92 (25 cells) | 23 | 23 | 2 |

**Feedback**:
The cross-sectional row sums cleanly (154 + 17 + 5 = 176), but the panel rows do not under any single consistent banding scheme. If the three columns are exclusive (as for the cross-sectional row), the 1990-92 row gives 23 + 23 + 2 = 48, nearly double its stated 25 cells, and the 1992-96 row gives 6 + 16 + 0 = 22, three short. A cumulative interpretation (where 'Within .01' includes exact matches) rescues 1990-92 (23 + 2 = 25) but leaves 1992-96 with 16 accounted and 9 missing. The likeliest fix: for 1990-92, the '23' in the Close column should be '0' (since all 23 within-.01 cells happen to be exact), and for 1992-96, the em-dash should read '3' (6 + 16 + 3 = 25). Whatever the correct counts, the table as printed cannot be verified. State the banding scheme explicitly and correct the entries so every row sums to its claimed total.

---

### 12. RC2 coherence claim ignores differential sample restriction across knowledge groups

**Status**: [Pending]

**Quote**:
> Critically, the *coherence* gradient (Table 4 correlations) is unaffected by the coding: dropping nonattitudes leaves the ideology×party gradient essentially unchanged (lowest group 0.11, highest 0.69).

**Feedback**:
HTMA is concentrated in the lowest-knowledge group (the same section reports 25.9% overall). Dropping these respondents removes a large fraction of the lowest-knowledge group but a small fraction of the highest. The surviving low-knowledge respondents are the more opinionated subset — exactly those most likely to produce coherent placements. Finding that this selected subpopulation shows a gradient of .11 to .69 demonstrates that among people who express attitudes, the gradient holds. It does not demonstrate that the coherence gradient is 'unaffected' by nonattitude coding. The paper recognizes this selection mechanism for breadth ('low-knowledge citizens lack attitudes to place, a selection effect') but does not acknowledge that the same mechanism operates when computing coherence on the restricted sample. Note that the 'unchanged' gradient reflects a differentially selected subpopulation, so the comparison is not strictly like-for-like with the midpoint-coded version.

---

### 13. WORDSUM quality invoked selectively: adequate for depth but inadequate for breadth

**Status**: [Pending]

**Quote**:
> Two design features drive it: WORDSUM indexes verbal ability, a weaker proxy for *political* knowledge; and GSS POLVIEWS offers no “haven’t thought much” escape

**Feedback**:
A few sentences earlier, the same WORDSUM bins are described as tracking Kalmoe's ANES gradient 'almost exactly' on every depth metric (7x for correlations, 15x for vote potency). If WORDSUM is adequate enough to produce faithful depth gradients, its weakness as a political-knowledge proxy cannot simultaneously explain why breadth fails — at least not without explaining why verbal ability would track depth but not breadth. The HTMA-mechanism explanation (no nonresponse escape in GSS) is self-sufficient and logically consistent with RC2. Invoking WORDSUM weakness on top of it creates a tension the text does not resolve. Either drop the WORDSUM-weakness argument for breadth non-replication and rely on the no-HTMA mechanism alone, or add a sentence explaining why verbal ability tracks one metric but not the other (e.g., because breadth is primarily a nonresponse artifact, the proxy's strength is irrelevant to it).

---

### 14. GSS 'dominates in every group' claim is unverifiable and likely razor-thin at top

**Status**: [Pending]

**Quote**:
> partisanship dominates ideology in *every* knowledge group and is near-flat across them (full-sample pseudo-R² 0.47)

**Feedback**:
Only the full-sample partisanship pseudo-R² (0.47) is reported; no group-specific values appear. Meanwhile, ideology at the highest WORDSUM group reaches 0.45 — only 0.02 below the full-sample partisanship figure. If partisanship is genuinely near-flat, the top-group comparison is approximately 0.47 vs. 0.45, a margin small enough that sampling variability or a slightly different specification could flip it. The italicized 'every' draws rhetorical weight to a claim the presented numbers cannot substantiate. Report partisanship pseudo-R² for at least the top and bottom knowledge groups so readers can verify the 'every group' claim and assess how thin the margin is at the highest stratum.

---

### 15. Panel conditioning bias omitted from the 'conservative' attenuation argument

**Status**: [Pending]

**Quote**:
> Because the reduced value batteries add noise that attenuates test–retest correlations, the egalitarianism and moral-traditionalism rises are if anything conservative.

**Feedback**:
Shorter scales do add measurement noise that depresses observed r², so the attenuation argument is directionally correct for random error. But the 2020-to-2024 comparison is drawn from respondents in a three-wave panel (2016-2020-2024): by the third interview, panel conditioning — respondents crystallizing attitudes or anchoring to remembered prior answers — can inflate test-retest correlations beyond what a fresh two-wave design would produce. If the original 1992-96 panel had fewer prior waves, part of the observed stability gain could reflect conditioning rather than genuine attitude persistence. Attenuation and conditioning push in opposite directions, and whether the net bias is 'conservative' depends on their relative magnitudes — which the paper does not discuss. Acknowledge the panel-conditioning risk and, ideally, note whether the 2020-wave items were also asked in 2016 (which would strengthen the conditioning concern) or whether freshly-recruited 2020 cross-section respondents show comparable stability patterns.

---

### 16. 'Nearly doubled' overstates a 73% increase

**Status**: [Pending]

**Quote**:
> Ideological identification nearly doubled, from .37 to 0.64.

**Feedback**:
A rise from .37 to .64 is a ratio of 1.73 — a 73% increase. 'Nearly doubled' implies approaching 2x, which would require reaching about .74. The observed value covers roughly three-quarters of the distance needed to actually double. In a paper that relies on precise ratio comparisons for its headline findings, this kind of overstatement is worth correcting. Rewrite as 'rose by roughly three-quarters' or simply 'increased from .37 to .64 (x1.73)' — the raw numbers are striking enough without inflation. The same phrasing appears in the table subtitle, so both should be updated.

---
