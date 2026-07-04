## 03_robustness.R
## Robustness / sensitivity suite for the reproduction of Kalmoe (2020),
## "Uses and Abuses of Ideology in Political Psychology", Political Psychology,
## doi:10.1111/pops.12650.
##
## Runs end-to-end via `Rscript R/03_robustness.R` from the project root, AFTER
## R/01_prepare_cdf.R has built output/repro_main/cdf_analysis.rds.
## Writes one tidy .rds per check to output/robustness/ (rc1_polar.rds ... rc8_issues.rds)
## and a human-readable robustness_report.md.
##
## Structure mirrors the FORRT robustness brief (RC1..RC8). Helper defs are copied
## from R/01/02 so cells stay directly comparable; 01/02 are NOT modified.

suppressMessages({
  library(dplyr); library(tidyr); library(psych)
  library(sandwich); library(MASS); library(marginaleffects)
})
select <- dplyr::select

DF   <- readRDS("output/repro_main/cdf_analysis.rds")
OUT  <- "output/robustness"
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

## ---- shared helpers (copied from 02) ----------------------------------------
klab5 <- c(`0`="Lowest", `0.25`="Low", `0.5`="Middle", `0.75`="High", `1`="Highest")
grp5  <- function(k) factor(klab5[as.character(k)],
                            levels = c("Lowest","Low","Middle","High","Highest"))
grp4  <- function(k) factor(ifelse(k<=0.25,"Lower", klab5[as.character(k)]),
                            levels = c("Lower","Middle","High","Highest"))
YR <- list(
  egal   = c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2004,2008,2012,2016),
  mt     = c(1986,1988,1990,1992,1994,1996,1998,2000,2004,2008,2012,2016),
  policy = c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2004,2008,2012,2016),
  ideo   = c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2002,2004,2008,2012,2016),
  party  = c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2002,2004,2008,2012,2016))
presyr  <- c(1984,1988,1992,1996,2000,2004,2008,2012,2016)
lev6    <- c("Full","Lowest","Low","Middle","High","Highest")
constructs <- c("egal","mt","policy","ideo","party")
item_cols <- list(egal=paste0("egal_i",1:6), mt=paste0("mt_i",1:4), policy=paste0("pol_i",1:5))

polar_incl <- function(s) as.integer(abs(s) >= 0.5)   # inclusive outer half (baseline)
wmean <- function(x, w) sum(x*w, na.rm=TRUE)/sum(w[!is.na(x)], na.rm=TRUE)
# weighted SD (population-style, matching Stata/summarize with weights)
wsd <- function(x, w) {
  ok <- !is.na(x) & !is.na(w); x <- x[ok]; w <- w[ok]
  m <- sum(w*x)/sum(w); sqrt(sum(w*(x-m)^2)/sum(w))
}
avgcov  <- function(M){ C <- cov(M, use="pairwise.complete.obs"); mean(C[lower.tri(C)]) }
alpha_raw <- function(M){ suppressWarnings(psych::alpha(M, warnings=FALSE, check.keys=FALSE)$total$raw_alpha) }

REP <- list()  # accumulate report chunks (character vectors)
rp  <- function(...) REP[[length(REP)+1]] <<- paste0(...)

## =====================================================================
## RC1 -- Polar-half operationalization (Table 1)
##   (a) exclusive |x|>0.5 vs inclusive >=0.5 (baseline)
##   (b) relative outlyingness: % beyond +-1 SD from construct pooled (weighted) mean
##       -> author SI Table A1 gives targets
##   (c) alternative polar = outer THIRD of the scale (|x|>1/3)
##   Weighted (Table 1 convention).
## =====================================================================
t1_target <- list(  # Table 1 polar-half (baseline) reference
  egal=c(32,26,26,30,35,43), mt=c(35,17,25,33,42,45),
  policy=c(18,11,13,16,21,29), ideo=c(27,11,16,24,34,44),
  party=c(61,41,55,63,66,67))
# author SI Table A1 "% >1 SD from mean" (transcribed from supplement; see report)
a1_1sd_target <- list(
  egal=c(30,20,22,28,34,43), mt=c(31,17,22,29,38,43),
  policy=c(26,18,20,23,29,38), ideo=c(27,11,16,24,34,44),
  party=c(44,25,35,45,50,54))

t1_variant <- function(rule) {
  # rule: function(scores, pooled_mean, pooled_sd) -> 0/1 flag
  rows <- lapply(constructs, function(v){
    x <- DF %>% filter(keepmode, year %in% YR[[v]], !is.na(know), !is.na(.data[[v]]))
    pm <- wmean(x[[v]], x$wt_x); ps <- wsd(x[[v]], x$wt_x)
    x$flag <- rule(x[[v]], pm, ps); x$g <- grp5(x$know)
    full <- 100*wmean(x$flag, x$wt_x)
    by <- sapply(levels(x$g), function(gl){ s <- x[x$g==gl,]; 100*wmean(s$flag, s$wt_x) })
    data.frame(construct=v, Full=full, Lowest=by["Lowest"], Low=by["Low"],
               Middle=by["Middle"], High=by["High"], Highest=by["Highest"],
               H_minus_L=by["Highest"]-by["Lowest"], H_div_L=by["Highest"]/by["Lowest"],
               row.names=NULL)
  })
  bind_rows(rows)
}

rc1_incl <- t1_variant(function(s,m,sd) as.integer(abs(s) >= 0.5))
rc1_excl <- t1_variant(function(s,m,sd) as.integer(abs(s) >  0.5))
rc1_1sd  <- t1_variant(function(s,m,sd) as.integer(abs(s-m) >  sd))
rc1_third<- t1_variant(function(s,m,sd) as.integer(abs(s) >  1/3))

rc1 <- list(inclusive=rc1_incl, exclusive=rc1_excl, sd1=rc1_1sd, third=rc1_third,
            a1_1sd_target=a1_1sd_target, t1_target=t1_target)
saveRDS(rc1, file.path(OUT,"rc1_polar.rds"))
cat("RC1 done\n")

