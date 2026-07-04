## Independent recompute of RC2 (nonattitude) and RC6c (AME vs coef) - not reusing pipeline fns.
suppressMessages({library(dplyr); library(marginaleffects)})

DF <- readRDS("output/repro_main/cdf_analysis.rds")
suppressWarnings(load("data/raw/timeseries_cum.rda"))
tc <- timeseries_cum
yrf <- as.numeric(tc$VCF0004) >= 1984
nzr <- function(v) as.numeric(tc[[v]])[yrf]
stopifnot(length(nzr("VCF0803"))==nrow(DF))

wmean <- function(x,w){ ok<-!is.na(x)&!is.na(w); sum(x[ok]*w[ok])/sum(w[ok]) }
klab5 <- c(`0`="Lowest",`0.25`="Low",`0.5`="Middle",`0.75`="High",`1`="Highest")
grp5 <- function(k) factor(klab5[as.character(k)], levels=c("Lowest","Low","Middle","High","Highest"))
YRideo <- c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2002,2004,2008,2012,2016)
YRpol  <- c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2004,2008,2012,2016)

## ---- RC2: build alternative codings from RAW ----
io <- nzr("VCF0803")                            # ideology 7pt, 9=HTMA
ideo_drop <- ifelse(io %in% 1:7, (io-4)/3, NA)  # HTMA -> NA
pol7na <- function(v,dir){ x<-nzr(v); s<-ifelse(x %in% 1:7,(x-4)/3,NA); if(dir<0) -s else s }
polM <- cbind(pol7na("VCF0843",-1),pol7na("VCF0809",-1),pol7na("VCF0830",-1),
              pol7na("VCF0806",-1),pol7na("VCF0839",+1))
nanmean <- function(M){ m<-rowMeans(M,na.rm=TRUE); m[is.nan(m)]<-NA; m }
policy_dkna <- nanmean(polM)

D2 <- DF %>% mutate(ideo_drop=ideo_drop, policy_dkna=policy_dkna, ioraw=io)

polar_row <- function(dat,var,yrs){
  x <- dat %>% filter(keepmode, year %in% yrs, !is.na(know), !is.na(.data[[var]])) %>%
    mutate(g=grp5(know), pol=as.integer(abs(.data[[var]])>=0.5))
  by <- sapply(levels(x$g), function(gl){ s<-x[x$g==gl,]; 100*wmean(s$pol,s$wt_x) })
  c(N=nrow(x), Full=100*wmean(x$pol,x$wt_x), by, H_minus_L=unname(by["Highest"]-by["Lowest"]))
}
cat("=== RC2: ideology polar-half by knowledge (weighted) ===\n")
cat("baseline (DF$ideo, HTMA->0):\n"); print(round(polar_row(D2,"ideo",YRideo),2))
cat("drop (ideo_drop, HTMA->NA):\n");  print(round(polar_row(D2,"ideo_drop",YRideo),2))
cat("\n=== RC2: policy polar-half by knowledge (weighted) ===\n")
cat("baseline (DF$policy, DK->0):\n");  print(round(polar_row(D2,"policy",YRpol),2))
cat("drop (policy_dkna, DK->NA):\n");   print(round(polar_row(D2,"policy_dkna",YRpol),2))

# HTMA share of ideology sample
hs <- D2 %>% filter(keepmode, year %in% YRideo, ioraw %in% c(1:7,9))
cat(sprintf("\nHTMA share of ideology sample: %.1f%%\n", 100*mean(hs$ioraw==9)))
# moderate bar: baseline folds HTMA into cat4; dropped = true moderates only
fb <- D2 %>% filter(keepmode, year %in% YRideo, !is.na(ideo_cat)) %>% count(ideo_cat) %>% mutate(p=100*n/sum(n))
fd <- D2 %>% filter(keepmode, year %in% YRideo, ioraw %in% 1:7) %>% count(ioraw) %>% mutate(p=100*n/sum(n))
cat(sprintf("moderate bar: folded(cat4)=%.1f%%  true-moderate(dropped)=%.1f%%\n",
            fb$p[fb$ideo_cat==4], fd$p[fd$ioraw==4]))

## ---- RC6c: AME vs coef ratio, ideology bivariate probit by knowledge (weighted) ----
presyr <- c(1984,1988,1992,1996,2000,2004,2008,2012,2016)
grp4 <- function(k) factor(ifelse(k<=0.25,"Lower",klab5[as.character(k)]),
                           levels=c("Lower","Middle","High","Highest"))
V <- DF %>% filter(keepmode, year %in% presyr, !is.na(know), !is.na(repvote), !is.na(wt_x)) %>%
  mutate(egal_rev=-egal, policy_rev=-policy, g4=grp4(know))

ame_coef <- function(dat,pred){
  d <- dat %>% filter(!is.na(.data[[pred]]), !is.na(repvote), !is.na(wt_x)); d$p<-d[[pred]]
  m <- suppressWarnings(glm(repvote~p, data=d, family=binomial("probit"), weights=wt_x))
  s <- marginaleffects::avg_slopes(m, variables="p", wts=d$wt_x)
  c(ame=s$estimate[1], coef=unname(coef(m)["p"]))
}
cat("\n=== RC6c: AME & coef by knowledge group (weighted probit) ===\n")
for(pr in c("party","ideo","egal_rev","mt","policy_rev")){
  by <- sapply(levels(V$g4), function(g0) ame_coef(V[V$g4==g0,], pr))
  cat(sprintf("%-10s  AME Lower=%.3f Highest=%.3f  AME H/L=%.2f | coef Lower=%.3f Highest=%.3f  coef H/L=%.2f\n",
      pr, by["ame","Lower"], by["ame","Highest"], by["ame","Highest"]/by["ame","Lower"],
      by["coef","Lower"], by["coef","Highest"], by["coef","Highest"]/by["coef","Lower"]))
}
