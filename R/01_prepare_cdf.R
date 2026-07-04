## 01_prepare_cdf.R
## Build the analysis dataset for reproducing Kalmoe (2020),
## "Uses and Abuses of Ideology in Political Psychology", Political Psychology,
## doi:10.1111/pops.12650 -- Figure 1, Tables 1, 2, 4, 5, footnote 5, in-text stats.
##
## Source: ANES Time Series Cumulative Data File 1948-2016 (timeseries_cum.rda,
## object `timeseries_cum`, 59,944 x 1,029; haven_labelled columns, values = codes).
##
## Output: output/repro_main/cdf_analysis.rds  (one row per CDF respondent, 1984-2016,
##   with all constructs, item columns, knowledge moderator, weights and filters).
##
## KEY CODING DECISIONS (empirically adjudicated against Table 1 anchors; see
## reproduction_report.md for the evidence):
##  * Knowledge  = 5-pt interviewer info rating, PRE (VCF0050a) preferred, POST
##    (VCF0050b) as fallback in years lacking a pre rating (1986/1990/1994/1998).
##    Recoded high=informed and mapped to 0/.25/.5/.75/1.
##  * Mode       = FTF + telephone only: VCF0017 in {0,1,2,3}; web (=4) excluded.
##  * Weight     = VCF0009x (FTF-sample weight) for weighted tables (1 & 5).
##  * Scales     = all constructs on -1..+1 (global convention in the paper).
##  * Indices    = mean of available items; policy DK(=9) -> scale midpoint (0);
##                 egal/MT DK(=8) -> missing (nonresponse <1%).
##  * Polar half = |scaled score| >= 0.5 (inclusive) -- applied in script 02.

suppressMessages({library(dplyr)})

data_path <- "data/raw/timeseries_cum.rda"
stopifnot(file.exists(data_path))
load(data_path)                       # -> timeseries_cum
d <- timeseries_cum
nz <- function(v) as.numeric(d[[v]])  # haven_labelled -> underlying code

## ---- Knowledge moderator ----------------------------------------------------
recK <- function(r) { r[!r %in% 1:5] <- NA; (5 - r) / 4 }  # 1=very high ->1 ; 5=very low ->0
k_pre  <- recK(nz("VCF0050a"))
k_post <- recK(nz("VCF0050b"))
know   <- ifelse(!is.na(k_pre), k_pre, k_post)             # pre preferred, post fallback

## ---- Identity scales (7-pt -> -1..+1) --------------------------------------
# Ideology VCF0803: 1 extremely liberal .. 7 extremely conservative, 9 = DK/HTMA.
#   high = conservative; HTMA(9) coded WITH moderates at 0 (scale midpoint).
io   <- nz("VCF0803")
ideo <- ifelse(io %in% 1:7, (io - 4) / 3, ifelse(io == 9, 0, NA))
ideo_cat <- ifelse(io %in% 1:7, io, ifelse(io == 9, 4L, NA))  # HTMA folded into "moderate" for Fig 1
# Party VCF0301: 1 Strong Dem .. 7 Strong Rep; high = Republican
pa    <- nz("VCF0301")
party <- ifelse(pa %in% 1:7, (pa - 4) / 3, NA)
party_cat <- ifelse(pa %in% 1:7, pa, NA)

## ---- Vote (Table 5 DV) ------------------------------------------------------
# VCF0704a two-party pres vote: 1 Dem, 2 Rep; Rep=1, Dem=0, else missing.
vt <- nz("VCF0704a")
repvote <- ifelse(vt == 2, 1L, ifelse(vt == 1, 0L, NA))

## ---- Core value / policy items (each item scaled to -1..+1) -----------------
sc5 <- function(v, dir) { x <- nz(v); x[!x %in% 1:5] <- NA; s <- (3 - x) / 2; if (dir < 0) -s else s }
#   5-pt agree-disagree: code1 "agree strongly" -> +1, code3 "neither" -> 0, code5 -> -1.
#   dir = +1 if agreement is in the construct-high direction, -1 if reverse-worded.