## =====================================================================
## RC2 -- Nonattitude coding: do "innocence" patterns depend on scoring
##   nonattitudes (ideology HTMA / policy DK) as moderate?
##   (a) ideology HTMA -> NA (drop)   (b) policy DK -> NA (answered-item mean)
##   (c) both together.
##   Recompute Figure-1 ideology distribution, Table 1 rows, Table 4 correlations.
##   Requires the RAW items (prepared data has HTMA/DK baked in at 0).
## =====================================================================
suppressWarnings(load("data/raw/timeseries_cum.rda"))
tc  <- timeseries_cum
yrf <- as.numeric(tc$VCF0004) >= 1984            # aligns to DF row order
nzr <- function(v) as.numeric(tc[[v]])[yrf]
stopifnot(length(nzr("VCF0803")) == nrow(DF))

# alternative ideology: HTMA(9) -> NA (drop) instead of -> 0
io <- nzr("VCF0803")
ideo_drop <- ifelse(io %in% 1:7, (io-4)/3, NA)          # HTMA removed
# alternative policy: DK(9) -> NA (mean of answered items only)
pol7na <- function(v, dir){ x <- nzr(v); s <- ifelse(x %in% 1:7,(x-4)/3, NA); if(dir<0) -s else s }
polM_na <- cbind(pol7na("VCF0843",-1), pol7na("VCF0809",-1), pol7na("VCF0830",-1),
                 pol7na("VCF0806",-1), pol7na("VCF0839",+1))
nanmean <- function(M){ m <- rowMeans(M, na.rm=TRUE); m[is.nan(m)] <- NA; m }
policy_dkna <- nanmean(polM_na)

D2 <- DF %>% mutate(ideo_drop = ideo_drop, policy_dkna = policy_dkna,
                    ideo_cat_raw = io)   # raw code (9 distinct from 4)

# -- Figure-1 ideology distribution: HTMA folded (baseline) vs HTMA dropped --
fd_base <- D2 %>% filter(keepmode, year %in% YR$ideo, !is.na(ideo_cat)) %>%
  count(ideo_cat) %>% mutate(pct = round(100*n/sum(n),1))
fd_drop <- D2 %>% filter(keepmode, year %in% YR$ideo, ideo_cat_raw %in% 1:7) %>%
  count(ideo_cat_raw) %>% mutate(pct = round(100*n/sum(n),1))
htma_share <- D2 %>% filter(keepmode, year %in% YR$ideo, ideo_cat_raw %in% c(1:7,9)) %>%
  summarise(htma = round(100*mean(ideo_cat_raw==9),1)) %>% pull(htma)

# -- Table 1 rows (weighted polar half) for the alternative codings --
t1_row <- function(var, yrs){
  x <- D2 %>% filter(keepmode, year %in% yrs, !is.na(know), !is.na(.data[[var]])) %>%
    mutate(g=grp5(know), pol=polar_incl(.data[[var]]))
  by <- sapply(levels(x$g), function(gl){ s<-x[x$g==gl,]; 100*wmean(s$pol,s$wt_x) })
  data.frame(var=var, N=nrow(x), Full=100*wmean(x$pol,x$wt_x),
             Lowest=by["Lowest"],Low=by["Low"],Middle=by["Middle"],High=by["High"],Highest=by["Highest"],
             H_minus_L=by["Highest"]-by["Lowest"], row.names=NULL)
}
rc2_t1 <- bind_rows(
  cbind(coding="ideo HTMA->0 (base)",  t1_row("ideo", YR$ideo)),
  cbind(coding="ideo HTMA->NA (drop)", t1_row("ideo_drop", YR$ideo)),
  cbind(coding="policy DK->0 (base)",  t1_row("policy", YR$policy)),
  cbind(coding="policy DK->NA",        t1_row("policy_dkna", YR$policy)))

# -- Table 4 correlations under alternative codings (unweighted Pearson, aligned +) --
cor_by_grp <- function(dat, a, b){
  x <- dat %>% filter(keepmode, !is.na(know), !is.na(.data[[a]]), !is.na(.data[[b]])) %>% mutate(g=grp5(know))
  full <- abs(cor(x[[a]], x[[b]]))
  by <- sapply(levels(x$g), function(gl){ s<-x[x$g==gl,]; if(nrow(s)>2) abs(cor(s[[a]],s[[b]])) else NA })
  c(N=nrow(x), Full=full, by)
}
pairs_ideo <- list(c("egal","ideo"),c("mt","ideo"),c("policy","ideo"),c("ideo","party"))
pairs_pol  <- list(c("egal","policy"),c("mt","policy"),c("policy","ideo"),c("policy","party"))
mk_cor_tab <- function(dat, pairlist, amap=identity, bmap=identity){
  rows <- lapply(pairlist, function(p){
    a <- amap(p[1]); b <- bmap(p[2])
    r <- cor_by_grp(dat, a, b)
    data.frame(pair=paste(p[1],"x",p[2]), N=r["N"], Full=r["Full"],
               Lowest=r["Lowest"],Low=r["Low"],Middle=r["Middle"],High=r["High"],Highest=r["Highest"],
               row.names=NULL)
  }); bind_rows(rows)
}
# (a) ideology correlations: baseline vs HTMA-dropped
rc2_cor_ideo_base <- mk_cor_tab(D2, pairs_ideo)
rc2_cor_ideo_drop <- mk_cor_tab(D2, pairs_ideo, bmap=function(x) ifelse(x=="ideo","ideo_drop",x),
                                                amap=function(x) ifelse(x=="ideo","ideo_drop",x))
# (b) policy correlations: baseline vs DK->NA
rc2_cor_pol_base <- mk_cor_tab(D2, pairs_pol)
rc2_cor_pol_dkna <- mk_cor_tab(D2, pairs_pol, amap=function(x) ifelse(x=="policy","policy_dkna",x),
                                              bmap=function(x) ifelse(x=="policy","policy_dkna",x))

