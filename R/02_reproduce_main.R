## 02_reproduce_main.R
## Reproduce Kalmoe (2020) main-text results from the ANES CDF analysis file.
## Produces: fig1_data.rds, table1.rds, table2.rds, table4.rds, table5.rds,
##           footnote5.rds, intext_stats.rds, and comparison.csv (orig vs repro).
## Run after 01_prepare_cdf.R, from project root: Rscript R/02_reproduce_main.R

suppressMessages({library(dplyr); library(tidyr); library(psych); library(sandwich); library(MASS)})
select <- dplyr::select

df  <- readRDS("output/repro_main/cdf_analysis.rds")
out <- "output/repro_main"

## Knowledge group labels (5 fixed interviewer-rating levels; NOT quantiles)
klab5 <- c(`0` = "Lowest", `0.25` = "Low", `0.5` = "Middle", `0.75` = "High", `1` = "Highest")
grp5  <- function(k) factor(klab5[as.character(k)], levels = c("Lowest","Low","Middle","High","Highest"))

## Construct year-sets (emerge from battery availability; used for the index tables)
YR <- list(
  egal   = c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2004,2008,2012,2016),  # 1998 has 2 of 6 items; mean-of-available keeps them (paper label "1984-2000")
  mt     = c(1986,1988,1990,1992,1994,1996,1998,2000,2004,2008,2012,2016),
  policy = c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2004,2008,2012,2016),
  ideo   = c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2002,2004,2008,2012,2016),
  party  = c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2002,2004,2008,2012,2016))

polar <- function(s) as.integer(abs(s) >= 0.5)   # inclusive outer-half
cmp   <- list()                                   # comparison rows accumulator
addc  <- function(table, cell, orig, repro)
  cmp[[length(cmp)+1]] <<- data.frame(table, cell, original = orig,
                                      reproduced = round(repro, 3),
                                      diff = round(repro - orig, 3))

## =====================================================================
## TABLE 1 -- Percent in polar half, WEIGHTED (VCF0009x), by knowledge
## =====================================================================
t1_tgt <- list(
  egal   = c(32,26,26,30,35,43), mt   = c(35,17,25,33,42,45),
  policy = c(18,11,13,16,21,29), ideo = c(27,11,16,24,34,44),
  party  = c(61,41,55,63,66,67))
t1_years <- c(egal="egal", mt="mt", policy="policy", ideo="ideo", party="party")
t1_rows <- lapply(names(t1_years), function(v) {
  x <- df %>% filter(keepmode, year %in% YR[[v]], !is.na(know), !is.na(.data[[v]])) %>%
    mutate(g = grp5(know), pol = polar(.data[[v]]))
  full <- 100 * weighted.mean(x$pol, x$wt_x)
  by   <- x %>% group_by(g) %>% summarise(p = 100 * weighted.mean(pol, wt_x), .groups="drop")
  vals <- setNames(by$p, by$g)[levels(x$g)]
  hl   <- vals["Highest"] - vals["Lowest"]; hr <- vals["Highest"]/vals["Lowest"]
  data.frame(construct=v, N=nrow(x), Full=full,
             Lowest=vals["Lowest"], Low=vals["Low"], Middle=vals["Middle"],
             High=vals["High"], Highest=vals["Highest"], H_minus_L=hl, H_div_L=hr,
             row.names=NULL)
})
table1 <- bind_rows(t1_rows)
saveRDS(table1, file.path(out,"table1.rds"))
for (v in names(t1_tgt)) { r <- table1[table1$construct==v,]
  got <- c(r$Full,r$Lowest,r$Low,r$Middle,r$High,r$Highest); nm <- c("Full","Lowest","Low","Middle","High","Highest")
  for (i in seq_along(nm)) addc("Table1", paste0(v,"_",nm[i]), t1_tgt[[v]][i], got[i]) }

