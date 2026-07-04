# Independent verification of Table 3 panel stability (V3)
# Does NOT source R/04_panels.R functions. Coding re-derived by hand.
ni <- function(x) as.numeric(unclass(x))   # haven_labelled-safe

# ideology: 1-7 scale -> (x-4)/3 ; HTMA(0)+moderate(4)+DK(8) -> 0 ; NA(9)/other -> NA
ideo_code <- function(x, dk = 8, htma = 0, na = 9) {
  ifelse(x %in% c(htma, 4, dk), 0,
    ifelse(x %in% 1:7, (x - 4)/3, NA_real_))
}
# party: 0-6 -> (x-3)/3 ; 7/8/9 -> NA
party_code <- function(x) ifelse(x %in% 0:6, (x - 3)/3, NA_real_)
know_group <- function(k){ k[!k %in% 1:5] <- NA
  cut(k, breaks=c(0,1,2,3,5), labels=c("Highest","High","Middle","Lowest")) }
sq_r <- function(a,b,sel){ ok <- sel & !is.na(a) & !is.na(b)
  if(sum(ok)<5) return(c(r2=NA,n=sum(ok)))
  c(r2=cor(a[ok],b[ok])^2, n=sum(ok)) }

load("data/raw/timeseries_1992.rda"); d92 <- timeseries_1992
load("data/raw/timeseries_1996.rda"); d96 <- timeseries_1996
load("data/raw/timeseries_2000.rda"); d00 <- timeseries_2000
load("data/raw/timeseries_2002.rda"); d02 <- timeseries_2002

cat("=================== 1990-92 ===================\n")
g <- function(v) ni(d92[[v]])
panel9092 <- g("V923005") == 1
cat("panel N (V923005==1):", sum(panel9092), "\n")
grp <- know_group(g("V924205"))
ideo90 <- ideo_code(g("V900406")); ideo92 <- ideo_code(g("V923509"))
party90 <- party_code(g("V900320")); party92 <- party_code(g("V923634"))
cat("Ideology r2 full:", round(sq_r(ideo90,ideo92,panel9092),4), " (target .29)\n")
cat("Party    r2 full:", round(sq_r(party90,party92,panel9092),4), " (target .61)\n")

cat("\n=================== 1992-96 MERGE ===================\n")
g6 <- function(v) ni(d96[[v]])
link <- g6("V960009")
cat("V960009 label:", attr(d96[["V960009"]],"label"), "\n")
cat("V960005 label:", attr(d96[["V960005"]],"label"), "(decisions_log D3 named this)\n")
key92 <- g("V923004")
cat("dup keys in V923004:", sum(duplicated(key92)), "\n")
midx <- match(link, key92); midx[link <= 0] <- NA
panel9296 <- !is.na(midx)
cat("matched N:", sum(panel9296), " / link>0:", sum(link>0,na.rm=TRUE), "\n")
cat("any many-to-one collision (dup midx among matched):", sum(duplicated(midx[panel9296])), "\n")
g2 <- function(v) ni(d92[[v]])[midx]
grp96 <- know_group(g2("V924205"))
ideo92b <- ideo_code(g2("V923509")); ideo96 <- ideo_code(g6("V960365"))
party92b <- party_code(g2("V923634")); party96 <- party_code(g6("V960420"))
cat("Ideology r2 full:", round(sq_r(ideo92b,ideo96,panel9296),4), " (target .37)\n")
cat("Party    r2 full:", round(sq_r(party92b,party96,panel9296),4), " (target .59)\n")
# one knowledge cell for ideology: Highest
for (gg in c("Highest","High","Middle","Lowest"))
  cat("  Ideology", gg, ":", round(sq_r(ideo92b,ideo96,panel9296 & !is.na(grp96) & grp96==gg),4),
      " target", c(Highest=.71,High=.48,Middle=.26,Lowest=.03)[gg], "\n")

