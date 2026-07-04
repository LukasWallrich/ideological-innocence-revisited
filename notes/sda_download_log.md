# SDA ANES Cumulative Data File 1948-2024 download log

**Date:** 2026-07-03
**Dataset:** ANES Cumulative Datafile 1948-2024 (`anes2024cumulative`) on SDA Berkeley
**URL:** https://sda.berkeley.edu/sdaweb/analysis?dataset=anes2024cumulative

## Steps taken

1. Opened the dataset analysis page with `browser-use --session sda` (headless Chromium). The dataset loaded correctly with the header "Study: ANES Cumulative Datafile 1948-2024".
2. Clicked the "Download Custom Subset" top-menu item, which revealed a 4-tab wizard: File Options / Select Cases / Select Variables / Create Files.
3. **File Options tab:** selected "CSV file (Comma Separated Values with header record)" as the data file type, and left "Codebook for subset data (ASCII)" checked (checked by default).
4. **Select Cases tab:** left "Selection Filter(s)" blank — confirmed the resulting subset would include every case in the original data file (no year/sample filtering).
5. **Select Variables tab:** entered all 37 requested variable names directly into the "Specify individual variable names" textarea:
   `VCF0004 VCF0006 VCF0009x VCF0009y VCF0009z VCF0017 VCF0050a VCF0050b VCF0110 VCF0101 VCF0104 VCF0301 VCF0310 VCF0803 VCF0806 VCF0809 VCF0830 VCF0838 VCF0839 VCF0843 VCF0851 VCF0852 VCF0853 VCF0854 VCF9013 VCF9014 VCF9015 VCF9016 VCF9017 VCF9018 VCF0702 VCF0704 VCF0704a VCF0705 VCF0729 VCF0713 VCF0523`
6. **Create Files tab:** used "Show List of All Variables Selected for Subset" to confirm the server recognized all 37 variables (none dropped/rejected) before creating files.
7. Clicked "Create Files". Server response: **"37 variables for 73745 cases in subset."** — i.e. no case filtering was applied and all variable names were valid.
8. The wizard then displayed three download buttons: "Data file", "Codebook", "Zip archive - ALL files". These are PrimeFaces `<button type="submit">` elements inside form `subsetWizardForm` with no `href`/static URL — clicking them causes a full-page POST-back that streams the file as the HTTP response (`Content-Disposition: attachment`).
9. Headless Chromium via CDP does not expose a straightforward "list downloaded files" mechanism in this browser-use CLI build, and no file appeared in the default download locations checked (`~/Downloads`, browser-use's temp downloads dir, Chromium's profile dir). Rather than fight the headless download plumbing further, I read the live DOM to extract the exact `subsetWizardForm` field set (radio button for CSV, codebook checkbox, `varTextarea` contents, `subsetTabview_activeIndex=3`, and the live `javax.faces.ViewState` token) plus the session's `JSESSIONID` cookie, and replicated the two button POSTs directly with `curl` against `https://sda.berkeley.edu/sdaweb/analysis/index.jsf`. This is functionally identical to clicking the buttons in a real browser (same form, same session, same view state) — not a different code path.
10. This retrieved both files directly:
    - Data file (button `subsetWizardForm:subsetTabview:j_idt1835`) → `Content-Disposition: attachment;filename="sub-data.txt"`, content is CSV text with a header row exactly matching the 37 requested variable names, and 73,745 data rows.
    - Codebook (button `subsetWizardForm:subsetTabview:j_idt1837`) → `Content-Disposition: attachment;filename="sub-cdbk.txt"`, ASCII text codebook with a table of contents and a full entry (data type, record/columns, and for coded variables the value labels) for each of the 37 variables.
11. Saved and renamed the files, verified them (see below), and closed the browser session (`browser-use --session sda close`).

## Missing / rejected variables

**None.** All 37 requested variable names were accepted by SDA — the "Show List of All Variables Selected for Subset" dialog and the final "Create Files" confirmation both reported exactly 37 variables in the subset, matching the count requested.

## Files produced

