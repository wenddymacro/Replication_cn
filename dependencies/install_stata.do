* Run from repository root. Default: audit only; no installation.
* Optional install-current is NOT a version-locked reproduction environment.
version 14
args mode
if "`mode'" != "" & "`mode'" != "install-current" {
    display as error "Usage: do dependencies/install_stata.do [install-current]"
    exit 198
}
local packages moremata ftools reghdfe ranktest ivreg2 ivreghdfe drdid csdid acreg avar bacondecomp bdiff did_multiplegt did_multiplegt_dyn did_multiplegt_old did_multiplegt_stat event_plot eventstudyinteract hdfe require xtabond2 xtbalance
foreach package of local packages {
    capture noisily which `package'
}
if "`mode'" == "" {
    display as text "Audit only. Existing research dependencies are preserved."
    exit
}
display as text "Installing CURRENT SSC versions into an isolated directory."
display as text "These versions are not verified against the retained copies."
local target "`c(pwd)'/.local-stata-ado"
local previous "`c(sysdir_plus)'"
capture mkdir "`target'"
net set ado "`target'"
local failures 0
foreach package of local packages {
    capture noisily ssc install `package'
    if _rc {
        local failures = `failures' + 1
        display as error "Installation failed or already present: `package'. Inspect output."
    }
}
net set ado "`previous'"
display as text "SSC attempts with errors: `failures'. No retained files were replaced."
if `failures' > 0 {
    exit 459
}
