# Replication materials search: Kalmoe (2020), "Uses and Abuses of Ideology in Political Psychology"

Political Psychology 41(4):771-793. DOI: 10.1111/pops.12650. Early view Feb 2020.

## Found

**Online Appendix (Supporting Information)** — downloaded to
`/Users/lukaswallrich/Documents/Coding/ai_rep_polsci/paper/kalmoe2020_online_supplement.pdf`
(9 pages, 370 KB).

- Source: linked from Nathan Kalmoe's research page (https://nathankalmoe.com/research-2/),
  under the "Uses and Abuses of Ideology in Political Psychology" entry, as "Online Appendix":
  https://www.dropbox.com/s/ru56r7ipcghddky/Online%20Supplement%20-%20Uses%20%26%20Abuses.pdf?dl=0
  (downloaded with `?dl=1`).
- Contents confirmed via `pdftotext`: Table of Contents lists —
  1. Replication of Table 1 with Relative Breadth Measures (standardized) — p.1
  2. Replication of All Tables with Campaign Quiz Knowledge Measure — p.2-4
  3. Replication of All Tables in ANES Data since Jost (2006) — p.5-8
  4. Replication of Table 4 Relationships with Polychoric Correlations — p.9
  5. Replication of Table 3 Stability with Follow-up Ideology ID Item — p.9
- This is a set of robustness/replication tables, not code or raw data.

The article's underlying data are the ANES (American National Election Studies) time-series
cumulative file and related public survey data — no proprietary dataset requiring separate
deposit was identified or expected for this design.

## Checked, nothing found

1. **Wiley article page** (https://onlinelibrary.wiley.com/doi/10.1111/pops.12650): blocked by
   paywall — both WebFetch and curl (with a spoofed browser user agent) returned HTTP 402/403
   (Wiley requires an authenticated session/subscription to view the article page and to serve
   `downloadSupplement` files). Tried direct supporting-info URL variants:
   `https://onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1111%2Fpops.12650&file=pops12650-sup-000{1,2,3}-Supinfo.{docx,pdf}`
   — all returned HTTP 403 (an HTML error page, not the actual file). Could not confirm Wiley's
   official Supporting Information filename/listing directly since the page itself is
   inaccessible without institutional access. (The Dropbox-hosted appendix above is very likely
   the same file Wiley hosts as supporting information, distributed directly by the author.)

2. **OSF** (https://api.osf.io/v2/search/?q=Kalmoe%20ideology): search returned only unrelated
   projects (e.g., "Diversity Ideologies," "Ideology and Invariance," "Ideology and Coronavirus")
   — nothing by Nathan Kalmoe related to this paper.

3. **Harvard Dataverse** (search API, queries "Kalmoe" and "Kalmoe ideology" and exact title):
   Kalmoe has a personal Dataverse ("Kalmoe and Piston POQ 2013 Dataverse") with several
   datasets for *other* papers (POQ 2013 racial prejudice/AMP, political violence measurement,
   genes/ideology/sophistication, aggressive metaphors, digital racial conflict, #MeToo
   partisanship, CES 2020, Trump-Russia scandal reactions) — none titled or matching
   "Uses and Abuses of Ideology" or Political Psychology 2020/2021. No dataset exists for this
   specific paper.

4. **Nathan Kalmoe's website**:
   - https://nathankalmoe.com/research-2/ — has the full publication entry with the Dropbox
     Online Appendix link (used above); no separate code/data link for this paper.
   - https://nathankalmoe.com/replication-files/ — lists replication files (mostly Dropbox links
     and TESS experiment links) for other papers (violent metaphors, crime news, flag imagery,
     trait aggression, implicit prejudice, 2013-2019 work); nothing for the 2020 ideology paper.

5. **Google/web search** for "Uses and Abuses of Ideology" + appendix/supporting
   information/replication: results pointed back to the same Dropbox appendix link and to a
   ResearchGate listing of the article; no separate GitHub/Dataverse/OSF repository found.

## Bottom line

The only supplementary material for this paper is the author-hosted **Online Appendix** (9-page
PDF of robustness tables), now saved locally. There is no separate code or raw-data replication
package (e.g., no Dataverse/OSF/GitHub repo) for this specific paper — consistent with it being
a secondary-data-analysis paper built on the public ANES time series (no proprietary dataset to
deposit). Wiley's official Supporting Information page could not be directly verified due to a
paywall, but the content and title match what a "Supporting Information" file would contain, and
it is directly linked from the author's own publications page as the paper's online appendix.