# (c) BOTH codings at once: the only pair that differs from the separate versions is
#     policy x ideology with policy_dkna AND ideo_drop simultaneously.
rc2_cor_both_polideo <- {
  r <- cor_by_grp(D2, "policy_dkna", "ideo_drop")
  data.frame(pair="policy x ideo (DK->NA & HTMA->drop)", N=r["N"], Full=r["Full"],
             Lowest=r["Lowest"], Low=r["Low"], Middle=r["Middle"], High=r["High"], Highest=r["Highest"],
             row.names=NULL)
}
# Figure-1 moderate/HTMA bar: baseline folds HTMA into "moderate"; dropped = true moderates only
moderate_bar <- data.frame(
  base_moderate_HTMA_pct = fd_base$pct[fd_base$ideo_cat==4],
  dropped_true_moderate_pct = fd_drop$pct[fd_drop$ideo_cat_raw==4])

rc2 <- list(fig1_baseline=fd_base, fig1_htma_dropped=fd_drop, htma_share_pct=htma_share,
            moderate_bar=moderate_bar, table1_rows=rc2_t1,
            cor_ideo_base=rc2_cor_ideo_base, cor_ideo_drop=rc2_cor_ideo_drop,
            cor_policy_base=rc2_cor_pol_base, cor_policy_dkna=rc2_cor_pol_dkna,
            cor_both_policy_ideo=rc2_cor_both_polideo)
saveRDS(rc2, file.path(OUT,"rc2_nonattitude.rds"))
cat("RC2 done\n")

## =====================================================================
## RC3 -- Weighting sensitivity.
##   Weighted versions of Table 2 (alpha / avg interitem cov) and Table 4
##   (correlations); unweighted version of Table 1 (polar half).
##   cov.wt() is listwise, so Table 2 is recomputed unweighted on the SAME
##   listwise rows to isolate the weighting effect from a deletion shift.
## =====================================================================
# weighted alpha + avg interitem covariance from a weighted covariance matrix
walpha_cov <- function(M, w){
  ok <- complete.cases(M) & !is.na(w); M <- M[ok,,drop=FALSE]; w <- w[ok]
  k <- ncol(M); C <- cov.wt(M, wt=w, method="ML")$cov
  a <- k/(k-1) * (1 - sum(diag(C))/sum(C))
  list(alpha=a, cov=mean(C[lower.tri(C)]), n=nrow(M))
}
ualpha_cov_listwise <- function(M){
  ok <- complete.cases(M); M <- M[ok,,drop=FALSE]
  list(alpha=alpha_raw(M), cov=avgcov(M), n=nrow(M))
}
rc3_t2 <- list()
for (v in c("egal","mt","policy")){
  cols <- item_cols[[v]]
  base <- DF %>% filter(keepmode, year %in% YR[[v]], !is.na(know),
                        rowSums(!is.na(across(all_of(cols)))) > 0)
  grpsets <- c(list(Full=base), split(base, grp5(base$know))[c("Lowest","Low","Middle","High","Highest")])
  wa <- sapply(grpsets, function(s){ r<-walpha_cov(as.matrix(s[,cols]), s$wt_x); r$alpha })
  wc <- sapply(grpsets, function(s){ r<-walpha_cov(as.matrix(s[,cols]), s$wt_x); r$cov })
  ua <- sapply(grpsets, function(s){ r<-ualpha_cov_listwise(as.matrix(s[,cols])); r$alpha })
  rc3_t2[[v]] <- data.frame(construct=v,
    stat=c("alpha_weighted","alpha_unweighted_listwise","avgcov_weighted"),
    Full=c(wa["Full"],ua["Full"],wc["Full"]),
    Lowest=c(wa["Lowest"],ua["Lowest"],wc["Lowest"]),
    Low=c(wa["Low"],ua["Low"],wc["Low"]), Middle=c(wa["Middle"],ua["Middle"],wc["Middle"]),
    High=c(wa["High"],ua["High"],wc["High"]), Highest=c(wa["Highest"],ua["Highest"],wc["Highest"]),
    row.names=NULL)
}
rc3_table2 <- bind_rows(rc3_t2)

# weighted Table 4 correlations (per-pair weighted Pearson via cov.wt, listwise per pair)
wcor <- function(x, y, w){ ok<-!is.na(x)&!is.na(y)&!is.na(w); C<-cov.wt(cbind(x[ok],y[ok]),wt=w[ok],cor=TRUE)$cor; C[1,2] }
pairs4 <- list(c("egal","mt"),c("egal","policy"),c("egal","ideo"),c("egal","party"),
               c("mt","policy"),c("mt","ideo"),c("mt","party"),
               c("policy","ideo"),c("policy","party"),c("ideo","party"))
rc3_t4 <- lapply(pairs4, function(p){
  x <- DF %>% filter(keepmode, !is.na(know), !is.na(.data[[p[1]]]), !is.na(.data[[p[2]]])) %>% mutate(g=grp5(know))
  full <- abs(wcor(x[[p[1]]], x[[p[2]]], x$wt_x))
  by <- sapply(levels(x$g), function(gl){ s<-x[x$g==gl,]; if(nrow(s)>2) abs(wcor(s[[p[1]]],s[[p[2]]],s$wt_x)) else NA })
  data.frame(pair=paste(p[1],"x",p[2]), Full=full, Lowest=by["Lowest"],Low=by["Low"],
             Middle=by["Middle"],High=by["High"],Highest=by["Highest"], row.names=NULL)
})
rc3_table4 <- bind_rows(rc3_t4)

# unweighted Table 1 (polar half) vs weighted baseline
rc3_t1 <- lapply(constructs, function(v){
  x <- DF %>% filter(keepmode, year %in% YR[[v]], !is.na(know), !is.na(.data[[v]])) %>%
    mutate(g=grp5(know), pol=polar_incl(.data[[v]]))
  wtd <- c(Full=100*wmean(x$pol,x$wt_x), sapply(levels(x$g),function(gl){s<-x[x$g==gl,];100*wmean(s$pol,s$wt_x)}))
  unw <- c(Full=100*mean(x$pol), sapply(levels(x$g),function(gl){s<-x[x$g==gl,];100*mean(s$pol)}))
  data.frame(construct=v, weighting=c("weighted","unweighted"),
             rbind(wtd,unw), row.names=NULL, check.names=FALSE)
})
rc3_table1 <- bind_rows(rc3_t1)

rc3 <- list(table1_polar=rc3_table1, table2_reliability=rc3_table2, table4_cor=rc3_table4)
saveRDS(rc3, file.path(OUT,"rc3_weighting.rds"))
cat("RC3 done\n")

