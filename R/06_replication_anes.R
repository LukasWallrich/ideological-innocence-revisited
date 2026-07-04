## ============================================================================
## 06_replication_anes.R  --  Replication-with-new-data of Kalmoe (2020),
##   "Uses and Abuses of Ideology in Political Psychology", Political Psychology,
##   doi:10.1111/pops.12650, extended to ANES 2020 and 2024 (data unavailable to
##   the original, which ran through 2016).
##
## Single entry point; runs end-to-end from the project root:
##     Rscript R/06_replication_anes.R
##
## Question: do the paper's conclusions hold in 2020/2024? (a) has mass ideological
## coherence/polarity/stability/potency risen relative to 1984-2016; (b) does the
## knowledge stratification ("meaningful ideology for a knowledgeable minority only")
## persist?
##
## MODULES
##   M1  Knowledge index (2020, 2024): proportion-correct quiz, binned to approximate
##       Kalmoe's 5 interviewer-rating shares; merged voter groups.
##   M2  Cross-sectional analogues (Fig 1, Tables 1,2,4,5, opinionation) per year,
##       side-by-side vs original 1984-2016 and SI 2008-16 (Tables C1-C5).
##   M3  Stability (Table 3 analogue): 2020->2024 squared continuity r^2 on the
##       2016-20-24 panel; bonus 2016->2020 / 2016->2024 rows.
##   M4  Verdicts per headline claim.
##
## Coding choices mirror the reproduction (output/repro_main/reproduction_report.md):
##   constructs on -1..+1; HTMA(VCF0803=9)->0 with moderates; policy DK(=9)->midpoint;
##   indices = mean of available items; polar half = |score| >= 0.5 (inclusive).
## FORCED DEVIATIONS (documented in the report):
##   * Knowledge: interviewer rating (VCF0050a) discontinued after 2016 -> quiz index
##     (decisions_log D5). Primary = 4 PRE civics items, proportion correct; the 5
##     natural score levels (0/.25/.5/.75/1) are the 5 knowledge groups (mirrors
##     Kalmoe's "5 fixed levels, not quantiles"). pre+post index kept as sensitivity.
##   * Mode: 2020/2024 are predominantly web; the FTF/phone restriction cannot apply.
##   * Egalitarianism has only 4 of 6 CDF items and moral traditionalism only 2 of 4
##     in 2020/2024 -> reliability comparisons lead with average inter-item COVARIANCE
##     (item-count invariant); alpha is flagged as not comparable across item counts,
##     and a matched-item 1984-2016 baseline (same 4 egal / 2 MT items) is provided.
##   * Two-party vote from VCF0704 (VCF0704a empty for 2024); single year per model ->
##     HC1 robust SEs (not year-clustered).
## ============================================================================

suppressMessages({library(dplyr); library(tidyr); library(psych); library(sandwich)})

OUT <- "output/replication"
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
num <- function(x) suppressWarnings(as.numeric(if (inherits(x, "haven_labelled")) unclass(x) else x))

## ---------------------------------------------------------------- helpers ----
## 5-pt agree-disagree CPV item -> -1..+1 (code1 agree->+1, 3 neither->0, 5->-1);
## dir=+1 if agreement is construct-high, -1 if reverse-worded.
sc5 <- function(x, dir) { x <- num(x); x[!x %in% 1:5] <- NA; s <- (3 - x) / 2; if (dir < 0) -s else s }
## 7-pt policy item -> -1..+1; DK(=9)->midpoint(0); dir=+1 aligned, -1 reversed.
pol7 <- function(x, dir) { x <- num(x); s <- ifelse(x %in% 1:7, (x - 4) / 3, ifelse(x == 9, 0, NA)); if (dir < 0) -s else s }
nanmean <- function(M) { m <- rowMeans(M, na.rm = TRUE); m[is.nan(m)] <- NA; m }
polar   <- function(s) as.integer(abs(s) >= 0.5)             # inclusive outer half
wmean   <- function(x, w) { ok <- !is.na(x) & !is.na(w); if (!any(ok)) return(NA); sum(x[ok]*w[ok])/sum(w[ok]) }
avgcov  <- function(M) { C <- cov(M, use = "pairwise.complete.obs"); mean(C[lower.tri(C)]) }
alpha_raw <- function(M) suppressWarnings(psych::alpha(M, warnings = FALSE, check.keys = FALSE)$total$raw_alpha)

