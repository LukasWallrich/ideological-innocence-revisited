## 05_gss.R
## GSS-based CONCEPTUAL REPLICATION of Kalmoe (2020), "Uses and Abuses of Ideology
## in Political Psychology", Political Psychology, doi:10.1111/pops.12650.
##
## Tests whether Kalmoe's knowledge-stratified pattern -- meaningful ideology
## (polar, coherent, potent) confined to the politically knowledgeable minority,
## while partisanship is strong for everyone -- reappears in a DIFFERENT survey
## (GSS Cumulative 1972-2024, SDA release gss24rel3) with a DIFFERENT knowledge
## proxy (WORDSUM 10-item vocabulary), addressing the FORRT "compare across
## datasets" priority.
##
## Source: data/raw/gss_subset.csv (SDA subset, 35 vars, 75,699 cases 1972-2024).
##   Missing codes in the CSV are period-prefixed (.d DK, .i inap/not-asked,
##   .n no-answer, .x not-in-release, .y not-in-year, ...). All ".*" -> NA except
##   where the DK->midpoint rule applies (handled per-variable from raw codes).
##
## Knowledge proxy: WORDSUM 0-10, binned into 5 FIXED ordinal groups (cutpoints
##   chosen once on the pooled distribution to approximate Kalmoe's 9/20/34/25/13
##   shares; held constant across analyses). Secondary stratifier: DEGREE (5 levels)
##   -- an education proxy that covers EVERY year (incl. 2021, when WORDSUM was not
##   asked), used as a clearly-labelled robustness check.
##
## Constructs (all -1..+1, mirroring Kalmoe's conventions):
##   * Ideology ID  : POLVIEWS 1..7 -> (code-4)/3, high=conservative; DK(.d)->0
##                    (analogue of Kalmoe's HTMA->0); DK rate reported.
##   * Partisanship : PARTYID 0..6 -> (code-3)/3, high=Republican; 7 "other"->NA.
##   * Policy index : mean of 5 govt-role items, each -1..+1, high=LIBERAL:
##                    EQWLTH(1-7) + HELPPOOR/HELPNOT/HELPSICK/HELPBLK(1-5). All
##                    GSS-coded low=liberal, so ALL reversed. Item DK(.d)->0
##                    (midpoint, Kalmoe's policy rule); mean of available items.
##   * Rep. vote    : each respondent's MOST-RECENT presidential vote from
##                    PRES84..PRES20 (Rep=1, Dem=0, other/refused/no-vote=NA), with
##                    that election's year for clustering. (GSS PRES* are retro-
##                    spective recall and not mutually exclusive across the two most
##                    recent elections, so most-recent is used.)
##
## Weight: WTSSPS (post-stratification weight, the only weight defined for the FULL
##   1972-2024 span; WTSSALL ends 2018, WTSSNRPS starts 2004). Used for the weighted
##   analyses (polar-half, vote probits); correlations & reliability UNWEIGHTED, as
##   in Kalmoe. Verdict caveats (WORDSUM = verbal ability not political knowledge;
##   GSS vote = recall; GSS POLVIEWS DK tiny) belong in the report, not the code.
##
## Run from project root:  Rscript R/05_gss.R   -> writes output/gss/*.rds + prints.

suppressMessages({library(dplyr); library(tidyr); library(psych); library(sandwich)})
select <- dplyr::select

out <- "output/gss"
dir.create(out, recursive = TRUE, showWarnings = FALSE)

## ============================================================================
## 1. LOAD & CLEAN
## ============================================================================
raw <- read.csv("data/raw/gss_subset.csv", stringsAsFactors = FALSE,
                strip.white = TRUE, colClasses = "character")
tonum <- function(x) { x <- trimws(x); x[grepl("^\\.", x)] <- NA; suppressWarnings(as.numeric(x)) }
d <- as.data.frame(lapply(raw, tonum))

## ---- Knowledge: WORDSUM 5 fixed groups --------------------------------------
## Fixed cutpoints (after scores 3,4,6,8) chosen once to approximate Kalmoe's
## 9/20/34/25/13 shares on the pooled WORDSUM distribution; NOT re-quantiled per
## analysis (mirrors Kalmoe's fixed rating levels). Realized shares ~12/10/38/27/14
## (WORDSUM is a right-skewed 11-value scale, so exact shares are unattainable).
WS_BRKS <- c(-1, 3, 4, 6, 8, 10)
WS_LAB  <- c("Lowest","Low","Middle","High","Highest")
ws_grp  <- function(w) cut(w, breaks = WS_BRKS, labels = WS_LAB)
d$kgrp <- ws_grp(d$wordsum)

