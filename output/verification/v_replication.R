## v_replication.R -- INDEPENDENT recompute of V1 headline claims.
## Deliberately re-derives all coding by hand; does NOT source R/06 functions.
suppressMessages({library(dplyr)})
num <- function(x) suppressWarnings(as.numeric(if(inherits(x,"haven_labelled")) unclass(x) else x))
cat2 <- function(...) cat(..., "\n")

cdf <- read.csv("data/raw/anes_cdf_1948_2024_subset.csv", stringsAsFactors = FALSE)
cdf[cdf == " "] <- NA; cdf[cdf == ""] <- NA

## ---- hand-rolled coders ----
code_ideo  <- function(io){ io<-num(io); ifelse(io %in% 1:7, (io-4)/3, ifelse(io==9, 0, NA)) }
code_party <- function(pa){ pa<-num(pa); ifelse(pa %in% 1:7, (pa-4)/3, NA) }
code_vote  <- function(vt){ vt<-num(vt); ifelse(vt==2, 1L, ifelse(vt==1, 0L, NA)) }
sc5v <- function(x, dir){ x<-num(x); x[!x %in% 1:5]<-NA; s<-(3-x)/2; if(dir<0) -s else s }
pol7v<- function(x, dir){ x<-num(x); s<-ifelse(x %in% 1:7,(x-4)/3, ifelse(x==9,0,NA)); if(dir<0) -s else s }
rmean<- function(M){ m<-rowMeans(M,na.rm=TRUE); m[is.nan(m)]<-NA; m }

build <- function(s){
  data.frame(
    caseid = num(s$VCF0006), year=num(s$VCF0004),
    ideo = code_ideo(s$VCF0803), ideo_raw = num(s$VCF0803),
    party = code_party(s$VCF0301),
    repvote = code_vote(s$VCF0704),
    egal = rmean(cbind(sc5v(s$VCF9013,1),sc5v(s$VCF9018,1),sc5v(s$VCF9016,-1),sc5v(s$VCF9017,-1))),
    mt   = rmean(cbind(sc5v(s$VCF0853,1),sc5v(s$VCF0852,-1))),
    policy = rmean(cbind(pol7v(s$VCF0843,-1),pol7v(s$VCF0809,-1),pol7v(s$VCF0830,-1),pol7v(s$VCF0806,-1),pol7v(s$VCF0839,1)))
  )
}
c20 <- build(cdf[num(cdf$VCF0004)==2020,])
c24 <- build(cdf[num(cdf$VCF0004)==2024,])
cat2("N 2020 rows:", nrow(c20), " N 2024 rows:", nrow(c24))

## ===== VOTE two-party split sanity (VCF0704) =====
cat2("\n== VCF0704 raw table 2020 =="); print(table(num(cdf$VCF0704[num(cdf$VCF0004)==2020]), useNA="ifany"))
cat2("== VCF0704 raw table 2024 =="); print(table(num(cdf$VCF0704[num(cdf$VCF0004)==2024]), useNA="ifany"))
cat2("Rep share 2020:", round(mean(c20$repvote,na.rm=TRUE),3), " 2024:", round(mean(c24$repvote,na.rm=TRUE),3))

## ===== KNOWLEDGE index (independent) =====
load("data/raw/timeseries_2020.rda"); t20<-timeseries_2020; g<-function(v) num(t20[[v]])
## verify answer distributions
cat2("\n== 2020 quiz raw distributions ==")
for(v in c("V201644","V201645","V201646","V201647")){ cat2(v,":"); print(table(g(v))[1:8]) }
adm20 <- function(v){ x<-g(v); !(x %in% c(-6,-7)) }
corr20 <- cbind(g("V201644")==6, g("V201645")==1, g("V201646")==1, g("V201647")==2)
a20 <- cbind(adm20("V201644"),adm20("V201645"),adm20("V201646"),adm20("V201647"))
nc <- rowSums(corr20 & a20, na.rm=TRUE); nd <- rowSums(a20, na.rm=TRUE)
know20 <- data.frame(caseid=g("V200001"), k=ifelse(nd>0, nc/nd, NA),
                     wt_post=g("V200010b"), wt_pre=g("V200010a"))
