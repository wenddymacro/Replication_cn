clear all
set more off
adopath ++ "../output/local_ado"
log using "../output/software_and_pretrend.log", text replace
display "Stata version: " c(stata_version)
foreach cmd in reghdfe ftools ivreg2 ivreghdfe bdiff acreg event_plot eventstudyinteract coefplot bacondecomp did_multiplegt_old {
which `cmd'
}
adopath ++ "../output/csdid_legacy"
which csdid
which drdid
estimates use "../output/A5_1.ster"
test pre4 pre3 pre2
file open pretest using "../output/pretrend_joint_test.txt", write replace
file write pretest "F=" (r(F)) " p=" (r(p)) _n
file close pretest
display "COMPLETE_audit"
log close
