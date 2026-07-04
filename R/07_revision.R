## ============================================================================
## 07_revision.R  --  Post-review revision analyses for the reproduction +
##   replication of Kalmoe (2020), "Uses and Abuses of Ideology in Political
##   Psychology", Political Psychology, doi:10.1111/pops.12650.
##
## Single entry point; runs end-to-end from the project root:
##     Rscript R/07_revision.R
##
## Adds the analyses requested by the automated peer review
## (coarse-output/manuscript_review.md). Writes output/revision/*.rds ONLY;
## reuses conventions/data from R/01-R/06 and does not modify their outputs.
##
## MODULES
##   A  Sorting vs constraint: ideology's INCREMENTAL vote contribution net of
##      party ID, by era x knowledge group (party-only vs party+ideology probit;
##      pseudo-R2 increment + joint-model ideology AME + reverse increment).
##   B  AME-based Highest/Lowest headline ratios for the bivariate vote models
##      (ideology & party), measure-matched across eras, alongside pseudo-R2.
##   C  Panel attrition: 2020 quiz-knowledge retention/composition and
##      post-stratified (reweighted) stability sensitivity.
##   D  Breadth with/without nonattitudes for 2020/2024 (parallel to RC2), plus
##      the nonresponse-vs-polar decomposition of the breadth rise.
##   E  Mode comparison within 2020 (web / video / phone): breadth, Moderate-vs-
##      HTMA split, mean |ideology|, ideology x party, web-vs-nonweb vote R2.
##   F  Small computations for detailed comments: GSS partisanship pseudo-R2 by
##      knowledge group (#14); Table 1 H/L ordering (#3); panel-fidelity banding
##      (#11); anchor-vs-validation cell partition (target #2); egalitarianism
##      item-count decomposition (#9).
## ============================================================================

suppressMessages({
  library(dplyr); library(tidyr); library(psych); library(sandwich)
  library(marginaleffects)
})

OUT <- "output/revision"
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
num <- function(x) suppressWarnings(as.numeric(if (inherits(x, "haven_labelled")) unclass(x) else x))
mcf <- function(m, m0) 1 - as.numeric(logLik(m) / logLik(m0))

## ============================================================================
## SHARED HELPERS (copied verbatim from R/06 so cells stay comparable) ---------
## ============================================================================
sc5 <- function(x, dir) { x <- num(x); x[!x %in% 1:5] <- NA; s <- (3 - x) / 2; if (dir < 0) -s else s }
pol7 <- function(x, dir) { x <- num(x); s <- ifelse(x %in% 1:7, (x - 4) / 3, ifelse(x == 9, 0, NA)); if (dir < 0) -s else s }
nanmean <- function(M) { m <- rowMeans(M, na.rm = TRUE); m[is.nan(m)] <- NA; m }
polar   <- function(s) as.integer(abs(s) >= 0.5)
wmean   <- function(x, w) { ok <- !is.na(x) & !is.na(w); if (!any(ok)) return(NA); sum(x[ok]*w[ok])/sum(w[ok]) }

build_constructs <- function(s) {
  io <- num(s$VCF0803)
  ideo     <- ifelse(io %in% 1:7, (io - 4)/3, ifelse(io == 9, 0, NA))
  ideo_cat <- ifelse(io %in% 1:7, io, ifelse(io == 9, 4L, NA))
  pa <- num(s$VCF0301)
  party     <- ifelse(pa %in% 1:7, (pa - 4)/3, NA)
  party_cat <- ifelse(pa %in% 1:7, pa, NA)
  vt <- num(s$VCF0704); repvote <- ifelse(vt == 2, 1L, ifelse(vt == 1, 0L, NA))
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
    setNames(as.data.frame(polM), paste0("pol_i", 1:5)),
    pol_raw = as.data.frame(sapply(c("VCF0843","VCF0809","VCF0830","VCF0806","VCF0839"), function(v) num(s[[v]]))))
  out
}

klab5 <- c(`0`="Lowest", `0.25`="Low", `0.5`="Middle", `0.75`="High", `1`="Highest")
grp5  <- function(k) factor(klab5[as.character(k)], levels = c("Lowest","Low","Middle","High","Highest"))
grp4  <- function(k) factor(ifelse(k <= 0.25, "Lower", klab5[as.character(k)]), levels = c("Lower","Middle","High","Highest"))
prop_correct <- function(corr, adm) { nc <- rowSums(corr & adm, na.rm = TRUE); na_ <- rowSums(adm, na.rm = TRUE); ifelse(na_ > 0, nc/na_, NA) }

## ============================================================================
## LOAD DATA + BUILD 2020/2024 CROSS-SECTION FRAMES (mirrors R/06) -------------
## ============================================================================
cdf <- read.csv("data/raw/anes_cdf_1948_2024_subset.csv", stringsAsFactors = FALSE)
cdf[cdf == " "] <- NA; cdf[cdf == ""] <- NA