## ---- Secondary stratifier: DEGREE (5 levels, covers all years) --------------
DEG_LAB <- c("LT HS","HS","JuCo","BA","Grad")
d$dgrp  <- factor(ifelse(d$degree %in% 0:4, DEG_LAB[d$degree + 1], NA), levels = DEG_LAB)

## ---- Ideology ID: POLVIEWS 1..7 -> -1..+1 (high=conservative); DK(.d)->0 ------
pv_raw <- trimws(raw$polviews)
d$ideo <- ifelse(d$polviews %in% 1:7, (d$polviews - 4) / 3, ifelse(pv_raw == ".d", 0, NA))
d$ideo_cat <- ifelse(d$polviews %in% 1:7, d$polviews, ifelse(pv_raw == ".d", 4L, NA))  # DK->moderate cat
d$pv_asked <- d$polviews %in% 1:7 | pv_raw %in% c(".d", ".n")   # administered POLVIEWS
d$pv_dk    <- pv_raw == ".d"

## ---- Partisanship: PARTYID 0..6 -> -1..+1 (high=Republican); 7->NA -----------
d$party     <- ifelse(d$partyid %in% 0:6, (d$partyid - 3) / 3, NA)
d$party_cat <- ifelse(d$partyid %in% 0:6, d$partyid, NA)

## ---- Policy index: 5 govt-role items, each -1..+1 high=LIBERAL ---------------
## GSS codes all run low=liberal; reverse each. Item DK(.d)->0 (midpoint); other
## non-numeric (.i not-asked, .n no-answer) -> NA. Mean of available items.
pol_items <- c("eqwlth","helppoor","helpnot","helpsick","helpblk")
pol_max   <- c(eqwlth = 7, helppoor = 5, helpnot = 5, helpsick = 5, helpblk = 5)
scale_pol <- function(vname) {
  rawv <- trimws(raw[[vname]]); numv <- suppressWarnings(as.numeric(rawv))
  mx <- pol_max[[vname]]; mid <- (mx + 1) / 2
  s <- ifelse(numv %in% 1:mx, -(numv - mid) / (mid - 1),   # reverse -> high=liberal
              ifelse(rawv == ".d", 0, NA))
  s
}
polM <- sapply(pol_items, scale_pol)
colnames(polM) <- paste0("pol_", pol_items)
d <- bind_cols(d, as.data.frame(polM))
d$pol_nitem <- rowSums(!is.na(polM))
nanmean <- function(M) { m <- rowMeans(M, na.rm = TRUE); m[is.nan(m)] <- NA; m }
d$policy <- nanmean(polM)

## per-item policy DK(.d) rates (among administered = numeric or .d)
pol_dk_rate <- sapply(pol_items, function(v){
  rv <- trimws(raw[[v]]); asked <- rv == ".d" | !is.na(suppressWarnings(as.numeric(rv)))
  mean(rv[asked] == ".d")
})

## ---- Presidential vote: most-recent two-party vote + election year ----------
pres_vars <- c("pres84","pres88","pres92","pres96","pres00","pres04","pres08","pres12","pres16","pres20")
pres_yr   <- c(1984,1988,1992,1996,2000,2004,2008,2012,2016,2020)
# most-recent answered pres var per respondent (highest election year with 1/2 or any code)
pres_code <- d[, pres_vars]
recent_idx <- apply(pres_code, 1, function(r){ w <- which(!is.na(r)); if (length(w)) max(w) else NA_integer_ })
d$elecyear <- ifelse(is.na(recent_idx), NA, pres_yr[recent_idx])
recent_code <- ifelse(is.na(recent_idx), NA, pres_code[cbind(seq_len(nrow(d)), recent_idx)])
d$repvote <- ifelse(recent_code == 2, 1L, ifelse(recent_code == 1, 0L, NA))  # Rep=1 Dem=0 else NA

## ---- Weight -----------------------------------------------------------------
d$wt <- d$wtssps                        # covers all years 1972-2024

saveRDS(d, file.path(out, "gss_analysis.rds"))

