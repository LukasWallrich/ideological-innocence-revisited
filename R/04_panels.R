# ------------------------------------------------------------------------
# 04_panels.R — Reproduce Table 3 of Kalmoe (2020), "Uses and Abuses of
# Ideology in Political Psychology" (Political Psychology, 10.1111/pops.12650)
#
# Table 3: squared test-retest ("continuity") Pearson correlations for
# egalitarianism, moral traditionalism, policy views, ideological ID and
# partisanship, unweighted, full sample and by interviewer-rated political
# knowledge (5 rating levels; two lowest merged), for three ANES panels:
#   1990-92 (single file: ANES 1990-1992 Full Panel File)
#   1992-96 (merge: ANES 1996 panel cases -> 1992 wave via 1992 case id)
#   2000-02 (merge: ANES 2002 panel cases -> 2000 wave via 2000 case id)
#
# Run from project root:  Rscript R/04_panels.R
# Outputs: output/repro_panels/table3.rds, output/repro_panels/comparison.csv
# (The accompanying panel_report.md documents all variable choices.)
# ------------------------------------------------------------------------

suppressWarnings(dir.create("output/repro_panels", recursive = TRUE, showWarnings = FALSE))

# ---------------------------------------------------------------- helpers --

as_int <- function(x) as.integer(x)

# 7-pt lib-con ideology: HTMA / DK / moderate -> 0; -1..+1, high = conservative
code_ideology <- function(x, htma_codes = c(0, 8), na_codes = 9) {
  out <- ifelse(x %in% c(htma_codes, 4), 0,
         ifelse(x %in% 1:7, (x - 4) / 3, NA_real_))
  out
}

# 7-pt party ID summary (0=StrDem..6=StrRep): -1..+1, high = Republican.
# 7 (other/refused), 8 (apolitical), 9 (NA) -> missing.
code_party <- function(x) ifelse(x %in% 0:6, (x - 3) / 3, NA_real_)

# 7-pt policy item: DK (8) and HTMA (0) -> scale midpoint (4); -1..+1.
# rev = TRUE flips so that high = liberal.
code_policy7 <- function(x, rev = FALSE) {
  y <- ifelse(x %in% 1:7, x, ifelse(x %in% c(0, 8), 4, NA_real_))
  if (rev) y <- 8 - y
  (y - 4) / 3
}

# 5-pt agree-disagree CPV item (1=agree strongly .. 5=disagree strongly);
# pro = TRUE if agreement indicates the construct (item then reversed so
# high = construct); DK/NA -> missing (DK <= 1% per the paper); -1..+1.
code_cpv <- function(x, pro) {
  y <- ifelse(x %in% 1:5, x, NA_real_)
  if (pro) y <- 6 - y
  (y - 3) / 2
}

# mean across items, using available items (see report for sensitivity)
index_mean <- function(mat, complete = FALSE) {
  if (complete) ifelse(rowSums(is.na(mat)) == 0, rowMeans(mat), NA_real_)
  else {
    out <- rowMeans(mat, na.rm = TRUE)
    out[is.nan(out)] <- NA_real_
    out
  }
}

# knowledge grouping: interviewer rating 1=very high .. 5=very low;
# two lowest knowledge levels (ratings 4+5) merged -> 4 groups
know_group <- function(k) {
  k[!k %in% 1:5] <- NA
  cut(k, breaks = c(0, 1, 2, 3, 5),
      labels = c("Highest", "High", "Middle", "Lowest"))
}

# squared Pearson correlation between waves
sq_r <- function(a, b, sel) {
  ok <- sel & !is.na(a) & !is.na(b)
  if (sum(ok) < 5) return(c(r2 = NA_real_, n = sum(ok)))
  c(r2 = cor(a[ok], b[ok])^2, n = sum(ok))
}

# build one construct row (full + 4 knowledge groups)
stab_row <- function(a, b, sel, grp, panel, construct) {
  full <- sq_r(a, b, sel)
  cells <- lapply(c("Lowest", "Middle", "High", "Highest"), function(g)
    sq_r(a, b, sel & !is.na(grp) & grp == g))
  data.frame(
    panel = panel, construct = construct,
    group = c("Full", "Lowest", "Middle", "High", "Highest"),
    r2 = c(full["r2"], vapply(cells, `[`, numeric(1), "r2")),
    n  = c(full["n"],  vapply(cells, `[`, numeric(1), "n"))
  )
}

