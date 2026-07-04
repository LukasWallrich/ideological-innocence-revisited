# Decisions Log — Reproduction & Replication of Kalmoe (2020)

Target: Kalmoe, N. P. (2020). Uses and Abuses of Ideology in Political Psychology.
*Political Psychology* 41(4), 771–793. doi:10.1111/pops.12650
FORRT ReplicaTHIS nomination #8 (https://forrt.org/replicatethis/nomination/8/).

Running log of consequential choices made during the project, with rationale.
(Chronological; each entry says what was decided, why, and what the alternatives were.)

## D1. Paper source
- Wiley version paywalled; PDF obtained from gwern.net mirror
  (https://gwern.net/doc/sociology/2020-kalmoe.pdf), which matches the journal
  version (doi on first page). Online Appendix obtained from Dropbox link on
  Kalmoe's own publications page (nathankalmoe.com). No code/data package exists
  anywhere (checked OSF, Harvard Dataverse incl. Kalmoe's own dataverse, Wiley SI,
  author website) — consistent with a secondary analysis of public ANES data.

## D2. Data source for ANES Cumulative Data File (CDF)
- electionstudies.org requires login and its Cloudflare challenge blocks automated
  browsers, so official direct download was not feasible autonomously.
- Used the `anesr` R package's GitHub data mirror (jamesmartherus/anesr), which
  redistributes official ANES files as .rda. Its `timeseries_cum` is the
  **1948–2016 CDF (59,944 × 1,029)** — the same vintage available to Kalmoe
  (paper submitted 2019), which is *better* for faithful reproduction than the
  current 1948-2024 release (recodes in later releases could differ).
- Replication data (2020, 2024 in CDF coding): subset of the ANES 1948-2024
  cumulative obtained from SDA Berkeley (sda.berkeley.edu, dataset
  anes2024cumulative; no login, publicly served) via browser automation.
- Trade-off: neither is the official ANES download page, but both redistribute
  unmodified official files; variable-level values will be cross-checked between
  the two independent sources (1984–2016 rows appear in both) as an integrity check.

## D3. Panel data for Table 3 (stability)
- ANES 1990–92 panel: the anesr `timeseries_1992` file is the 1990–1992 Full Panel
  File (N=2,485; contains V90*, V91*, V92* variables) — single-file panel.
- 1992–96: merge `timeseries_1996` (panel cases carry 1992 ID link V960009) with
  `timeseries_1992`. [Corrected: an earlier version of this entry named V960005,
  which is a weight; the script always used V960009.]
- 2000–02: merge `timeseries_2002` (carries 2000 case ID link) with `timeseries_2000`.
- These reconstruct the panels Kalmoe used (he cites "ANES panels for 1990-92 and
  1992-96... and 2000-2002").

## D4. Scope of the convenience-sample section (paper pp. 16-17)
- Kalmoe's own Knowledge Networks 2010, MTurk 2012/13/15, and student samples are
  not publicly archived → **not reproducible**; will be documented as such in the
  manuscript. The Clifford et al. (2015) comparison numbers are quoted from a
  published paper, not re-computed.

## D5. Knowledge measure for the 2020/2024 replication
- The interviewer information rating (VCF0050a/b) — Kalmoe's stratifier — was
  discontinued: absent for all 2020 and 2024 CDF cases (confirmed empirically).
- Replication therefore stratifies 2020/2024 by a quiz-knowledge index
  (2020: V201644-47 civics + V202139-42 office recall; 2024 analogues),
  binned into 5 categories approximating the interviewer-rating share
  distribution — exactly the method Kalmoe himself uses in Online Appendix
  Tables B1–B5 ("divide quiz knowledge into 5 categories that approximate the
  proportion of respondents in each of the 5 bins of interviewer-rated
  knowledge"). Deviation is forced by data availability and is anchored in the
  original's own robustness approach; his SI shows quiz stratification gives
  similar but "slightly less distinct" patterns — relevant when comparing
  replication gradients to original gradients.
- Mode: 2020/2024 ANES are predominantly web; Kalmoe's FTF/phone restriction
  cannot be applied. Web administration plausibly changes DK/HTMA behaviour
  (no interviewer probing); this is an unavoidable, documented deviation.
- 2024 note: VCF0704a/VCF0705 (major-party vote recodes) are empty in the
  current CDF release for 2024; two-party vote derived from VCF0704 instead.

## D6. Observation: probable N transposition in original Table 1
- Reproduced construct Ns: Ideology ID 24,557, Partisanship 25,427.
- Paper's Table 1 prints Ideology N=25,332, Partisanship N=24,307.
- The crosswise match (party↔25,332 within 0.4%; ideology↔24,307 within 1.0%)
  fits far better than the printed assignment (errors of ~3-4.5%), and party ID
  has near-zero item nonresponse while ideology loses cases — so party *should*
  have the larger N, as in our reproduction. Conclusion: the printed Ns for
  these two rows were most likely transposed in the original. Treat as a minor
  erratum candidate; flag in manuscript, do not "correct" silently.

## D7. Response to automated peer review (coarse pipeline, 2026-07-03)
- Full review archived at coarse-output/manuscript_review.md. Verdict: major
  revision — well-executed but headline "time-bound" claim needs a
  sorting-vs-constraint analysis; plus 4 further targets and 16 detailed comments.
- Decision: implement ALL five key targets (party-controlled incremental
  ideology vote models by era×knowledge; anchor/validation cell partition;
  panel retention + reweighted stability; breadth ± nonattitudes for 2020/24;
  within-2020 mode comparison) and all 16 detailed comments. New analyses in
  R/07_revision.R → output/revision/. No review point rejected; several were
  outright errors we should have caught (e.g. "dominance widened" vs "gap
  narrowed" contradiction, 'nearly doubled' for ×1.73).

## D8. Analysis stack
- R + Quarto. Probit models via glm(binomial(link="probit")), McFadden pseudo-R²
  (matches Stata's default `pr2`, which the paper's "pseudo r2" almost certainly is,
  given SE clustering language), cluster-robust SEs by year (sandwich/clubSandwich).
- "Squared continuity correlations" (Table 3) = squared Pearson r between waves
  (per Converse 2000, cited in the paper).

## D9. Publication to GitHub Pages (2026-07-04)
- Public repo: https://github.com/LukasWallrich/ideological-innocence-revisited
- Live manuscript: https://lukaswallrich.github.io/ideological-innocence-revisited/
- Prominent "AI-generated / not yet validated" warning in README (top) AND injected
  as an on-page banner at deploy time.
- Anti-drift design: the manuscript HTML lives in exactly one place
  (manuscript/manuscript.html, committed). A GitHub Action
  (.github/workflows/deploy-pages.yml) runs scripts/build_pages.py to inject the
  banner and deploy to Pages on each push that touches the HTML/script/workflow.
  No second committed copy of the HTML; the published page is always derived from
  the single source. Pages source = GitHub Actions (build_type=workflow).
- NOT redistributed (gitignored): raw ANES/GSS microdata (data/raw/), the two large
  respondent-level intermediates (cdf_analysis.rds, gss_analysis.rds), and the
  copyrighted Wiley paper + supplement (paper/). knowledge.rds (284K derived quiz
  index, needed to render) IS included. Data-availability note added to README.