## ============================================================================
## 2. YEAR-COVERAGE TABLE (marginal + joint; documents split-ballot dropouts)
## ============================================================================
## NB: joint terms reference the raw item vectors; marginal counts get "_n"
## suffixes so they do not shadow those vectors within this sequential summarise.
coverage <- d %>% group_by(year) %>% summarise(
  n            = n(),
  wordsum_n    = sum(!is.na(wordsum)),
  polviews_n   = sum(!is.na(ideo)),
  partyid_n    = sum(!is.na(party)),
  policy_any   = sum(pol_nitem >= 1),
  policy_all5  = sum(pol_nitem == 5),
  ws_x_polv    = sum(!is.na(wordsum) & !is.na(ideo)),     # joint (split-ballot check)
  ws_x_pol5    = sum(!is.na(wordsum) & pol_nitem == 5),
  degree_n     = sum(!is.na(dgrp)),
  wtssall_n    = sum(!is.na(wtssall)),
  wtssps_n     = sum(!is.na(wtssps)),
  wtssnrps_n   = sum(!is.na(wtssnrps)),
  .groups = "drop")
saveRDS(coverage, file.path(out, "coverage_by_year.rds"))

## realized knowledge-group shares (WORDSUM) & DEGREE shares, plus per-cell N
ws_shares  <- prop.table(table(d$kgrp))
deg_shares <- prop.table(table(d$dgrp))

## ============================================================================
## Helpers
## ============================================================================
polar <- function(s) as.integer(abs(s) >= 0.5)          # inclusive outer-half
lev5  <- c("Lowest","Low","Middle","High","Highest")

## ============================================================================
## 3. ANALYSIS 1 -- POLAR-HALF (Table 1 analogue), WEIGHTED (WTSSPS)
##    ideology, party, policy x knowledge group. WORDSUM (1984+) & DEGREE (all yrs).
## ============================================================================
polar_table <- function(df0, gvar, glevels, constructs) {
  rows <- lapply(names(constructs), function(cn) {
    v <- constructs[[cn]]
    x <- df0 %>% filter(!is.na(.data[[gvar]]), !is.na(.data[[v]]), !is.na(wt)) %>%
      mutate(g = .data[[gvar]], pol = polar(.data[[v]]))
    full <- 100 * weighted.mean(x$pol, x$wt)
    by <- x %>% group_by(g) %>%
      summarise(p = 100 * weighted.mean(pol, wt), n = n(), .groups = "drop")
    vals <- setNames(by$p, as.character(by$g))[glevels]
    ns   <- setNames(by$n, as.character(by$g))[glevels]
    data.frame(construct = cn, N = nrow(x), Full = round(full, 1),
               setNames(as.list(round(vals, 1)), glevels),
               H_minus_L = round(vals[length(glevels)] - vals[1], 1),
               H_div_L   = round(vals[length(glevels)] / vals[1], 2),
               row.names = NULL, check.names = FALSE)
  })
  bind_rows(rows)
}
constructs <- list(Ideology = "ideo", Partisanship = "party", Policy = "policy")

polar_wordsum <- polar_table(d %>% filter(year >= 1984, !is.na(kgrp)), "kgrp", lev5, constructs)
polar_degree  <- polar_table(d %>% filter(year >= 1984, !is.na(dgrp)), "dgrp", DEG_LAB, constructs)
polar_degree_recent <- polar_table(d %>% filter(year >= 2018, !is.na(dgrp)), "dgrp", DEG_LAB, constructs)
saveRDS(list(wordsum = polar_wordsum, degree = polar_degree,
             degree_recent2018 = polar_degree_recent,
             ws_shares = round(100*ws_shares,1), deg_shares = round(100*deg_shares,1)),
        file.path(out, "analysis1_polar.rds"))

## ============================================================================
## 4. ANALYSIS 2 -- RELIABILITY (Table 2 analogue) of the 5 policy items,
##    UNWEIGHTED: Cronbach alpha + avg interitem covariance, by knowledge group.
## ============================================================================
pol_cols <- paste0("pol_", pol_items)
avgcov  <- function(M) { C <- cov(M, use = "pairwise.complete.obs"); mean(C[lower.tri(C)]) }
alpha_r <- function(M) suppressWarnings(psych::alpha(M, warnings = FALSE, check.keys = FALSE)$total$raw_alpha)

