## Independent recompute of GSS ideology x party correlation by WORDSUM group.
## Does NOT reuse pipeline functions; reads raw CSV directly.
raw <- read.csv("data/raw/gss_subset.csv", stringsAsFactors=FALSE,
                strip.white=TRUE, colClasses="character")
num <- function(x){ x<-trimws(x); x[grepl("^\\.",x)]<-NA; suppressWarnings(as.numeric(x)) }

pv <- num(raw$polviews)     # 1..7
pid<- num(raw$partyid)      # 0..7 (7=other)
ws <- num(raw$wordsum)      # 0..10
yr <- num(raw$year)

# constructs, direction-aligned (both high = conservative/Republican)
ideo  <- ifelse(pv %in% 1:7, (pv-4)/3, NA)   # NOTE: independent = DK dropped (raw ".d" not folded)
party <- ifelse(pid %in% 0:6, (pid-3)/3, NA)

# WORDSUM 5 fixed bins (same cutpoints as pipeline)
grp <- cut(ws, breaks=c(-1,3,4,6,8,10), labels=c("Lowest","Low","Middle","High","Highest"))

sel <- yr>=1984 & !is.na(grp) & !is.na(ideo) & !is.na(party)
cat("=== GSS: cor(ideo, party) by WORDSUM group, year>=1984, DK-as-NA (independent) ===\n")
full <- cor(ideo[sel], party[sel])
cat(sprintf("Full N=%d  r=%.3f  |r|=%.3f\n", sum(sel), full, abs(full)))
for(g in levels(grp)){
  s <- sel & grp==g
  r <- cor(ideo[s], party[s])
  cat(sprintf("  %-8s N=%5d  r=%.3f\n", g, sum(s), r))
}

# Also replicate pipeline coding exactly: DK(.d) POLVIEWS -> 0 (folded), for comparison
pv_raw <- trimws(raw$polviews)
ideo_dk0 <- ifelse(pv %in% 1:7, (pv-4)/3, ifelse(pv_raw==".d", 0, NA))
cat("\n=== Pipeline coding: POLVIEWS DK(.d)->0 folded (matches R/05_gss.R) ===\n")
sel2 <- yr>=1984 & !is.na(grp) & !is.na(ideo_dk0) & !is.na(party)
cat(sprintf("Full N=%d  |r|=%.3f\n", sum(sel2), abs(cor(ideo_dk0[sel2], party[sel2]))))
for(g in levels(grp)){
  s <- sel2 & grp==g
  cat(sprintf("  %-8s N=%5d  |r|=%.3f\n", g, sum(s), abs(cor(ideo_dk0[s], party[s]))))
}

# Year span & pooling
cat("\n=== Pooling: which years contribute (DK->0 coding) ===\n")
yrs <- sort(unique(yr[sel2]))
cat("N years:", length(yrs), " range:", min(yrs),"-",max(yrs),"\n")
print(table(yr[sel2]))