cat2("2020 knowledge shares (0/.25/.5/.75/1):", round(100*prop.table(table(factor(know20$k,levels=c(0,.25,.5,.75,1)))),1))
cat2("mean 2020:", round(mean(know20$k,na.rm=TRUE),3))

k24 <- read.csv("data/raw/anes2024_knowledge.csv", stringsAsFactors=FALSE); h<-function(v) num(k24[[v]])
cat2("\n== 2024 quiz raw distributions ==")
for(v in c("V241612","V241613","V241614","V241615")){ cat2(v,":"); print(table(h(v))[1:8]) }
adm24<-function(v){x<-h(v); !(x %in% c(-6,-7))}
corr24 <- cbind(h("V241612")==6, h("V241613")==1, h("V241614")==2, h("V241615")==1)
a24 <- cbind(adm24("V241612"),adm24("V241613"),adm24("V241614"),adm24("V241615"))
nc4<-rowSums(corr24 & a24,na.rm=TRUE); nd4<-rowSums(a24,na.rm=TRUE)
know24 <- data.frame(caseid=h("V240001"), k=ifelse(nd4>0,nc4/nd4,NA), wt_post=h("V240107b"), wt_pre=h("V240107a"))
cat2("2024 knowledge shares:", round(100*prop.table(table(factor(know24$k,levels=c(0,.25,.5,.75,1)))),1))
cat2("mean 2024:", round(mean(know24$k,na.rm=TRUE),3))

## group factors
grp5 <- function(k) factor(c("0"="Lowest","0.25"="Low","0.5"="Middle","0.75"="High","1"="Highest")[as.character(k)],
                           levels=c("Lowest","Low","Middle","High","Highest"))
grp4 <- function(k) factor(ifelse(k<=0.25,"Lower",c("0.5"="Middle","0.75"="High","1"="Highest")[as.character(k)]),
                           levels=c("Lower","Middle","High","Highest"))
know20$g5<-grp5(know20$k); know20$g4<-grp4(know20$k)
know24$g5<-grp5(know24$k); know24$g4<-grp4(know24$k)

## merge onto constructs
m20 <- merge(c20, know20, by="caseid", all.x=TRUE)
m24 <- merge(c24, know24, by="caseid", all.x=TRUE)

## ===== VOTE PROBIT by group (independent) =====
probit_r2 <- function(dat, predname, wname){
  d <- dat[!is.na(dat[[predname]]) & !is.na(dat$repvote) & !is.na(dat[[wname]]),]
  if(nrow(d)<30 || length(unique(d$repvote))<2) return(c(r2=NA,N=nrow(d)))
  m  <- suppressWarnings(glm(repvote~d[[predname]], data=d, family=binomial("probit"), weights=d[[wname]]))
  m0 <- suppressWarnings(glm(repvote~1, data=d, family=binomial("probit"), weights=d[[wname]]))
  c(r2=1-as.numeric(logLik(m)/logLik(m0)), N=nrow(d))
}
## predictors aligned to Rep vote: -egal, mt, -policy, ideo, party
mkpred <- function(df){ df$p_egal<--df$egal; df$p_mt<-df$mt; df$p_policy<--df$policy; df$p_ideo<-df$ideo; df$p_party<-df$party; df }
m20<-mkpred(m20); m24<-mkpred(m24)
preds <- c(Egal="p_egal", MoralTrad="p_mt", Policy="p_policy", Ideo="p_ideo", Party="p_party")

vote_table <- function(df, yr){
  base <- df[!is.na(df$g4),]
  cat2("\n===== VOTE pseudo-R2", yr, "(weight wt_post) =====")
  cat2(sprintf("%-10s %6s %6s %6s %6s %6s | %8s %8s %8s","pred","Full","Lower","Middle","High","Highest","Hi/Lo","Full/Lo","N.Lo"))
  for(nm in names(preds)){
    pv<-preds[[nm]]
    full<-probit_r2(base,pv,"wt_post")
    gr<-sapply(levels(base$g4), function(gl) probit_r2(base[base$g4==gl,],pv,"wt_post"))
    r2<-c(Full=full["r2"], gr["r2",])
    cat2(sprintf("%-10s %6.3f %6.3f %6.3f %6.3f %6.3f | %8.2f %8.2f %8.0f",
      nm, full["r2"], gr["r2","Lower"], gr["r2","Middle"], gr["r2","High"], gr["r2","Highest"],
      gr["r2","Highest"]/gr["r2","Lower"], full["r2"]/gr["r2","Lower"], gr["N","Lower"]))
  }
}
vote_table(m20,2020); vote_table(m24,2024)