## ---- 2020 knowledge quiz (pre-only 4-item) ----
load("data/raw/timeseries_2020.rda"); t20 <- timeseries_2020; g <- function(v) num(t20[[v]])
pre_c20 <- cbind(g("V201644")==6, g("V201645")==1, g("V201646")==1, g("V201647")==2)
pre_a20 <- sapply(c("V201644","V201645","V201646","V201647"), function(v){ x <- g(v); !(x %in% c(-6,-7)) })
know20 <- data.frame(caseid = g("V200001"),
                     know_pre = prop_correct(pre_c20, pre_a20),
                     wt_pre  = g("V200010a"), wt_post = g("V200010b"))
know20$know5 <- grp5(know20$know_pre); know20$know4 <- grp4(know20$know_pre)

## ---- 2024 knowledge quiz ----
k24 <- read.csv("data/raw/anes2024_knowledge.csv", stringsAsFactors = FALSE); h <- function(v) num(k24[[v]])
pre_c24 <- cbind(h("V241612")==6, h("V241613")==1, h("V241614")==2, h("V241615")==1)
pre_a24 <- sapply(c("V241612","V241613","V241614","V241615"), function(v){ x <- h(v); !(x %in% c(-6,-7)) })
know24 <- data.frame(caseid = h("V240001"),
                     know_pre = prop_correct(pre_c24, pre_a24),
                     wt_pre = h("V240107a"), wt_post = h("V240107b"),
                     mode24 = h("V240002a"))
know24$know5 <- grp5(know24$know_pre); know24$know4 <- grp4(know24$know_pre)

frame_year <- function(yr, kn) {
  s <- cdf[num(cdf$VCF0004) == yr, ]
  cc <- build_constructs(s)
  merge(cc, kn[, c("caseid","know_pre","know5","know4","wt_pre","wt_post")], by = "caseid", all.x = TRUE)
}
d20 <- frame_year(2020, know20)
d24 <- frame_year(2024, know24)
stopifnot(nrow(d20) == 8280, nrow(d24) == 5521)
d20$web <- d20$mode_cdf == 4
d20$mode_lab <- ifelse(d20$mode_cdf == 4, "Web", ifelse(d20$mode_cdf == 5, "Video", ifelse(d20$mode_cdf == 3, "Phone", "Other")))
d24 <- merge(d24, know24[, c("caseid","mode24")], by = "caseid", all.x = TRUE)
d24$web <- d24$mode24 %in% c(2,3,4)

## ---- original-era prepared frame + 1988-92 campaign quiz (mirrors R/03 RC4) ----
DF <- readRDS("output/repro_main/cdf_analysis.rds")
suppressWarnings(load("data/raw/timeseries_cum.rda")); tc <- timeseries_cum
yrf <- as.numeric(tc$VCF0004) >= 1984
nzr <- function(v) as.numeric(tc[[v]])[yrf]
stopifnot(length(nzr("VCF0803")) == nrow(DF))
house <- ifelse(nzr("VCF0729")%in%1:2, as.integer(nzr("VCF0729")==2), NA)
senate<- ifelse(nzr("VCF9036")%in%c(1,2,4,5,8), as.integer(nzr("VCF9036")%in%1:2), NA)
nmc   <- nzr("VCF0976") %% 10
names2<- ifelse(nzr("VCF0976")%in%c(0,10,11,20,21,22,30,31,32,33), pmin(nmc,2)/2, NA)
incum <- ifelse(nzr("VCF0978")%in%1:2, as.integer(nzr("VCF0978")==1), NA)
DF$quiz <- nanmean(cbind(house, senate, names2, incum))
## bin the 1988/1992 voter quiz into 5 groups (RC4 B5 shares), then MERGE lowest two -> grp4
qbin <- function(q, sel, targ=c(.12,.11,.37,.21,.20)){
  cutp <- cumsum(targ); g <- rep(NA_integer_, length(q))
  s <- which(sel & !is.na(q)); o <- s[order(q[s])]
  cs <- cumsum(rep(1, length(o)))/length(o)
  lab <- findInterval(cs, cutp[-5]) + 1
  g[o] <- lab; factor(c("Lowest","Low","Middle","High","Highest")[g],
                      levels=c("Lowest","Low","Middle","High","Highest"))
}
presyr <- c(1984,1988,1992,1996,2000,2004,2008,2012,2016)

