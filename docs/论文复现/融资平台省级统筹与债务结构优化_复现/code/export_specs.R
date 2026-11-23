Sys.setlocale("LC_CTYPE", ".UTF-8")
library(data.table)
library(haven)
library(jsonlite)
z <- readRDS("prepared.rds")
printed <- fread("printed.csv")
firm <- as.data.table(read_dta("firm.dta", col_select=tidyselect::all_of(c("id","year","Integ","上划year"))))
setnames(firm,"上划year","recorded")
h <- firm[, {
  dates <- unique(recorded[!is.na(recorded) & recorded>0 & recorded<2025])
  first <- if(any(Integ==1)) min(year[Integ==1]) else Inf
  .(g0=if(length(dates)==1 && all(Integ==as.integer(year>=dates))) dates[1] else first)
}, by=id]
write <- function(x,path){
  dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE)
  write_json(x,path,pretty=TRUE,auto_unbox=TRUE,null="null")
}
paper <- "cie121816"
screens <- list()
for (i in seq_along(z$queue)) {
  s <- z$queue[[i]]
  if(s$loc=="T3_B4") next
  d <- copy(z$samples[[i]])
  d[h,g0:=i.g0,on="id"]
  if(s$x!="Integ") d[,g0:=if(any(get(s$x)==1)) g0 else Inf,by=id]
  stopifnot(all(as.integer(d$year>=d$g0)==d[[s$x]]))
  key <- paste0(paper,"__",s$loc)
  dir.create("model_data",showWarnings=FALSE)
  saveRDS(d[,unique(c("id","year","g0",s$y,s$cc)),with=FALSE],paste0("model_data/",key,".rds"))
  r <- printed[spec_id==s$loc]
  table <- as.integer(substr(s$loc,2,2))
  col <- as.integer(sub(".*[^0-9]","",s$loc))
  panel <- if(table==3) substr(s$loc,4,4) else ""
  loc <- sprintf("表%s %s第(%s)列",table,if(nzchar(panel))paste0(panel,"部分 ")else "",col)
  screening <- list(spec_id=s$loc,location=loc,static_or_event="static",outcome=s$y,
                    treatment_definition=s$x,fixed_effects="平台、年份",clustering="平台",
                    controls=as.list(s$cc),coef=r$published_coef,se=r$published_se,n_obs=r$published_n)
  screens[[s$loc]] <- screening
  write(list(paper_id=paper,spec_id=s$loc,journal="cie",data_path=paste0("$CIE_RAW/model_data/",key,".rds"),
             id_var="id",time_var="year",y_var=s$y,gvar="g0",cluster_var="id",controls=as.list(s$cc),static_or_event="static",
             published_coef=r$published_coef,published_se=r$published_se,published_n=r$published_n,published_source=loc,
             table=as.character(table),panel=panel,column=as.character(col),preferred=s$loc=="T1_3",
             in_abstract_intro=table<3,reports_modern_estimator=TRUE,software="Stata",
             replication_status="exact",notes="作者回归有效样本。首治日期用平台政策字段核对，必要时以平台首次观测处理年推断。"),
        file.path("data",if(length(s$cc)) "specs_controls" else "specs",paste0(key,".json")))
}
write(list(paper_id=paper,journal="cie",year=2025,issue=12,title="约束与激励：融资平台省级统筹与债务结构优化",
           screened_from="article_text+package",screener="Codex",screen_date="2026-11-23",staggered_design=TRUE,
           eligible_design=TRUE,near_miss=FALSE,near_miss_controls_only=TRUE,main_or_robustness="main",
           policy_or_event="融资平台分期上划省级统筹",unit="lgfv",assignment_unit="lgfv",time_unit="year",
           reports_modern_estimator=TRUE,estimators_reported=as.list(c("twfe_static","twfe_event","sun_abraham","psm_did")),
           data_access="public",package_status="data_and_code",software="Stata",
           eligible_specs=unname(screens["T1_1"]),near_miss_controls_only_specs=unname(screens[setdiff(names(screens),"T1_1")]),
           pending_specs=list(list(spec_id="T3_B4",location="表3 B部分第(4)列",reason="债券样本与平台样本处理历史无法直接对应，另报债券样本首次可见处理年的敏感性估计")),
           appendix_specs=list(list(spec_id="F_A5",location="附图A5",pre_min=-6,post_max=3,ref=-1,ends="bin"),
             list(location="附图A7",estimator="Sun-Abraham"),list(location="附表A4–A11",scope="稳健性及匹配回归，独立于正文")),
           n_eligible_specs=1,priority=1),file.path("data","screening","by_paper",paste0(paper,".json")))