cat("\n=================== 2000-02 IDEOLOGY N ===================\n")
g02 <- function(v) ni(d02[[v]])
link02 <- g02("V020002")
midx0 <- match(link02, ni(d00$V000001))
panel0002 <- !is.na(midx0) & g02("V021001")==1
cat("panel N:", sum(panel0002), "\n")
g0 <- function(v) ni(d00[[v]])[midx0]
x439 <- g0("V000439"); x439a <- g0("V000439a")
cat("V000439 label:", attr(d00[["V000439"]],"label"), "\n")
cat("V000439a label:", attr(d00[["V000439a"]],"label"), "\n")
cat("non-missing V000439 (<9) in panel:", sum(!is.na(x439) & x439<9 & panel0002), "\n")
cat("non-missing V000439a (<9) in panel:", sum(!is.na(x439a) & x439a<9 & panel0002), "\n")
raw00 <- ifelse(!is.na(x439)&x439<9, x439, ifelse(!is.na(x439a)&x439a<9, x439a, NA))
ideo00 <- ideo_code(raw00)
ideo02 <- ideo_code(g02("V023022"), htma=90, dk=8, na=99)
# 2002 var codes:
cat("V023022 codes:\n"); print(table(g02("V023022")[panel0002], useNA="ifany"))
cat("Ideology r2 full:", round(sq_r(ideo00,ideo02,panel0002),4), " target .38, N target 564\n")
party00 <- party_code(g0("V000523")); party02 <- party_code(g02("V023038x"))
cat("Party r2 full:", round(sq_r(party00,party02,panel0002),4), " target .71, N target 1165\n")

cat("\n=================== PROBE: failing constructs (bug vs irreproducible) ===================\n")
cpv <- function(x, pro){ y <- ifelse(x %in% 1:5, x, NA_real_); if(pro) y <- 6-y; (y-3)/2 }
imean <- function(mat, complete=FALSE){ if(complete) ifelse(rowSums(is.na(mat))==0, rowMeans(mat), NA_real_)
  else { o <- rowMeans(mat, na.rm=TRUE); o[is.nan(o)] <- NA_real_; o } }
# 1992-96 egalitarianism, independent (polarities per report table)
eg92 <- imean(cbind(cpv(g2("V926024"),TRUE), cpv(g2("V926025"),FALSE), cpv(g2("V926026"),FALSE),
                    cpv(g2("V926027"),FALSE), cpv(g2("V926028"),TRUE), cpv(g2("V926029"),TRUE)))
eg96 <- imean(cbind(cpv(g6("V961229"),TRUE), cpv(g6("V961230"),FALSE), cpv(g6("V961231"),TRUE),
                    cpv(g6("V961232"),FALSE), cpv(g6("V961233"),FALSE), cpv(g6("V961234"),TRUE)))
cat("Egal 1992-96 Full r2:", round(sq_r(eg92,eg96,panel9296),4), " (script rds=.348, paper=.31)\n")
# 2000-02 policy, independent
sp00 <- function(v){ x<-g0(v); ifelse(x==1,1,ifelse(x==5,1/3,ifelse(x==3,-1/3,ifelse(x==7,-1,ifelse(x==8,0,NA_real_))))) }
sp02 <- function(v){ x<-g02(v); ifelse(x==1,1,ifelse(x==3,1/3,ifelse(x==2,-1/3,ifelse(x==4,-1,ifelse(x==8,0,NA_real_))))) }
v00 <- c("V000675","V000676","V000677","V000678","V000681","V000682","V000684","V000685","V000687")
v02 <- c("V025104x","V025107x","V025106x","V025116x","V025117x","V025113x","V025109x","V025110x","V025119x")
p00 <- imean(sapply(v00,sp00), complete=TRUE); p02 <- imean(sapply(v02,sp02), complete=TRUE)
cat("Policy 2000-02 Full r2:", round(sq_r(p00,p02,panel0002),4), " (script rds=.395, paper=.27)\n")