## =====================================================================
## TABLE 2 -- Cronbach alpha + avg interitem covariance, UNWEIGHTED
## =====================================================================
t2_tgt <- list(
  egal_a   = c(.67,.50,.53,.64,.73,.79), egal_cov = c(.10,.05,.06,.09,.13,.17),
  mt_a     = c(.62,.35,.47,.59,.68,.73), mt_cov   = c(.11,.04,.06,.10,.14,.18),
  policy_a = c(.64,.38,.46,.58,.69,.80), policy_cov=c(.08,.03,.04,.06,.09,.14))
item_cols <- list(egal=paste0("egal_i",1:6), mt=paste0("mt_i",1:4), policy=paste0("pol_i",1:5))
avgcov <- function(M){ C <- cov(M, use="pairwise.complete.obs"); mean(C[lower.tri(C)]) }
alpha_raw <- function(M){ suppressWarnings(psych::alpha(M, warnings=FALSE, check.keys=FALSE)$total$raw_alpha) }
t2_rows <- list()
for (v in c("egal","mt","policy")) {
  cols <- item_cols[[v]]
  base <- df %>% filter(keepmode, year %in% YR[[v]], !is.na(know),
                        rowSums(!is.na(across(all_of(cols)))) > 0)
  grpsets <- c(list(Full=base), split(base, grp5(base$know))[c("Lowest","Low","Middle","High","Highest")])
  aa <- sapply(grpsets, function(s) alpha_raw(as.matrix(s[,cols])))
  cc <- sapply(grpsets, function(s) avgcov(as.matrix(s[,cols])))
  t2_rows[[paste0(v,"_a")]]   <- c(construct=v, stat="alpha",   as.list(round(aa,3)))
  t2_rows[[paste0(v,"_cov")]] <- c(construct=v, stat="avg_cov", as.list(round(cc,3)))
  for (nm in c("Full","Lowest","Low","Middle","High","Highest")) {
    addc("Table2", paste0(v,"_alpha_",nm),  t2_tgt[[paste0(v,"_a")]][match(nm,c("Full","Lowest","Low","Middle","High","Highest"))], aa[nm])
    addc("Table2", paste0(v,"_cov_",nm),    t2_tgt[[paste0(v,"_cov")]][match(nm,c("Full","Lowest","Low","Middle","High","Highest"))], cc[nm]) }
}
table2 <- bind_rows(lapply(t2_rows, as.data.frame))
saveRDS(table2, file.path(out,"table2.rds"))

## =====================================================================
## TABLE 4 -- Pearson correlations among constructs, UNWEIGHTED, by knowledge
##   "(rev.)" aligns liberal/conservative direction -> report positive value.
## =====================================================================
# pair, varA, varB, sign to make aligned-positive (product of directions)
pairs4 <- tibble::tribble(
  ~pair,                          ~a,      ~b,       ~tgt,
  "Egal x MoralTrad(rev)",        "egal",  "mt",     ".28",
  "Egal x Policy",                "egal",  "policy", ".44",
  "Egal x IdeoID(rev)",           "egal",  "ideo",   ".35",
  "Egal x Party(rev)",            "egal",  "party",  ".35",
  "MoralTrad x Policy(rev)",      "mt",    "policy", ".29",
  "MoralTrad x IdeoID",           "mt",    "ideo",   ".40",
  "MoralTrad x Party",            "mt",    "party",  ".27",
  "Policy x IdeoID(rev)",         "policy","ideo",   ".39",
  "Policy x Party(rev)",          "policy","party",  ".44",
  "IdeoID x Party",               "ideo",  "party",  ".44")
t4_tgt <- list(
  "Egal x MoralTrad(rev)"  = c(.28,.04,.11,.23,.32,.45),
  "Egal x Policy"          = c(.44,.27,.29,.40,.51,.59),
  "Egal x IdeoID(rev)"     = c(.35,.06,.11,.27,.42,.55),
  "Egal x Party(rev)"      = c(.35,.11,.17,.29,.42,.52),
  "MoralTrad x Policy(rev)"= c(.29,.03,.13,.22,.31,.49),
  "MoralTrad x IdeoID"     = c(.40,.08,.18,.32,.46,.59),
  "MoralTrad x Party"      = c(.27,.03,.08,.21,.32,.48),
  "Policy x IdeoID(rev)"   = c(.39,.05,.18,.29,.47,.64),
  "Policy x Party(rev)"    = c(.44,.12,.22,.37,.50,.62),
  "IdeoID x Party"         = c(.44,.06,.17,.35,.54,.68))
