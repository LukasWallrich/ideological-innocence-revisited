# Ideological Innocence, Revisited

> ## ⚠️ AI-generated and not yet validated
>
> **This project was produced end-to-end by an AI-agent workflow (Anthropic's Claude) and has
> not yet been validated by the human author or anyone else.** It has not been checked
> line-by-line, has not been peer-reviewed, and has not been independently replicated by a
> person. The internal cross-checks described below (an automated verification pass and an
> automated review) are themselves AI-generated and are **not** a substitute for human scrutiny.
>
> Treat every number, claim, and interpretation here as **provisional and unverified**. Do not
> cite it, make decisions based on it, or represent its findings as established until it has been
> checked by a qualified human. It is published openly for transparency and to invite exactly
> that scrutiny — not as a finished or trustworthy result.

A fully reproducible computational **reproduction**, **robustness analysis**, and **new-data
replication** of Kalmoe (2020), *Uses and Abuses of Ideology in Political Psychology*
(doi:10.1111/pops.12650), responding to [FORRT ReplicaTHIS nomination #8](https://forrt.org/replicatethis/nomination/8/).

📄 **Rendered manuscript:** see the GitHub Pages site for this repository (the same
`manuscript/manuscript.html` served on the web).

The deliverable is `manuscript/manuscript.qmd`, which renders to a self-contained HTML report.
The manuscript **reads precomputed `.rds` outputs** produced by the numbered `R/` scripts, so it
renders in seconds and independently of the analysis chain.

## What the project does

1. **Reproduces** the paper's public-data analyses (Figure 1; Tables 1, 2, 4, 5; the panel
   stability Table 3; footnote 5; and the reproducible in-text statistics) from the same ANES
   Cumulative Data File vintage the author used.
2. **Stress-tests** them with eight robustness checks (RC1–RC8), validated against the author's
   own online supplement where possible.
3. **Replicates** them in data the author never saw — ANES 2020 and 2024, plus the
   2020→2024 panel — and in the **GSS** as a cross-dataset conceptual replication.
4. **Independently verifies** every headline number before it enters the manuscript.

Headline findings: the reproduction is faithful (154/176 cells tight, 5 diverge); every
substantive conclusion survives the robustness suite; and the replication is two-sided — mass
ideological coherence, polarity, stability, and potency all rose sharply (the "innocence"
portrait is time-bound), while knowledge stratification of ideological coherence persists and
stratification of vote potency is sharply reduced but not eliminated. Partisanship still
dominates every metric, but the gap narrowed.

## Run order

Run from the project root with R 4.5.3. Each script is deterministic (no randomness), writes tidy
`.rds` outputs plus a Markdown report to `output/<module>/`, and runs end-to-end in seconds.

```bash
Rscript R/01_prepare_cdf.R        # ANES CDF (1948–2016 vintage) → output/repro_main/cdf_analysis.rds
Rscript R/02_reproduce_main.R     # Tables 1,2,4,5, Fig 1, footnote 5, in-text stats
Rscript R/03_robustness.R         # RC1–RC8 robustness/sensitivity suite
Rscript R/04_panels.R             # Table 3 stability (1990–92, 1992–96, 2000–02 panels)
Rscript R/05_gss.R                # GSS 1972–2024 conceptual replication
Rscript R/06_replication_anes.R   # ANES 2020/2024 cross-sections + 2020→2024 panel
Rscript R/07_revision.R           # post-review analyses → output/revision/*.rds

# independent adversarial verification pass (recomputes every headline from raw data)
Rscript output/verification/v_reproduction.R
Rscript output/verification/v_robustness.R
Rscript output/verification/v_panels.R
Rscript output/verification/v_replication.R
Rscript output/verification/v_gss.R

quarto render manuscript/manuscript.qmd   # builds manuscript/manuscript.html
```

`R/01` and `R/02` must run in order (02 depends on `cdf_analysis.rds`); `R/03` also depends on
`cdf_analysis.rds`. `R/04`, `R/05`, `R/06` are independent of each other. `R/07` depends on the
`repro_main`, `robustness`, `gss`, and `replication` outputs (it reuses their conventions and reads a
few of their `.rds`). The manuscript depends only on the `.rds` files in `output/`, so `quarto render`
can be run any time after the scripts. The revision analyses (`R/07`) were added in response to an
automated peer review archived at `coarse-output/manuscript_review.md`.

## Repository layout

```
R/                       # numbered, deterministic analysis pipeline (01–07)
data/raw/                # source survey data — NOT in this repo (see "Data availability"); obtain per notes/
output/
  repro_main/            # reproduction of Tables 1,2,4,5 + Fig 1 + footnote 5 (.rds, comparison.csv, report)
  repro_panels/          # reproduction of Table 3 stability panels
  robustness/            # RC1–RC8 (.rds + report)
  replication/           # ANES 2020/2024 + panel (.rds + report)
  gss/                   # GSS conceptual replication (.rds + report)
  revision/              # post-review analyses (R/07): sorting/constraint, AME ratios, attrition, etc.
  verification/          # independent adversarial verification (v_*.R + report)
notes/                   # paper spec, decisions log, data-provenance logs
manuscript/              # manuscript.qmd, references.bib, rendered manuscript.html
```

## Requirements

- **R 4.5.3** with `dplyr`, `tidyr`, `psych`, `sandwich`, `MASS`, `marginaleffects`, `here`
  (analysis scripts); `gt` and `ggplot2` are additionally used by the manuscript.
- **Quarto** (for rendering the manuscript).
- The `anesr` package's redistributed ANES `.rda` files provide the 1948–2016 CDF vintage and the
  panels; the 2020/2024 and GSS subsets in `data/raw/` were downloaded from SDA Berkeley
  (accessed 2026-07-03). See `notes/sda_download_log.md` and `notes/materials_search.md`.

## Data availability

The raw survey microdata are **not redistributed in this repository**. The ANES Time-Series
Cumulative Data File, the ANES 2020/2024 studies, and the GSS are governed by their providers'
terms and should be obtained from source: the `anesr` package (1948–2016 CDF and the panels) and
SDA Berkeley (`sda.berkeley.edu`, for the 1948–2024 CDF subset, the 2024 knowledge items, and the
GSS 1972–2024 cumulative). Exact variables, dataset ids, and steps are in
`notes/sda_download_log.md`. Running `R/01`–`R/07` after placing those files in `data/raw/`
regenerates every output.

The `output/` directory does include the small **derived analysis tables** the manuscript reads
(aggregate results, plus one respondent-level derived index, `replication/knowledge.rds`, needed
to render). The two large respondent-level intermediates (`repro_main/cdf_analysis.rds`,
`gss/gss_analysis.rds`) are excluded and are regenerated by `R/01` and `R/05`.

## Data provenance and reproducibility

There is no official code or data package for Kalmoe (2020); the pipeline reconstructs the
analysis from the paper and its author-hosted online supplement, adjudicating unstated
methodological choices empirically against the anchors the original tables supply (construct Ns,
knowledge-group shares, and published cell values). All choices are documented in
`notes/decisions_log.md` and the per-module reports. The independent verification pass
(`output/verification/`) recomputed every headline number from the raw data with hand-rolled
coders, confirmed the pipelines regenerate byte-identically, and found and corrected one bug (a
mislabelled vote-stratification ratio) before publication.

## AI-assistance statement

The empirical work and this repository were executed by an AI-agent workflow (Anthropic's Claude,
via Claude Code) under the direction and review of the human author, Lukas Wallrich, who defined
the scope and framing, made the consequential judgment calls, and is responsible for the content.
Every quantitative claim in the manuscript is loaded programmatically from, or checked against,
the precomputed analysis outputs. See the manuscript's "Workflow and AI-Assistance Statement" for
detail.