## ============================================================================
## MODULE A -- SORTING vs CONSTRAINT
##   For each era and knowledge group (merged 4-group, as in Table 5):
##     r2_party      = pseudo-R2 of probit(vote ~ party)
##     r2_partyideo  = pseudo-R2 of probit(vote ~ party + ideology)
##     incr_ideo     = r2_partyideo - r2_party   (ideology beyond party)
##     r2_ideo       = pseudo-R2 of probit(vote ~ ideology)
##     incr_party    = r2_partyideo - r2_ideo    (reverse: party beyond ideology)
##     ame_ideo_joint= AME of ideology in the joint model (weighted)
##   All models fit on the IDENTICAL complete-case rows (party+ideo+vote+weight).
## ============================================================================
incr_cells <- function(dat, wvar) {
  d <- dat[!is.na(dat$party) & !is.na(dat$ideo) & !is.na(dat$repvote) & !is.na(dat[[wvar]]), ]
  if (nrow(d) < 40 || length(unique(d$repvote)) < 2) {
    return(data.frame(n=nrow(d), r2_party=NA, r2_partyideo=NA, r2_ideo=NA,
                      incr_ideo=NA, incr_party=NA, ame_ideo_joint=NA, cor_ideo_party=NA))
  }
  d$w <- d[[wvar]]
  m0 <- suppressWarnings(glm(repvote ~ 1, data=d, family=binomial("probit"), weights=w))
  mP <- suppressWarnings(glm(repvote ~ party, data=d, family=binomial("probit"), weights=w))
  mI <- suppressWarnings(glm(repvote ~ ideo, data=d, family=binomial("probit"), weights=w))
  mPI<- suppressWarnings(glm(repvote ~ party + ideo, data=d, family=binomial("probit"), weights=w))
  r2P <- mcf(mP,m0); r2I <- mcf(mI,m0); r2PI <- mcf(mPI,m0)
  ame <- tryCatch(marginaleffects::avg_slopes(mPI, variables="ideo", wts=d$w)$estimate[1],
                  error=function(e) NA)
  data.frame(n=nrow(d), r2_party=r2P, r2_partyideo=r2PI, r2_ideo=r2I,
             incr_ideo=r2PI-r2P, incr_party=r2PI-r2I, ame_ideo_joint=ame,
             cor_ideo_party=cor(d$ideo, d$party))
}
incr_era <- function(dat, gfac, wvar, era) {
  base <- dat[!is.na(gfac), ]; gf <- droplevels(gfac[!is.na(gfac)])
  rows <- list(cbind(era=era, group="Full", incr_cells(base, wvar)))
  for (gl in levels(gf)) rows[[length(rows)+1]] <- cbind(era=era, group=gl, incr_cells(base[gf==gl,], wvar))
  do.call(rbind, rows)
}
## era 1: 1984-2016 interviewer rating (merged voter groups), weight VCF0009x
A1 <- { base <- DF[DF$keepmode & DF$year %in% presyr & !is.na(DF$know), ]
        incr_era(base, grp4(base$know), "wt_x", "1984-2016 (interviewer)") }
## era 2: 1988-92 campaign quiz (merged voter groups), weight VCF0009x
A2 <- { sel <- DF$year %in% c(1988,1992) & DF$keepmode & !is.na(DF$quiz) & !is.na(DF$repvote)
        base <- DF[sel, ]
        gq5 <- qbin(DF$quiz, sel)[sel]
        gq4 <- factor(ifelse(gq5 %in% c("Lowest","Low"), "Lower", as.character(gq5)),
                      levels=c("Lower","Middle","High","Highest"))
        incr_era(base, gq4, "wt_x", "1988-92 (quiz)") }
## era 3/4: 2020, 2024 quiz (merged voter groups), weight wt_post
A3 <- incr_era(d20, d20$know4, "wt_post", "2020 (quiz)")
A4 <- incr_era(d24, d24$know4, "wt_post", "2024 (quiz)")
moduleA <- do.call(rbind, list(A1,A2,A3,A4))
rownames(moduleA) <- NULL
for (cc in c("r2_party","r2_partyideo","r2_ideo","incr_ideo","incr_party","ame_ideo_joint","cor_ideo_party"))
  moduleA[[cc]] <- round(moduleA[[cc]], 3)
saveRDS(moduleA, file.path(OUT, "A_sorting_constraint.rds"))