group_shares <- function(grp, sel) {
  tab <- table(grp[sel])
  round(100 * prop.table(tab), 1)
}

results <- list()
shares_log <- list()

# ============================================================ 1990-92 =====
# ANES 1990-1992 Full Panel File (anesr timeseries_1992): 1992 respondents
# (N = 2,485); panel cases (V923005 == 1, N = 1,359) carry 1990 (V90*) data.

load("data/raw/timeseries_1992.rda")
d92 <- timeseries_1992
g <- function(v) as_int(d92[[v]])

panel9092 <- g("V923005") == 1                      # 1,359 panel respondents

# knowledge: 1992 PRE interviewer rating of R's information level (V924205)
# (resolved empirically; see report — matches header shares 18/38/30/14)
grp9092 <- know_group(g("V924205"))
shares_log[["1990-92"]] <- group_shares(grp9092, panel9092)

# --- constructs, 1990 wave ---
ideo90 <- code_ideology(g("V900406"))               # R SELF-LIB/CONS SCALE
party90 <- code_party(g("V900320"))                 # R'S PARTY ID: SUMMARY
pol90 <- index_mean(cbind(                           # 4 items in BOTH waves
  code_policy7(g("V900452"), rev = FALSE),          # govt services (7 = more)
  code_policy7(g("V900439"), rev = TRUE),           # defense spending
  code_policy7(g("V900446"), rev = TRUE),           # guaranteed jobs/std liv
  code_policy7(g("V900447"), rev = TRUE)))          # aid to blacks
egal90 <- index_mean(cbind(                          # 6-item battery (form B)
  code_cpv(g("V900426"), pro = TRUE),               # equal opportunity needed
  code_cpv(g("V900427"), pro = FALSE),              # pushed equal rights too far
  code_cpv(g("V900428"), pro = TRUE),               # big problem: no equal chance
  code_cpv(g("V900429"), pro = FALSE),              # worry less about equality
  code_cpv(g("V900430"), pro = FALSE),              # unequal chance not a problem
  code_cpv(g("V900431"), pro = TRUE)))              # fewer problems if more equal
mt90 <- index_mean(cbind(                            # 4-item battery
  code_cpv(g("V900500"), pro = TRUE),               # new lifestyles -> breakdown
  code_cpv(g("V900501"), pro = FALSE),              # world changing, adjust morals
  code_cpv(g("V900502"), pro = TRUE),               # traditional family ties
  code_cpv(g("V900503"), pro = FALSE)))             # tolerant of other morals

# --- constructs, 1992 wave ---
ideo92 <- code_ideology(g("V923509"))               # 92PRE G3a lib-con 7pt
party92 <- code_party(g("V923634"))                 # 92PRE K1z party ID summary
pol92 <- index_mean(cbind(
  code_policy7(g("V923701"), rev = FALSE),          # L1a services/spending
  code_policy7(g("V923707"), rev = TRUE),           # L2a defense
  code_policy7(g("V923718"), rev = TRUE),           # L7a guaranteed jobs
  code_policy7(g("V923724"), rev = TRUE)))          # L8a aid to blacks
egal92 <- index_mean(cbind(
  code_cpv(g("V926024"), pro = TRUE),               # L5a society ensure equal opp
  code_cpv(g("V926025"), pro = FALSE),              # L5b gone too far
  code_cpv(g("V926026"), pro = FALSE),              # L5c worry less
  code_cpv(g("V926027"), pro = FALSE),              # L5d inequality not a problem
  code_cpv(g("V926028"), pro = TRUE),               # L5e fewer problems if equal
  code_cpv(g("V926029"), pro = TRUE)))              # L5f big problem: no eq chance
mt92 <- index_mean(cbind(
  code_cpv(g("V926118"), pro = TRUE),               # DD lifestyle breakdown
  code_cpv(g("V926115"), pro = FALSE),              # D/A world changing
  code_cpv(g("V926117"), pro = TRUE),               # DC traditional family ties
  code_cpv(g("V926116"), pro = FALSE)))             # DB should be tolerant