lev6 <- c("Full","Lowest","Low","Middle","High","Highest")
t4_rows <- list()
for (i in seq_len(nrow(pairs4))) {
  a <- pairs4$a[i]; b <- pairs4$b[i]; pr <- pairs4$pair[i]
  x <- df %>% filter(keepmode, !is.na(know), !is.na(.data[[a]]), !is.na(.data[[b]])) %>%
    mutate(g = grp5(know))
  rr <- function(s) abs(cor(s[[a]], s[[b]]))   # abs() = the "(rev.)"-aligned positive value
  full <- rr(x)
  by <- sapply(lev6[-1], function(gl){ s <- x[x$g==gl,]; if(nrow(s)>2) rr(s) else NA })
  vals <- c(Full=full, by)
  t4_rows[[pr]] <- c(list(pair=pr, N=nrow(x)), as.list(round(vals,3)))
  for (nm in lev6) addc("Table4", paste0(pr," | ",nm), t4_tgt[[pr]][match(nm,lev6)], vals[nm])
}
table4 <- bind_rows(lapply(t4_rows, as.data.frame, check.names=FALSE))
saveRDS(table4, file.path(out,"table4.rds"))

## =====================================================================
## TABLE 5 -- Weighted bivariate probit of Republican pres. vote,
##   one predictor at a time; robust SE clustered by year; McFadden pseudo-R2.
##   Voters only, presidential years; knowledge groups merge lowest two.
## =====================================================================
presyr <- c(1984,1988,1992,1996,2000,2004,2008,2012,2016)
# predictors coded to point toward Republican vote:
#   egal(rev) = -egal ; policy(rev) = -policy ; mt, ideo, party as-is (high=cons/Rep)
grp4 <- function(k) factor(ifelse(k<=0.25,"Lower", klab5[as.character(k)]),
                           levels=c("Lower","Middle","High","Highest"))
t5_specs <- tibble::tribble(
  ~name,            ~expr,
  "Egalitarianism", "-egal",
  "MoralTrad",      "mt",
  "PolicyViews",    "-policy",
  "IdeoID",         "ideo",
  "Partisanship",   "party")
t5_tgt_coef <- list(Egalitarianism=c(1.58,1.03,1.32,1.75,2.00), MoralTrad=c(1.29,.88,1.07,1.29,1.74),
  PolicyViews=c(2.10,1.38,1.75,2.35,2.67), IdeoID=c(1.91,.97,1.57,2.12,2.54), Partisanship=c(1.81,1.42,1.77,1.89,2.11))
t5_tgt_r2 <- list(Egalitarianism=c(.15,.05,.10,.19,.28), MoralTrad=c(.13,.04,.08,.14,.26),
  PolicyViews=c(.21,.08,.14,.26,.37), IdeoID=c(.23,.04,.14,.29,.43), Partisanship=c(.49,.32,.47,.52,.60))