## ============================================================================
## MODULE B -- AME-based Highest/Lowest ratios (bivariate models)
##   For ideology & party, per era: AME by group + Highest/Lower ratio, and the
##   same-grouping pseudo-R2 Highest/Lower ratio, so the two metrics are
##   like-for-like (comment #5). Weighted; merged 4-group throughout.
## ============================================================================
biv_ame_group <- function(dat, predvar, gfac, wvar) {
  d0 <- dat[!is.na(dat[[predvar]]) & !is.na(dat$repvote) & !is.na(dat[[wvar]]) & !is.na(gfac), ]
  gf <- droplevels(gfac[!is.na(dat[[predvar]]) & !is.na(dat$repvote) & !is.na(dat[[wvar]]) & !is.na(gfac)])
  one <- function(sub) {
    if (nrow(sub) < 40 || length(unique(sub$repvote)) < 2) return(c(ame=NA, r2=NA, n=nrow(sub)))
    sub$p <- sub[[predvar]]; sub$w <- sub[[wvar]]
    m  <- suppressWarnings(glm(repvote ~ p, data=sub, family=binomial("probit"), weights=w))
    m0 <- suppressWarnings(glm(repvote ~ 1, data=sub, family=binomial("probit"), weights=w))
    a <- tryCatch(marginaleffects::avg_slopes(m, variables="p", wts=sub$w)$estimate[1], error=function(e) NA)
    c(ame=a, r2=mcf(m,m0), n=nrow(sub))
  }
  full <- one(d0)
  low  <- one(d0[gf=="Lower", ]); high <- one(d0[gf=="Highest", ])
  data.frame(AME_Lower=round(low["ame"],3), AME_Highest=round(high["ame"],3),
             AME_H_div_L=round(high["ame"]/low["ame"],2),
             R2_Lower=round(low["r2"],3), R2_Highest=round(high["r2"],3),
             R2_H_div_L=round(high["r2"]/low["r2"],2),
             n_Lower=low["n"], n_Highest=high["n"], row.names=NULL)
}
B_rows <- list()
add_B <- function(era, predlab, dat, predvar, gfac, wvar)
  B_rows[[length(B_rows)+1]] <<- cbind(era=era, predictor=predlab, biv_ame_group(dat, predvar, gfac, wvar))
## eras: 1984-2016 interviewer, 1988-92 quiz, 2020, 2024
b1base <- DF[DF$keepmode & DF$year %in% presyr & !is.na(DF$know), ]; b1g <- grp4(b1base$know)
add_B("1984-2016 (interviewer)","Ideology", b1base, "ideo",  b1g, "wt_x")
add_B("1984-2016 (interviewer)","Party",    b1base, "party", b1g, "wt_x")
sel2 <- DF$year %in% c(1988,1992) & DF$keepmode & !is.na(DF$quiz) & !is.na(DF$repvote)
b2base <- DF[sel2, ]; g2q5 <- qbin(DF$quiz, sel2)[sel2]
b2g <- factor(ifelse(g2q5 %in% c("Lowest","Low"),"Lower",as.character(g2q5)), levels=c("Lower","Middle","High","Highest"))
add_B("1988-92 (quiz)","Ideology", b2base, "ideo",  b2g, "wt_x")
add_B("1988-92 (quiz)","Party",    b2base, "party", b2g, "wt_x")
add_B("2020 (quiz)","Ideology", d20, "ideo",  d20$know4, "wt_post")
add_B("2020 (quiz)","Party",    d20, "party", d20$know4, "wt_post")
add_B("2024 (quiz)","Ideology", d24, "ideo",  d24$know4, "wt_post")
add_B("2024 (quiz)","Party",    d24, "party", d24$know4, "wt_post")
moduleB <- do.call(rbind, B_rows); rownames(moduleB) <- NULL
saveRDS(moduleB, file.path(OUT, "B_ame_ratios.rds"))

## ============================================================================
## MODULE C -- PANEL ATTRITION / RETENTION + reweighted stability
## ============================================================================
panel <- read.csv("data/raw/anes2024_panel_link.csv", stringsAsFactors = FALSE)
panel <- panel[num(panel$V200001) > 0, ]
panel$id2020 <- num(panel$V200001); panel$id2024 <- num(panel$V240001)
panel$wt_panel_post <- num(panel$V240106b)

## composition: 2020 quiz distribution among all cross-section vs panel cases
cs_grp5 <- know20$know5                                   # all 2020 respondents
pn_grp5 <- know20$know5[match(panel$id2020, know20$caseid)]
cs_grp4 <- know20$know4; pn_grp4 <- know20$know4[match(panel$id2020, know20$caseid)]
comp5 <- data.frame(group = levels(cs_grp5),
  crosssection_n = as.integer(table(factor(cs_grp5, levels=levels(cs_grp5)))),
  panel_n        = as.integer(table(factor(pn_grp5, levels=levels(cs_grp5)))))
comp5$crosssection_pct <- round(100*comp5$crosssection_n/sum(comp5$crosssection_n),1)
comp5$panel_pct        <- round(100*comp5$panel_n/sum(comp5$panel_n),1)
comp5$retention_pct    <- round(100*comp5$panel_n/comp5$crosssection_n,1)   # share of the group retained in panel
overall_retention <- round(100*nrow(panel)/sum(comp5$crosssection_n),1)

## post-stratification weights on the 5 quiz groups (panel -> 2020 cross-section)
cs_share <- comp5$crosssection_n/sum(comp5$crosssection_n)
pn_share <- comp5$panel_n/sum(comp5$panel_n)
ps_w_by_group <- setNames(cs_share/pn_share, comp5$group)
panel$ps_w <- unname(ps_w_by_group[as.character(pn_grp5)])