## Build the five constructs + item columns from CDF rows (harmonised VCF coding).
## Egalitarianism uses the 4 CDF items present in 2020/2024 (VCF9013/9018 pro,
## VCF9016/9017 anti); moral traditionalism the 2 present items (VCF0853 pro,
## VCF0852 reverse); policy the 5 classic items.
build_constructs <- function(s) {
  io <- num(s$VCF0803)
  ideo     <- ifelse(io %in% 1:7, (io - 4)/3, ifelse(io == 9, 0, NA))   # high=conservative; HTMA->0
  ideo_cat <- ifelse(io %in% 1:7, io, ifelse(io == 9, 4L, NA))          # HTMA folded into "moderate" for Fig 1
  pa <- num(s$VCF0301)
  party     <- ifelse(pa %in% 1:7, (pa - 4)/3, NA)                       # high=Republican
  party_cat <- ifelse(pa %in% 1:7, pa, NA)
  vt <- num(s$VCF0704); repvote <- ifelse(vt == 2, 1L, ifelse(vt == 1, 0L, NA))  # Rep=1, Dem=0
  eg1 <- sc5(s$VCF9013, +1); eg2 <- sc5(s$VCF9018, +1); eg3 <- sc5(s$VCF9016, -1); eg4 <- sc5(s$VCF9017, -1)
  egM <- cbind(eg1, eg2, eg3, eg4)
  m1 <- sc5(s$VCF0853, +1); m2 <- sc5(s$VCF0852, -1); mtM <- cbind(m1, m2)
  p1 <- pol7(s$VCF0843, -1); p2 <- pol7(s$VCF0809, -1); p3 <- pol7(s$VCF0830, -1)
  p4 <- pol7(s$VCF0806, -1); p5 <- pol7(s$VCF0839, +1); polM <- cbind(p1, p2, p3, p4, p5)
  out <- data.frame(
    caseid = num(s$VCF0006), year = num(s$VCF0004), mode_cdf = num(s$VCF0017),
    ideo = ideo, ideo_cat = ideo_cat, party = party, party_cat = party_cat, repvote = repvote,
    ideo_raw = io,
    egal = nanmean(egM), mt = nanmean(mtM), policy = nanmean(polM))
  out <- cbind(out,
    setNames(as.data.frame(egM), paste0("egal_i", 1:4)),
    setNames(as.data.frame(mtM), paste0("mt_i", 1:2)),
    setNames(as.data.frame(polM), paste0("pol_i", 1:5)),
    pol_raw = as.data.frame(sapply(c("VCF0843","VCF0809","VCF0830","VCF0806","VCF0839"), function(v) num(s[[v]]))))
  out
}

## ============================================================================
## LOAD DATA
## ============================================================================
cdf <- read.csv("data/raw/anes_cdf_1948_2024_subset.csv", stringsAsFactors = FALSE)
cdf[cdf == " "] <- NA; cdf[cdf == ""] <- NA

## ============================================================================
## M1  KNOWLEDGE INDEX
## ============================================================================
## proportion-correct helpers: administered = item asked (not a no-interview
## sentinel); DK/RF/breakoff/partial count as INCORRECT (standard).
prop_correct <- function(corr, adm) { nc <- rowSums(corr & adm, na.rm = TRUE); na_ <- rowSums(adm, na.rm = TRUE); ifelse(na_ > 0, nc/na_, NA) }
## bin a lumpy index to approximate cumulative target shares (used for pre+post sensitivity)
bin_sharetarget <- function(idx, target = c(.09,.20,.34,.25,.13)) {
  cum_t <- cumsum(target)[1:4]; v <- idx[!is.na(idx)]; uv <- sort(unique(v))
  cf <- sapply(uv, function(z) mean(v <= z)); brks <- unique(sapply(cum_t, function(ct) uv[which.min(abs(cf - ct))]))
  cut(idx, breaks = c(-Inf, brks, Inf), labels = FALSE)
}
klab5 <- c(`0`="Lowest", `0.25`="Low", `0.5`="Middle", `0.75`="High", `1`="Highest")
grp5  <- function(k) factor(klab5[as.character(k)], levels = c("Lowest","Low","Middle","High","Highest"))
grp4  <- function(k) factor(ifelse(k <= 0.25, "Lower", klab5[as.character(k)]), levels = c("Lower","Middle","High","Highest"))

## ---- 2020 knowledge (timeseries_2020: V201644-47 pre civics; V202139-42y1 post recall) ----
load("data/raw/timeseries_2020.rda"); t20 <- timeseries_2020; g <- function(v) num(t20[[v]])
pre_c20 <- cbind(g("V201644")==6, g("V201645")==1, g("V201646")==1, g("V201647")==2)  # answers verified from labels
pre_a20 <- sapply(c("V201644","V201645","V201646","V201647"), function(v){ x <- g(v); !(x %in% c(-6,-7)) })
post_c20 <- cbind(g("V202139y1")==1, g("V202140y1")==1, g("V202141y1")==1, g("V202142y1")==1)  # binary, ==1 correct
post_a20 <- sapply(c("V202139y1","V202140y1","V202141y1","V202142y1"), function(v){ x <- g(v); x >= 0 })
know20 <- data.frame(caseid = g("V200001"),
                     know_pre     = prop_correct(pre_c20, pre_a20),
                     know_prepost = prop_correct(cbind(pre_c20, post_c20), cbind(pre_a20, post_a20)),
                     wt_pre  = g("V200010a"), wt_post = g("V200010b"),
                     id2016  = num(t20[["V160001_orig"]]))