t5_lev <- c("Full","Lower","Middle","High","Highest")
fit5 <- function(dat, pexpr) {
  dat$pred <- eval(parse(text=pexpr), dat)
  dat <- dat %>% filter(!is.na(pred), !is.na(repvote), !is.na(wt_x))
  m  <- suppressWarnings(glm(repvote ~ pred, data=dat, family=binomial("probit"), weights=wt_x))
  m0 <- suppressWarnings(glm(repvote ~ 1,    data=dat, family=binomial("probit"), weights=wt_x))
  mcf <- 1 - as.numeric(logLik(m)/logLik(m0))
  se  <- tryCatch(sqrt(diag(sandwich::vcovCL(m, cluster = dat$year)))["pred"],
                  error=function(e) sqrt(diag(vcov(m)))["pred"])
  list(coef=unname(coef(m)["pred"]), se=unname(se), r2=mcf, N=nrow(dat))
}
t5_rows <- list()
for (i in seq_len(nrow(t5_specs))) {
  nm <- t5_specs$name[i]; ex <- t5_specs$expr[i]
  base <- df %>% filter(keepmode, year %in% presyr, !is.na(know)) %>% mutate(g = grp4(know))
  res_full <- fit5(base, ex)
  res_grp  <- lapply(levels(base$g), function(gl) fit5(base[base$g==gl,], ex))
  names(res_grp) <- levels(base$g)
  coefs <- c(Full=res_full$coef, sapply(res_grp, `[[`, "coef"))
  ses   <- c(Full=res_full$se,   sapply(res_grp, `[[`, "se"))
  r2s   <- c(Full=res_full$r2,   sapply(res_grp, `[[`, "r2"))
  t5_rows[[nm]] <- data.frame(predictor=nm, N=res_full$N,
    stat=c("coef","se","pseudoR2"),
    Full=c(res_full$coef,res_full$se,res_full$r2),
    Lower=c(res_grp$Lower$coef,res_grp$Lower$se,res_grp$Lower$r2),
    Middle=c(res_grp$Middle$coef,res_grp$Middle$se,res_grp$Middle$r2),
    High=c(res_grp$High$coef,res_grp$High$se,res_grp$High$r2),
    Highest=c(res_grp$Highest$coef,res_grp$Highest$se,res_grp$Highest$r2))
  for (j in seq_along(t5_lev)) {
    addc("Table5", paste0(nm,"_coef_",t5_lev[j]), t5_tgt_coef[[nm]][j], coefs[t5_lev[j]])
    addc("Table5", paste0(nm,"_R2_",t5_lev[j]),   t5_tgt_r2[[nm]][j],   r2s[t5_lev[j]]) }
}
table5 <- bind_rows(t5_rows)
saveRDS(table5, file.path(out,"table5.rds"))

## =====================================================================
## FOOTNOTE 5 -- ordered probit of abortion on moral traditionalism,
##   most-knowledgeable third vs least-knowledgeable two-thirds.
## =====================================================================
fn <- df %>% filter(keepmode, !is.na(know), !is.na(abortion), !is.na(mt)) %>%
  mutate(top = know >= 0.75)          # top third = High + Highest
mcf_polr <- function(dat) {
  m  <- MASS::polr(factor(abortion) ~ mt, data=dat, method="probit", Hess=TRUE)
  m0 <- MASS::polr(factor(abortion) ~ 1,  data=dat, method="probit", Hess=TRUE)
  list(coef=unname(coef(m)["mt"]), r2=1 - as.numeric(logLik(m)/logLik(m0)), N=nrow(dat))
}
fn_top <- mcf_polr(fn %>% filter(top))
fn_bot <- mcf_polr(fn %>% filter(!top))
footnote5 <- data.frame(
  group=c("top_third(High+Highest)","bottom_two_thirds"),
  share=round(c(mean(fn$top), mean(!fn$top)),3),
  coef =round(c(fn_top$coef, fn_bot$coef),3),
  pseudoR2=round(c(fn_top$r2, fn_bot$r2),3),
  N=c(fn_top$N, fn_bot$N))
footnote5$coef_ratio <- round(fn_top$coef/fn_bot$coef,2)
footnote5$r2_ratio   <- round(fn_top$r2/fn_bot$r2,2)
saveRDS(footnote5, file.path(out,"footnote5.rds"))

## =====================================================================
## IN-TEXT STATISTICS
## =====================================================================
# opinionation: mean knowledge for HTMA vs lib/con identifiers vs moderates.
# ideo_cat folds HTMA into "moderate", so read the raw VCF0803 code to separate them.
suppressWarnings(load("data/raw/timeseries_cum.rda"))
rawc <- as.numeric(timeseries_cum$VCF0803)[as.numeric(timeseries_cum$VCF0004) >= 1984]
kk   <- df$know; km <- df$keepmode
grpmean <- function(codes) mean(kk[km & !is.na(kk) & rawc %in% codes], na.rm=TRUE)
kn_htma   <- grpmean(9)
kn_ident  <- grpmean(c(1,2,3,5,6,7))
kn_mod    <- grpmean(4)

