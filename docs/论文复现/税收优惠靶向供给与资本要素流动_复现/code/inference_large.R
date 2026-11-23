# Score-based inference for the unmodified BJS point estimate.
infer_bjs <- function(d,xt,ctrl,ok,tw=NULL,event_bins=NULL){
  dd <- copy(d[ok])
  stage <- paste(ctrl_rhs(ctrl),"|",fe_terms(xt))
  first <- feols(as.formula(paste("y ~",stage)),dd[D==0],fixef.rm="none",notes=FALSE,warn=FALSE)
  residual <- dd$y-predict(first,newdata=dd)
  treated <- dd$D==1
  n_t <- sum(treated)
  if(is.null(event_bins)){
    target <- as.numeric(treated)
    center <- ifelse(treated,mean(residual[treated]),0)
  } else {
    bins <- dd[[event_bins]][treated]
    counts <- table(bins)
    target <- numeric(nrow(dd))
    target[treated] <- n_t/(length(counts)*as.numeric(counts[as.character(bins)]))
    center <- numeric(nrow(dd))
    center[treated] <- ave(residual[treated],bins,FUN=mean)
  }
  estimate <- sum(target*residual)/n_t
  dd[,target:=target]
  # The weighted projection with treated weight h converges to the untreated
  # normal-equation solution for the counterfactual mean as h tends to zero.
  influence <- function(h){
    dd[,pw:=ifelse(treated,h,1)]
    f <- feols(as.formula(paste("target ~",stage)),dd,weights=~pw,
               fixef.rm="none",fixef.tol=1e-11,fixef.iter=20000,notes=FALSE,warn=FALSE)
    ifelse(treated,target,-fitted(f)/h)/n_t
  }
  hi <- influence(1e-6)
  lo <- influence(1e-7)
  linear <-  (10*lo-hi)/9
  error <- abs(sum(linear*dd$y)-estimate)
  if(!is.finite(error)||error>1e-5||sum(abs(hi-lo))>0.002)
    stop(sprintf("BJS weight validation failed (outcome error %.3g, change in weights %.3g)",error,sum(abs(hi-lo))))
  scores <- data.table(cl=dd$cl,score=linear*(residual-center))
  b <- scores[,.(bjs=sum(score)),by=cl]
  if(is.null(tw)){
    lev <- leverage(linear,dd$cl)
    return(list(estimate=estimate,error=error,bjs_se=sqrt(sum(b$bjs^2)),
                G_eff_bjs=lev$G_eff,L_max_bjs=lev$L_max,scores=b))
  }
  t <- tw[,.(twfe=sum(score)),by=cl]
  t[b,bjs:=i.bjs,on="cl"]
  t[is.na(bjs),bjs:=0]
  lev <- leverage(linear,dd$cl)
  list(estimate=estimate,error=error,bjs_se=sqrt(sum(t$bjs^2)),G_eff_bjs=lev$G_eff,
       L_max_bjs=lev$L_max,scores=t)
}