# Egalitarianism (high = egalitarian). 9013/9015/9018 pro-egal ; 9014/9016/9017 anti-egal.
egal1 <- sc5("VCF9013", +1); egal2 <- sc5("VCF9015", +1); egal3 <- sc5("VCF9018", +1)
egal4 <- sc5("VCF9014", -1); egal5 <- sc5("VCF9016", -1); egal6 <- sc5("VCF9017", -1)
egM <- cbind(egal1, egal2, egal3, egal4, egal5, egal6)

# Moral traditionalism (high = traditional). 0851/0853 pro-trad ; 0852/0854 reverse-worded.
mt1 <- sc5("VCF0851", +1); mt2 <- sc5("VCF0853", +1)
mt3 <- sc5("VCF0852", -1); mt4 <- sc5("VCF0854", -1)
mtM <- cbind(mt1, mt2, mt3, mt4)

# Policy views index (5x 7-pt items; high = LIBERAL). DK(=9) -> midpoint (0); 0 = NA.
pol7 <- function(v, dir) { x <- nz(v); s <- ifelse(x %in% 1:7, (x - 4) / 3, ifelse(x == 9, 0, NA)); if (dir < 0) -s else s }
pol1 <- pol7("VCF0843", -1)   # defense spending  (1=decrease=liberal -> reverse)
pol2 <- pol7("VCF0809", -1)   # guaranteed jobs   (1=govt guarantee=liberal -> reverse)
pol3 <- pol7("VCF0830", -1)   # aid to blacks     (1=govt help=liberal -> reverse)
pol4 <- pol7("VCF0806", -1)   # govt health ins.  (1=govt plan=liberal -> reverse)
pol5 <- pol7("VCF0839", +1)   # services/spending (7=more services=liberal -> aligned)
polM <- cbind(pol1, pol2, pol3, pol4, pol5)

nanmean <- function(M) { m <- rowMeans(M, na.rm = TRUE); m[is.nan(m)] <- NA; m }
egal   <- nanmean(egM)
mt     <- nanmean(mtM)
policy <- nanmean(polM)

## ---- Abortion (footnote 5) --------------------------------------------------
# VCF0838 4-pt: 1 never .. 4 always; 9=DK -> missing. Kept as ordered outcome.
ab <- nz("VCF0838")
abortion <- ifelse(ab %in% 1:4, ab, NA)

## ---- Assemble ---------------------------------------------------------------
out <- tibble(
  year      = d$VCF0004,
  mode      = nz("VCF0017"),
  keepmode  = nz("VCF0017") %in% 0:3,          # FTF + telephone, exclude web
  wt_x      = d$VCF0009x,                       # FTF-sample weight (weighted tables)
  wt_z      = d$VCF0009z,                       # full-sample weight (for reference)
  know      = know,
  ideo = ideo, ideo_cat = ideo_cat,
  party = party, party_cat = party_cat,
  repvote = repvote,
  egal = egal, mt = mt, policy = policy,
  abortion = abortion,
  egal_nitem = rowSums(!is.na(egM)),
  mt_nitem   = rowSums(!is.na(mtM)),
  pol_nitem  = rowSums(!is.na(polM))
)
# item columns (for Table 2 reliability)
out <- bind_cols(out,
  as.data.frame(egM) |> setNames(paste0("egal_i", 1:6)),
  as.data.frame(mtM) |> setNames(paste0("mt_i", 1:4)),
  as.data.frame(polM) |> setNames(paste0("pol_i", 1:5)))

out <- out %>% filter(year >= 1984)

dir.create("output/repro_main", recursive = TRUE, showWarnings = FALSE)
saveRDS(out, "output/repro_main/cdf_analysis.rds")

cat("Saved output/repro_main/cdf_analysis.rds :", nrow(out), "rows,", ncol(out), "cols\n")
cat("Years:", paste(sort(unique(out$year)), collapse = " "), "\n")