## =====================================================================
## RC4 -- Knowledge stratifier alternatives (measurement of the moderator).
##   (a) Education (VCF0110, 4-cat) as the stratifier.
##   (b) Campaign quiz knowledge 1986-1992, 5 bins approximating interviewer
##       shares -> compare to author SI Tables B1/B2/B4.
##   (c) Median split of the interviewer rating -> how much stratification a
##       2-group split hides vs 5 groups (the Azevedo point).
##   Generalized builders: strata table for Table 1 / 2 / 4 given a group factor.
## =====================================================================
# generic stratified builders (group factor `g` supplied; `gl` = ordered levels)
t1_by <- function(dat, gl){
  lapply(constructs, function(v){
    x <- dat %>% filter(!is.na(g), year %in% YR[[v]], !is.na(.data[[v]])) %>% mutate(pol=polar_incl(.data[[v]]))
    full <- 100*wmean(x$pol, x$wt_x)
    by <- sapply(gl, function(g0){ s<-x[x$g==g0,]; 100*wmean(s$pol,s$wt_x) })
    data.frame(construct=v, N=nrow(x), Full=full, t(by),
               H_minus_L=by[length(gl)]-by[1], check.names=FALSE, row.names=NULL)
  }) %>% bind_rows()
}
t2_by <- function(dat, gl){
  lapply(c("egal","mt","policy"), function(v){
    cols <- item_cols[[v]]
    b <- dat %>% filter(!is.na(g), year %in% YR[[v]], rowSums(!is.na(across(all_of(cols))))>0)
    sets <- c(list(Full=b), split(b, b$g)[gl])
    aa <- sapply(sets, function(s) alpha_raw(as.matrix(s[,cols])))
    data.frame(construct=v, stat="alpha", t(round(aa,3)),
               H_minus_L=round(aa[length(gl)+1]-aa[2],3), check.names=FALSE, row.names=NULL)
  }) %>% bind_rows()
}
t4_by <- function(dat, gl){
  lapply(pairs4, function(p){
    x <- dat %>% filter(!is.na(g), !is.na(.data[[p[1]]]), !is.na(.data[[p[2]]]))
    full <- abs(cor(x[[p[1]]], x[[p[2]]]))
    by <- sapply(gl, function(g0){ s<-x[x$g==g0,]; if(nrow(s)>2) abs(cor(s[[p[1]]],s[[p[2]]])) else NA })
    data.frame(pair=paste(p[1],"x",p[2]), Full=full, t(by),
               H_minus_L=by[length(gl)]-by[1], check.names=FALSE, row.names=NULL)
  }) %>% bind_rows()
}

## ---- (a) Education stratifier (4 groups) ----
edu <- nzr("VCF0110"); edu[!edu %in% 1:4] <- NA
edulab <- c("GradeSch","HighSch","SomeColl","College+")
Da <- DF %>% mutate(g = factor(edulab[edu], levels=edulab)) %>% filter(keepmode)
rc4a <- list(shares = round(prop.table(table(Da$g[!is.na(Da$g)])),3),
             table1 = t1_by(Da, edulab), table2 = t2_by(Da, edulab), table4 = t4_by(Da, edulab))

## ---- (b) Campaign quiz knowledge (1986-1992), 5 bins ----
house <- ifelse(nzr("VCF0729")%in%1:2, as.integer(nzr("VCF0729")==2), NA)
senate<- ifelse(nzr("VCF9036")%in%c(1,2,4,5,8), as.integer(nzr("VCF9036")%in%1:2), NA)
nmc   <- nzr("VCF0976") %% 10
names2<- ifelse(nzr("VCF0976")%in%c(0,10,11,20,21,22,30,31,32,33), pmin(nmc,2)/2, NA)
incum <- ifelse(nzr("VCF0978")%in%1:2, as.integer(nzr("VCF0978")==1), NA)
quiz  <- nanmean(cbind(house, senate, names2, incum))
qyr   <- DF$year %in% c(1986,1988,1990,1992)
# validation anchors vs paper (m=.48, sd=.26, r(interviewer)=.48)
qv_sel <- qyr & DF$keepmode & !is.na(quiz)
quiz_anchors <- c(m=mean(quiz[qv_sel]), sd=sd(quiz[qv_sel]),
                  r_interviewer=cor(quiz[qv_sel], DF$know[qv_sel], use="complete.obs"),
                  n=sum(qv_sel))
# bin into 5 groups approximating interviewer B1 shares 19/15/35/17/14
qbin <- function(q, sel, targ=c(.19,.15,.35,.17,.14)){
  cutp <- cumsum(targ); qv <- q; g <- rep(NA_integer_, length(q))
  s <- which(sel & !is.na(q)); o <- s[order(qv[s])]
  cs <- cumsum(rep(1, length(o)))/length(o)
  lab <- findInterval(cs, cutp[-5]) + 1
  g[o] <- lab; factor(c("Lowest","Low","Middle","High","Highest")[g],
                      levels=c("Lowest","Low","Middle","High","Highest"))
}
Db <- DF %>% mutate(g = qbin(quiz, qv_sel)) %>% filter(keepmode, qyr)
qgl <- c("Lowest","Low","Middle","High","Highest")
# restrict Db to 1986-1992 already; but t1_by/t4_by re-filter by YR (which include these yrs)
rc4b <- list(anchors=round(quiz_anchors,3),
             shares=round(prop.table(table(Db$g[!is.na(Db$g)])),3),
             table1=t1_by(Db, qgl), table2=t2_by(Db, qgl), table4=t4_by(Db, qgl))
# author SI B-table targets (1986-1992 quiz knowledge), transcribed from supplement
rc4b$B1_polar_target <- list(  # Full, Lowest, Low, Middle, High, Highest
  egal=c(35,29,30,32,32,36), mt=c(38,24,32,34,42,47), policy=c(16,15,16,17,15,21),
  ideo=c(26,18,26,33,39,NA), party=c(66,61,64,67,69,66))
rc4b$B2_alpha_target <- list(egal=c(.70,.61,.65,.69,.73,.79), mt=c(.64,.49,.58,.62,.71,.76),
  policy=c(.62,.49,.59,.58,.70,.77))