## construct frames per wave (keyed by caseid), aligned to panel
c20 <- build_constructs(cdf[num(cdf$VCF0004)==2020, ])
c24 <- build_constructs(cdf[num(cdf$VCF0004)==2024, ])
ia <- match(panel$id2020, c20$caseid); ib <- match(panel$id2024, c24$caseid)
CV <- c("egal","mt","policy","ideo","party"); CVlab <- c("Egalitarianism","Moral Traditionalism","Policy Views","Ideology ID","Partisanship")
wsq <- function(a, b, w){ ok <- !is.na(a)&!is.na(b)&!is.na(w); if(sum(ok)<5) return(NA)
  aw<-a[ok]; bw<-b[ok]; ww<-w[ok]; ma<-sum(ww*aw)/sum(ww); mb<-sum(ww*bw)/sum(ww)
  cov<-sum(ww*(aw-ma)*(bw-mb)); va<-sum(ww*(aw-ma)^2); vb<-sum(ww*(bw-mb)^2); (cov/sqrt(va*vb))^2 }
usq <- function(a,b){ ok<-!is.na(a)&!is.na(b); if(sum(ok)<5) return(NA); cor(a[ok],b[ok])^2 }
stab_reweight <- data.frame(construct = CVlab,
  unweighted   = sapply(CV, function(v) round(usq(c20[[v]][ia], c24[[v]][ib]),2)),
  poststrat_5grp = sapply(CV, function(v) round(wsq(c20[[v]][ia], c24[[v]][ib], panel$ps_w),2)),
  panelwt_V240106b = sapply(CV, function(v) round(wsq(c20[[v]][ia], c24[[v]][ib], panel$wt_panel_post),2)),
  poststrat_x_panelwt = sapply(CV, function(v) round(wsq(c20[[v]][ia], c24[[v]][ib], panel$ps_w*panel$wt_panel_post),2)),
  row.names = NULL)
moduleC <- list(composition_5grp = comp5,
                composition_4grp = data.frame(group=levels(cs_grp4),
                  crosssection_pct=round(100*as.integer(table(factor(cs_grp4,levels=levels(cs_grp4))))/sum(!is.na(cs_grp4)),1),
                  panel_pct=round(100*as.integer(table(factor(pn_grp4,levels=levels(cs_grp4))))/sum(!is.na(pn_grp4)),1)),
                overall_retention_pct = overall_retention,
                n_panel = nrow(panel),
                stability_reweighted = stab_reweight,
                ps_weights = round(ps_w_by_group,3))
saveRDS(moduleC, file.path(OUT, "C_panel_attrition.rds"))

## ============================================================================
## MODULE D -- BREADTH WITH/WITHOUT NONATTITUDES, 2020/2024 (parallel to RC2)
##   Weighted (wt_pre) polar-half of ideology under HTMA->0 (baseline) vs
##   HTMA->dropped (placers only); same for policy DK. Plus decomposition of the
##   27 -> 40/41 breadth rise into nonresponse decline vs polar movement.
## ============================================================================
## ideology: base uses ideo (HTMA=0 -> non-polar); drop = placers only (ideo_raw 1:7)
breadth_ideo <- function(df) {
  adm <- df$ideo_raw %in% c(1:7, 9)
  w <- df$wt_pre
  base <- 100*wmean(polar(df$ideo[adm]), w[adm])                       # HTMA folded, non-polar
  plc  <- df$ideo_raw %in% 1:7
  drop <- 100*wmean(polar(df$ideo[plc]), w[plc])                       # among placers
  htma <- 100*wmean(as.integer(df$ideo_raw[adm]==9), w[adm])
  c(base=base, holders=drop, htma=htma)
}
## policy: base uses policy index (DK->0); drop = DK->NA (mean of answered items)
polrawcols <- grep("^pol_raw", names(d20), value=TRUE)
policy_dropna <- function(df) {
  pr <- df[, polrawcols]
  M <- sapply(seq_along(polrawcols), function(j){
    dir <- c(-1,-1,-1,-1,+1)[j]; x <- num(pr[[j]])
    s <- ifelse(x %in% 1:7, (x-4)/3, NA); if (dir<0) -s else s })   # DK -> NA
  nanmean(M)
}
breadth_policy <- function(df) {
  w <- df$wt_pre
  base <- 100*wmean(polar(df$policy), w)
  pol_na <- policy_dropna(df)
  drop <- 100*wmean(polar(pol_na), w)
  ## policy DK share: any DK among administered items / total DK-eligible cells
  pr <- df[, polrawcols]; adm <- sapply(pr, function(x) num(x) %in% c(1:7,9)); dk <- sapply(pr, function(x) num(x)==9)
  dkrate <- 100*sum(dk & adm, na.rm=TRUE)/sum(adm, na.rm=TRUE)
  c(base=base, holders=drop, dk=dkrate)
}
bi20 <- breadth_ideo(d20); bi24 <- breadth_ideo(d24)
bp20 <- breadth_policy(d20); bp24 <- breadth_policy(d24)
## original-era anchors (RC2): ideo base 27.24 holders 36.83 htma 25.9; policy base 19.15 holders 25.34
RC2 <- readRDS("output/robustness/rc2_nonattitude.rds")
orig_ideo <- c(base = RC2$table1_rows$Full[RC2$table1_rows$coding=="ideo HTMA->0 (base)"],
               holders = RC2$table1_rows$Full[RC2$table1_rows$coding=="ideo HTMA->NA (drop)"],
               htma = RC2$htma_share_pct)
