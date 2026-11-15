# TWFE, Callaway-Sant'Anna DiD-averaging (CSA) and Borusyak-Jaravel-Spiess imputation (BJS) for one specification,
# with Hull's (2026) leverage screen and the Borusyak-Hull ex post TWFE weights. See docs/PROTOCOL.md Section 5.
#
# Conventions for the prepared data d (data.table, built by prep_data()):
#   id, t (consecutive integer index of calendar periods), y (standardized in the regression sample), w (analysis weight),
#   cl (cluster), g (first treated period on the t index; Inf = never treated), D (1 if t >= g), xt_* (time-invariant
#   characteristics interacted with t), and the time-varying controls (secondary sample only).
# Every estimator is linear in y; *_influence() returns a with estimate = sum(a * y), used by the leverage screen.
suppressPackageStartupMessages({ library(data.table); library(fixest) })
`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a
HAS_DID <- requireNamespace("did", quietly = TRUE)
HAS_DID2S <- requireNamespace("did2s", quietly = TRUE)
XT_MAX_LEVELS <- 60   # characteristics with more categories get no CSA estimate (PROTOCOL 5.4)

wvar <- function(x, w) { m <- sum(w * x) / sum(w); sum(w * (x - m)^2) / sum(w) }
fe_terms <- function(xt) paste(c("id", "t", if (length(xt)) paste0("t^", xt)), collapse = " + ")
ctrl_rhs <- function(ctrl, none = "1") if (length(ctrl)) paste(ctrl, collapse = " + ") else none
is_rc <- function(d) anyDuplicated(d, by = c("id", "t")) > 0   # several rows per unit-period: repeated cross-section
is_unbal <- function(d) d[, uniqueN(t)] * d[, uniqueN(id)] != nrow(unique(d, by = c("id", "t")))

# ---------------------------------------------------------------------------------------------------------------
# Data preparation
# ---------------------------------------------------------------------------------------------------------------
# raw: data.table with the spec's columns. Returns list(d, notes).
prep_data <- function(raw, spec) {
  notes <- character()
  s <- function(k) { v <- spec[[k, exact = TRUE]]; if (is.null(v) || (is.character(v) && !nzchar(v[1]))) NULL else v }
  d <- data.table(id = raw[[s("id_var")]], tcal = as.numeric(raw[[s("time_var")]]), y = as.numeric(raw[[s("y_var")]]))
  d[, w := if (!is.null(s("weight_var"))) as.numeric(raw[[s("weight_var")]]) else 1]
  d[, cl := if (!is.null(s("cluster_var"))) raw[[s("cluster_var")]] else id]
  xt <- unlist(s("xt_vars")); ctrl <- unlist(s("controls"))
  for (v in xt) d[, (paste0("xt_", v)) := raw[[v]]]
  for (v in ctrl) d[, (v) := as.numeric(raw[[v]])]
  xt <- if (length(xt)) paste0("xt_", xt) else character()
  if (!is.null(s("log_y"))) d[, y := if (s("log_y") == "log1p") log1p(y) else log(y)]
  # first treated calendar period
  if (!is.null(s("gvar"))) {
    gc <- as.numeric(raw[[s("gvar")]]); gc[is.na(gc) | gc == 0] <- Inf
    d[, gcal := gc]
    d[, gcal := min(gcal), by = id]
  } else {
    d[, Dobs := as.numeric(raw[[s("treat_var")]])]
    d[, gcal := { x <- tcal[!is.na(Dobs) & Dobs == 1]; if (length(x)) min(x) else Inf }, by = id]
    off <- d[is.finite(gcal) & tcal >= gcal & !is.na(Dobs) & Dobs == 0, .N]
    if (off > 0) { d <- d[!(is.finite(gcal) & tcal >= gcal & !is.na(Dobs) & Dobs == 0)]; notes <- c(notes, sprintf("switch_off_rows_dropped=%d", off)) }
    d[, Dobs := NULL]
  }
  keep <- complete.cases(d[, c("y", "w", "tcal", xt, ctrl), with = FALSE]) & !is.na(d$id) & !is.na(d$cl) & d$w > 0
  if (any(!keep)) notes <- c(notes, sprintf("rows_missing_dropped=%d", sum(!keep)))
  d <- d[keep]
  # time-invariant characteristics: hold at the unit's first observed value (PROTOCOL 3)
  for (v in xt) {
    nv <- d[, uniqueN(get(v)), by = id][V1 > 1, .N]
    if (nv > 0) { setorder(d, id, tcal); d[, (v) := get(v)[1], by = id]; notes <- c(notes, sprintf("%s_held_fixed_units=%d", v, nv)) }
  }
  # consecutive period index; cohorts mapped to the first sample period at or after the adoption date
  tt <- sort(unique(d$tcal))
  d[, t := match(tcal, tt)]
  d[, g := ifelse(is.finite(gcal), findInterval(gcal - 1e-9, tt) + 1, Inf)]
  d[g > length(tt), g := Inf]   # adopts after the sample: never treated within the sample
  if (any(diff(tt) != median(diff(tt)))) notes <- c(notes, "calendar_gaps(t_is_index)")
  d[, D := as.integer(t >= g)]
  d[, id := as.character(id)]; d[, cl := as.character(cl)]
  list(d = d, xt = xt, ctrl = ctrl, notes = notes, periods = tt)
}

standardize_y <- function(d) { s <- sqrt(wvar(d$y, d$w)); d[, y := y / s]; s }

design_stats <- function(d) {
  t1 <- min(d$t)
  list(n = nrow(d), n_units = uniqueN(d$id), n_clusters = uniqueN(d$cl),
       n_cohorts = uniqueN(d$g[is.finite(d$g) & d$g > t1]),
       share_never = mean(!is.finite(d$g)), share_always = mean(is.finite(d$g) & d$g <= t1),
       unbalanced = as.integer(!is_rc(d) && is_unbal(d)), repeated_cs = as.integer(is_rc(d)))
}

# ---------------------------------------------------------------------------------------------------------------
# Leverage screen (Hull 2026, App. B): L_c = sum_{j in c} a_j^2 / sum_j a_j^2; G_eff = 1 / sum_c L_c^2
# ---------------------------------------------------------------------------------------------------------------
leverage <- function(a, cl) {
  if (is.null(a) || anyNA(a)) return(list(G_eff = NA_real_, L_max = NA_real_))
  L <- tapply(a^2, cl, sum) / sum(a^2)
  list(G_eff = 1 / sum(L^2), L_max = max(L))
}
passes <- function(G, L) !is.na(G) & !is.na(L) & G >= 10 & L <= 0.25

# ---------------------------------------------------------------------------------------------------------------
# TWFE
# ---------------------------------------------------------------------------------------------------------------
twfe_static <- function(d, xt, ctrl) {
  m <- feols(as.formula(paste0("y ~ D", if (length(ctrl)) paste0(" + ", ctrl_rhs(ctrl)), " | ", fe_terms(xt))),
             data = d, weights = ~w, cluster = ~cl, notes = FALSE, warn = FALSE)
  list(est = unname(coef(m)["D"]), se = unname(se(m)["D"]), n = nobs(m))
}
# residual of D (or bin dummies) on FE and controls: FWL
resid_fe <- function(d, lhs, xt, ctrl) {
  m <- feols(as.formula(paste0("c(", paste(lhs, collapse = ","), ") ~ ", ctrl_rhs(ctrl), " | ", fe_terms(xt))),
             data = d, weights = ~w, notes = FALSE, warn = FALSE, fixef.rm = "none")
  if (length(lhs) == 1) matrix(resid(m), ncol = 1) else sapply(m, resid)
}
twfe_influence <- function(d, xt, ctrl) { Dt <- resid_fe(d, "D", xt, ctrl)[, 1]; d$w * Dt / sum(d$w * Dt * d$D) }
# Borusyak-Hull ex post weights psi_j = Dtilde_j * D_j (times w)
twfe_negweights <- function(d, xt, ctrl) {
  Dt <- resid_fe(d, "D", xt, ctrl)[, 1]; tr <- d$D == 1; psi <- (d$w * Dt)[tr]
  list(neg_rows = mean(psi < 0), neg_abs = -sum(pmin(psi, 0)) / sum(abs(psi)))
}

# ---------------------------------------------------------------------------------------------------------------
# BJS imputation
# ---------------------------------------------------------------------------------------------------------------
fe_levels <- function(d, xt) {
  L <- list(id = d$id, t = as.character(d$t))
  for (v in xt) L[[paste0("t_", v)]] <- paste(d$t, d[[v]], sep = "|")
  L
}
# Treated rows whose counterfactual is identified: every FE level has untreated observations. Others are dropped from
# the imputation estimate (always-treated units, periods with no untreated units).
bjs_imputable <- function(d, xt) {
  L <- fe_levels(d, xt); ok <- rep(TRUE, nrow(d)); u <- d$D == 0
  for (k in names(L)) ok <- ok & (L[[k]] %in% unique(L[[k]][u]))
  ok | u
}
# Point estimate: fit FE (+ controls) on untreated rows, impute Y(0), weighted mean of y - yhat over treated rows in `sel`
bjs_point <- function(d, xt, ctrl, sel = d$D == 1) {
  m0 <- feols(as.formula(paste0("y ~ ", ctrl_rhs(ctrl), " | ", fe_terms(xt))), data = d[D == 0], weights = ~w,
              notes = FALSE, warn = FALSE, fixef.rm = "none")
  yh <- predict(m0, newdata = d)
  tr <- sel & !is.na(yh)
  sum(d$w[tr] * (d$y[tr] - yh[tr])) / sum(d$w[tr])
}
# Influence coefficients: a_j = q_j on treated rows (q = target weights summing to 1), a_U = -w_U * (Z_U b) with
# Z_U' W_U Z_U b = Z_1' q, solved by Gauss-Seidel over the FE dimensions. Only without controls.
bjs_influence <- function(d, xt, q, tol = 1e-11, maxit = 20000) {
  L <- fe_levels(d, xt); u <- d$D == 0; K <- names(L)
  idx <- lapply(L, function(x) as.integer(factor(x)))
  nl <- sapply(idx, max)
  sumby <- function(x, g, n) { r <- numeric(n); s <- rowsum(x, g); r[as.integer(rownames(s))] <- s[, 1]; r }
  R <- lapply(K, function(k) sumby(q[!u], idx[[k]][!u], nl[[k]]))
  S <- lapply(K, function(k) sumby(d$w[u], idx[[k]][u], nl[[k]]))
  IU <- lapply(K, function(k) idx[[k]][u])
  names(R) <- names(S) <- names(IU) <- K
  b <- lapply(nl, function(n) numeric(n)); fitU <- numeric(sum(u)); wu <- d$w[u]
  for (it in seq_len(maxit)) {
    delta <- 0
    for (k in K) {
      iu <- IU[[k]]
      other <- fitU - b[[k]][iu]
      bn <- ifelse(S[[k]] > 0, (R[[k]] - sumby(wu * other, iu, nl[[k]])) / S[[k]], 0)
      delta <- max(delta, max(abs(bn - b[[k]])))
      b[[k]] <- bn; fitU <- other + bn[iu]
    }
    if (delta < tol) break
  }
  if (delta >= tol) warning(sprintf("bjs_influence: Gauss-Seidel not converged (delta %.2g)", delta))
  a <- q; a[u] <- -wu * fitU
  a
}
bjs_static <- function(d, xt, ctrl) {
  ok <- bjs_imputable(d, xt); dropped <- sum(!ok); dd <- d[ok]
  est <- bjs_point(dd, xt, ctrl)
  se <- NA_real_; note <- if (dropped) sprintf("bjs_nonimputable_dropped=%d", dropped) else ""
  if (HAS_DID2S) {
    fs <- as.formula(paste0("~ ", ctrl_rhs(ctrl, none = "0"), " | ", fe_terms(xt)))
    m <- tryCatch(did2s::did2s(data = as.data.frame(dd), yname = "y", first_stage = fs, second_stage = ~ i(D, ref = 0),
                               treatment = "D", cluster_var = "cl", weights = "w", verbose = FALSE),
                  error = function(e) e)
    if (inherits(m, "error")) note <- paste(note, "did2s_error:", substr(conditionMessage(m), 1, 80)) else {
      se <- unname(fixest::se(m)[1])
      if (abs(coef(m)[1] - est) > 1e-6 * max(1, abs(est))) note <- paste(note, sprintf("did2s_point=%.6g", coef(m)[1]))
    }
  } else note <- paste(note, "no_did2s:se_NA")
  a <- NULL
  if (!length(ctrl)) {
    q <- ifelse(dd$D == 1, dd$w / sum(dd$w[dd$D == 1]), 0)
    a <- bjs_influence(dd, xt, q)
    if (abs(sum(a * dd$y) - est) > 1e-6 * max(1, abs(est))) { a <- NULL; note <- paste(note, "bjs_lev_check_failed") }
  }
  lev <- leverage(a, dd$cl)
  list(est = est, se = se, note = trimws(note), G_eff = lev$G_eff, L_max = lev$L_max)
}

# ---------------------------------------------------------------------------------------------------------------
# CSA DiD-averaging: not-yet-treated (incl. never-treated) controls, base period g-1 for post cells
# ---------------------------------------------------------------------------------------------------------------
# Cell implementation (no covariates): ATT(g,t) = [ybar(g,t) - ybar(g,b)] - [ybar(C,t) - ybar(C,b)], C = units with
# g' > max(t, b) (never-treated included), weighted means over whichever rows are observed (Hull's cohort averages;
# equals did's panel estimator on balanced panels). Returns cells with their influence vectors on y.
csa_cells <- function(d, cells) {
  Tn <- max(d$t); out <- vector("list", nrow(cells)); A <- matrix(0, nrow(d), nrow(cells))
  for (k in seq_len(nrow(cells))) {
    g <- cells$g[k]; tt <- cells$t[k]; b <- cells$b[k]
    ctl <- d$g > max(tt, b)            # Inf > anything
    sets <- list(gt = d$g == g & d$t == tt, gb = d$g == g & d$t == b, ct = ctl & d$t == tt, cb = ctl & d$t == b)
    W <- sapply(sets, function(s) sum(d$w[s]))
    if (any(W == 0)) { out[[k]] <- data.table(g = g, t = tt, att = NA_real_, ntr = 0); next }
    a <- numeric(nrow(d))
    a[sets$gt] <- d$w[sets$gt] / W["gt"]; a[sets$gb] <- a[sets$gb] - d$w[sets$gb] / W["gb"]
    a[sets$ct] <- a[sets$ct] - d$w[sets$ct] / W["ct"]; a[sets$cb] <- a[sets$cb] + d$w[sets$cb] / W["cb"]
    A[, k] <- a
    out[[k]] <- data.table(g = g, t = tt, att = sum(a * d$y), ntr = W[["gt"]])
  }
  list(cells = rbindlist(out), A = A)
}
csa_post_cells <- function(d) {
  t1 <- min(d$t); Tn <- max(d$t)
  G <- sort(unique(d$g[is.finite(d$g) & d$g > t1 & d$g <= Tn]))
  cells <- rbindlist(lapply(G, function(g) data.table(g = g, t = g:Tn, b = g - 1)))
  # a post cell needs a not-yet-treated comparison group at t
  cells[vapply(seq_len(nrow(cells)), function(k) any(d$g > cells$t[k] & d$t == cells$t[k]), TRUE)]
}
# Static: weights proportional to treated observations (Hull) = cohort size x periods (did "simple") in balanced panels
# weights = "hull": treated-observation counts n(g,t) (Hull 2026); "did": did's aggte(simple) weights, cohort share x periods,
# with cohort shares from unit weights (panels, balanced or not) or row weights (repeated cross-sections)
csa_static_cells <- function(d, weights = "hull") {
  cc <- csa_post_cells(d); if (!nrow(cc)) return(list(est = NA_real_, a = NULL, note = "csa_no_cells"))
  r <- csa_cells(d, cc); ok <- !is.na(r$cells$att)
  if (weights == "hull") om <- r$cells$ntr[ok] / sum(r$cells$ntr[ok]) else {
    pg <- if (is_rc(d)) d[, .(pg = sum(w)), by = g] else unique(d, by = "id")[, .(pg = sum(w)), by = g]
    om <- pg$pg[match(r$cells$g[ok], pg$g)]; om <- om / sum(om)
  }
  a <- drop(r$A[, ok, drop = FALSE] %*% om)
  list(est = sum(a * d$y), a = a, note = if (any(!ok)) sprintf("csa_empty_cells=%d", sum(!ok)) else "")
}
did_ids <- function(d) { d <- copy(d); d[, id_num := as.integer(factor(id))]; d[, cl_num := as.integer(factor(cl))]; d[, g0 := ifelse(is.finite(g), g, 0)]; d }
csa_did <- function(d, xt, ctrl, type = "simple", min_e = -Inf, max_e = Inf, base = "varying", B = 999) {
  dd <- did_ids(d); rc <- is_rc(d); unb <- !rc && is_unbal(d)
  xf <- NULL
  if (length(xt) || length(ctrl)) xf <- as.formula(paste("~", paste(c(if (length(xt)) paste0("factor(", xt, ")"), ctrl), collapse = " + ")))
  cv <- if (identical(d$cl, d$id)) NULL else c("id_num", "cl_num")
  set.seed(20261109)
  at <- did::att_gt(yname = "y", tname = "t", idname = "id_num", gname = "g0", data = as.data.frame(dd), xformla = xf,
                    panel = !rc, allow_unbalanced_panel = unb, control_group = "notyettreated", weightsname = "w",
                    clustervars = cv, est_method = "reg", base_period = base, bstrap = TRUE, biters = B, cband = FALSE,
                    print_details = FALSE)
  ag <- did::aggte(at, type = type, min_e = min_e, max_e = max_e, na.rm = TRUE, bstrap = TRUE, biters = B, cband = FALSE)
  list(est = ag$overall.att, se = ag$overall.se, agg = ag, attgt = at, note = paste0(if (rc) "rc" else if (unb) "unbalanced" else "", ""))
}
csa_static <- function(d, xt, ctrl) {
  big <- vapply(xt, function(v) uniqueN(d[[v]]) > XT_MAX_LEVELS, TRUE)
  if (any(big)) return(list(est = NA_real_, se = NA_real_, note = paste0("csa_skipped_xt_levels>", XT_MAX_LEVELS, ":", paste(xt[big], collapse = ","))))
  nocov <- !length(xt) && !length(ctrl)
  cs <- if (nocov) csa_static_cells(d, "did") else list(est = NA_real_, a = NULL, note = "")
  hw <- if (nocov) csa_static_cells(d, "hull")$est else NA_real_
  res <- list(est = cs$est, se = NA_real_, note = cs$note)
  if (HAS_DID) {
    r <- tryCatch(csa_did(d, xt, ctrl), error = function(e) e)
    if (inherits(r, "error")) res$note <- paste(res$note, "did_error:", substr(conditionMessage(r), 1, 80)) else {
      if (!is.na(cs$est) && abs(r$est - cs$est) > 1e-6 * max(1, abs(cs$est)))
        res$note <- paste(res$note, sprintf("cells=%.6g_did=%.6g", cs$est, r$est))
      res$est <- r$est; res$se <- r$se; res$note <- paste(res$note, r$note)
    }
  } else res$note <- paste(res$note, "no_did:se_NA")
  lev <- if (!is.null(cs$a) && isTRUE(abs(cs$est - res$est) <= 1e-6 * max(1, abs(res$est)))) leverage(cs$a, d$cl) else
    list(G_eff = NA_real_, L_max = NA_real_)
  if (is.na(lev$G_eff) && !is.null(cs$a)) res$note <- paste(res$note, "csa_lev_na:cells_differ_from_did")
  c(res[c("est", "se")], list(hullw = hw, note = trimws(res$note), G_eff = lev$G_eff, L_max = lev$L_max))
}

# ---------------------------------------------------------------------------------------------------------------
# Static comparison
# ---------------------------------------------------------------------------------------------------------------
compare_static <- function(d, xt, ctrl, B = 0) {
  tw <- twfe_static(d, xt, ctrl); nw <- twfe_negweights(d, xt, ctrl)
  ltw <- leverage(twfe_influence(d, xt, ctrl), d$cl)
  bj <- tryCatch(bjs_static(d, xt, ctrl), error = function(e) list(est = NA, se = NA, note = paste("bjs_error:", conditionMessage(e)), G_eff = NA, L_max = NA))
  cs <- tryCatch(csa_static(d, xt, ctrl), error = function(e) list(est = NA, se = NA, note = paste("csa_error:", conditionMessage(e)), G_eff = NA, L_max = NA))
  res <- data.table(window = "static", twfe = tw$est, twfe_se = tw$se, csa = cs$est, csa_se = cs$se, csa_hullw = cs$hullw %||% NA_real_,
                    bjs = bj$est, bjs_se = bj$se,
                    neg_rows = nw$neg_rows, neg_abs = nw$neg_abs,
                    G_eff_twfe = ltw$G_eff, L_max_twfe = ltw$L_max, G_eff_csa = cs$G_eff, L_max_csa = cs$L_max,
                    G_eff_bjs = bj$G_eff, L_max_bjs = bj$L_max, csa_note = cs$note, bjs_note = bj$note)
  if (B > 0) res <- cbind(res, boot_cov_static(d, xt, ctrl, B))
  res
}

# Joint cluster Bayesian bootstrap (Hull fn. 18): exponential weights per cluster multiply w; point estimates of all three
# estimators re-computed on each draw (CSA by the cell implementation, so only without covariates).
boot_cov_static <- function(d, xt, ctrl, B = 999, seed = 1) {
  set.seed(seed); cls <- unique(d$cl); w0 <- d$w; ci <- match(d$cl, cls)
  ok <- bjs_imputable(d, xt); use_csa <- !length(xt) && !length(ctrl)
  draws <- t(vapply(seq_len(B), function(b) {
    d[, w := w0 * rexp(length(cls))[ci]]
    c(twfe = coef(feols(as.formula(paste0("y ~ D", if (length(ctrl)) paste0(" + ", ctrl_rhs(ctrl)), " | ", fe_terms(xt))), data = d, weights = ~w, notes = FALSE, warn = FALSE))[["D"]],
      csa = if (use_csa) csa_static_cells(d, "did")$est else NA_real_,
      bjs = bjs_point(d[ok], xt, ctrl))
  }, numeric(3)))
  d[, w := w0]
  V <- cov(draws, use = "pairwise.complete.obs")
  data.table(boot_B = B, cov_twfe_csa = V["twfe", "csa"], cov_twfe_bjs = V["twfe", "bjs"],
             bsd_twfe = sqrt(V["twfe", "twfe"]), bsd_csa = sqrt(V["csa", "csa"]), bsd_bjs = sqrt(V["bjs", "bjs"]))
}

# ---------------------------------------------------------------------------------------------------------------
# Event studies: authors' bins and reference (event_structure: pre_min, post_max, ref, ends)
# ---------------------------------------------------------------------------------------------------------------
NEVER <- -9999L
event_bins <- function(d, es) {
  pre_min <- as.integer(es$pre_min); post_max <- as.integer(es$post_max); ref <- as.integer(unlist(es$ref %||% -1))
  ends <- es$ends %||% "bin"
  d[, rel := ifelse(is.finite(g), t - g, NA_real_)]
  out <- is.finite(d$g) & (d$rel < pre_min | d$rel > post_max)
  if (ends == "drop") d <- d[!out] else if (ends == "bin") d[, rel := pmin(pmax(rel, pre_min), post_max)]
  d[, ebin := ifelse(!is.finite(g), NEVER, ifelse(rel < pre_min | rel > post_max, NEVER, rel))]   # ends = "ref": outside -> reference
  d[ebin %in% ref, ebin := NEVER]
  bins <- setdiff(pre_min:post_max, ref)
  list(d = d, bins = bins, post = bins[bins >= 0], pre = bins[bins < 0], ref = ref)
}
lincomb <- function(b, V, cvec) { nm <- names(cvec); list(est = sum(b[nm] * cvec), se = sqrt(drop(t(cvec) %*% V[nm, nm] %*% cvec))) }
twfe_event <- function(d, xt, ctrl, S) {
  m <- feols(as.formula(paste0("y ~ i(ebin, ref = ", NEVER, ")", if (length(ctrl)) paste0(" + ", ctrl_rhs(ctrl)), " | ", fe_terms(xt))),
             data = d, weights = ~w, cluster = ~cl, notes = FALSE, warn = FALSE)
  b <- coef(m); V <- vcov(m); nm <- function(k) paste0("ebin::", k)
  got <- function(ks) ks[nm(ks) %in% names(b)]
  post <- got(S$post); pre <- got(S$pre)
  cp <- setNames(rep(1 / length(post), length(post)), nm(post)); cr <- setNames(rep(1 / max(1, length(pre)), length(pre)), nm(pre))
  # leverage of the post average: a = W R M c (FWL with all bin dummies)
  dn <- paste0("bin_", sub("-", "m", S$bins))
  for (k in seq_along(S$bins)) d[, (dn[k]) := as.numeric(ebin == S$bins[k])]
  keep <- dn[colSums(d[, dn, with = FALSE]) > 0]
  Rm <- resid_fe(d, keep, xt, ctrl); M <- solve(crossprod(Rm, d$w * Rm))
  cfull <- setNames(numeric(length(keep)), keep); cfull[paste0("bin_", sub("-", "m", post))] <- 1 / length(post)
  a <- d$w * drop(Rm %*% (M %*% cfull))
  d[, (dn) := NULL]
  list(post = lincomb(b, V, cp), pre = if (length(pre)) lincomb(b, V, cr) else list(est = NA, se = NA), lev = leverage(a, d$cl), n = nobs(m))
}
bjs_event <- function(d, xt, ctrl, S) {
  ok <- bjs_imputable(d, xt); dd <- d[ok]; note <- if (any(!ok)) sprintf("bjs_nonimputable_dropped=%d", sum(!ok)) else ""
  m0 <- feols(as.formula(paste0("y ~ ", ctrl_rhs(ctrl), " | ", fe_terms(xt))), data = dd[D == 0], weights = ~w, notes = FALSE, warn = FALSE, fixef.rm = "none")
  dd[, res := y - predict(m0, newdata = dd)]
  post <- intersect(S$post, unique(dd$ebin[dd$D == 1]))
  pe <- dd[D == 1 & ebin %in% post, .(m = sum(w * res) / sum(w)), by = ebin][, mean(m)]
  pse <- NA_real_
  if (HAS_DID2S) {
    dd[, ebp := ifelse(D == 1 & ebin %in% post, ebin, NEVER)]
    m <- tryCatch(did2s::did2s(data = as.data.frame(dd), yname = "y", first_stage = as.formula(paste0("~ ", ctrl_rhs(ctrl, none = "0"), " | ", fe_terms(xt))),
                               second_stage = as.formula(paste0("~ i(ebp, ref = ", NEVER, ")")), treatment = "D", cluster_var = "cl", weights = "w", verbose = FALSE),
                  error = function(e) e)
    if (!inherits(m, "error")) {
      cv <- setNames(rep(1 / length(post), length(post)), paste0("ebp::", post))
      lc <- lincomb(coef(m), vcov(m), cv); pse <- lc$se
      if (abs(lc$est - pe) > 1e-6 * max(1, abs(pe))) note <- paste(note, sprintf("did2s_post=%.6g", lc$est))
    } else note <- paste(note, "did2s_error")
  }
  # pre: BJS lead test on untreated rows (leads pre_min..-1 of eventually treated units; earlier rows and never-treated are baseline)
  pre <- list(est = NA_real_, se = NA_real_)
  if (length(S$pre)) {
    u <- dd[D == 0]; u[, lead := ifelse(is.finite(g) & (t - g) >= min(S$pre) & (t - g) <= -1, t - g, NEVER)]
    ml <- tryCatch(feols(as.formula(paste0("y ~ i(lead, ref = ", NEVER, ")", if (length(ctrl)) paste0(" + ", ctrl_rhs(ctrl)), " | ", fe_terms(xt))),
                         data = u, weights = ~w, cluster = ~cl, notes = FALSE, warn = FALSE), error = function(e) NULL)
    if (!is.null(ml)) {
      ks <- paste0("lead::", S$pre); ks <- ks[ks %in% names(coef(ml))]
      if (length(ks)) pre <- lincomb(coef(ml), vcov(ml), setNames(rep(1 / length(ks), length(ks)), ks))
    }
  }
  lev <- list(G_eff = NA_real_, L_max = NA_real_)
  if (!length(ctrl)) {
    sel <- dd$D == 1 & dd$ebin %in% post
    Wb <- dd[sel, .(W = sum(w)), by = ebin]
    q <- numeric(nrow(dd)); q[sel] <- dd$w[sel] / Wb$W[match(dd$ebin[sel], Wb$ebin)] / length(post)
    a <- bjs_influence(dd, xt, q)
    if (abs(sum(a * dd$y) - pe) <= 1e-6 * max(1, abs(pe))) lev <- leverage(a, dd$cl) else note <- paste(note, "bjs_lev_check_failed")
  }
  list(post = list(est = pe, se = pse), pre = pre, lev = lev, note = trimws(note))
}
csa_event <- function(d, xt, ctrl, S) {
  if (!HAS_DID) return(list(post = list(est = NA, se = NA), pre = list(est = NA, se = NA), note = "no_did"))
  big <- vapply(xt, function(v) uniqueN(d[[v]]) > XT_MAX_LEVELS, TRUE)
  if (any(big)) return(list(post = list(est = NA, se = NA), pre = list(est = NA, se = NA), note = "csa_skipped_xt_levels"))
  r <- csa_did(d, xt, ctrl, type = "dynamic", min_e = min(S$bins, S$ref), max_e = max(S$post), base = "universal")
  ag <- r$agg; e <- ag$egt; att <- ag$att.egt; IF <- ag$inf.function$dynamic.inf.func.e
  # reference contrast: effect at the reference bins (0 when the reference is -1 with the universal base period)
  rr <- which(e %in% S$ref); cref <- numeric(length(e)); if (length(rr)) cref[rr] <- 1 / length(rr)
  comb <- function(ks) {
    ix <- which(e %in% ks); if (!length(ix)) return(list(est = NA_real_, se = NA_real_))
    cv <- numeric(length(e)); cv[ix] <- 1 / length(ix); cv <- cv - cref
    psi <- IF %*% cv; n <- nrow(IF)
    list(est = sum(cv * att), se = sqrt(sum(psi^2)) / n)   # unit-level IF (did normalizes IF by n)
  }
  list(post = comb(S$post), pre = comb(S$pre), note = trimws(paste(r$note, "csa_event_se_unit_clustered")))
}
compare_event <- function(d, xt, ctrl, es) {
  S <- event_bins(d, es); d <- S$d
  tw <- twfe_event(d, xt, ctrl, S); nw <- twfe_negweights(d, xt, ctrl)
  bj <- tryCatch(bjs_event(d, xt, ctrl, S), error = function(e) list(post = list(est = NA, se = NA), pre = list(est = NA, se = NA), lev = list(G_eff = NA, L_max = NA), note = paste("bjs_error:", conditionMessage(e))))
  cs <- tryCatch(csa_event(d, xt, ctrl, S), error = function(e) list(post = list(est = NA, se = NA), pre = list(est = NA, se = NA), note = paste("csa_error:", conditionMessage(e))))
  row <- function(win) data.table(window = win, twfe = tw[[win]]$est, twfe_se = tw[[win]]$se, csa = cs[[win]]$est, csa_se = cs[[win]]$se,
                                  bjs = bj[[win]]$est, bjs_se = bj[[win]]$se, neg_rows = nw$neg_rows, neg_abs = nw$neg_abs,
                                  G_eff_twfe = tw$lev$G_eff, L_max_twfe = tw$lev$L_max, G_eff_csa = NA_real_, L_max_csa = NA_real_,
                                  G_eff_bjs = bj$lev$G_eff, L_max_bjs = bj$lev$L_max, csa_note = cs$note, bjs_note = bj$note)
  list(res = rbind(row("post"), row("pre")), d = d)
}