# policy DK: per-item DK rate, % answering all five, knowledge by DK count
poly <- df %>% filter(keepmode, year %in% YR$policy)
pol_items_raw <- c("VCF0843","VCF0809","VCF0830","VCF0806","VCF0839")
# per-item DK rate among those to whom the item was administered (code in 1:7 or 9)
rawpol <- sapply(pol_items_raw, function(v){ as.numeric(timeseries_cum[[v]])[as.numeric(timeseries_cum$VCF0004)>=1984] })
km_pol <- df$keepmode & df$year %in% YR$policy
dkrate <- sapply(1:5, function(j){ x <- rawpol[km_pol, j]; asked <- x %in% c(1:7,9); mean(x[asked]==9) })
names(dkrate) <- pol_items_raw
# respondents to whom all 5 asked; among them % with no DK; knowledge by DK count
allasked <- rowSums(sapply(1:5, function(j) rawpol[,j] %in% c(1:7,9))) == 5
sub <- km_pol & allasked
dkcount <- rowSums(sapply(1:5, function(j) rawpol[,j]==9))
pct_all_five <- mean(dkcount[sub]==0)
kn_dk3plus <- mean(df$know[sub & dkcount>=3 & !is.na(df$know)], na.rm=TRUE)
kn_dk0     <- mean(df$know[sub & dkcount==0 & !is.na(df$know)], na.rm=TRUE)

# vote correlations (voters, presidential years) -- individual-level Pearson
vot <- df %>% filter(keepmode, year %in% presyr, !is.na(repvote))
r_ideo_vote  <- cor(vot$ideo,  vot$repvote, use="complete.obs")
r_party_vote <- cor(vot$party, vot$repvote, use="complete.obs")
# leaners (party codes 3,5) folded to Independent (0): reproduces the paper's .68
party_fold <- ifelse(vot$party_cat %in% c(3,5), 0, vot$party)
r_party_vote_leanfold <- cor(party_fold, vot$repvote, use="complete.obs")
# loyalty from the 3-party vote (VCF0704): defection to a third-party counts as disloyal
v3 <- as.numeric(timeseries_cum$VCF0704)[as.numeric(timeseries_cum$VCF0004) >= 1984]
df$v3 <- v3
vot3 <- df %>% filter(keepmode, year %in% presyr, v3 %in% 1:3, !is.na(party_cat))
loyal <- vot3 %>% filter(party_cat %in% c(1,2,6,7)) %>%
  mutate(own = ifelse(party_cat %in% c(1,2), 1, 2), loyal = as.integer(v3 == own)) %>%
  group_by(party_cat) %>% summarise(loyal = mean(loyal), n = n(), .groups="drop")
# polar-party / outer-ideology among voters (literal reading)
vot_p <- vot %>% filter(!is.na(party_cat)); pct_polar_party <- mean(abs(vot_p$party) >= 0.5)
vot_i <- vot %>% filter(!is.na(ideo_cat));  pct_outer_ideo  <- mean(vot_i$ideo_cat %in% c(1,2,6,7))
# full-sample equivalents (what Kalmoe's quoted 62%/28% numerically track -- see Table 1 Full)
fs_p <- df %>% filter(keepmode, year %in% YR$party, !is.na(party))
pct_polar_party_full <- weighted.mean(abs(fs_p$party) >= 0.5, fs_p$wt_x)
fs_i <- df %>% filter(keepmode, year %in% YR$ideo, !is.na(ideo_cat))
pct_outer_ideo_full  <- weighted.mean(fs_i$ideo_cat %in% c(1,2,6,7), fs_i$wt_x)