- `/Users/lukaswallrich/Documents/Coding/ai_rep_polsci/data/raw/anes_cdf_1948_2024_subset.csv` (11,357,033 bytes; CSV with header row, 73,745 data rows + 1 header row)
- `/Users/lukaswallrich/Documents/Coding/ai_rep_polsci/data/raw/anes_cdf_1948_2024_subset_codebook.txt` (22,599 bytes; ASCII codebook, one entry per variable with value labels)

## Verification

- Header row column count: 37, matching the requested variable list exactly (same names, same order).
- Total data rows: 73,745, matching the server's reported "73745 cases in subset".
- `VCF0004` (Year of Study) distinct values span 1948 to 2024: 1948, 1952, 1954, 1956, 1958, 1960, 1962, 1964, 1966, 1968, 1970, 1972, 1974, 1976, 1978, 1980, 1982, 1984, 1986, 1988, 1990, 1992, 1994, 1996, 1998, 2000, 2002, 2004, 2008, 2012, 2016, 2020, 2024.
  - 2020: 8,280 rows
  - 2024: 5,521 rows
  - (Gaps at 2006/2010/2014/2018/2022 reflect that the ANES Cumulative Data File does not include those midterm-year studies — this is a property of the source CDF, not a filtering choice made during this download.)
- Codebook contains a table of contents and a full entry for all 37 variables, confirming they exist in the 2024 vintage of the CDF and describing exactly the concepts requested (e.g. VCF0301 Party ID 7-point scale, VCF0803 Liberal-Conservative Scale, VCF0704/VCF0704a/VCF0705 presidential vote variants, VCF9013-VCF9018 equal-opportunity/egalitarianism items, etc.).

## Data quality finding: VCF0704a and VCF0705 are empty for 2024

Non-blank-rate checks by year (2016/2020/2024) on a set of key substantive variables showed 100% population for VCF0301, VCF0803, VCF0704, VCF0110, and VCF0009z in all three years. However:

- **VCF0704a** ("Vote for President - Major Parties") and **VCF0705** ("Vote for President - Major Parties and Other") are **completely blank for all 5,521 2024 cases** (0/5521 non-blank), while fully populated for 2020 (8,280/8,280) and 2016 (4,270/4,270).
- **VCF0704** ("Vote for President - Major Candidates") itself *is* populated for 2024 (values 0/1/2/3 present, matching the coding scheme in the codebook), so the base vote-choice variable is available — only the two derived/recoded variants (major-parties-only and major-parties-plus-other) appear not yet to have been back-filled for the 2024 wave in this SDA release of the cumulative file.

This is a property of the ANES Cumulative Data File as currently released via SDA, not an artifact of the variable selection or download process (the columns exist and are documented in the codebook; they are simply empty for 2024 rows). Anyone using VCF0704a/VCF0705 for 2024 analysis should be aware they will need to either wait for a future SDA/ANES data update, or derive an equivalent "major parties only" recode from VCF0704 for 2024 cases.

## Other things downstream code should account for

- Missing values in the CSV appear as blank or single-space (`" "`) fields, not as a sentinel numeric code — downstream R/pandas loading code should treat blank/whitespace-only cells as `NA`.
- Weight variables (e.g. VCF0009x/y/z) are written in scientific notation (e.g. `1.00000000000000000e+00`).

## ANES 2024 knowledge items

**Date:** 2026-07-03
**Dataset:** ANES 2024 Time Series Study Full Release (`anes2024full`) on SDA Berkeley
**URL:** https://sda.berkeley.edu/sdaweb/analysis?dataset=anes2024full

### Step 1: Finding the variable IDs

The dataset's own HTML codebook (linked from the dataset page as "Codebook") is served as static pages under `https://sda.berkeley.edu/sdaweb/docs/anes2024full/DOC/`. Starting from the title page (`hcbk.htm`), the "Sequential Variable List" (`hcbkh01.htm`) gives a table of contents of ~199 thematic headings, each linking to the page containing that section's variables. This was far faster than searching the tree UI:

- `hcbkx01.htm#1.HEADING` → "Technical Weight- and Sample-related Variables" → led to `hcbk0001.htm`, which contains the case ID, mode-of-interview, and all weight variables.
- `hcbkx02.htm#91.HEADING` → "Political Knowledge" → led to `hcbk0028.htm`, which contains the four pre-election knowledge items.
- `hcbkx02.htm#102.HEADING` → "Recall of Political Facts" → led to `hcbk0037.htm`, which contains the post-election office-recall items.

A `grep -in 'recognition'` across all three main body pages (`hcbkx01/02/03.htm`) found no "office recognition" battery in the 2024 full release — only "office recall" (open-ended, subsequently coded) items exist for 2024, unlike some earlier ANES waves that also had a closed-form recognition battery.

Variable IDs found:

| Variable | Label | Notes |
|---|---|---|
| `V240001` | 2024 Time Series Case ID | Range 140001–399909, numeric, one row per case, no duplicates |
| `V240002a` | Mode of interview: pre-election interview | 1=FTF, 2=Web, 3=Web w/PAPI, 4=Panel (per ANES coding) |
| `V240002b` | Mode of interview: post-election interview | Same mode scheme; -6/-7 used for no-post-interview/deleted |
| `V240107a` | Pre-election raked weight: FTF+Web+Panel+PAPI combined [FINAL] | SDA UI labels this "Pre full sample: in-person + web + panel + PAPI" |
| `V240107b` | Post-election raked weight: FTF+Web+Panel+PAPI combined [FINAL] | SDA UI labels this "Post full sample: in-person + web + panel + PAPI" — **the full-sample post weight** |
| `V240108a` | Pre-election raked weight: FTF+Web+Panel combined (no PAPI) [FINAL] | SDA UI: "Pre full sample: in-person + web + panel" |
| `V240108b` | Post-election raked weight: FTF+Web+Panel combined (no PAPI) [FINAL] | SDA UI: "Post full sample: in-person + web + panel" |
| `V241612` | PRE: How many years in full term for US Senator | Correct answer: 6 |
| `V241613` | PRE: On which program does Federal government spend the least | Correct answer: 1 = Foreign aid |
| `V241614` | PRE: Party with most members in House before election | Correct answer: 2 = Republicans |
| `V241615` | PRE: Party with most members in Senate before election | Correct answer: 1 = Democrats |
| `V242118y` | POST: Office recall catch question [coded] — Lemanu Peleti Mauga (Governor of American Samoa) | Attention-check item, not a standard knowledge item |
| `V242120y1` | POST: Office recall: Senate Majority Leader Schumer [coded] — scheme 1 | Ternary: 0=incorrect, 1=partially correct, 2=correct |
| `V242121y1` | POST: Office recall: Speaker of the House Johnson [coded] — scheme 1 | Binary: 0=incorrect, 1=correct |
| `V242122y1` | POST: Office recall: French President Emmanuel Macron [coded] — scheme 1 | Binary: 0=incorrect, 1=correct. Note: 2024 full release uses the French President (not the German Chancellor, as in 2020) for this office-recall slot |
| `V242123y1` | POST: Office recall: Russian President Vladimir Putin [coded] — scheme 1 | Binary: 0=incorrect, 1=correct |
| `V242124y1` | POST: Office recall: US Supreme Ct Chief Justice Roberts [coded] — scheme 1 | Ternary: 0=incorrect, 1=partially correct, 2=correct |

The weight was resolved by opening the "Analysis" tab's Weight dropdown, which lists full option labels (`V240107a - Pre full sample: in-person + web + panel + PAPI`, `V240108a - Pre full sample: in-person + web + panel`, etc.) — confirming both V240107\* and V240108\* pairs are "full sample" weights, differing only in whether the small PAPI (paper-and-pencil) component is folded in. Both pairs were downloaded rather than guessing which one downstream analysis should use.

### Step 2: Download