# -- B5: quiz-knowledge bivariate vote probit (1988, 1992), 5 bins (shares 12/11/37/21/20) --
mcf_local <- function(m,m0) 1 - as.numeric(logLik(m)/logLik(m0))
probit_r2 <- function(d, predexpr){
  d$p <- eval(parse(text=predexpr), d); d <- d %>% filter(!is.na(p),!is.na(repvote),!is.na(wt_x))
  if(nrow(d)<30) return(c(coef=NA,r2=NA))
  m<-suppressWarnings(glm(repvote~p,data=d,family=binomial("probit"),weights=wt_x))
  m0<-suppressWarnings(glm(repvote~1,data=d,family=binomial("probit"),weights=wt_x))
  c(coef=unname(coef(m)["p"]), r2=mcf_local(m,m0))
}
qv_vote_sel <- DF$year %in% c(1988,1992) & DF$keepmode & !is.na(quiz) & !is.na(DF$repvote)
Dqv <- DF %>% mutate(gq = qbin(quiz, qv_vote_sel, targ=c(.12,.11,.37,.21,.20)),
                     egal_rev=-egal, policy_rev=-policy) %>%
  filter(year %in% c(1988,1992), keepmode, !is.na(quiz), !is.na(repvote))
qv_specs <- c(Egalitarianism="egal_rev", MoralTrad="mt", PolicyViews="policy_rev",
              IdeoID="ideo", Partisanship="party")
rc4b_vote <- lapply(names(qv_specs), function(nm){
  ex <- qv_specs[nm]
  full <- probit_r2(Dqv, ex)
  by <- sapply(qgl, function(g0) probit_r2(Dqv[Dqv$gq==g0,], ex))
  data.frame(predictor=nm, stat="pseudoR2", Full=round(full["r2"],3), t(round(by["r2",],3)),
             coef_Full=round(full["coef"],3), check.names=FALSE, row.names=NULL)
}) %>% bind_rows()
rc4b$vote_probit <- rc4b_vote
rc4b$vote_shares <- round(prop.table(table(Dqv$gq[!is.na(Dqv$gq)])),3)
# author SI Table B5 pseudo-R2 targets (Full,Lowest,Low,Middle,High,Highest)
rc4b$B5_r2_target <- list(
  Egalitarianism=c(.13,.13,.07,.10,.18,.17), MoralTrad=c(.10,.05,.09,.07,.17,.17),
  PolicyViews=c(.20,.05,.07,.18,.25,.43), IdeoID=c(.19,.04,.09,.14,.32,.42),
  Partisanship=c(.48,.31,.34,.50,.57,.56))

## ---- (c) Median split of interviewer rating (2 groups) ----
kmed <- median(rep(DF$know[DF$keepmode & !is.na(DF$know)], 1))
# split so the two halves are as close to 50/50 as possible on the population
Dc <- DF %>% filter(keepmode, !is.na(know)) %>%
  mutate(g = factor(ifelse(know <= 0.5, "BottomHalf","TopHalf"), levels=c("BottomHalf","TopHalf")))
med_shares <- round(prop.table(table(Dc$g)),3)
mgl <- c("BottomHalf","TopHalf")
rc4c_t1 <- t1_by(Dc, mgl); rc4c_t2 <- t2_by(Dc, mgl); rc4c_t4 <- t4_by(Dc, mgl)
# compare 2-group spread to 5-group spread (baseline Table 1 H-L from rc1_incl)
spread_cmp <- data.frame(construct=constructs,
  fivegrp_H_minus_L = round(rc1_incl$H_minus_L,1),
  twogrp_Top_minus_Bottom = round(rc4c_t1$H_minus_L,1))
rc4c <- list(split_at=kmed, shares=med_shares, table1=rc4c_t1, table2=rc4c_t2, table4=rc4c_t4,
             spread_comparison=spread_cmp)

rc4 <- list(education=rc4a, quiz=rc4b, median_split=rc4c)
saveRDS(rc4, file.path(OUT,"rc4_stratifier.rds"))
cat("RC4 done\n")

## =====================================================================
## RC5 -- Reliability operationalization (Table 2).
##   Ordinal (polychoric) alpha and McDonald's omega-total by knowledge group;
##   does the knowledge gradient in coherence survive ordinal treatment?
##   Validation: author SI Table D4 compares average interitem Pearson vs
##   polychoric correlations (1986-1992, interviewer-rating groups).
##   Ordinal codes are reconstructed (direction-aligned) from the item columns.
## =====================================================================
# aligned integer ordinal codes from the -1..+1 aligned item columns
to_ord <- function(s, npt){ if(npt==5) round(2*s+3) else round(3*s+4) }
ord_mat <- function(sub, v){
  cols <- item_cols[[v]]; npt <- if(v=="policy") 7 else 5
  M <- as.matrix(sub[,cols]); apply(M, 2, to_ord, npt=npt)
}
avg_iic <- function(R) mean(R[lower.tri(R)], na.rm=TRUE)
# ordinal alpha = alpha on polychoric matrix; omega_total from polychoric
rel_measures <- function(sub, v){
  cols <- item_cols[[v]]
  Mc <- as.matrix(sub[,cols])                       # continuous aligned (Pearson)
  Mo <- ord_mat(sub, v)                             # integer ordinal aligned
  Rp <- cor(Mc, use="pairwise.complete.obs")
  pearson_alpha <- tryCatch(suppressWarnings(psych::alpha(Rp, n.obs=nrow(sub))$total$std.alpha), error=function(e) NA)
  rho <- tryCatch(suppressWarnings(psych::polychoric(Mo, progress=FALSE)$rho), error=function(e) NULL)
  if (is.null(rho) || any(is.na(rho))) { ord_alpha<-NA; omega_t<-NA; poly_iic<-NA }
  else {
    ord_alpha <- tryCatch(suppressWarnings(psych::alpha(rho, n.obs=nrow(sub))$total$std.alpha), error=function(e) NA)
    omega_t   <- tryCatch(suppressWarnings(psych::omega(rho, nfactors=1, n.obs=nrow(sub), plot=FALSE, flip=FALSE)$omega.tot), error=function(e) NA)
    poly_iic  <- avg_iic(rho)
  }
  c(pearson_alpha=pearson_alpha, ordinal_alpha=ord_alpha, omega_total=omega_t,
    pearson_iic=avg_iic(Rp), poly_iic=poly_iic)
}
rc5_main <- list()
for (v in c("egal","mt","policy")){
  cols <- item_cols[[v]]
  base <- DF %>% filter(keepmode, year %in% YR[[v]], !is.na(know),
                        rowSums(!is.na(across(all_of(cols))))>0)
  sets <- c(list(Full=base), split(base, grp5(base$know))[c("Lowest","Low","Middle","High","Highest")])
  M <- sapply(sets, function(s) rel_measures(s, v))
  rc5_main[[v]] <- data.frame(construct=v, stat=rownames(M), round(t(t(M)),3), check.names=FALSE)
}
rc5_reliability <- bind_rows(lapply(rc5_main, function(x){ rownames(x)<-NULL; x }))