results[["9092"]] <- rbind(
  stab_row(egal90, egal92, panel9092, grp9092, "1990-92", "Egalitarianism"),
  stab_row(mt90,   mt92,   panel9092, grp9092, "1990-92", "Moral Traditionalism"),
  stab_row(pol90,  pol92,  panel9092, grp9092, "1990-92", "Policy Views"),
  stab_row(ideo90, ideo92, panel9092, grp9092, "1990-92", "Ideology ID"),
  stab_row(party90, party92, panel9092, grp9092, "1990-92", "Partisanship"))

# ============================================================ 1992-96 =====
# ANES 1996 (anesr timeseries_1996): panel cases that originated in the 1992
# time series carry the 1992 case id (V960009 > 0); merge to the 1992 file
# on its 1992 case id (V923004). 597 matched cases.

load("data/raw/timeseries_1996.rda")
d96 <- timeseries_1996
g6 <- function(v) as_int(d96[[v]])

link  <- g6("V960009")
midx  <- match(link, g("V923004"))                  # row of d92 for each d96 row
midx[link <= 0] <- NA
panel9296 <- !is.na(midx)                           # 597 merged panel cases
g2 <- function(v) as_int(d92[[v]])[midx]            # 1992 wave, aligned to d96

# knowledge: 1992 PRE interviewer rating (V924205), as in the 1990-92 panel
# (resolved empirically; header shares 20/35/31/14 match this rating's
#  distribution in the full 1992 sample — see report)
grp9296 <- know_group(g2("V924205"))
shares_log[["1992-96"]] <- group_shares(grp9296, panel9296)

# --- constructs, 1992 wave (same items/coding as above, via merge) ---
ideo92b <- code_ideology(g2("V923509"))
party92b <- code_party(g2("V923634"))
pol92b <- index_mean(cbind(                          # all 5 classic items
  code_policy7(g2("V923701"), rev = FALSE),         # services/spending
  code_policy7(g2("V923707"), rev = TRUE),          # defense
  code_policy7(g2("V923716"), rev = TRUE),          # govt health insurance
  code_policy7(g2("V923718"), rev = TRUE),          # guaranteed jobs
  code_policy7(g2("V923724"), rev = TRUE)))         # aid to blacks
egal92b <- index_mean(cbind(
  code_cpv(g2("V926024"), pro = TRUE),  code_cpv(g2("V926025"), pro = FALSE),
  code_cpv(g2("V926026"), pro = FALSE), code_cpv(g2("V926027"), pro = FALSE),
  code_cpv(g2("V926028"), pro = TRUE),  code_cpv(g2("V926029"), pro = TRUE)))
mt92b <- index_mean(cbind(
  code_cpv(g2("V926118"), pro = TRUE),  code_cpv(g2("V926115"), pro = FALSE),
  code_cpv(g2("V926117"), pro = TRUE),  code_cpv(g2("V926116"), pro = FALSE)))

# --- constructs, 1996 wave ---
ideo96 <- code_ideology(g6("V960365"))              # 96PR R scale lib-con
party96 <- code_party(g6("V960420"))                # 96PR summary party ID
pol96 <- index_mean(cbind(
  code_policy7(g6("V960450"), rev = FALSE),         # services/spending
  code_policy7(g6("V960463"), rev = TRUE),          # defense
  code_policy7(g6("V960479"), rev = TRUE),          # govt health insurance
  code_policy7(g6("V960483"), rev = TRUE),          # guaranteed jobs
  code_policy7(g6("V960487"), rev = TRUE)))         # aid to blacks
egal96 <- index_mean(cbind(
  code_cpv(g6("V961229"), pro = TRUE),              # society ensure equal opp
  code_cpv(g6("V961230"), pro = FALSE),             # gone too far
  code_cpv(g6("V961231"), pro = TRUE),              # big problem: no eq chance
  code_cpv(g6("V961232"), pro = FALSE),             # better if less worried
  code_cpv(g6("V961233"), pro = FALSE),             # not a problem: unequal
  code_cpv(g6("V961234"), pro = TRUE)))             # fewer problems if equal
mt96 <- index_mean(cbind(
  code_cpv(g6("V961247"), pro = TRUE),              # new lifestyles bad
  code_cpv(g6("V961248"), pro = FALSE),             # adjust moral behavior
  code_cpv(g6("V961249"), pro = TRUE),              # more traditional families
  code_cpv(g6("V961250"), pro = FALSE)))            # tolerate other standards