## ---- 2024 knowledge (anes2024_knowledge.csv) ----
k24 <- read.csv("data/raw/anes2024_knowledge.csv", stringsAsFactors = FALSE); h <- function(v) num(k24[[v]])
pre_c24 <- cbind(h("V241612")==6, h("V241613")==1, h("V241614")==2, h("V241615")==1)
pre_a24 <- sapply(c("V241612","V241613","V241614","V241615"), function(v){ x <- h(v); !(x %in% c(-6,-7)) })
post_c24 <- cbind(h("V242120y1")==2, h("V242121y1")==1, h("V242122y1")==1, h("V242123y1")==1, h("V242124y1")==2) # 2 ternary(==2), 3 binary(==1)
post_a24 <- sapply(c("V242120y1","V242121y1","V242122y1","V242123y1","V242124y1"), function(v){ x <- h(v); x >= 0 })
know24 <- data.frame(caseid = h("V240001"),
                     know_pre     = prop_correct(pre_c24, pre_a24),
                     know_prepost = prop_correct(cbind(pre_c24, post_c24), cbind(pre_a24, post_a24)),
                     wt_pre = h("V240107a"), wt_post = h("V240107b"),
                     mode24 = h("V240002a"))                       # 1 FTF, 2 Web, 3 Web+PAPI, 4 Panel

## primary index = pre-only 4-item; 5 natural levels -> 5 groups
know20$know5 <- grp5(know20$know_pre); know20$know4 <- grp4(know20$know_pre)
know24$know5 <- grp5(know24$know_pre); know24$know4 <- grp4(know24$know_pre)

achieved_shares <- function(kn) {
  data.frame(
    metric = c("pre_only(primary)","pre_post(sensitivity)"),
    Lowest = c(round(100*mean(kn$know_pre==0, na.rm=TRUE),1), NA),
    rbind(round(100*prop.table(table(factor(kn$know_pre, levels=c(0,.25,.5,.75,1)))),1),
          round(100*prop.table(table(factor(bin_sharetarget(kn$know_prepost), levels=1:5))),1)) |> setNames(c("g1","g2","g3","g4","g5")))
}
shares20 <- data.frame(year=2020,
  group=c("Lowest","Low","Middle","High","Highest"),
  target_1984_2016 = c(9,20,34,25,13),
  pre_only  = as.numeric(round(100*prop.table(table(factor(know20$know_pre, levels=c(0,.25,.5,.75,1)))),1)),
  pre_post  = as.numeric(round(100*prop.table(table(factor(bin_sharetarget(know20$know_prepost), levels=1:5))),1)))
shares24 <- data.frame(year=2024,
  group=c("Lowest","Low","Middle","High","Highest"),
  target_1984_2016 = c(9,20,34,25,13),
  pre_only  = as.numeric(round(100*prop.table(table(factor(know24$know_pre, levels=c(0,.25,.5,.75,1)))),1)),
  pre_post  = as.numeric(round(100*prop.table(table(factor(bin_sharetarget(know24$know_prepost), levels=1:5))),1)))
saveRDS(list(shares_2020 = shares20, shares_2024 = shares24,
             know2020 = know20, know2024 = know24,
             mean_know = c(y2020 = mean(know20$know_pre, na.rm=TRUE), y2024 = mean(know24$know_pre, na.rm=TRUE))),
        file.path(OUT, "knowledge.rds"))

## ============================================================================
## Assemble per-year analysis frames (CDF constructs + knowledge + weights + mode)
## ============================================================================
frame_year <- function(yr, kn) {
  s <- cdf[num(cdf$VCF0004) == yr, ]
  cc <- build_constructs(s)
  m <- merge(cc, kn[, c("caseid","know_pre","know_prepost","know5","know4","wt_pre","wt_post")],
             by = "caseid", all.x = TRUE)
  m
}
d20 <- frame_year(2020, know20)
d24 <- frame_year(2024, know24)
stopifnot(nrow(d20) == 8280, nrow(d24) == 5521, mean(!is.na(d20$know5)) > .99, mean(!is.na(d24$know5)) > .99)
## mode indicators (interviewer present?)  2020: web=4 no interviewer; video=5/phone=3 yes.
d20$web <- d20$mode_cdf == 4
d20$mode_lab <- ifelse(d20$mode_cdf == 4, "Web", ifelse(d20$mode_cdf == 5, "Video", ifelse(d20$mode_cdf == 3, "Phone", "Other")))
d24 <- merge(d24, know24[, c("caseid","mode24")], by = "caseid", all.x = TRUE)
d24$web <- d24$mode24 %in% c(2,3,4)      # web / web+PAPI / panel-web
d24$mode_lab <- ifelse(d24$mode24 == 1, "FTF", ifelse(d24$mode24 %in% c(2,3), "Web", ifelse(d24$mode24 == 4, "Web(panel)", "Other")))