# ---- D4 validation: avg interitem Pearson vs polychoric, 1986-1992 ----
d4_rows <- list()
for (v in c("egal","mt","policy")){
  cols <- item_cols[[v]]
  base <- DF %>% filter(keepmode, year %in% 1986:1992, !is.na(know),
                        rowSums(!is.na(across(all_of(cols))))>0)
  sets <- c(list(Full=base), split(base, grp5(base$know))[c("Lowest","Low","Middle","High","Highest")])
  ic <- sapply(sets, function(s){ r<-rel_measures(s,v); c(pearson=r["pearson_iic"], poly=r["poly_iic"]) })
  d4_rows[[v]] <- data.frame(construct=v, stat=c("polychoric","pearson"),
    rbind(round(ic["poly.poly_iic",],3), round(ic["pearson.pearson_iic",],3)),
    check.names=FALSE, row.names=NULL)
}
rc5_d4 <- bind_rows(d4_rows)
# author D4 targets (Full, Lowest, Highest only readable): poly / pearson
rc5_d4_target <- list(
  egal   = list(poly=c(Full=.30,Lowest=.17,Highest=.46), pearson=c(Full=.26,Lowest=.14,Highest=.39)),
  mt     = list(poly=c(Full=.35,Lowest=.13,Highest=.49), pearson=c(Full=.30,Lowest=.12,Highest=.41)),
  policy = list(poly=c(Full=.29,Lowest=.12,Highest=.47), pearson=c(Full=.26,Lowest=.11,Highest=.44)))

rc5 <- list(reliability=rc5_reliability, d4_interitem=rc5_d4, d4_target=rc5_d4_target)
saveRDS(rc5, file.path(OUT,"rc5_reliability.rds"))
cat("RC5 done\n")

## =====================================================================
## RC6 -- Vote models (Table 5).
##   (a) Multivariate probit with all 5 predictors; incremental McFadden R2
##       from adding VALUES (egal+MT) to a party+ideology base. Full & by group.
##   (b) Logit and LPM versions of the bivariate models -> do conclusions
##       depend on probit?
##   (c) Average marginal effects (AMEs) of the bivariate probits by group
##       (marginaleffects, weighted) -> coefficients are distribution-insensitive
##       but AMEs incorporate the distributions.
## =====================================================================
mcf <- function(m, m0) 1 - as.numeric(logLik(m)/logLik(m0))
V <- DF %>% filter(keepmode, year %in% presyr, !is.na(know), !is.na(repvote), !is.na(wt_x)) %>%
  mutate(egal_rev=-egal, policy_rev=-policy, g4=grp4(know))
predset <- c("party","ideo","egal_rev","mt","policy_rev")

## ---- (a) Multivariate / incremental ----
incr_fit <- function(dat){
  d <- dat %>% filter(if_all(all_of(c(predset,"repvote","wt_x")), ~ !is.na(.)))
  if (nrow(d) < 50) return(NULL)
  f <- function(rhs) suppressWarnings(glm(as.formula(paste("repvote ~", rhs)), data=d,
                                          family=binomial("probit"), weights=wt_x))
  m0 <- f("1")
  seq_models <- list(
    party            = f("party"),
    party_ideo       = f("party + ideo"),
    party_ideo_pol   = f("party + ideo + policy_rev"),
    all5             = f("party + ideo + policy_rev + egal_rev + mt"))
  r2 <- sapply(seq_models, mcf, m0=m0)
  # increment from adding the two VALUES to a party+ideo(+policy) base
  m_base_pv <- f("party + ideo"); m_add_values <- f("party + ideo + egal_rev + mt")
  d_incr_values <- mcf(m_add_values, m0) - mcf(m_base_pv, m0)
  # full-model coefficients (all 5) with clustered SE
  mfull <- seq_models$all5
  se <- tryCatch(sqrt(diag(sandwich::vcovCL(mfull, cluster=d$year))), error=function(e) sqrt(diag(vcov(mfull))))
  co <- coef(mfull)
  list(N=nrow(d), r2_seq=r2, incr_values=d_incr_values,
       coef=co[predset], se=se[predset])
}
rc6a_full <- incr_fit(V)
rc6a_grp  <- lapply(levels(V$g4), function(g0) incr_fit(V[V$g4==g0,]))
names(rc6a_grp) <- levels(V$g4)
# assemble tidy tables
rc6a_r2 <- rbind(
  data.frame(group="Full", t(rc6a_full$r2_seq), incr_values=rc6a_full$incr_values),
  do.call(rbind, lapply(names(rc6a_grp), function(g0){
    r<-rc6a_grp[[g0]]; if(is.null(r)) return(NULL)
    data.frame(group=g0, t(r$r2_seq), incr_values=r$incr_values) })))
rc6a_coef <- data.frame(predictor=predset,
  Full_coef=round(rc6a_full$coef,3), Full_se=round(rc6a_full$se,3))

