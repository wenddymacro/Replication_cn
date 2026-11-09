# Correctness checks for code/R/estimators.R. Usage: Rscript code/R/test_estimators.R
suppressPackageStartupMessages(library(data.table))
source("code/R/estimators.R")
ok <- function(cond, msg) { cat(if (isTRUE(cond)) "PASS" else "FAIL", msg, "\n"); if (!isTRUE(cond)) assign("n_fail", n_fail + 1, envir = .GlobalEnv) }
n_fail <- 0
sim <- function(n = 400, Tn = 10, het = TRUE, balanced = TRUE, seed = 1) {
  set.seed(seed)
  u <- data.table(id = 1:n, gc = sample(c(4, 6, 8, Inf), n, TRUE), a = rnorm(n), prov = sample(1:8, n, TRUE))
  d <- CJ(id = 1:n, tcal = 2001:(2000 + Tn))[u, on = "id"]
  d[, tt := tcal - 2000]
  d[, D := as.integer(tt >= gc)]
  d[, tau := if (het) ifelse(D == 1, ifelse(gc == 4, 0.5, ifelse(gc == 6, 0.2, -0.1)) * (tt - gc + 1), 0) else 1 * D]
  d[, y := a + 0.1 * tt + 0.05 * prov * tt + tau + rnorm(.N)]
  d[, cl := (id - 1) %/% 8]
  if (!balanced) d <- d[runif(.N) > 0.1]
  d[, .(id, tcal, y, treat = D, cl, prov, tau)]
}
spec <- list(id_var = "id", time_var = "tcal", y_var = "y", treat_var = "treat", cluster_var = "cl", xt_vars = character(), controls = character())

# 1. constant effect = 1: all three estimators close to 1 (unstandardized)
P <- prep_data(sim(het = FALSE), spec); d <- P$d
tw <- twfe_static(d, NULL, NULL)$est; bj <- bjs_static(d, NULL, NULL); cs <- csa_static(d, NULL, NULL)
cat(sprintf("constant effect: TWFE %.3f  BJS %.3f  CSA %.3f\n", tw, bj$est, cs$est))
ok(abs(tw - 1) < 0.1 && abs(bj$est - 1) < 0.1 && abs(cs$est - 1) < 0.1, "constant effect recovered by all estimators")

# 2. heterogeneous dynamic effects: BJS and CSA recover the ATT on the treated, TWFE does not
s2 <- sim(het = TRUE, n = 2000); truth <- s2[treat == 1, mean(tau)]
P <- prep_data(s2, spec); d <- P$d
tw <- twfe_static(d, NULL, NULL)$est; bj <- bjs_static(d, NULL, NULL); cs <- csa_static(d, NULL, NULL)
cat(sprintf("heterogeneous: truth %.3f  TWFE %.3f  BJS %.3f  CSA %.3f (CSA weights = treated obs; BJS = all treated obs)\n", truth, tw, bj$est, cs$est))
ok(abs(bj$est - truth) < 0.1, "BJS recovers the treated-observation ATT")
ok(abs(tw - truth) > 0.2, "static TWFE is biased under heterogeneous dynamic effects (as designed)")

# 3. influence coefficients reproduce the estimates exactly
a <- twfe_influence(d, NULL, NULL); ok(abs(sum(a * d$y) - tw) < 1e-8, "TWFE influence: sum(a*y) = estimate")
q <- ifelse(d$D == 1, d$w / sum(d$w[d$D == 1]), 0); okr <- bjs_imputable(d, NULL)
a <- bjs_influence(d[okr], NULL, q[okr]); ok(abs(sum(a * d$y[okr]) - bjs_point(d[okr], NULL, NULL)) < 1e-7, "BJS influence: sum(a*y) = estimate")
ok(!is.na(bj$G_eff) && !is.na(cs$G_eff), "leverage computed for BJS and CSA")

# 4. cell CSA = did::att_gt + aggte(simple) on a balanced panel; with unbalanced panel report the gap
if (HAS_DID) {
  cc <- csa_static_cells(d, "did")$est; dd <- csa_did(d, NULL, NULL, B = 99)$est
  ok(abs(cc - csa_static_cells(d, "hull")$est) < 1e-8, "Hull and did weights coincide on a balanced panel")
  cat(sprintf("balanced: CSA cells %.8f  did %.8f\n", cc, dd)); ok(abs(cc - dd) < 1e-8, "CSA cells = did (balanced)")
  P2 <- prep_data(sim(het = TRUE, balanced = FALSE, n = 1000), spec)
  hw <- csa_static_cells(P2$d, "hull")$est; cc <- csa_static_cells(P2$d, "did")$est; dd <- csa_did(P2$d, NULL, NULL, B = 99)$est
  cat(sprintf("unbalanced: CSA cells, did weights %.8f; did allow_unbalanced %.8f; Hull treated-count weights %.6f\n", cc, dd, hw))
  ok(abs(cc - dd) < 1e-8, "CSA cells = did (unbalanced, allow_unbalanced_panel)")
}

# 5. province-by-year FE (time-invariant characteristic x time)
spec_x <- modifyList(spec, list(xt_vars = "prov"))
P <- prep_data(sim(het = FALSE), spec_x); d <- P$d
tw <- twfe_static(d, P$xt, NULL)$est; bj <- bjs_static(d, P$xt, NULL)
ok(abs(tw - 1) < 0.1 && abs(bj$est - 1) < 0.1, sprintf("province x year FE: TWFE %.3f BJS %.3f", tw, bj$est))

# 6. event study: constant effect 1 -> post average 1, pre average 0 for all estimators
P <- prep_data(sim(het = FALSE, n = 1000), spec); d <- P$d
r <- compare_event(d, NULL, NULL, list(pre_min = -3, post_max = 3, ref = -1, ends = "bin"))$res
print(r[, .(window, twfe, csa, bjs)], digits = 3)
ok(all(abs(unlist(r[window == "post", .(twfe, csa, bjs)]) - 1) < 0.15, na.rm = TRUE), "event post averages close to 1")
ok(all(abs(unlist(r[window == "pre", .(twfe, csa, bjs)])) < 0.15, na.rm = TRUE), "event pre averages close to 0")

cat(if (n_fail == 0) "\nall checks passed\n" else sprintf("\n%d checks FAILED\n", n_fail))
quit(status = as.integer(n_fail > 0))
