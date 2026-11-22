library(data.table)
library(haven)
d <- as.data.table(read_dta("data_city_after.dta"))
d <- d[!province %in% c(31,11,12,50) & between(year,2003,2018)]
vars <- c("D","debtnew_h_l","debtold_h_l","bondnew_h_l","bondold_h_l","feibiaonew_h_l","feibiaoold_h_l","bankloan_h_z","fiscalgap_ratio","fiscal_GDP","GDPg","lninvest","lnpop","workyear")
r <- rbindlist(lapply(vars,function(v){x<-na.omit(d[[v]]);data.table(outcome=v,n=length(x),mean=mean(x),sd=sd(x),min=min(x),max=max(x))}))
fwrite(r,"output/table1.csv")