## ---- (b) Logit and LPM bivariate ----
biv_fit <- function(dat, pred, fam){
  d <- dat %>% filter(!is.na(.data[[pred]]), !is.na(repvote), !is.na(wt_x))
  d$p <- d[[pred]]
  if (fam=="lpm"){ m <- lm(repvote ~ p, data=d, weights=wt_x); return(c(coef=coef(m)["p"], r2=summary(m)$r.squared, N=nrow(d))) }
  m  <- suppressWarnings(glm(repvote ~ p, data=d, family=binomial(fam), weights=wt_x))
  m0 <- suppressWarnings(glm(repvote ~ 1,  data=d, family=binomial(fam), weights=wt_x))
  c(coef=unname(coef(m)["p"]), r2=mcf(m,m0), N=nrow(d))
}
rc6b <- list()
for (fam in c("probit","logit","lpm")){
  rows <- lapply(predset, function(pr){
    full <- biv_fit(V, pr, fam)
    by <- sapply(levels(V$g4), function(g0) biv_fit(V[V$g4==g0,], pr, fam))
    data.frame(predictor=pr, model=fam,
      Full_r2=full["r2"], Lower_r2=by["r2","Lower"], Middle_r2=by["r2","Middle"],
      High_r2=by["r2","High"], Highest_r2=by["r2","Highest"],
      Full_coef=full["coef"], row.names=NULL)
  })
  rc6b[[fam]] <- bind_rows(rows)
}
rc6b_tab <- bind_rows(rc6b)

## ---- (c) AMEs of bivariate probits by knowledge group (weighted) ----
ame_fit <- function(dat, pred){
  d <- dat %>% filter(!is.na(.data[[pred]]), !is.na(repvote), !is.na(wt_x)); d$p <- d[[pred]]
  m <- suppressWarnings(glm(repvote ~ p, data=d, family=binomial("probit"), weights=wt_x))
  s <- tryCatch(marginaleffects::avg_slopes(m, variables="p", wts=d$wt_x), error=function(e) NULL)
  co <- unname(coef(m)["p"])
  if (is.null(s)) return(c(ame=NA, coef=co)) ; c(ame=s$estimate[1], coef=co)
}
# AME by group, with the probit-coefficient ratio and pseudo-R2 ratio as like-for-like refs.
rc6c <- lapply(predset, function(pr){
  full <- ame_fit(V, pr)
  by <- sapply(levels(V$g4), function(g0) ame_fit(V[V$g4==g0,], pr))
  r2 <- sapply(levels(V$g4), function(g0) unname(biv_fit(V[V$g4==g0,], pr, "probit")["r2"]))
  data.frame(predictor=pr, Full_AME=round(full["ame"],3),
    Lower_AME=round(by["ame","Lower"],3), Middle_AME=round(by["ame","Middle"],3),
    High_AME=round(by["ame","High"],3), Highest_AME=round(by["ame","Highest"],3),
    AME_H_div_L=round(by["ame","Highest"]/by["ame","Lower"],2),
    coef_H_div_L=round(by["coef","Highest"]/by["coef","Lower"],2),
    pseudoR2_H_div_L=round(r2["Highest"]/r2["Lower"],2), row.names=NULL)
}) %>% bind_rows()

rc6 <- list(multivariate_r2=rc6a_r2, multivariate_coef=rc6a_coef,
            bivariate_family=rc6b_tab, ame=rc6c)
saveRDS(rc6, file.path(OUT,"rc6_vote.rds"))
cat("RC6 done\n")

## =====================================================================
## RC7 -- Time periods. Recompute Table 1 (polar, weighted), Table 2 (alpha,
##   unweighted), Table 4 (correlations, unweighted) for 1984-1996 vs 2000-2016
##   (5 groups); and 2008-2016 (4 groups) to validate vs SI Tables C1/C2/C4/C5.
##   Has ideological coherence / stratification grown with polarization?
## =====================================================================
gfun5 <- function(k) grp5(k); gfun4 <- function(k) grp4(k)
t1_period <- function(yrs, gf, gl){
  lapply(constructs, function(v){
    x <- DF %>% filter(keepmode, year %in% intersect(YR[[v]],yrs), !is.na(know), !is.na(.data[[v]])) %>%
      mutate(g=gf(know), pol=polar_incl(.data[[v]]))
    by <- sapply(gl, function(g0){ s<-x[x$g==g0,]; 100*wmean(s$pol,s$wt_x) })
    data.frame(construct=v, N=nrow(x), Full=100*wmean(x$pol,x$wt_x), t(by),
               H_minus_L=by[length(gl)]-by[1], check.names=FALSE, row.names=NULL)
  }) %>% bind_rows()
}
t2_period <- function(yrs, gf, gl){
  lapply(c("egal","mt","policy"), function(v){
    cols<-item_cols[[v]]
    b <- DF %>% filter(keepmode, year %in% intersect(YR[[v]],yrs), !is.na(know),
                       rowSums(!is.na(across(all_of(cols))))>0) %>% mutate(g=gf(know))
    sets <- c(list(Full=b), split(b, b$g)[gl])
    aa <- sapply(sets, function(s) alpha_raw(as.matrix(s[,cols])))
    data.frame(construct=v, Full=round(aa["Full"],3), t(round(aa[gl],3)),
               H_minus_L=round(aa[gl[length(gl)]]-aa[gl[1]],3), check.names=FALSE, row.names=NULL)
  }) %>% bind_rows()
}
t4_period <- function(yrs, gf, gl){
  lapply(pairs4, function(p){
    x <- DF %>% filter(keepmode, year %in% yrs, !is.na(know), !is.na(.data[[p[1]]]), !is.na(.data[[p[2]]])) %>% mutate(g=gf(know))
    by <- sapply(gl, function(g0){ s<-x[x$g==g0,]; if(nrow(s)>2) abs(cor(s[[p[1]]],s[[p[2]]])) else NA })
    data.frame(pair=paste(p[1],"x",p[2]), Full=abs(cor(x[[p[1]]],x[[p[2]]])), t(by),
               H_minus_L=by[length(gl)]-by[1], check.names=FALSE, row.names=NULL)
  }) %>% bind_rows()
}
# per-construct average |r| across its pairs (the C4-summary statistic)
avg_r_by_construct <- function(t4){
  sapply(constructs, function(v){
    rows <- grepl(paste0("\\b",v,"\\b"), t4$pair); mean(t4$Full[rows]) })
}
yr_early <- 1984:1996; yr_late <- 2000:2016; yr_08 <- 2008:2016
g5l <- levels(grp5(0)); g4l <- levels(grp4(0))
rc7 <- list(
  table1_early = t1_period(yr_early, gfun5, g5l), table1_late = t1_period(yr_late, gfun5, g5l),
  table2_early = t2_period(yr_early, gfun5, g5l), table2_late = t2_period(yr_late, gfun5, g5l),
  table4_early = t4_period(yr_early, gfun5, g5l), table4_late = t4_period(yr_late, gfun5, g5l))
