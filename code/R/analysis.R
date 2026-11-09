# Compare TWFE with the two modern estimators across all re-estimated specifications (PROTOCOL Section 6).
# Usage: Rscript code/R/analysis.R            (papers cie*; INCLUDE_EXAMPLE=1 adds the simulated EXAMPLE specs)
# Inputs:  output/specs/*.csv (main sample), output/specs_controls/*.csv (secondary sample with time-varying controls)
# Outputs: output/specs_main.csv, output/tables/comparison_summary.{csv,md}, output/figures/scatter_<sample>.png
suppressPackageStartupMessages(library(data.table))
OUT <- Sys.getenv("OUT_DIR", "output")
inc_ex <- Sys.getenv("INCLUDE_EXAMPLE") == "1"

load_dir <- function(sub) {
  f <- list.files(file.path(OUT, sub), pattern = "\\.csv$", full.names = TRUE)
  if (!inc_ex) f <- f[!grepl("^EXAMPLE__", basename(f))]
  if (!length(f)) return(NULL)
  rbindlist(lapply(f, fread), fill = TRUE)
}
passes <- function(G, L) !is.na(G) & !is.na(L) & G >= 10 & L <= 0.25

# long format: one row per comparison (TWFE vs one modern estimator, one window)
to_long <- function(x) {
  one <- function(m) {
    has_cov <- paste0("cov_twfe_", m) %in% names(x)
    y <- x[, .(paper_id, spec_id, window, estimator = m, twfe, twfe_se, modern = get(m), modern_se = get(paste0(m, "_se")),
               cov = if (has_cov) get(paste0("cov_twfe_", m)) else NA_real_,
               G_twfe = G_eff_twfe, L_twfe = L_max_twfe, G_mod = get(paste0("G_eff_", m)), L_mod = get(paste0("L_max_", m)),
               neg_abs, neg_rows, n_cohorts, share_never, share_always, unbalanced, preferred, in_abstract_intro, reports_modern_estimator)]
    y[]
  }
  z <- rbind(one("csa"), one("bjs"))
  z <- z[!is.na(modern) & !is.na(twfe)]
  # leverage screen: both estimators; where the modern estimator's leverage is not computed, TWFE's alone (flagged)
  z[, screen_basis := ifelse(is.na(G_mod), "twfe_only", "both")]
  z[, pass := passes(G_twfe, L_twfe) & (is.na(G_mod) | passes(G_mod, L_mod))]
  z[, cov_used := fifelse(is.na(cov), 0, cov)]
  z[, vdiff := modern_se^2 + twfe_se^2 - 2 * cov_used]
  # non-positive variance: rescale the bootstrap correlation by the analytic SEs (always valid)
  z[vdiff <= 0 & !is.na(cov), vdiff := modern_se^2 + twfe_se^2 - 2 * pmin(1, abs(cov) / (twfe_se * modern_se)) * sign(cov) * twfe_se * modern_se * 0.999]
  z[, z_diff := (modern - twfe) / sqrt(vdiff)]
  z[, flip := sign(modern) != sign(twfe)]
  z[, sig_flip := flip & abs(z_diff) > qnorm(0.975)]
  z[, se_ratio := modern_se / twfe_se]
  z[, wpaper := 1 / .N, by = .(paper_id, estimator)]
  z[]
}
wcor <- function(x, y, w) { w <- w / sum(w); mx <- sum(w * x); my <- sum(w * y); sum(w * (x - mx) * (y - my)) / sqrt(sum(w * (x - mx)^2) * sum(w * (y - my)^2)) }
summarise <- function(z, label) {
  z[, .(sample = label, comparisons = .N, papers = uniqueN(paper_id),
        corr = if (.N > 2) cor(twfe, modern) else NA_real_,
        corr_paper_w = if (.N > 2) wcor(twfe, modern, wpaper) else NA_real_,
        flip = mean(flip), flip_paper_w = sum(wpaper * flip) / sum(wpaper),
        sig_flip = mean(sig_flip, na.rm = TRUE),
        se_ratio_mean = mean(se_ratio, na.rm = TRUE), se_ratio_median = median(se_ratio, na.rm = TRUE),
        with_boot_cov = sum(!is.na(cov)), screen_twfe_only = sum(screen_basis == "twfe_only"),
        neg_abs_mean = mean(neg_abs, na.rm = TRUE)), by = estimator]
}
scatter <- function(z, file, title) {
  dir.create(dirname(file), recursive = TRUE, showWarnings = FALSE)
  png(file, width = 1400, height = 700, res = 150)
  op <- par(mfrow = c(1, 2), mar = c(4.2, 4.2, 2.5, 1))
  for (m in c("csa", "bjs")) {
    s <- z[estimator == m]
    lab <- c(csa = "DiD-averaging (Callaway-Sant'Anna)", bjs = "Imputation (Borusyak-Jaravel-Spiess)")[m]
    if (!nrow(s)) { plot.new(); title(lab); next }
    r <- range(c(s$twfe, s$modern, 0))
    plot(s$twfe, s$modern, xlim = r, ylim = r, pch = ifelse(s$sig_flip, 17, 16), col = ifelse(s$flip, "#c0392b", "#2c6fbb"),
         xlab = "TWFE (outcome SD units)", ylab = lab, main = sprintf("%s: %s", title, lab), cex.main = 0.8)
    abline(0, 1, lty = 2, col = "grey50"); abline(h = 0, v = 0, col = "grey80")
  }
  par(op); dev.off()
}

samples <- list(main = "specs", controls = "specs_controls")
summ <- list(); all_main <- NULL
for (nm in names(samples)) {
  x <- load_dir(samples[[nm]]); if (is.null(x)) next
  z <- to_long(x)
  if (nm == "main") all_main <- z
  summ[[length(summ) + 1]] <- summarise(z[pass == TRUE], paste0(nm, ":pass_screen"))
  summ[[length(summ) + 1]] <- summarise(z, paste0(nm, ":all"))
  scatter(z[pass == TRUE], file.path(OUT, "figures", paste0("scatter_", nm, ".png")), nm)
}
if (!length(summ)) { cat("no specification outputs found in", OUT, "(set INCLUDE_EXAMPLE=1 to use the simulated example)\n"); quit(save = "no") }
S <- rbindlist(summ)
dir.create(file.path(OUT, "tables"), recursive = TRUE, showWarnings = FALSE)
fwrite(S, file.path(OUT, "tables", "comparison_summary.csv"))
if (!is.null(all_main)) fwrite(all_main, file.path(OUT, "specs_main.csv"))
md <- c(paste("|", paste(names(S), collapse = " | "), "|"), paste0("|", strrep("---|", ncol(S))),
        apply(S, 1, function(r) paste("|", paste(sapply(r, function(v) { n <- suppressWarnings(as.numeric(v)); if (is.na(n)) v else if (n == round(n)) v else sprintf("%.3f", n) }), collapse = " | "), "|")))
writeLines(c("Notes: corr = correlation of TWFE and modern estimates; flip = share with opposite signs; sig_flip = opposite signs",
             "and a significant difference at 5% (covariance from the joint bootstrap where computed, else 0, which is conservative);",
             "se_ratio = modern SE / TWFE SE; *_paper_w weights papers equally; screen_twfe_only = comparisons screened on TWFE leverage",
             "alone because the modern estimator's leverage is not computed (event-study DiD-averaging, specs with controls).", "", md),
           file.path(OUT, "tables", "comparison_summary.md"))
print(S, digits = 3)