## ============================================================================
## COMPARISON ANCHORS (original 1984-2016 = Tables 1,2,4,5; SI 2008-16 = C1-C5)
## ============================================================================
anchor_full <- data.frame(
  construct = c("Egalitarianism","Moral Tradition","Policy Views","Ideology ID","Partisanship"),
  breadth_8416 = c(32,35,18,27,61),     breadth_0816 = c(34,34,26,32,58),
  alpha_8416   = c(.67,.62,.64,NA,NA),  alpha_0816   = c(.67,.57,.70,NA,NA),
  cov_8416     = c(.10,.11,.08,NA,NA),  cov_0816     = c(.10,.10,.10,NA,NA),
  avgcorr_8416 = c(.36,.31,.39,.39,.37),avgcorr_0816 = c(.37,.33,.40,.42,.42),
  voter2_8416  = c(.15,.13,.21,.23,.49),voter2_0816  = c(.20,.18,.25,.32,.53))
## info-gain (Highest/Lowest) ratios, for the stratification-persistence trajectory.
## Includes the MEASURE-MATCHED quiz-stratified original-era benchmark (SI Tables B1/B5,
## 1986-92 / 1988-92 quiz knowledge) -- the fair comparison to the 2020/2024 quiz index,
## since interviewer-rated gradients (Table 1/5, C1/C5) are known to be more distinct.
anchor_infogain <- data.frame(
  construct = c("Egalitarianism","Moral Tradition","Policy Views","Ideology ID","Partisanship"),
  breadth_HdivL_8416      = c(1.65,2.65,2.64,4.00,1.63),   # Table 1  (interviewer)
  breadth_HdivL_0816      = c(1.67,2.56,2.11,3.27,1.61),   # Table C1 (interviewer)
  breadth_HdivL_quiz8692  = c(1.24,1.96,1.31,2.29,1.08),   # Table B1 (QUIZ, measure-matched)
  vote_R2_HdivL_8416      = c(5.60,6.50,4.63,10.75,1.88),  # Table 5  (interviewer)
  vote_R2_HdivL_0816      = c(6.60,3.50,4.44,4.50,1.42),   # Table C5 (interviewer)
  vote_R2_HdivL_quiz8892  = c(1.31,3.40,8.60,10.50,1.81))  # Table B5 (QUIZ, measure-matched)
## SI Table B5 quiz-stratified Lowest-group ideology vote pseudo-R2 = .04 (Full .19, Highest .42)

## ============================================================================
## M2  CROSS-SECTIONAL ANALOGUES
## ============================================================================
CONS <- c(egal="Egalitarianism", mt="Moral Tradition", policy="Policy Views", ideo="Ideology ID", party="Partisanship")

## ---- Table 1 analogue: % in polar half, weighted (pre weight), by knowledge ----
tbl1 <- function(df, wname = "wt_pre") {
  do.call(rbind, lapply(names(CONS), function(v) {
    x <- df[!is.na(df[[v]]) & !is.na(df$know5), ]; w <- x[[wname]]
    full <- 100*wmean(polar(x[[v]]), w)
    by <- sapply(levels(x$know5), function(gl){ s <- x[x$know5==gl,]; 100*wmean(polar(s[[v]]), s[[wname]]) })
    data.frame(construct = CONS[v], N = nrow(x), Full = full,
               Lowest = by["Lowest"], Low = by["Low"], Middle = by["Middle"], High = by["High"], Highest = by["Highest"],
               H_minus_L = by["Highest"]-by["Lowest"], H_div_L = by["Highest"]/by["Lowest"], row.names = NULL)
  }))
}
t1_20 <- tbl1(d20); t1_24 <- tbl1(d24)

## ---- Table 2 analogue: alpha + avg interitem covariance, unweighted, by knowledge ----
item_cols <- list(egal = paste0("egal_i",1:4), mt = paste0("mt_i",1:2), policy = paste0("pol_i",1:5))
tbl2 <- function(df) {
  rows <- list()
  for (v in c("egal","mt","policy")) {
    cols <- item_cols[[v]]
    base <- df[rowSums(!is.na(df[,cols])) > 0 & !is.na(df$know5), ]
    sets <- c(list(Full = base), split(base, base$know5)[c("Lowest","Low","Middle","High","Highest")])
    aa <- sapply(sets, function(s) if (nrow(s) > 5) alpha_raw(as.matrix(s[,cols])) else NA)
    cc <- sapply(sets, function(s) if (nrow(s) > 5) avgcov(as.matrix(s[,cols])) else NA)
    rows[[paste0(v,"_alpha")]] <- data.frame(construct=CONS[v], stat="alpha",   t(round(aa,3)))
    rows[[paste0(v,"_cov")]]   <- data.frame(construct=CONS[v], stat="avg_cov", t(round(cc,3)))
  }
  do.call(rbind, rows)
}
t2_20 <- tbl2(d20); t2_24 <- tbl2(d24)

## ---- Table 4 analogue: unweighted Pearson correlations among constructs, by knowledge ----
pairs4 <- data.frame(a = c("egal","egal","egal","egal","mt","mt","mt","policy","policy","ideo"),
                     b = c("mt","policy","ideo","party","policy","ideo","party","ideo","party","party"),
                     stringsAsFactors = FALSE)
pairlab <- c("Egal x MoralTrad(rev)","Egal x Policy","Egal x IdeoID(rev)","Egal x Party(rev)",
             "MoralTrad x Policy(rev)","MoralTrad x IdeoID","MoralTrad x Party",
             "Policy x IdeoID(rev)","Policy x Party(rev)","IdeoID x Party")
