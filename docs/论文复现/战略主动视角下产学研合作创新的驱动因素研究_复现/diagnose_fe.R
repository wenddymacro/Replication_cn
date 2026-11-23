library(haven)
library(data.table)
library(fixest)
d <- as.data.table(read_dta("input.dta"))
d[, geo_ind := interaction(province,ind,drop=TRUE)]
f <- feols(rinsitinum ~ tshock3 + Size:year + BM:year + ROA + TobinQ + Growth + AssetGrowth | year+geo_ind+stkcd, d, vcov=~stkcd, notes=FALSE)
x <- d[obs(f)]
m <- x[,uniqueN(geo_ind),by=stkcd][V1>1,stkcd]
a <- x[stkcd==m[1],geo_ind[1]]
x[, dummy := as.integer(geo_ind==a)]
projection <- feols(dummy ~ 1 | stkcd+year,x,notes=FALSE)
cat("One province-industry dummy residual max abs:",max(abs(resid(projection))),"\n")
cat("Province-industry-year cells with both treated and untreated firms:",x[,uniqueN(tshock3),by=.(geo_ind,year)][V1>1,.N],"\n")
cat("Firms with changing province-industry:",length(m),"\n")