# Compare changes for units observed in both g-1 and t. Restrict comparisons
# to origin-destination province cells containing treated and eligible controls.
paired_csa <- function(d,ctrl,event=FALSE){
  needed <- c("id","t","y","cl","g","xt_prov","xt_prov_son",ctrl)
  x <- copy(d[,..needed])
  x[,stratum:=.GRP,by=.(xt_prov,xt_prov_son)]
  x[,row:=.I]
  setkey(x,t)
  n <- nrow(x)
  used <- rep(FALSE,n)
  linear <- numeric(n)
  cell_results <- list()
  score_results <- list()
  all_n <- 0L
  for(g0 in sort(unique(x[is.finite(g),g]))){
    base <- x[J(g0-1),c("id","y","row",ctrl),with=FALSE]
    if(!nrow(base))next
    setnames(base,c("y","row"),c("y0","row0"))
    periods <- if(event) sort(unique(x[t!=g0-1,t])) else sort(unique(x[t>=g0,t]))
    for(tp in periods){
      post <- x[J(tp)][g==g0 | g>max(tp,g0-1),.(id,g,cl,stratum,y,row)]
      s <- post[base,on="id",nomatch=0L]
      if(!nrow(s))next
      s[,treat:=g==g0]
      available <- s[treat==TRUE,.N]
      all_n <- all_n+available
      s[, `:=`(nc=sum(!treat),nt=sum(treat)),by=stratum]
      s <- s[nc>0 & nt>0]
      if(!nrow(s))next
      nt <- sum(s$treat)
      s[,dy:=y-y0]
      s[,dif:=dy-mean(dy[!treat]),by=stratum]
      tr <- s$treat
      wt <- ifelse(tr,1,-s$nt/s$nc)/nt
      if(length(ctrl)){
        # Restore row order after the stratified centering.
        centered <- s[,c(list(ix=.I),lapply(.SD,function(u)u-mean(u[!treat]))),by=stratum,.SDcols=ctrl]
        setorder(centered,ix)
        v <- as.matrix(centered[,..ctrl])
        vc <- v[!tr,,drop=FALSE]
        fit <- lm.fit(vc,s$dif[!tr])
        active <- !is.na(fit$coefficients)
        if(any(active)){
          coef <- fit$coefficients[active]
          v <- v[,active,drop=FALSE]
          vc <- vc[,active,drop=FALSE]
          target <- colMeans(v[tr,,drop=FALSE])
          wt[!tr] <- wt[!tr]-drop(vc %*% qr.solve(crossprod(vc),target,tol=1e-12))
          s[,dif:=dif-drop(v%*%coef)]
        }
      }
      est <- mean(s$dif[tr])
      s[,score:=wt*(dif-ifelse(treat,est,0))]
      scores <- s[,.(value=sum(score),n_treat=sum(treat)),by=cl]
      scores[,value:=value*nt]
      stopifnot(abs(sum(wt*s$dy)-est)<1e-8)
      linear[s$row] <- linear[s$row]+wt*nt
      linear[s$row0] <- linear[s$row0]-wt*nt
      scores[,weighted_att:=n_treat*est]
      idx <- length(cell_results)+1L
      cell_results[[idx]] <- data.table(g=g0,t=tp,att=est,n_treated=nt,n_paired_treated=available,
                                        n_control=sum(!tr),strata=uniqueN(s$stratum))
      score_results[[idx]] <- scores
      used[c(s$row,s$row0)] <- TRUE
    }
  }
  c <- rbindlist(cell_results)
  if(!nrow(c))return(NULL)
  if(event){
    c[,bin:=pmax(-4,pmin(3,t-g))]
    per_period <- lapply(sort(unique(c$bin)),function(k){
      ix <- which(c$bin==k)
      total <- sum(c$n_treated[ix])
      est <- weighted.mean(c$att[ix],c$n_treated[ix])
      b <- rbindlist(score_results[ix])[,.(score=sum(value+weighted_att-n_treat*est)/total),by=cl]
      list(point=data.table(bin=k,estimate=est,se=sqrt(sum(b$score^2)),matched=total),score=b)
    })
    point <- rbindlist(lapply(per_period,`[[`,"point"))
    avg <- rbindlist(lapply(c("pre","post"),function(k){
      ix <- if(k=="pre")which(point$bin<0)else which(point$bin>=0)
      if(!length(ix))return(NULL)
      b <- rbindlist(lapply(per_period[ix],`[[`,"score"))[,.(score=sum(score)/length(ix)),by=cl]
      data.table(window=k,estimate=mean(point$estimate[ix]),se=sqrt(sum(b$score^2)),bins_used=length(ix))
    }))
    return(list(point=point,average=avg))
  }
  total <- sum(c$n_treated)
  est <- weighted.mean(c$att,c$n_treated)
  b <- rbindlist(score_results)[,.(csa=sum(value+weighted_att-n_treat*est)/total),by=cl]
  linear <- linear/total
  stopifnot(abs(sum(linear*d$y)-est)<1e-8,abs(sum(b$csa))<1e-8)
  lev <- leverage(linear,d$cl)
  list(est=est,se=sqrt(sum(b$csa^2)),n=total,n_available=all_n,cells=c,scores=b,used=used,lev=lev)
}
joint_multiplier <- function(m,B=999){
  set.seed(20261123)
  scores <- as.matrix(m[,setdiff(names(m),"cl"),with=FALSE])
  draws <- t(vapply(seq_len(B),function(i)drop(crossprod(rnorm(nrow(scores)),scores)),numeric(ncol(scores))))
  colnames(draws) <- colnames(scores)
  cov(draws)
}




