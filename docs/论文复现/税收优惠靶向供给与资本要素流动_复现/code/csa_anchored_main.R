library(haven)
library(data.table)
source("estimators.R")
source("csa_rank.R")
setFixest_nthreads(3)
types <- c(3,1)
v <- c("idcitycp","citycp","prov","prov_son","year","ydcom_add1","ntreat","did3","did1","treat3","treat1")
full <- as.data.table(read_dta("data1.dta", col_select=tidyselect::all_of(v)))
for(i in seq_along(types)){
  k <- types[i]
  spec_id <- c("T1_1","T2_1")[i]
  x <- paste0("did",k)
  where <- paste0("treat",k)
  d <- full[get(where)==1|ntreat==1]
  h <- d[,.(g0=if(any(get(x)==1)) min(year[get(x)==1]) else Inf),by=citycp]
  anchor <- fread(paste0("event_dates_by_citypair_",k,".csv"))[compatible==TRUE]
  h[anchor,g0:=i.g_event,on="citycp"]
  d[h,g0:=i.g0,on="citycp"]
  stopifnot(all(d[[x]]==as.integer(d$year>=d$g0)),!anyDuplicated(d,by=c("idcitycp","year")))
  q <- prep_data(d,list(id_var="idcitycp",time_var="year",y_var="ydcom_add1",gvar="g0",
                      cluster_var="citycp",xt_vars=c("prov","prov_son")))
  rm(d,h)
  gc()
  a <- q$d
  ysd <- standardize_y(a)
  r <- did_ids(a)
  for(method in c("reg","rank")){
    tryCatch({
      set.seed(20261109)
      at <- did::att_gt(yname="y",tname="t",idname="id_num",gname="g0",data=as.data.frame(r),
        xformla=~factor(xt_prov)+factor(xt_prov_son),panel=TRUE,allow_unbalanced_panel=TRUE,
        control_group="notyettreated",clustervars=c("id_num","cl_num"),
        est_method=if(method=="reg") "reg" else support_reg_did,
        bstrap=TRUE,biters=999,cband=FALSE)
      cells <- data.table(g=at$group,t=at$t,att=at$att,se=at$se)
      cells[, `:=`(g=q$periods[g],t=q$periods[t])]
      fwrite(cells,paste0("output/anchored_",method,"_",spec_id,"_cells.csv"))
      ag <- did::aggte(at,type="simple",na.rm=TRUE,bstrap=TRUE,biters=999,cband=FALSE)
      fwrite(data.table(spec_id,csa=ag$overall.att,csa_se=ag$overall.se,
              post_cells=sum(cells$t>=cells$g),supported=sum(cells$t>=cells$g&is.finite(cells$att))),
            paste0("output/anchored_",method,"_",spec_id,".csv"))
      cat("FINISHED",spec_id,method,ag$overall.att,ag$overall.se,"\n")
    },error=function(e)cat("ERROR",spec_id,method,conditionMessage(e),"\n"))
    flush.console()
    gc()
  }
}