tbl4 <- function(df) {
  lev6 <- c("Full","Lowest","Low","Middle","High","Highest")
  rows <- lapply(seq_len(nrow(pairs4)), function(i) {
    a <- pairs4$a[i]; b <- pairs4$b[i]
    x <- df[!is.na(df[[a]]) & !is.na(df[[b]]) & !is.na(df$know5), ]
    rr <- function(s) if (nrow(s) > 2) abs(cor(s[[a]], s[[b]])) else NA   # abs = "(rev.)"-aligned
    vals <- c(Full = rr(x), sapply(lev6[-1], function(gl) rr(x[x$know5==gl,])))
    data.frame(pair = pairlab[i], N = nrow(x), t(round(vals,3)))
  })
  do.call(rbind, rows)
}
t4_20 <- tbl4(d20); t4_24 <- tbl4(d24)
## average correlation per construct (C4-style, grouping-robust)
avgcorr_by_construct <- function(t4) {
  m <- setNames(t4$Full, t4$pair)
  invol <- list(Egalitarianism = 1:4, `Moral Tradition` = c(1,5,6,7), `Policy Views` = c(2,5,8,9),
                `Ideology ID` = c(3,6,8,10), Partisanship = c(4,7,9,10))
  sapply(invol, function(ix) round(mean(m[ix]),3))
}
ac20 <- avgcorr_by_construct(t4_20); ac24 <- avgcorr_by_construct(t4_24)

## ---- Table 5 analogue: weighted bivariate probit of Rep two-party vote, HC1 SEs ----
t5_specs <- data.frame(name = CONS, expr = c("-egal","mt","-policy","ideo","party"), stringsAsFactors = FALSE)
fit_probit <- function(dat, pexpr, wname = "wt_post") {
  dat$pred <- eval(parse(text = pexpr), dat)
  dat <- dat[!is.na(dat$pred) & !is.na(dat$repvote) & !is.na(dat[[wname]]), ]
  if (nrow(dat) < 30 || length(unique(dat$repvote)) < 2) return(list(coef=NA, se=NA, r2=NA, N=nrow(dat)))
  w <- dat[[wname]]
  m  <- suppressWarnings(glm(repvote ~ pred, data = dat, family = binomial("probit"), weights = w))
  m0 <- suppressWarnings(glm(repvote ~ 1,    data = dat, family = binomial("probit"), weights = w))
  se <- tryCatch(sqrt(diag(sandwich::vcovHC(m, type = "HC1")))["pred"], error = function(e) sqrt(diag(vcov(m)))["pred"])
  list(coef = unname(coef(m)["pred"]), se = unname(se), r2 = 1 - as.numeric(logLik(m)/logLik(m0)), N = nrow(dat))
}
tbl5 <- function(df) {
  lev <- c("Full","Lower","Middle","High","Highest")
  rows <- lapply(seq_len(nrow(t5_specs)), function(i) {
    ex <- t5_specs$expr[i]
    base <- df[!is.na(df$know4), ]
    rf <- fit_probit(base, ex)
    rg <- lapply(levels(base$know4), function(gl) fit_probit(base[base$know4==gl,], ex))
    names(rg) <- levels(base$know4)
    coef <- c(Full=rf$coef, sapply(rg, `[[`, "coef")); se <- c(Full=rf$se, sapply(rg, `[[`, "se")); r2 <- c(Full=rf$r2, sapply(rg, `[[`, "r2"))
    data.frame(predictor = t5_specs$name[i], N = rf$N, stat = c("coef","se","pseudoR2"),
               Full = c(rf$coef, rf$se, rf$r2),
               Lower = c(rg$Lower$coef, rg$Lower$se, rg$Lower$r2),
               Middle = c(rg$Middle$coef, rg$Middle$se, rg$Middle$r2),
               High = c(rg$High$coef, rg$High$se, rg$High$r2),
               Highest = c(rg$Highest$coef, rg$Highest$se, rg$Highest$r2),
               H_div_L_R2 = c(NA, NA, rg$Highest$r2/rg$Lower$r2))
  })
  do.call(rbind, rows)
}
t5_20 <- tbl5(d20); t5_24 <- tbl5(d24)