Followed the exact method from the section above (same session name `sda2` to avoid clashing with `sda`):
1. `browser-use --session sda2 open https://sda.berkeley.edu/sdaweb/analysis?dataset=anes2024full`
2. Clicked "Download Custom Subset", selected CSV file type on the File Options tab, left the Select Cases filter blank, and typed all 17 variable names into the Select Variables textarea.
3. "Show List of All Variables Selected for Subset" confirmed exactly 17 variables were recognized (none dropped).
4. Clicked "Create Files" — server reported **"17 variables for 5521 cases in subset."**
5. Rather than fight headless-Chromium download plumbing again, extracted the `javax.faces.ViewState` via `browser-use eval`, the `JSESSIONID` cookie via `browser-use cookies get` (the built-in `cookies` subcommand, which the previous session hadn't used, works even though the cookie is `httpOnly` and invisible to `document.cookie`), and the full `subsetWizardForm` field set via `new FormData(form)` in `browser-use eval`. Replicated both button POSTs (`subsetWizardForm:subsetTabview:j_idt1835` for Data file, `j_idt1837` for Codebook) with `curl --data-urlencode` against `https://sda.berkeley.edu/sdaweb/analysis/index.jsf`.
6. Both requests returned `Content-Disposition: attachment` with the expected filenames (`sub-data.txt`, `sub-cdbk.txt`) and full content.
7. Closed the browser session: `browser-use --session sda2 close`.

### Files produced

- `/Users/lukaswallrich/Documents/Coding/ai_rep_polsci/data/raw/anes2024_knowledge.csv` (767,573 bytes; CSV with header row, 5,521 data rows + 1 header row)
- `/Users/lukaswallrich/Documents/Coding/ai_rep_polsci/data/raw/anes2024_knowledge_codebook.txt` (10,722 bytes; ASCII codebook with full entries and value labels for all 17 variables)

### Verification (Python/pandas via `uv run --with pandas`)

- Row count: 5,521 data rows, matching the server's "17 variables for 5521 cases in subset" and the study's documented N ("ANES 2024 Time Series Study Full Release — 5,521 Cases").
- **Case ID join to the CDF confirmed exact:** filtered the previously-downloaded CDF subset (`anes_cdf_1948_2024_subset.csv`) to `VCF0004 == 2024` (5,521 rows) and compared its `VCF0006` values against `V240001` from this download as sets — **5,521 / 5,521 values overlap (100%)**, i.e. `V240001` is exactly the 2024 CDF case ID `VCF0006`, one-to-one, no gaps. `V240001` itself is unique across all 5,521 rows (no duplicates), range 140001–399909.
- Weight variables: `V240107a` (pre, full sample w/PAPI) has all 5,521 cases populated (mean ≈ 1.0000, as expected for a raked weight); `V240107b` (post) is populated for 4,964/5,521 (the rest lack a post-election interview); `V240108a`/`V240108b` (no-PAPI variants) populated for 5,276/5,521 and 4,764/5,521 respectively. All means ≈ 1.0000 as expected.
- Mode of interview: `V240002a` (pre) — 966 FTF, 4,234 Web, 245 Web+PAPI, 76 Panel. `V240002b` (post) has the same coding plus -6 (no post interview, 517 cases) and -7 (insufficient partial, deleted, 40 cases).

**% correct among valid responses (excluding refused/inapplicable/breakoff/no-post-interview/deleted, per the codebook's own sentinel codes -1/-2/-5/-6/-7/-9):**

Pre-election knowledge battery:
| Variable | Item | Correct answer | % correct | Valid N |
|---|---|---|---|---|
| V241612 | Years in full US Senate term | 6 | 41.4% | 5,083 |
| V241613 | Program Federal govt spends least on | 1 = Foreign aid | 27.3% | 5,137 |
| V241614 | Party with House majority before election | 2 = Republicans | 64.9% | 5,134 |
| V241615 | Party with Senate majority before election | 1 = Democrats | 61.9% | 5,128 |

Post-election office recall (coded, scheme 1; ternary items report correct/partial separately, binary items report correct only):
| Variable | Item | % correct | % partial | Valid N |
|---|---|---|---|---|
| V242120y1 | Senate Majority Leader Schumer | 12.3% | 47.6% | 4,027 |
| V242121y1 | Speaker of the House Johnson | 38.6% | — (binary) | 4,027 |
| V242122y1 | French President Macron | 47.8% | — (binary) | 4,027 |
| V242123y1 | Russian President Putin | 90.9% | — (binary) | 4,027 |
| V242124y1 | SCOTUS Chief Justice Roberts | 20.6% | 19.7% | 4,027 |

All percentages reproduce exactly the frequency distributions shown in the downloaded codebook (cross-checked against `hcbk0028.htm`/`hcbk0037.htm`), confirming the CSV data matches the documented distributions.

### Missing / rejected variables

**None.** All 17 requested variable names were accepted; the "Show List of All Variables Selected for Subset" dialog and the "Create Files" confirmation both reported 17 variables.

### Notes for downstream use

- The catch question `V242118y` (Lemanu Peleti Mauga, Governor of American Samoa) is an attention-check/validity item, not a standard knowledge item with a "correct is good" interpretation in the usual sense — 4,598/4,763 (96.5%) valid respondents scored 0 ("incorrect", i.e., did not claim to know an office for this fictitious-sounding but real name), which is the expected/desired pattern for a catch question.
- The office-recall coded "scheme 1" items are **not uniformly binary**: Schumer and Roberts have three levels (0 incorrect / 1 partially correct / 2 correct), while Johnson, Macron, and Putin are binary (0/1). Downstream code computing "% fully correct" must use `== 2` for the two ternary items and `== 1` for the three binary items, not a single `>= 1` or `== max` rule applied uniformly.
- 2024's post-election office-recall battery swaps in Speaker Mike Johnson, Senate Majority Leader Schumer (added; 2020 asked about the Senate Majority Leader as well but the specific office assignments shifted with control of the chamber), French President Macron, Russian President Putin, and SCOTUS Chief Justice Roberts — Macron replaces the German Chancellor slot used in 2020 (Angela Merkel).
- Weight choice: use `V240107b` (post-election, full sample including PAPI) as the default full-sample post-election weight unless there's a specific reason to exclude the PAPI cases (`V240108b`) or to use a pre-election-only weight (`V240107a`) for pre-election-only items.

## ANES 2024 panel link to 2020 (and 2016) Time Series

**Date:** 2026-07-03
**Dataset:** ANES 2024 Time Series Study Full Release (`anes2024full`) on SDA Berkeley

### Finding: the panel link IS in the public file

The 2024 full release's "Technical Weight- and Sample-related Variables" section (codebook page `hcbk0001.htm`) contains, directly and publicly:

| Variable | Label | Notes |
|---|---|---|
| `V200001` | 2020 Time Series Case ID | Valid range 200015–236427; `-1` sentinel for non-panel cases |
| `V160001_orig` | 2016 Time Series Case ID | Valid range 300001–407791; `-1` sentinel for non-panel cases |
| `V240003` | Sample Type | 1 = Panel (2016-20-24), 2 = Fresh sample (WEB), 3 = Fresh sample (FTF), 4 = GSS (0 cases in this release) |
| `V240106a` | Pre-election raked weight: 2016-2024 Panel sample [FINAL] | Panel-subsample-specific weight |
| `V240106b` | Post-election raked weight: 2016-2024 Panel sample [FINAL] | Panel-subsample-specific weight |

Important design detail: the 2024 panel component is a **2016–2020–2024 panel** (respondents first drawn for the 2016 Time Series, re-interviewed in 2020 and again in 2024) — hence every panel case carries *both* a 2020 and a 2016 case ID. There is no separate 2020-only panel; "Panel" in `V240002a/b` mode code 4 and `V240003` code 1 both refer to this 2016-20-24 panel.

### Download

Same method as the sections above (browser-use session `sda2` to set up the subset wizard → 6 variables `V240001 V240003 V200001 V160001_orig V240106a V240106b`, CSV + codebook, no case filter → server confirmed "6 variables for 5521 cases in subset" → ViewState via `browser-use eval`, JSESSIONID via `browser-use cookies get` → two `curl` POSTs replicating the Data file / Codebook buttons). Note: the download-button POST value can be any string (`=x` works); only the button's *name* parameter matters. Browser session closed afterwards.

### Files produced

- `/Users/lukaswallrich/Documents/Coding/ai_rep_polsci/data/raw/anes2024_panel_link.csv` (5,521 data rows + header)
- `/Users/lukaswallrich/Documents/Coding/ai_rep_polsci/data/raw/anes2024_panel_link_codebook.txt`

### Verification (Python/pandas)

- 5,521 rows, 6 columns, `V240001` present for joining to the knowledge file.
- `V240003`: 2,171 panel (code 1), 2,308 fresh web (2), 1,042 fresh FTF (3) — matches the codebook exactly.
- `V200001 > 0` for exactly the 2,171 panel cases (all other cases have the `-1` sentinel); all 2,171 values unique, range 200015–236427.
- **Overlap with the CDF:** all **2,171 / 2,171 (100%)** valid `V200001` values are present among the 8,280 `VCF0006` values for `VCF0004 == 2020` in `data/raw/anes_cdf_1948_2024_subset.csv`. The panel link is fully joinable to the 2020 wave in the cumulative file.
- `V160001_orig > 0` for the same 2,171 panel cases (all unique) — the 2016 link is equally usable.
- Panel weights: `V240106a` populated (>0) for all 2,171 panel cases (mean ≈ 1.0000); `V240106b` for 2,070 (panel cases with a post-election interview); both blank for non-panel cases.

### Notes for downstream use

- Non-panel cases carry `-1` in `V200001`/`V160001_orig` — treat `<= 0` as "no link", don't just test for missing (the CSV writes the sentinel, not a blank).
- For analyses of the 2020→2024 panel subsample use `V240106a/b` (panel-specific raked weights), not the full-sample weights.

## GSS subset

**Date:** 2026-07-03
**Dataset:** GSS 1972-2024 Cumulative Datafile - Release 3 (`gss24rel3`) on SDA Berkeley
**URL:** https://sda.berkeley.edu/sdaweb/analysis?dataset=gss24rel3
**Purpose:** GSS-based conceptual replication of Kalmoe (2020) — knowledge-stratified
ideology in a different survey with a different knowledge proxy (WORDSUM).

### Steps taken

Same PrimeFaces/JSF recipe as the ANES sections above (browser-use `--session gss` to
drive the subset wizard, then replicate the download-button POST-backs with `curl`).

1. `browser-use --session gss open https://sda.berkeley.edu/sdaweb/analysis?dataset=gss24rel3`
   — header confirmed "Study: GSS 1972-2024 Cumulative Datafile - Release 3".
2. Clicked **Download Custom Subset** → 4-tab wizard. On **File Options** selected the CSV
   radio (`subsetWizardForm:subsetTabview:j_idt1749:2`, value `CSV`) via a JS `.click()`;
   the ASCII **Codebook** checkbox was already checked by default.
3. On **Select Variables**, set the `varTextarea` value directly (JS, dispatching input/change
   events) to the variable list; left **Select Cases** filter blank (all cases, all years).
4. **Create Files** → "Show List of All Variables Selected" confirmed the requested count.
   - **First attempt failed:** `ERROR: cannot find the specified variable(s): wtsscomp`.
     `WTSSCOMP` (the weight named in the task brief) **does not exist in gss24rel3**. Consulted
     the static codebook weights section (`DOC/hcbkx15.htm`), which lists the actual weight
     variables: `wtss, wtssall, wtssnr, wtssnrps, wtssps, compwt, formwt, ballotformwt,
     ballotformwtnr`. Replaced `WTSSCOMP` with **`WTSSNRPS`** (the nonresponse-adjusted +
     post-stratification full-series composite).
   - Re-ran Create Files → **"35 variables for 75699 cases in subset."** (no error, all 35
     variable names valid, no case filtering).
5. Extracted `javax.faces.ViewState`, the `subsetWizardForm` FormData (confirming CSV +
   codebook=on + the corrected varTextarea + `subsetTabview_activeIndex=3`), and the
   `JSESSIONID` cookie (`browser-use cookies get`), then replicated the two button POSTs with
   `curl --data-urlencode` against `https://sda.berkeley.edu/sdaweb/analysis/index.jsf`:
   - Data file button `subsetWizardForm:subsetTabview:j_idt1835` → `sub-data.txt`
   - Codebook button `subsetWizardForm:subsetTabview:j_idt1837` → `sub-cdbk.txt`
   The data POST streams slowly (~90 s for 13 MB); run it in the background and wait for the
   file to finish (last line ends in a newline / max year = 2024) before using it.
6. Closed the browser session (`browser-use --session gss close`).

### Variables requested (35, all accepted)

`YEAR ID WTSSALL WTSSNRPS WTSSPS BALLOT MODE FORM SAMPLE POLVIEWS PARTYID PRES84 PRES88
PRES92 PRES96 PRES00 PRES04 PRES08 PRES12 PRES16 PRES20 WORDSUM DEGREE EDUC EQWLTH HELPPOOR
HELPNOT HELPSICK HELPBLK NATARMS NATFARE NATRACE NATHEAL NATEDUC ABANY`

### Missing / substituted variables

- **`WTSSCOMP` → `WTSSNRPS`.** `WTSSCOMP` is not a variable in gss24rel3 (see step 4). Kept
  `WTSSALL` (classic 1972-2018 weight) and `WTSSPS` (post-stratification, all years) as
  requested and added `WTSSNRPS`. VOTE* turnout variables were intentionally skipped (task:
  "skip if not simple"; they are turnout, not vote choice, and are not needed).

### Files produced

- `data/raw/gss_subset.csv` (13,096,178 bytes; header + 75,699 data rows, years 1972-2024)
- `data/raw/gss_subset_codebook.txt` (47,965 bytes; ASCII codebook, one entry per variable)

### Verification (R)

- 75,699 data rows, matching the server's "75699 cases in subset"; 35 columns matching the
  requested names (lowercased by SDA). Years 1972-2024.
- **Missing-data codes are period-prefixed strings** (`.d` DK, `.i` inap/not-asked, `.n`
  no-answer, `.x` not-in-release, `.y` not-in-year, `.r` refused, `.s` skipped-on-web, …) —
  numeric columns therefore import as character; downstream code must map any `^\.` token to
  NA (and, where a DK→midpoint rule applies, treat `.d` specially before that).
- Coding confirmed against the codebook: POLVIEWS 1-7 (1 extremely liberal .. 7 extremely
  conservative), PARTYID 0-6 (+7 other party), PRES* 1=Democrat 2=Republican 3=other
  4=refused 5=no-vote, EQWLTH 1-7 and HELP* 1-5 all coded low=liberal, NAT* 1=too-little
  2=about-right 3=too-much, DEGREE 0-4 (LT HS..Grad).

### Notes for downstream use (verified against the data)

- **WORDSUM is NOT asked every year** (it is a rotating/ballot item). Present: 1974, 1976,
  1978, 1982, 1984, 1987-2000 (most), 2004, 2006-2018, **2022, 2024**. Absent: 1972-73, 1975,
  1977, 1980, 1983, 1985-86, 2002, **2021**. (Contrary to the brief's guess, WORDSUM DOES
  continue past 2018 — only 2021 lacks it.) In many years it is a subsample (~900-2300/yr).
- **Split-ballot joint coverage matters.** In **2004**, WORDSUM and POLVIEWS/the policy battery
  sit on *disjoint* ballots — WORDSUM×POLVIEWS overlap = 0 — so 2004 contributes nothing to
  any WORDSUM-stratified ideology/policy table (it drops out automatically under listwise
  filtering). All other WORDSUM years have healthy joint coverage.
- **Weight span:** `WTSSALL` is defined 1972-2018 only (0 for 2021/2022/2024); `WTSSNRPS`
  only 2004-2024; **`WTSSPS` is the only weight populated for the full 1972-2024 span** and is
  used for the weighted analyses. In an overlap year (2016) WTSSPS ≈ WTSSALL (mean ratio 0.99).
- PARTYID code 7 ("other party", 1,375 cases) is set to NA. POLVIEWS DK (`.d`) is ~3.4% of
  administered cases (much smaller than ANES's non-opinion mass).
