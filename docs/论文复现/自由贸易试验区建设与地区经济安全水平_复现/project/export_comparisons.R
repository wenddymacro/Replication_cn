# Only export the upstream comparison function's individual control rows;
# source code and numerical formulas remain unchanged.
source('code/R/analysis.R')
dir.create('diagnostics',showWarnings=FALSE)
fwrite(to_long(load_dir('specs_controls')),'diagnostics/controls_comparisons.csv')