## ---- Opinionation (HTMA, policy DK, knowledge gaps), incl. by mode ----
opinionation <- function(df) {
  adm <- df$ideo_raw %in% c(1:7, 9)
  htma_rate <- mean(df$ideo_raw[adm] == 9)
  kn_htma  <- mean(df$know_pre[df$ideo_raw == 9], na.rm = TRUE)
  kn_ident <- mean(df$know_pre[df$ideo_raw %in% c(1,2,3,5,6,7)], na.rm = TRUE)
  kn_mod   <- mean(df$know_pre[df$ideo_raw == 4], na.rm = TRUE)
  pol_raw <- df[, grep("^pol_raw", names(df))]
  dkrate <- sapply(pol_raw, function(x){ a <- x %in% c(1:7,9); mean(x[a]==9) })
  allasked <- rowSums(sapply(pol_raw, function(x) x %in% c(1:7,9))) == 5
  dkcount  <- rowSums(sapply(pol_raw, function(x) x == 9))
  pct_all5 <- mean(dkcount[allasked] == 0)
  kn_dk3 <- mean(df$know_pre[allasked & dkcount >= 3], na.rm = TRUE)
  kn_dk0 <- mean(df$know_pre[allasked & dkcount == 0], na.rm = TRUE)
  ## by mode: HTMA rate + mean policy-DK count among administered
  bymode <- df %>% mutate(dkc = rowSums(sapply(pol_raw, function(x) x == 9)),
                          htma = ifelse(ideo_raw %in% c(1:7,9), as.integer(ideo_raw==9), NA)) %>%
    group_by(mode_lab) %>% summarise(n = n(), htma_rate = round(mean(htma, na.rm=TRUE),3),
                                     mean_policyDK = round(mean(dkc, na.rm=TRUE),2), .groups="drop")
  list(summary = data.frame(
         stat = c("htma_rate","knowledge_HTMA","knowledge_libcon","knowledge_moderate(between)",
                  "policy_DK_min","policy_DK_max","pct_answered_all5","knowledge_DK3plus","knowledge_answeredall5"),
         value = round(c(htma_rate, kn_htma, kn_ident, kn_mod, min(dkrate), max(dkrate), pct_all5, kn_dk3, kn_dk0),3)),
       policy_dk_rates = round(dkrate,3), by_mode = as.data.frame(bymode))
}
op20 <- opinionation(d20); op24 <- opinionation(d24)

## ---- Figure 1 analogue: distributions of the five constructs (+ %HTMA) ----
fig1 <- function(df) {
  fi <- df[!is.na(df$ideo_cat),] %>% count(ideo_cat) %>% mutate(pct = round(100*n/sum(n),1),
        label = c("Extremely liberal","Liberal","Slightly liberal","Moderate/HTMA","Slightly conservative","Conservative","Extremely conservative")[ideo_cat])
  fp <- df[!is.na(df$party_cat),] %>% count(party_cat) %>% mutate(pct = round(100*n/sum(n),1),
        label = c("Strong Dem","Weak Dem","Lean Dem","Independent","Lean Rep","Weak Rep","Strong Rep")[party_cat])
  binx <- function(v){ x <- df[[v]][!is.na(df[[v]])]; h <- cut(x, breaks=seq(-1,1,0.1), include.lowest=TRUE)
                       data.frame(bin=levels(h), pct=round(100*as.numeric(table(h))/length(x),1)) }
  adm <- df$ideo_raw %in% c(1:7,9)
  list(ideology = fi, partisanship = fp, egal = binx("egal"), mt = binx("mt"), policy = binx("policy"),
       pct_htma = round(100*mean(df$ideo_raw[adm]==9),1),
       ideo_moderate_or_htma = fi$pct[fi$ideo_cat==4])
}
f1_20 <- fig1(d20); f1_24 <- fig1(d24)

## ---- Build side-by-side full-sample comparison (primary deliverable) ----
## reliability full-sample (alpha + cov) for the 3 index constructs
rel_full <- function(t2, yr) data.frame(
  construct = t2$construct[t2$stat=="alpha"],
  alpha = t2$Full[t2$stat=="alpha"], cov = t2$Full[t2$stat=="avg_cov"], year = yr)
rel20 <- rel_full(t2_20, 2020); rel24 <- rel_full(t2_24, 2024)

## matched-item 1984-2016 baseline (same 4 egal / 2 MT items available in 2020/2024)
## for the item-count-fair reliability + breadth comparison. Built directly from the
## 1948-2016 CDF (timeseries_cum.rda), FTF/phone modes only, 1984+, to mirror the
## reproduction's full sample (self-contained; no dependency on other scripts).
matched_baseline <- {
  load("data/raw/timeseries_cum.rda"); tc <- timeseries_cum
  keep <- num(tc$VCF0004) >= 1984 & num(tc$VCF0017) %in% 0:3
  eg <- cbind(sc5(tc$VCF9013[keep], +1), sc5(tc$VCF9018[keep], +1),
              sc5(tc$VCF9016[keep], -1), sc5(tc$VCF9017[keep], -1))
  mt <- cbind(sc5(tc$VCF0853[keep], +1), sc5(tc$VCF0852[keep], -1))
  egi <- nanmean(eg); mti <- nanmean(mt)
  data.frame(construct = c("Egalitarianism","Moral Tradition"),
             alpha_matched_8416 = round(c(alpha_raw(eg), alpha_raw(mt)),3),
             cov_matched_8416   = round(c(avgcov(eg), avgcov(mt)),3),
             breadth_matched_8416 = round(100*c(mean(polar(egi), na.rm=TRUE), mean(polar(mti), na.rm=TRUE))))
}