## ===== CORRELATIONS ideology x party by group (independent, WITH SIGN) =====
cor_by_grp <- function(df, a, b, yr){
  x<-df[!is.na(df[[a]])&!is.na(df[[b]])&!is.na(df$g5),]
  cat2(sprintf("\n== cor %s x %s %s (signed) ==", a,b,yr))
  full<-cor(x[[a]],x[[b]])
  gr<-sapply(levels(x$g5), function(gl){ s<-x[x$g5==gl,]; if(nrow(s)>2) cor(s[[a]],s[[b]]) else NA})
  cat2(sprintf("Full=%.3f | Lowest=%.3f Low=%.3f Middle=%.3f High=%.3f Highest=%.3f",
    full, gr["Lowest"],gr["Low"],gr["Middle"],gr["High"],gr["Highest"]))
}
cor_by_grp(m20,"ideo","party",2020); cor_by_grp(m24,"ideo","party",2024)

## avg correlation per construct (full sample), to check ".39->.64"
avgcorr <- function(df){
  cons<-c("egal","mt","policy","ideo","party")
  M<-df[,cons]; C<-cor(M, use="pairwise.complete.obs")
  diag(C)<-NA; abs_off<-abs(C)
  round(rowMeans(abs_off, na.rm=TRUE),3)
}
cat2("\n== avg |corr| per construct 2020 =="); print(avgcorr(m20))
cat2("== avg |corr| per construct 2024 =="); print(avgcorr(m24))

## ===== PANEL JOIN diagnostics + stability =====
panel <- read.csv("data/raw/anes2024_panel_link.csv", stringsAsFactors=FALSE)
cat2("\n== panel file: nrow", nrow(panel), " cols:", paste(head(names(panel),8),collapse=","))
panel <- panel[num(panel$V200001)>0,]
id20<-num(panel$V200001); id24<-num(panel$V240001)
cat2("panel cases (V200001>0):", nrow(panel))
cat2("VCF0006 unique within 2020?", !any(duplicated(c20$caseid)), " within 2024?", !any(duplicated(c24$caseid)))
cat2("match rate id2020->c20:", round(mean(id20 %in% c20$caseid),3), " id2024->c24:", round(mean(id24 %in% c24$caseid),3))
ia<-match(id20,c20$caseid); ib<-match(id24,c24$caseid)
cat2("n matched both waves:", sum(!is.na(ia)&!is.na(ib)))

stab <- function(v){ A<-c20[[v]][ia]; B<-c24[[v]][ib]; ok<-!is.na(A)&!is.na(B); c(r2=cor(A[ok],B[ok])^2, n=sum(ok)) }
cat2("\n== stability 2020->2024 (full, independent) ==")
for(v in c("egal","mt","policy","ideo","party")){ s<-stab(v); cat2(sprintf("%-8s r2=%.3f N=%d", v, s["r2"], s["n"])) }
## ideology stability by 2020 knowledge group (merged lower)
grp<-know20$g4[match(id20, know20$caseid)]
cat2("\n== ideology stability by 2020 knowledge group ==")
for(gl in levels(grp)){ sel<-!is.na(grp)&grp==gl; A<-c20$ideo[ia][sel]; B<-c24$ideo[ib][sel]; ok<-!is.na(A)&!is.na(B)
  cat2(sprintf("%-8s r2=%.3f N=%d", gl, cor(A[ok],B[ok])^2, sum(ok))) }
cat2("panel group shares:", round(100*prop.table(table(grp)),1))

## weights sanity
cat2("\n== weights sanity ==")
cat2("2020 wt_post: NA frac", round(mean(is.na(know20$wt_post)),3), " sd", round(sd(know20$wt_post,na.rm=TRUE),3))
cat2("2024 wt_post: NA frac", round(mean(is.na(know24$wt_post)),3), " sd", round(sd(know24$wt_post,na.rm=TRUE),3))
cat2("\n===== DONE =====")