reliability_table <- function(df0, gvar, glevels) {
  base <- df0 %>% filter(!is.na(.data[[gvar]]), rowSums(!is.na(across(all_of(pol_cols)))) >= 2)
  sets <- c(list(Full = base), split(base, base[[gvar]])[glevels])
  a <- sapply(sets, function(s) alpha_r(as.matrix(s[, pol_cols])))
  cv <- sapply(sets, function(s) avgcov(as.matrix(s[, pol_cols])))
  n <- sapply(sets, nrow)
  data.frame(stat = c("alpha","avg_interitem_cov","N"),
             rbind(round(a,3), round(cv,3), n), row.names = NULL, check.names = FALSE)
}
rel_wordsum <- reliability_table(d %>% filter(year >= 1984, !is.na(kgrp)), "kgrp", lev5)
rel_degree  <- reliability_table(d %>% filter(year >= 1984, !is.na(dgrp)), "dgrp", DEG_LAB)
saveRDS(list(wordsum = rel_wordsum, degree = rel_degree, pol_dk_rate = round(pol_dk_rate,3)),
        file.path(out, "analysis2_reliability.rds"))

## ============================================================================
## 5. ANALYSIS 3 -- CORRELATIONS (Table 4 analogue) among constructs,
##    UNWEIGHTED Pearson, by knowledge group. Aligned so a positive r means the
##    two constructs agree in liberal/conservative direction ("(rev.)").
## ============================================================================
corr_pairs <- tibble::tribble(
  ~pair,               ~a,      ~b,
  "Ideology x Party",  "ideo",  "party",
  "Ideology x Policy", "ideo",  "policy",   # ideo high=cons, policy high=lib -> abs()
  "Party x Policy",    "party", "policy")
corr_table <- function(df0, gvar, glevels) {
  rows <- lapply(seq_len(nrow(corr_pairs)), function(i){
    a <- corr_pairs$a[i]; b <- corr_pairs$b[i]
    x <- df0 %>% filter(!is.na(.data[[gvar]]), !is.na(.data[[a]]), !is.na(.data[[b]])) %>%
      mutate(g = .data[[gvar]])
    rr <- function(s) abs(cor(s[[a]], s[[b]]))          # abs = direction-aligned
    vals <- c(Full = rr(x),
              sapply(glevels, function(gl){ s <- x[x$g == gl,]; if (nrow(s) > 2) rr(s) else NA }))
    ns   <- c(Full = nrow(x), sapply(glevels, function(gl) sum(x$g == gl)))
    data.frame(pair = corr_pairs$pair[i],
               setNames(as.list(round(vals, 3)), names(vals)),
               H_minus_L = round(vals[length(vals)] - vals[2], 3),
               N = nrow(x), row.names = NULL, check.names = FALSE)
  })
  bind_rows(rows)
}
corr_wordsum <- corr_table(d %>% filter(year >= 1984, !is.na(kgrp)), "kgrp", lev5)
corr_degree  <- corr_table(d %>% filter(year >= 1984, !is.na(dgrp)), "dgrp", DEG_LAB)
saveRDS(list(wordsum = corr_wordsum, degree = corr_degree),
        file.path(out, "analysis3_correlations.rds"))

## ============================================================================
## 6. ANALYSIS 4 -- VOTE PROBITS (Table 5 analogue). Weighted (WTSSPS) bivariate
##    probit of Republican pres. vote on each construct; robust SE clustered by
##    election year; McFadden pseudo-R2. Full + by WORDSUM group.
##    Predictors point toward Republican vote: ideo (high=cons), party (high=Rep)
##    as-is; policy (high=lib) reversed.
## ============================================================================
fit_probit <- function(dat, pexpr) {
  dat$pred <- eval(parse(text = pexpr), dat)
  dat <- dat %>% filter(!is.na(pred), !is.na(repvote), !is.na(wt), !is.na(elecyear))
  if (nrow(dat) < 30 || length(unique(dat$repvote)) < 2) return(list(coef=NA,se=NA,r2=NA,N=nrow(dat)))
  m  <- suppressWarnings(glm(repvote ~ pred, data = dat, family = binomial("probit"), weights = wt))
  m0 <- suppressWarnings(glm(repvote ~ 1,    data = dat, family = binomial("probit"), weights = wt))
  mcf <- 1 - as.numeric(logLik(m) / logLik(m0))
  nclust <- length(unique(dat$elecyear))
  se <- tryCatch({ if (nclust > 1) sqrt(diag(sandwich::vcovCL(m, cluster = dat$elecyear)))["pred"]
                   else sqrt(diag(vcov(m)))["pred"] }, error = function(e) sqrt(diag(vcov(m)))["pred"])
  list(coef = unname(coef(m)["pred"]), se = unname(se), r2 = mcf, N = nrow(dat))
}
probit_specs <- list(Ideology = "ideo", Partisanship = "party", Policy = "-policy")
probit_rows <- lapply(names(probit_specs), function(nm) {
  ex <- probit_specs[[nm]]
  base <- d %>% filter(!is.na(kgrp), !is.na(repvote))
  rf <- fit_probit(base, ex)
  rg <- lapply(lev5, function(gl) fit_probit(base[base$kgrp == gl, ], ex))
  names(rg) <- lev5
  data.frame(predictor = nm, stat = c("coef","se","pseudoR2","N"),
    Full = c(rf$coef, rf$se, rf$r2, rf$N),
    setNames(lapply(lev5, function(gl) c(rg[[gl]]$coef, rg[[gl]]$se, rg[[gl]]$r2, rg[[gl]]$N)), lev5),
    row.names = NULL, check.names = FALSE)
})
probit_table <- bind_rows(probit_rows)
probit_table[probit_table$stat != "N", -(1:2)] <- round(probit_table[probit_table$stat != "N", -(1:2)], 3)
saveRDS(probit_table, file.path(out, "analysis4_probit.rds"))