saveRDS(list(table1_2020=t1_20, table1_2024=t1_24), file.path(OUT,"table1_breadth.rds"))
saveRDS(list(table2_2020=t2_20, table2_2024=t2_24, matched_baseline=matched_baseline,
             rel_full_2020=rel20, rel_full_2024=rel24), file.path(OUT,"table2_reliability.rds"))
saveRDS(list(table4_2020=t4_20, table4_2024=t4_24, avgcorr_2020=ac20, avgcorr_2024=ac24), file.path(OUT,"table4_correlations.rds"))
saveRDS(list(table5_2020=t5_20, table5_2024=t5_24), file.path(OUT,"table5_vote.rds"))
saveRDS(list(y2020=op20, y2024=op24), file.path(OUT,"opinionation.rds"))
saveRDS(list(y2020=f1_20, y2024=f1_24), file.path(OUT,"fig1_distributions.rds"))
saveRDS(list(anchor_full=anchor_full, anchor_infogain=anchor_infogain,
             breadth_2020=setNames(round(t1_20$Full),t1_20$construct), breadth_2024=setNames(round(t1_24$Full),t1_24$construct),
             breadth_HdivL_2020=setNames(round(t1_20$H_div_L,2),t1_20$construct),
             breadth_HdivL_2024=setNames(round(t1_24$H_div_L,2),t1_24$construct),
             voteR2_2020=setNames(round(t5_20$Full[t5_20$stat=="pseudoR2"],3),unique(t5_20$predictor)),
             voteR2_2024=setNames(round(t5_24$Full[t5_24$stat=="pseudoR2"],3),unique(t5_24$predictor)),
             voteR2_HdivL_2020=setNames(round(t5_20$H_div_L_R2[t5_20$stat=="pseudoR2"],2),unique(t5_20$predictor)),
             voteR2_HdivL_2024=setNames(round(t5_24$H_div_L_R2[t5_24$stat=="pseudoR2"],2),unique(t5_24$predictor)),
             avgcorr_2020=ac20, avgcorr_2024=ac24, rel20=rel20, rel24=rel24,
             matched_baseline=matched_baseline),
        file.path(OUT,"comparison_fullsample.rds"))

## ============================================================================
## M3  STABILITY (Table 3 analogue)
## ============================================================================
sq_r <- function(a, b) { ok <- !is.na(a) & !is.na(b); c(r2 = if (sum(ok) >= 5) cor(a[ok],b[ok])^2 else NA, n = sum(ok)) }
panel <- read.csv("data/raw/anes2024_panel_link.csv", stringsAsFactors = FALSE)
panel <- panel[num(panel$V200001) > 0, ]                       # 2,171 panel cases (drop -1 sentinels)
panel$id2020 <- num(panel$V200001); panel$id2024 <- num(panel$V240001); panel$id2016 <- num(panel$V160001_orig)
panel$wt_panel_post <- num(panel$V240106b)

## construct frames keyed by caseid for each wave (from the CDF subset)
c20 <- build_constructs(cdf[num(cdf$VCF0004)==2020, ])
c24 <- build_constructs(cdf[num(cdf$VCF0004)==2024, ])
## NOTE: the optional 2016->2020 / 2016->2024 bonus rows are INFEASIBLE with this
## data. The 1948-2024 SDA cumulative file keys VCF0006 to the native study case id
## for 2020/2024 (so V200001/V240001 join cleanly), but for 2016 VCF0006 is a plain
## sequential row index (1..5090), NOT the 2016 time-series case id (300001..407791
## carried in V160001_orig). There is thus no crosswalk from the panel's 2016 link to
## the 2016 attitude rows, so 2016 measures cannot be attached. Documented, not chased.

CV <- c("egal","mt","policy","ideo","party")
CVlab <- c("Egalitarianism","Moral Traditionalism","Policy Views","Ideology ID","Partisanship")

## generic stability builder: waveA -> waveB, stratified by a knowledge grp4 keyed to waveA caseid
stability_rows <- function(idA, idB, cA, cB, knA_group, know_caseid, gap_label, wt = NULL) {
  ## align: for each panel row, pull construct vectors + group
  ia <- match(idA, cA$caseid); ib <- match(idB, cB$caseid)
  grp <- knA_group[match(idA, know_caseid)]
  rows <- list()
  for (j in seq_along(CV)) {
    v <- CV[j]; A <- cA[[v]][ia]; B <- cB[[v]][ib]
    full <- sq_r(A, B)
    cells <- sapply(levels(grp), function(gl){ sel <- !is.na(grp) & grp==gl; sq_r(A[sel], B[sel]) })
    rows[[j]] <- data.frame(gap = gap_label, construct = CVlab[j],
      Full = round(full["r2"],2), Lower = round(cells["r2","Lower"],2), Middle = round(cells["r2","Middle"],2),
      High = round(cells["r2","High"],2), Highest = round(cells["r2","Highest"],2),
      N_full = full["n"], row.names = NULL)
  }
  do.call(rbind, rows)
}

## primary: 2020 -> 2024, stratified by 2020 pre-only quiz knowledge (merged lowest two)
kn20_group <- know20[, c("caseid","know4")]
stab_2024 <- stability_rows(panel$id2020, panel$id2024, c20, c24,
                            kn20_group$know4, kn20_group$caseid, "2020->2024")