intext <- tibble::tribble(
  ~stat, ~original, ~reproduced,
  "knowledge_HTMA_ideology",        0.36, round(kn_htma,3),
  "knowledge_libcon_identifiers",   0.63, round(kn_ident,3),
  "knowledge_moderates(between)",   NA,   round(kn_mod,3),
  "policy_DK_rate_min",             0.12, round(min(dkrate),3),
  "policy_DK_rate_max",             0.15, round(max(dkrate),3),
  "policy_pct_answered_all_five",   0.66, round(pct_all_five,3),
  "knowledge_DK_3plus",             0.32, round(kn_dk3plus,3),
  "knowledge_answered_all_five",    0.63, round(kn_dk0,3),
  "r_ideology_vote",                0.49, round(r_ideo_vote,3),
  "r_partisanship_vote",            0.68, round(r_party_vote,3),
  "r_partisanship_vote_leanerfold", 0.68, round(r_party_vote_leanfold,3),
  "pct_voters_polar_party",         0.62, round(pct_polar_party,3),
  "pct_voters_outer_ideology",      0.28, round(pct_outer_ideo,3),
  "pct_polar_party_fullsample",     0.62, round(pct_polar_party_full,3),
  "pct_outer_ideology_fullsample",  0.28, round(pct_outer_ideo_full,3))
intext_stats <- list(summary=intext, party_loyalty=loyal, policy_dk_rates=round(dkrate,3))
saveRDS(intext_stats, file.path(out,"intext_stats.rds"))
for (i in seq_len(nrow(intext))) if(!is.na(intext$original[i]))
  addc("InText", intext$stat[i], intext$original[i], intext$reproduced[i])
# footnote 5 ratios into comparison
addc("Footnote5", "coef_ratio_top_vs_bottom(~2x)", 2.0, footnote5$coef_ratio[1])
addc("Footnote5", "R2_ratio_top_vs_bottom(~5x)",   5.0, footnote5$r2_ratio[1])

## =====================================================================
## FIGURE 1 -- distributions, UNWEIGHTED
## =====================================================================
f_ideo <- df %>% filter(keepmode, year %in% YR$ideo, !is.na(ideo_cat)) %>%
  count(ideo_cat) %>% mutate(pct = round(100*n/sum(n),1),
    label = c("Extremely liberal","Liberal","Slightly liberal","Moderate/HTMA",
              "Slightly conservative","Conservative","Extremely conservative")[ideo_cat])
f_party <- df %>% filter(keepmode, year %in% YR$party, !is.na(party_cat)) %>%
  count(party_cat) %>% mutate(pct = round(100*n/sum(n),1),
    label = c("Strong Dem","Weak Dem","Lean Dem","Independent","Lean Rep","Weak Rep","Strong Rep")[party_cat])
bin_index <- function(v, yrs) {
  x <- df %>% filter(keepmode, year %in% yrs, !is.na(.data[[v]]))
  h <- cut(x[[v]], breaks=seq(-1,1,0.1), include.lowest=TRUE)
  data.frame(bin=levels(h), pct=round(100*as.numeric(table(h))/nrow(x),1))
}
fig1_data <- list(ideology=f_ideo, partisanship=f_party,
  policy=bin_index("policy",YR$policy), moraltrad=bin_index("mt",YR$mt),
  egalitarianism=bin_index("egal",YR$egal))
saveRDS(fig1_data, file.path(out,"fig1_data.rds"))
# Figure-1 anchors into comparison
addc("Figure1","ideology_moderate_HTMA_bar(~49%)", 49, f_ideo$pct[f_ideo$ideo_cat==4])
addc("Figure1","party_StrongDem_bar(~19%)",        19, f_party$pct[f_party$party_cat==1])
addc("Figure1","party_Independent_bar(~11%)",      11, f_party$pct[f_party$party_cat==4])

## =====================================================================
## COMPARISON TABLE
## =====================================================================
comparison <- bind_rows(cmp)
write.csv(comparison, file.path(out,"comparison.csv"), row.names=FALSE)

cat("Done. Rows in comparison.csv:", nrow(comparison), "\n")
cat("Table1 max |diff|:", max(abs(comparison$diff[comparison$table=='Table1']),na.rm=TRUE), "\n")
cat("Table2 max |diff|:", max(abs(comparison$diff[comparison$table=='Table2']),na.rm=TRUE), "\n")
cat("Table4 max |diff|:", max(abs(comparison$diff[comparison$table=='Table4']),na.rm=TRUE), "\n")
cat("Table5 max |diff|:", max(abs(comparison$diff[comparison$table=='Table5']),na.rm=TRUE), "\n")