results[["9296"]] <- rbind(
  stab_row(egal92b, egal96, panel9296, grp9296, "1992-96", "Egalitarianism"),
  stab_row(mt92b,   mt96,   panel9296, grp9296, "1992-96", "Moral Traditionalism"),
  stab_row(pol92b,  pol96,  panel9296, grp9296, "1992-96", "Policy Views"),
  stab_row(ideo92b, ideo96, panel9296, grp9296, "1992-96", "Ideology ID"),
  stab_row(party92b, party96, panel9296, grp9296, "1992-96", "Partisanship"))

# ============================================================ 2000-02 =====
# ANES 2002 (anesr timeseries_2002): panel cases (V021001 == 1, N = 1,187)
# carry the 2000 case id (V020002); merge to ANES 2000 (V000001).

load("data/raw/timeseries_2000.rda"); load("data/raw/timeseries_2002.rda")
d00 <- timeseries_2000; d02 <- timeseries_2002
g02v <- function(v) as_int(d02[[v]])

link02 <- g02v("V020002")
midx0  <- match(link02, as_int(d00$V000001))
panel0002 <- !is.na(midx0) & g02v("V021001") == 1   # 1,187 panel cases
g0 <- function(v) as_int(d00[[v]])[midx0]           # 2000 wave, aligned to d02

# knowledge: 2000 PRE interviewer rating "R informed about politics" (V001033)
grp0002 <- know_group(g0("V001033"))
shares_log[["2000-02"]] <- group_shares(grp0002, panel0002)

# --- ideology: 7-pt scale format only (form-1 half sample in 2000: FTF
#     V000439 / phone V000439a); 2002 asked the 7-pt scale of everyone (F1).
x439  <- g0("V000439"); x439a <- g0("V000439a")
raw00 <- ifelse(!is.na(x439) & x439 < 9, x439,
         ifelse(!is.na(x439a) & x439a < 9, x439a, NA_integer_))
ideo00 <- code_ideology(raw00)
ideo02 <- code_ideology(g02v("V023022"), htma_codes = c(90, 8))

# --- partisanship ---
party00 <- code_party(g0("V000523"))                # K1x party ID summary
party02 <- code_party(g02v("V023038x"))             # J1x party ID summary

# --- policy views: the classic 7-pt scales do not exist in 2002; the items
#     asked identically in both waves are 9 federal-spending items.
#     2000 codes: 1 increased, 5 kept same, 3 decreased, 7 cut out entirely
#     2002 codes: 1 increased, 3 kept same, 2 decreased, 4 cut out entirely
#     coded ordinally (+1, +1/3, -1/3, -1; high = more spending = liberal),
#     DK -> midpoint (0); index requires all 9 items (complete case), which
#     reproduces the published N (1,017 vs 1,016). See report: values remain
#     systematically higher than published — unresolved.
sp00 <- function(v) { x <- g0(v)
  ifelse(x == 1, 1, ifelse(x == 5, 1/3, ifelse(x == 3, -1/3,
  ifelse(x == 7, -1, ifelse(x == 8, 0, NA_real_))))) }
sp02 <- function(v) { x <- g02v(v)
  ifelse(x == 1, 1, ifelse(x == 3, 1/3, ifelse(x == 2, -1/3,
  ifelse(x == 4, -1, ifelse(x == 8, 0, NA_real_))))) }
v00sp <- c("V000675","V000676","V000677","V000678","V000681",
           "V000682","V000684","V000685","V000687")
# highways, welfare, AIDS research, foreign aid, social security,
# environment, crime, child care, aid to blacks  (2000 pre, L7 battery)
v02sp <- c("V025104x","V025107x","V025106x","V025116x","V025117x",
           "V025113x","V025109x","V025110x","V025119x")
# same items, 2002 pre/post combined summaries (K1/K2 + L1/L2 batteries)
pol00 <- index_mean(sapply(v00sp, sp00), complete = TRUE)
pol02 <- index_mean(sapply(v02sp, sp02), complete = TRUE)

results[["0002"]] <- rbind(
  stab_row(pol00,  pol02,  panel0002, grp0002, "2000-02", "Policy Views"),
  stab_row(ideo00, ideo02, panel0002, grp0002, "2000-02", "Ideology ID"),
  stab_row(party00, party02, panel0002, grp0002, "2000-02", "Partisanship"))