## decomposition of ideology breadth rise (base = holders*(1-h)); attribute to h vs P
decomp <- function(orig, new) {
  ho <- orig["htma"]/100; Po <- orig["holders"]; hn <- new["htma"]/100; Pn <- new["holders"]
  nonresp <- Po*(ho - hn)                 # holding polar-among-holders fixed, less HTMA
  polar_move <- (1 - hn)*(Pn - Po)        # more polar among holders
  c(total_rise = unname(new["base"]-orig["base"]),
    nonresponse_component = unname(nonresp), polar_component = unname(polar_move),
    P_orig = unname(Po), P_new = unname(Pn), h_orig = unname(orig["htma"]), h_new = unname(new["htma"]))
}
moduleD <- list(
  ideology = rbind(orig=round(orig_ideo,1), y2020=round(bi20,1), y2024=round(bi24,1)),
  policy   = rbind(orig=c(base=RC2$table1_rows$Full[RC2$table1_rows$coding=="policy DK->0 (base)"],
                          holders=RC2$table1_rows$Full[RC2$table1_rows$coding=="policy DK->NA"], dk=NA),
                   y2020=round(bp20,1), y2024=round(bp24,1)),
  decomp_2020 = round(decomp(orig_ideo, bi20),1),
  decomp_2024 = round(decomp(orig_ideo, bi24),1))
saveRDS(moduleD, file.path(OUT, "D_breadth_nonattitudes.rds"))

## ============================================================================
## MODULE E -- MODE COMPARISON WITHIN 2020 (web / video / phone)
## ============================================================================
mode_stats <- function(df, ml) {
  s <- df[df$mode_lab == ml, ]
  adm <- s$ideo_raw %in% c(1:7,9); plc <- s$ideo_raw %in% 1:7
  n_adm <- sum(adm)
  polar_share <- 100*mean(polar(s$ideo[plc]))                 # among placers, unweighted (tiny cells)
  polar_overall <- 100*mean(polar(s$ideo[adm]))               # HTMA folded
  moderate <- 100*mean(s$ideo_raw[adm]==4)                    # true Moderate self-placement
  htma <- 100*mean(s$ideo_raw[adm]==9)                        # HTMA
  mean_abs <- mean(abs(s$ideo[plc]))
  ip <- s[!is.na(s$ideo) & !is.na(s$party), ]
  cor_ip <- if (nrow(ip) > 3) cor(ip$ideo, ip$party) else NA
  ## Wilson CI for the polar (overall, administered) share
  k <- sum(polar(s$ideo[adm])); nn <- n_adm; ph <- k/nn; z <- 1.96
  lo <- (ph + z^2/(2*nn) - z*sqrt(ph*(1-ph)/nn + z^2/(4*nn^2)))/(1+z^2/nn)
  hi <- (ph + z^2/(2*nn) + z*sqrt(ph*(1-ph)/nn + z^2/(4*nn^2)))/(1+z^2/nn)
  data.frame(mode=ml, n_administered=n_adm, n_placers=sum(plc),
             polar_among_placers=round(polar_share,1), polar_overall=round(polar_overall,1),
             polar_overall_lo=round(100*lo,1), polar_overall_hi=round(100*hi,1),
             moderate_pct=round(moderate,1), htma_pct=round(htma,1),
             mean_abs_ideo=round(mean_abs,3), cor_ideo_party=round(cor_ip,3), row.names=NULL)
}
E_modes <- do.call(rbind, lapply(c("Web","Video","Phone"), function(ml) mode_stats(d20, ml)))
## web vs non-web pooled: ideology bivariate vote pseudo-R2 (unweighted, small non-web n)
d20$nonweb <- ifelse(d20$web, "Web", "Non-web")
r2_by_web <- sapply(c("Web","Non-web"), function(grp){
  s <- d20[d20$nonweb==grp & !is.na(d20$ideo) & !is.na(d20$repvote), ]
  if (nrow(s) < 30 || length(unique(s$repvote))<2) return(c(r2=NA, n=nrow(s)))
  m <- suppressWarnings(glm(repvote~ideo, data=s, family=binomial("probit")))
  m0<- suppressWarnings(glm(repvote~1, data=s, family=binomial("probit")))
  c(r2=round(mcf(m,m0),3), n=nrow(s)) })
moduleE <- list(mode_table = E_modes,
                ideo_voteR2_web = data.frame(group=colnames(r2_by_web), t(r2_by_web), row.names=NULL))
saveRDS(moduleE, file.path(OUT, "E_mode_comparison.rds"))

