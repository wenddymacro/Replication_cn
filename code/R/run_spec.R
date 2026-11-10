# Re-estimate one specification with TWFE, CSA and BJS (docs/PROTOCOL.md Section 5; fields in docs/SPEC_SCHEMA.md).
# Usage: Rscript code/R/run_spec.R data/specs/<paper_id>__<spec_id>.json [B]
#   B = number of joint Bayesian bootstrap draws for the TWFE-modern covariance (static specs; default 0 = not computed)
# Output: $OUT_DIR/specs[_controls]/<paper_id>__<spec_id>.csv (OUT_DIR defaults to output)
suppressPackageStartupMessages({ library(data.table); library(jsonlite) })
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("usage: Rscript code/R/run_spec.R spec.json [B]")
spec <- fromJSON(args[1], simplifyVector = TRUE)
B <- if (length(args) > 1) as.integer(args[2]) else 0L
source("code/R/estimators.R")

raw_root <- path.expand(Sys.getenv("CIE_RAW", "~/cie_raw"))
path <- path.expand(sub("^\\$CIE_RAW", raw_root, spec$data_path))
read_any <- function(p) {
  ext <- tolower(tools::file_ext(p))
  d <- switch(ext,
    dta = tryCatch(haven::read_dta(p), error = function(e) haven::read_dta(p, encoding = "GBK")),
    csv = tryCatch(fread(p, encoding = "UTF-8"), error = function(e) fread(p, encoding = "Latin-1")),
    rds = readRDS(p),
    parquet = arrow::read_parquet(p),
    xlsx = , xls = readxl::read_excel(p),
    stop("unsupported data format: ", ext))
  d <- as.data.table(d)
  for (v in names(d)) if (inherits(d[[v]], "haven_labelled")) d[, (v) := as.vector(d[[v]])]
  d
}
raw <- read_any(path)
if (!is.null(spec$sample_filter) && nzchar(spec$sample_filter)) raw <- raw[eval(parse(text = spec$sample_filter))]

P <- prep_data(raw, spec)
d <- P$d; xt <- P$xt; ctrl <- P$ctrl
is_event <- identical(spec$static_or_event, "event")
if (is_event) {
  S0 <- event_bins(copy(d), spec$event_structure); d <- S0$d[, c("rel", "ebin") := NULL]
}
# raw-unit TWFE, for comparison with the printed coefficient
twfe_raw <- if (!is_event) twfe_static(d, xt, ctrl)$est else NA_real_
y_sd <- standardize_y(d)
st <- design_stats(d)
if (st$n_cohorts < 2) warning("fewer than two adoption cohorts in the sample: not a staggered design")
res <- if (is_event) compare_event(d, xt, ctrl, spec$event_structure)$res else compare_static(d, xt, ctrl, B)
res <- cbind(data.table(paper_id = spec$paper_id, spec_id = spec$spec_id, journal = spec$journal %||% "cie",
                        static_or_event = spec$static_or_event, controls = length(ctrl) > 0), res,
             data.table(twfe_raw = twfe_raw, y_sd = y_sd, published_coef = spec$published_coef %||% NA_real_,
                        published_se = spec$published_se %||% NA_real_, n = st$n, n_units = st$n_units, n_clusters = st$n_clusters,
                        n_cohorts = st$n_cohorts, share_never = st$share_never, share_always = st$share_always,
                        unbalanced = st$unbalanced, repeated_cs = st$repeated_cs, prep_notes = paste(P$notes, collapse = ";"),
                        preferred = isTRUE(spec$preferred), in_abstract_intro = isTRUE(spec$in_abstract_intro),
                        reports_modern_estimator = isTRUE(spec$reports_modern_estimator)))
sub_dir <- if (length(ctrl)) "specs_controls" else "specs"
out <- file.path(Sys.getenv("OUT_DIR", "output"), sub_dir, paste0(spec$paper_id, "__", spec$spec_id, ".csv"))
dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
fwrite(res, out)
print(res[, .(window, twfe, twfe_se, csa, csa_se, bjs, bjs_se, neg_abs, G_eff_twfe, G_eff_bjs, G_eff_csa)], digits = 4)
if (!is_event && !is.na(res$published_coef[1]))
  cat(sprintf("TWFE in raw units %.6g vs published %.6g (ratio %.4f)\n", twfe_raw, res$published_coef[1], twfe_raw / res$published_coef[1]))
cat("->", out, "\n")