## weighted (V240106b) full-sample sensitivity
wsq <- function(a, b, w){ ok <- !is.na(a)&!is.na(b)&!is.na(w); if(sum(ok)<5) return(NA)
  m<-lm(b~a, weights=w, subset=ok); # weighted r^2 = weighted squared correlation
  aw<-a[ok]; bw<-b[ok]; ww<-w[ok]; ma<-sum(ww*aw)/sum(ww); mb<-sum(ww*bw)/sum(ww)
  cov<-sum(ww*(aw-ma)*(bw-mb)); va<-sum(ww*(aw-ma)^2); vb<-sum(ww*(bw-mb)^2); (cov/sqrt(va*vb))^2 }
ia <- match(panel$id2020, c20$caseid); ib <- match(panel$id2024, c24$caseid)
stab_2024_wt <- sapply(CV, function(v) round(wsq(c20[[v]][ia], c24[[v]][ib], panel$wt_panel_post),2))
## group shares (2020 quiz knowledge, merged) among panel cases
panel_grp <- kn20_group$know4[match(panel$id2020, kn20_group$caseid)]
stab_shares <- round(100*prop.table(table(panel_grp)),1)

## original 1992-96 panel (same 4-year gap) full-sample values, for comparison
orig_9296 <- data.frame(construct = CVlab, r2_1992_96 = c(.31,.37,.42,.37,.59))

saveRDS(list(stability_2020_2024 = stab_2024, weighted_full_2020_2024 = stab_2024_wt,
             stability_2016_bonus = "infeasible: 2016 VCF0006 is a sequential index, not the 2016 time-series case id in V160001_orig (no crosswalk to attitudes)",
             panel_group_shares = stab_shares, n_panel = nrow(panel),
             original_1992_96 = orig_9296),
        file.path(OUT,"table3_stability.rds"))

## ============================================================================
## M4  VERDICTS
## ============================================================================
b20 <- setNames(round(t1_20$Full), t1_20$construct); b24 <- setNames(round(t1_24$Full), t1_24$construct)
r20 <- setNames(round(t5_20$Full[t5_20$stat=="pseudoR2"],3), unique(t5_20$predictor))
r24 <- setNames(round(t5_24$Full[t5_24$stat=="pseudoR2"],3), unique(t5_24$predictor))
hg20 <- setNames(round(t1_20$H_div_L,2), t1_20$construct); hg24 <- setNames(round(t1_24$H_div_L,2), t1_24$construct)
verdicts <- data.frame(
  claim = c(
    "1. Polar/coherent/potent ideology only for knowledgeable minority",
    "2. Partisanship dominates ideology on every metric",
    "3. Knowledge stratification is enormous (info-gain ratios)",
    "4. Values carry the same knowledge-dependent limits as ideology",
    "(a) Has mass ideological coherence/polarity/potency RISEN vs 1984-2016?",
    "(b) Does the knowledge stratification persist?"),
  verdict = NA_character_, stringsAsFactors = FALSE)
saveRDS(list(verdicts_scaffold = verdicts,
             breadth = rbind(orig=anchor_full$breadth_8416, si0816=anchor_full$breadth_0816, y2020=b20, y2024=b24),
             voteR2  = rbind(orig=anchor_full$voter2_8416, si0816=anchor_full$voter2_0816, y2020=r20, y2024=r24),
             breadth_HdivL = rbind(y2020=hg20, y2024=hg24)),
        file.path(OUT,"verdicts.rds"))

cat("\n===== DONE =====\n")
cat("Knowledge shares 2020 (pre-only, target 9/20/34/25/13):", shares20$pre_only, "\n")
cat("Knowledge shares 2024 (pre-only):", shares24$pre_only, "\n")
cat("Mean quiz knowledge: 2020 =", round(mean(know20$know_pre,na.rm=TRUE),3), " 2024 =", round(mean(know24$know_pre,na.rm=TRUE),3), "\n\n")
cat("Breadth (%polar half), Full sample [8416 / 0816 / 2020 / 2024]:\n")
for (i in 1:5) cat(sprintf("  %-16s %2d / %2d / %2d / %2d   (H/L ratio 2020=%.2f 2024=%.2f)\n",
  anchor_full$construct[i], anchor_full$breadth_8416[i], anchor_full$breadth_0816[i], b20[i], b24[i], hg20[i], hg24[i]))
cat("\nVote pseudo-R2, Full sample [8416 / 0816 / 2020 / 2024]:\n")
for (i in 1:5) cat(sprintf("  %-16s %.2f / %.2f / %.2f / %.2f\n",
  anchor_full$construct[i], anchor_full$voter2_8416[i], anchor_full$voter2_0816[i], r20[i], r24[i]))
cat("\nStability 2020->2024 (full r^2):\n"); print(stab_2024[,c("construct","Full","N_full")], row.names=FALSE)
cat("Panel group shares (2020 quiz, merged lowest two):", stab_shares, "\n")