## ============================================================================
## MODULE F -- SMALL COMPUTATIONS FOR DETAILED COMMENTS
## ============================================================================
## F#14 -- GSS partisanship & ideology pseudo-R2 by WORDSUM group (already in G4)
G4 <- readRDS("output/gss/analysis4_probit.rds")
gss_by_group <- G4[G4$stat=="pseudoR2", c("predictor","Full","Lowest","Low","Middle","High","Highest")]
gss_n <- G4[G4$stat=="N", c("predictor","Lowest","Highest")]

## F#3 -- Table 1 Highest/Lowest ordering
R_t1 <- readRDS("output/repro_main/table1.rds")
t1_order <- data.frame(construct = c("Egalitarianism","Moral Tradition","Policy Views","Ideology ID","Partisanship"),
  H_div_L = round(R_t1$H_div_L, 2))
orig_t1_hl <- c(1.65, 2.65, 2.64, 4.00, 1.63)   # published Table 1

## F#11 -- panel-fidelity banding (exclusive bands that sum to cell totals)
pc <- read.csv("output/repro_panels/comparison.csv", stringsAsFactors = FALSE)
band <- cut(abs(pc$diff), breaks = c(-Inf, .005, .015, .025, Inf),
            labels = c("exact_le005","within_01","within_02","beyond_02"))
panel_band <- as.data.frame.matrix(table(pc$panel, band))
panel_band$total <- rowSums(panel_band)
panel_band <- cbind(panel = rownames(panel_band), panel_band); rownames(panel_band) <- NULL

## F target#2 -- anchor vs validation partition of the 176 cross-sectional cells
cc <- read.csv("output/repro_main/comparison.csv", stringsAsFactors = FALSE)
cc <- cc[cc$table %in% c("Table1","Table2","Table4","Table5"), ]
## per-cell match band using the reproduction report's thresholds
cell_band <- function(tbl, cell, diff) {
  ad <- abs(diff)
  if (tbl == "Table1") return(ifelse(ad<=1,"tight",ifelse(ad<=2,"close","diverge")))
  if (tbl %in% c("Table2","Table4")) return(ifelse(ad<=.01,"tight",ifelse(ad<=.02,"close","diverge")))
  ## Table5: coef vs R2 rows have different tolerances
  if (grepl("_coef_", cell)) return(ifelse(ad<=.05,"tight",ifelse(ad<=.10,"close","diverge")))
  return(ifelse(ad<=.01,"tight",ifelse(ad<=.02,"close","diverge")))  # _R2_
}
cc$band <- mapply(cell_band, cc$table, cc$cell, cc$diff)
## anchor tagging (generous, documented in the manuscript):
##   Table 1 Full cells + Table 1 ideology row (adjudicated pre/post, weighting,
##   polar boundary); Table 2 policy alpha cells (adjudicated DK->midpoint).
is_anchor <- with(cc,
  (table=="Table1" & (grepl("_Full$", cell) | grepl("^ideo_", cell))) |
  (table=="Table2" & grepl("^policy_alpha_", cell)))
cc$role <- ifelse(is_anchor, "anchor", "validation")
## a generous sensitivity: ALL Table 1 cells + policy alpha as anchors
is_anchor_gen <- with(cc, table=="Table1" | (table=="Table2" & grepl("^policy_alpha_", cell)))
cc$role_generous <- ifelse(is_anchor_gen, "anchor", "validation")
partition_rate <- function(role_col) {
  tab <- table(cc[[role_col]], cc$band)
  data.frame(role = rownames(tab),
             n = rowSums(tab),
             tight = tab[,"tight"],
             close = if ("close" %in% colnames(tab)) tab[,"close"] else 0,
             diverge = if ("diverge" %in% colnames(tab)) tab[,"diverge"] else 0,
             tight_pct = round(100*tab[,"tight"]/rowSums(tab),1), row.names=NULL)
}
moduleF <- list(
  gss_pseudoR2_by_group = gss_by_group, gss_n = gss_n,
  table1_HdivL = cbind(t1_order, published = orig_t1_hl),
  panel_fidelity_band = panel_band,
  anchor_partition = partition_rate("role"),
  anchor_partition_generous = partition_rate("role_generous"),
  total_band = as.data.frame(table(cc$band)))
## F#9 -- egalitarianism item-count decomposition
X_cmp <- readRDS("output/replication/comparison_fullsample.rds")
egal_matched <- X_cmp$matched_baseline$breadth_matched_8416[X_cmp$matched_baseline$construct=="Egalitarianism"]
egal_full8416 <- X_cmp$anchor_full$breadth_8416[X_cmp$anchor_full$construct=="Egalitarianism"]
mt_matched <- X_cmp$matched_baseline$breadth_matched_8416[X_cmp$matched_baseline$construct=="Moral Tradition"]
mt_full8416 <- X_cmp$anchor_full$breadth_8416[X_cmp$anchor_full$construct=="Moral Tradition"]
moduleF$item_count_decomp <- data.frame(
  construct = c("Egalitarianism","Moral Tradition"),
  unmatched_8416 = c(egal_full8416, mt_full8416),
  matched_8416   = c(egal_matched, mt_matched),
  y2020 = c(unname(X_cmp$breadth_2020["Egalitarianism"]), unname(X_cmp$breadth_2020["Moral Tradition"])),
  y2024 = c(unname(X_cmp$breadth_2024["Egalitarianism"]), unname(X_cmp$breadth_2024["Moral Tradition"])))