# ======================================================== consolidate =====

repro <- do.call(rbind, results)
rownames(repro) <- NULL

# original Table 3 values (transcribed in notes/paper_spec.md §3)
orig <- rbind(
  data.frame(panel="1990-92", construct="Egalitarianism",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.24,.14,.26,.32,.38), n_orig=NA),
  data.frame(panel="1990-92", construct="Moral Traditionalism",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.34,.13,.26,.40,.55), n_orig=NA),
  data.frame(panel="1990-92", construct="Policy Views",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.32,.13,.28,.40,.51), n_orig=c(1359,NA,NA,NA,NA)),
  data.frame(panel="1990-92", construct="Ideology ID",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.29,.05,.20,.33,.60), n_orig=c(1359,NA,NA,NA,NA)),
  data.frame(panel="1990-92", construct="Partisanship",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.61,.44,.59,.66,.73), n_orig=c(1334,NA,NA,NA,NA)),
  data.frame(panel="1992-96", construct="Egalitarianism",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.31,.18,.28,.30,.30), n_orig=NA),
  data.frame(panel="1992-96", construct="Moral Traditionalism",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.37,.16,.42,.46,.37), n_orig=NA),
  data.frame(panel="1992-96", construct="Policy Views",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.42,.26,.39,.38,.62), n_orig=NA),
  data.frame(panel="1992-96", construct="Ideology ID",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.37,.03,.26,.48,.71), n_orig=NA),
  data.frame(panel="1992-96", construct="Partisanship",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.59,.49,.58,.77,.58), n_orig=NA),
  data.frame(panel="2000-02", construct="Policy Views",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.27,.19,.22,.30,.30), n_orig=c(1016,NA,NA,NA,NA)),
  data.frame(panel="2000-02", construct="Ideology ID",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.38,.04,.37,.46,.61), n_orig=c(564,NA,NA,NA,NA)),
  data.frame(panel="2000-02", construct="Partisanship",
             group=c("Full","Lowest","Middle","High","Highest"),
             r2_orig=c(.71,.56,.69,.77,.76), n_orig=c(1165,NA,NA,NA,NA)))

comp <- merge(repro, orig, by = c("panel", "construct", "group"), sort = FALSE)
comp$r2_repro_2dp <- round(comp$r2, 2)
comp$diff <- comp$r2_repro_2dp - comp$r2_orig
comp$match_2dp <- abs(comp$diff) < 0.005
comp$within_01 <- abs(comp$diff) < 0.015
comp$abs_diff <- abs(comp$diff)

# order rows as in the paper
panel_order <- c("1990-92", "1992-96", "2000-02")
constr_order <- c("Egalitarianism", "Moral Traditionalism", "Policy Views",
                  "Ideology ID", "Partisanship")
group_order <- c("Full", "Lowest", "Middle", "High", "Highest")
comp <- comp[order(match(comp$panel, panel_order),
                   match(comp$construct, constr_order),
                   match(comp$group, group_order)), ]

saveRDS(list(table3 = repro, comparison = comp, knowledge_shares = shares_log),
        "output/repro_panels/table3.rds")
write.csv(comp[, c("panel","construct","group","r2_orig","r2_repro_2dp",
                   "r2","n","n_orig","diff","match_2dp","within_01")],
          "output/repro_panels/comparison.csv", row.names = FALSE)

# ---------------------------------------------------------- console log --
cat("Knowledge group shares (analysis samples; two lowest merged):\n")
for (p in names(shares_log)) {
  cat(sprintf("  %s: %s\n", p,
      paste(names(shares_log[[p]]), shares_log[[p]], sep = "=", collapse = ", ")))
}
cat("\nCell-level match:\n")
agg <- aggregate(cbind(exact = match_2dp, within_01) ~ panel, comp,
                 function(x) sum(x))
agg$cells <- as.vector(table(comp$panel)[agg$panel])
print(agg, row.names = FALSE)
cat("\nCells off by more than .02:\n")
print(comp[comp$abs_diff > .02,
           c("panel","construct","group","r2_orig","r2_repro_2dp","n")],
      row.names = FALSE)
cat("\nFull comparison written to output/repro_panels/comparison.csv\n")
