# Group-time outcome regression with a rank check on the treated covariate contrast.
weighted_regression <- function(x,y,w,target){
  scale <- sqrt(colSums(w*x^2)/sum(w))
  scale[scale < 1e-10] <- 1
  x <- sweep(x,2,scale,"/")
  target <- target/scale
  gram <- crossprod(x,w*x)
  eig <- eigen(gram,symmetric=TRUE)
  keep <- eig$values>1e-10*max(eig$values)
  span <- eig$vectors[,keep,drop=FALSE]
  coords <- drop(crossprod(span,target))
  missing <- max(abs(target-drop(span%*%coords)))
  if(missing>1e-6)return(NULL)
  slope <- function(z)drop(span %*% (crossprod(span,z)/eig$values[keep]))
  beta <- slope(crossprod(x,w*y))
  m <- sum(target*beta)
  score <- w*(y-drop(x%*%beta))*drop(x%*%slope(target))
  list(mean=m,beta=beta/scale,score=score)
}
support_reg_did <- function(D,covariates,i.weights,inffunc=TRUE,y=NULL,post=NULL,y1=NULL,y0=NULL,...){
  n <- length(D)
  x <- as.matrix(covariates)
  w <- i.weights
  tr <- D==1
  ctr <- !tr
  target <- colSums(w[tr]*x[tr,,drop=FALSE])/sum(w[tr])
  empty <- list(ATT=NA_real_,att.inf.func=if(inffunc)rep(NA_real_,n)else NULL)
  infl <- numeric(n)
  if(is.null(y)){
    delta <- y1-y0
    reg <- weighted_regression(x[ctr,,drop=FALSE],delta[ctr],w[ctr],target)
    if(is.null(reg))return(empty)
    err <- delta[tr]-drop(x[tr,,drop=FALSE]%*%reg$beta)
    att <- weighted.mean(err,w[tr])
    infl[tr] <- w[tr]*(err-att)/sum(w[tr])
    infl[ctr] <- -reg$score
  } else {
    before <- post==0
    after <- post==1
    reg0 <- weighted_regression(x[ctr&before,,drop=FALSE],y[ctr&before],w[ctr&before],target)
    reg1 <- weighted_regression(x[ctr&after,,drop=FALSE],y[ctr&after],w[ctr&after],target)
    if(is.null(reg0)||is.null(reg1))return(empty)
    yt0 <- weighted.mean(y[tr&before],w[tr&before])
    yt1 <- weighted.mean(y[tr&after],w[tr&after])
    contrast <- drop(x[tr,,drop=FALSE]%*%(reg1$beta-reg0$beta))
    att <- yt1-yt0-(reg1$mean-reg0$mean)
    infl[ctr&before] <- reg0$score
    infl[ctr&after] <- -reg1$score
    infl[tr] <- -w[tr]*(contrast-(reg1$mean-reg0$mean))/sum(w[tr])
    infl[tr&before] <- infl[tr&before]-w[tr&before]*(y[tr&before]-yt0)/sum(w[tr&before])
    infl[tr&after] <- infl[tr&after]+w[tr&after]*(y[tr&after]-yt1)/sum(w[tr&after])
  }
  list(ATT=att,att.inf.func=if(inffunc)n*infl else NULL)
}