moduleF$item_count_decomp$rise_unmatched_2024 <- moduleF$item_count_decomp$y2024 - moduleF$item_count_decomp$unmatched_8416
moduleF$item_count_decomp$rise_matched_2024   <- moduleF$item_count_decomp$y2024 - moduleF$item_count_decomp$matched_8416
moduleF$item_count_decomp$itemcount_pp_2024   <- moduleF$item_count_decomp$matched_8416 - moduleF$item_count_decomp$unmatched_8416
saveRDS(moduleF, file.path(OUT, "F_small_computations.rds"))

## ============================================================================
## MODULE G -- BOOTSTRAP CI for the 2020 ideology vote-potency H/L ratio
##   Nonparametric bootstrap (case resampling) of the pseudo-R2 Highest/Lower
##   ratio and the AME Highest/Lower ratio, to bound the headline ratio's noise.
## ============================================================================
set.seed(20240703)
gvote <- d20[!is.na(d20$ideo) & !is.na(d20$repvote) & !is.na(d20$wt_post) & !is.na(d20$know4), ]
gvote$g <- droplevels(gvote$know4)
r2_ratio_once <- function(df) {
  fit <- function(sub) {
    if (nrow(sub) < 30 || length(unique(sub$repvote)) < 2) return(NA)
    m <- suppressWarnings(glm(repvote ~ ideo, data=sub, family=binomial("probit"), weights=wt_post))
    m0<- suppressWarnings(glm(repvote ~ 1,    data=sub, family=binomial("probit"), weights=wt_post))
    mcf(m, m0)
  }
  hi <- fit(df[df$g=="Highest",]); lo <- fit(df[df$g=="Lower",]); hi/lo
}
point_ratio <- r2_ratio_once(gvote)
B <- 500
boot <- replicate(B, {
  idx <- sample(nrow(gvote), replace = TRUE)
  suppressWarnings(r2_ratio_once(gvote[idx, ]))
})
ratio_ci <- list(point = round(point_ratio, 2),
                 ci = round(quantile(boot, c(.025,.975), na.rm=TRUE), 2),
                 B = B,
                 n_lower = sum(gvote$g=="Lower"), n_highest = sum(gvote$g=="Highest"))
saveRDS(ratio_ci, file.path(OUT, "G_bootstrap_ratio.rds"))

## ============================================================================
## CONSOLE SUMMARY
## ============================================================================
cat("\n================= MODULE A: sorting vs constraint =================\n")
print(moduleA[, c("era","group","n","r2_party","r2_partyideo","incr_ideo","ame_ideo_joint","cor_ideo_party")], row.names=FALSE)
cat("\n================= MODULE B: AME vs pseudo-R2 H/L ratios ============\n")
print(moduleB[, c("era","predictor","AME_H_div_L","R2_H_div_L","n_Lower","n_Highest")], row.names=FALSE)
cat("\n================= MODULE C: panel retention & reweighted stability =\n")
print(moduleC$composition_5grp); cat("overall retention %:", overall_retention, " n_panel:", nrow(panel), "\n")
print(moduleC$stability_reweighted)
cat("\n================= MODULE D: breadth with/without nonattitudes ======\n")
print(moduleD$ideology); cat("decomp 2020:\n"); print(moduleD$decomp_2020); cat("decomp 2024:\n"); print(moduleD$decomp_2024)
cat("\n================= MODULE E: 2020 mode comparison ==================\n")
print(moduleE$mode_table); print(moduleE$ideo_voteR2_web)
cat("\n================= MODULE F: small computations ====================\n")
cat("GSS pseudo-R2 by group:\n"); print(gss_by_group)
cat("Table1 H/L:\n"); print(moduleF$table1_HdivL)
cat("Panel fidelity banding:\n"); print(panel_band)
cat("Anchor/validation partition (primary):\n"); print(moduleF$anchor_partition)
cat("Anchor/validation partition (generous):\n"); print(moduleF$anchor_partition_generous)
cat("Total band (should be 154/17/5):\n"); print(moduleF$total_band)
cat("Egal item-count decomp:\n"); print(moduleF$item_count_decomp)
cat("2020 ideology H/L pseudo-R2 ratio:", ratio_ci$point, " 95% boot CI:", ratio_ci$ci, "\n")
cat("\n===== 07_revision.R DONE =====\n")