rc7$avg_r_early <- round(avg_r_by_construct(rc7$table4_early),3)
rc7$avg_r_late  <- round(avg_r_by_construct(rc7$table4_late),3)
# 2008-2016 validation (4 groups) vs C tables
rc7$table1_2008 <- t1_period(yr_08, gfun4, g4l)
rc7$table2_2008 <- t2_period(yr_08, gfun4, g4l)
rc7$table4_2008 <- t4_period(yr_08, gfun4, g4l)
rc7$avg_r_2008  <- round(avg_r_by_construct(rc7$table4_2008),3)
# vote pseudo-R2 (full sample) 2008-2016 vs C5
V08 <- V %>% filter(year %in% yr_08)
rc7$vote_r2_2008 <- sapply(predset, function(pr){ r<-biv_fit(V08,pr,"probit"); unname(r["r2"]) })
# author C-table targets
rc7$C1_target <- list(egal=c(34,27,29,35,45), mt=c(34,18,30,39,46), policy=c(26,18,22,28,38),
                      ideo=c(32,15,26,39,49), party=c(58,41,57,63,66))  # Full,Lower,Middle,High,Highest
rc7$C2_target <- list(egal=c(.67,.51,.63,.70,.80), mt=c(.57,.33,.53,.59,.71), policy=c(.70,.49,.66,.73,.81))
rc7$C4_avg_target  <- c(egal=.37, mt=.33, policy=.40, ideo=.42, party=.42)
rc7$C5_r2_target   <- c(party=.53, ideo=.32, egal_rev=.20, mt=.18, policy_rev=.25)
saveRDS(rc7, file.path(OUT,"rc7_time.rds"))
cat("RC7 done\n")

## =====================================================================
## RC8 -- Issue selection (policy index).
##   (a) Leave-one-out versions of the 5-item policy index: recompute Table 4
##       policy x ideology / policy x party correlations and Table 5 policy
##       pseudo-R2 for each.
##   (b) 6-item variant adding the 4-pt abortion item (VCF0838, rescaled) -->
##       does broadening the issue set change conclusions?
##   LOO reuses the DK->midpoint pol_i columns; abortion is rescaled the same way.
## =====================================================================
polcols <- paste0("pol_i",1:5)
pol_labels <- c(pol_i1="defense", pol_i2="jobs", pol_i3="aid_blacks", pol_i4="health_ins", pol_i5="services")
nanmean_r <- function(M){ m<-rowMeans(M,na.rm=TRUE); m[is.nan(m)]<-NA; m }
# abortion rescaled to -1..+1, high = liberal (permissive), DK(9)->midpoint like policy
ab_raw <- nzr("VCF0838")
ab_s <- ifelse(ab_raw %in% 1:4, (ab_raw-2.5)/1.5, ifelse(ab_raw==9, 0, NA))

D8 <- DF
# build the index variants
for (j in 1:5){ keep<-polcols[-j]; D8[[paste0("pol_drop_",pol_labels[polcols[j]])]] <- nanmean_r(as.matrix(DF[,keep])) }
D8$pol_6item <- nanmean_r(cbind(as.matrix(DF[,polcols]), ab_s))
D8$pol_full5 <- DF$policy   # reference

variants <- c("pol_full5", paste0("pol_drop_",pol_labels[polcols]), "pol_6item")

# Table 4: policy-variant x ideo and x party, by knowledge group (unweighted)
rc8_cor <- lapply(variants, function(pv){
  res <- lapply(c("ideo","party"), function(other){
    x <- D8 %>% filter(keepmode, !is.na(know), !is.na(.data[[pv]]), !is.na(.data[[other]])) %>% mutate(g=grp5(know))
    full <- abs(cor(x[[pv]], x[[other]]))
    by <- sapply(levels(x$g), function(g0){ s<-x[x$g==g0,]; if(nrow(s)>2) abs(cor(s[[pv]],s[[other]])) else NA })
    data.frame(index=pv, vs=other, Full=full, Lowest=by["Lowest"], Highest=by["Highest"],
               H_minus_L=by["Highest"]-by["Lowest"], row.names=NULL)
  }); bind_rows(res)
}) %>% bind_rows()

# Table 5: policy-variant pseudo-R2 (weighted probit), predictor = -index (rev), Full + by grp4
V8 <- D8 %>% filter(keepmode, year %in% presyr, !is.na(know), !is.na(repvote), !is.na(wt_x)) %>%
  mutate(g4 = grp4(know))
rc8_r2 <- lapply(variants, function(pv){
  Vv <- V8 %>% mutate(predv = -.data[[pv]])   # (rev.) toward Republican vote
  ff <- function(d){ d<-d %>% filter(!is.na(predv),!is.na(repvote),!is.na(wt_x))
    m<-suppressWarnings(glm(repvote~predv,data=d,family=binomial("probit"),weights=wt_x))
    m0<-suppressWarnings(glm(repvote~1,data=d,family=binomial("probit"),weights=wt_x)); mcf(m,m0) }
  full <- ff(Vv); by <- sapply(levels(Vv$g4), function(g0) ff(Vv[Vv$g4==g0,]))
  data.frame(index=pv, Full=round(full,3), Lower=round(by["Lower"],3), Middle=round(by["Middle"],3),
             High=round(by["High"],3), Highest=round(by["Highest"],3), row.names=NULL)
}) %>% bind_rows()

rc8 <- list(correlations=rc8_cor, vote_r2=rc8_r2, abortion_n=sum(!is.na(ab_s) & DF$keepmode))
saveRDS(rc8, file.path(OUT,"rc8_issues.rds"))
cat("RC8 done\n")
