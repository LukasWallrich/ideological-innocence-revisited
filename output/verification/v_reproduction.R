## v_reproduction.R -- INDEPENDENT recompute of V2 spot-checks from raw CDF.
## Does NOT use cdf_analysis.rds or R/02 functions; rebuilds from timeseries_cum.rda.
suppressMessages({library(psych)})
load("data/raw/timeseries_cum.rda"); d <- timeseries_cum
nz <- function(v) suppressWarnings(as.numeric(d[[v]]))

yr <- nz("VCF0004"); mode <- nz("VCF0017"); keep <- mode %in% 0:3 & yr >= 1984
wtx <- as.numeric(d$VCF0009x)

## knowledge: pre-preferred combined, mapped 0/.25/.5/.75/1 (high=informed)
recK <- function(r){ r[!r %in% 1:5]<-NA; (5-r)/4 }
kpre<-recK(nz("VCF0050a")); kpost<-recK(nz("VCF0050b")); know<-ifelse(!is.na(kpre),kpre,kpost)

## constructs
io<-nz("VCF0803"); ideo<-ifelse(io %in% 1:7,(io-4)/3, ifelse(io==9,0,NA))
pa<-nz("VCF0301"); party<-ifelse(pa %in% 1:7,(pa-4)/3,NA)
sc5<-function(v,dir){x<-nz(v); x[!x %in% 1:5]<-NA; s<-(3-x)/2; if(dir<0) -s else s}
egM<-cbind(sc5("VCF9013",1),sc5("VCF9015",1),sc5("VCF9018",1),sc5("VCF9014",-1),sc5("VCF9016",-1),sc5("VCF9017",-1))
nanmean<-function(M){m<-rowMeans(M,na.rm=TRUE);m[is.nan(m)]<-NA;m}
egal<-nanmean(egM)
polar<-function(s) as.integer(abs(s)>=0.5)

## ---- Table 1 partisanship FULL (weighted, target repro 62 / paper 61) ----
party_yrs <- yr %in% c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2002,2004,2008,2012,2016)
sel <- keep & party_yrs & !is.na(party) & !is.na(know)
p_full <- 100*weighted.mean(polar(party[sel]), wtx[sel])
cat(sprintf("Table1 partisanship FULL (weighted): %.1f  [target repro 62 / paper 61]  N=%d\n", p_full, sum(sel)))
## group shares check
klab<-c("0"="Lowest","0.25"="Low","0.5"="Middle","0.75"="High","1"="Highest")
g<-factor(klab[as.character(know[sel])],levels=c("Lowest","Low","Middle","High","Highest"))
cat("  knowledge group shares (unweighted):", round(100*prop.table(table(g)),1),"\n")

## ---- Table 2 egalitarianism alpha FULL (unweighted 6 items, target .68/.67) ----
egal_yrs <- yr %in% c(1984,1986,1988,1990,1992,1994,1996,1998,2000,2004,2008,2012,2016)
esel <- keep & egal_yrs & !is.na(know) & rowSums(!is.na(egM))>0
a_full <- suppressWarnings(psych::alpha(egM[esel,], warnings=FALSE, check.keys=FALSE)$total$raw_alpha)
C<-cov(egM[esel,],use="pairwise.complete.obs"); cov_full<-mean(C[lower.tri(C)])
cat(sprintf("Table2 egal alpha FULL: %.3f  [target .68]   cov FULL: %.3f [target .10]  N=%d\n", a_full, cov_full, sum(esel)))

## ---- Table 4 ideology x party FULL (unweighted abs cor, target .44) ----
csel <- keep & !is.na(ideo) & !is.na(party) & !is.na(know)
r_ip <- abs(cor(ideo[csel], party[csel]))
cat(sprintf("Table4 ideology x party FULL (unweighted): %.3f  [target .44]  N=%d\n", r_ip, sum(csel)))
## by-group lowest and highest (target .06 / .68)
gg<-factor(klab[as.character(know[csel])],levels=c("Lowest","Low","Middle","High","Highest"))
il<-csel; ideoc<-ideo[csel]; partyc<-party[csel]
for(gl in c("Lowest","Highest")){ s<-gg==gl; cat(sprintf("   IdeoxParty %s: %.3f\n", gl, abs(cor(ideoc[s],partyc[s])))) }

## ---- construct Ns (D6 transposition check) ----
ideo_yrs <- party_yrs
nid <- sum(keep & ideo_yrs & !is.na(ideo))
npa <- sum(keep & party_yrs & !is.na(party))
cat(sprintf("\nD6 check -- Ideology N=%d (paper 25,332), Party N=%d (paper 24,307)\n", nid, npa))
cat("  party has near-zero item nonresponse; ideology loses HTMA-adjacent? Actually HTMA->0 kept.\n")
cat("===== DONE =====\n")