## ============================================================================
## 7. ANALYSIS 5 -- TIME TREND. Ideology x Party and Ideology x Policy Pearson
##    correlations by decade, full sample and top vs bottom WORDSUM knowledge.
## ============================================================================
d$decade <- paste0(floor(d$year/10)*10, "s")
trend_rows <- list()
for (pr in list(c("Ideology x Party","ideo","party"), c("Ideology x Policy","ideo","policy"))) {
  a <- pr[2]; b <- pr[3]
  for (dc in sort(unique(d$decade))) {
    sub <- d %>% filter(decade == dc, !is.na(.data[[a]]), !is.na(.data[[b]]))
    rr  <- function(s) if (nrow(s) > 3) round(abs(cor(s[[a]], s[[b]])), 3) else NA
    top <- sub %>% filter(kgrp %in% c("High","Highest"))
    bot <- sub %>% filter(kgrp %in% c("Lowest","Low"))
    trend_rows[[length(trend_rows)+1]] <- data.frame(
      pair = pr[1], decade = dc, N_full = nrow(sub),
      r_full = rr(sub), r_bottomK = rr(bot), r_topK = rr(top),
      N_bottomK = nrow(bot), N_topK = nrow(top))
  }
}
time_trend <- bind_rows(trend_rows)
saveRDS(time_trend, file.path(out, "analysis5_timetrend.rds"))

## ============================================================================
## 8. POLVIEWS DK / no-opinion rate by knowledge group (opinionation analogue)
## ============================================================================
dk_by_group <- d %>% filter(year >= 1984, pv_asked, !is.na(kgrp)) %>%
  group_by(kgrp) %>% summarise(n_asked = n(), dk_rate = round(mean(pv_dk), 4), .groups = "drop")
dk_full <- d %>% filter(year >= 1984, pv_asked) %>% summarise(dk_rate = round(mean(pv_dk),4)) %>% pull()
moderate_share <- d %>% filter(year >= 1984, polviews %in% 1:7) %>%
  summarise(m = round(mean(polviews == 4), 4)) %>% pull()   # substantive "moderate" category
saveRDS(list(by_group = dk_by_group, full = dk_full, moderate_cat_share = moderate_share),
        file.path(out, "analysis6_polviews_dk.rds"))

## ============================================================================
## CONSOLE SUMMARY
## ============================================================================
cat("== GSS conceptual replication of Kalmoe (2020) ==\n")
cat("rows:", nrow(d), " years:", min(d$year), "-", max(d$year), "\n")
cat("WORDSUM group shares (%):", paste(names(ws_shares), round(100*ws_shares,1), sep="="), "\n")
cat("POLVIEWS DK rate (asked cases, 1984+):", dk_full, " | moderate-cat share:", moderate_share, "\n")
cat("policy per-item DK(.d) rates:", paste(pol_items, round(pol_dk_rate,3), sep="="), "\n\n")
cat("--- Analysis 1: polar-half by WORDSUM (weighted) ---\n"); print(polar_wordsum)
cat("\n--- Analysis 2: policy reliability by WORDSUM ---\n"); print(rel_wordsum)
cat("\n--- Analysis 3: correlations by WORDSUM ---\n"); print(corr_wordsum)
cat("\n--- Analysis 4: vote probit by WORDSUM ---\n"); print(probit_table)
cat("\n--- Analysis 5: time trend (ideo x party / ideo x policy) ---\n"); print(time_trend)
cat("\n--- Analysis 6: POLVIEWS DK by WORDSUM group ---\n"); print(as.data.frame(dk_by_group))
cat("\nSaved outputs to", out, "\n")
