**# 代码直接运行 #
**# use 图6_数据.dta #
global cv "Size Lnage Roa Lev Dual Tobin Digital RD LnPatcum"
local W = 8       
preserve
    keep if !missing(treat)
    capture drop event
    capture drop pt_m*
    capture drop pt_p*
    capture drop pt_0
    gen int event = year - 2015
    label variable event "相对2015年的事件时间"
    keep if inrange(event, -`W', `W')

    local prevars
    local postvars
    local coeflabs

    forvalues k = `W'(-1)2 {

        gen byte pt_m`k' = ///
            treat * (event == -`k')

        label variable pt_m`k' ///
            "Treat × event=-`k'"

        local prevars `prevars' pt_m`k'

        local coeflabs `coeflabs' ///
            pt_m`k' = "-`k'"
    }


    gen byte pt_0 = treat * (event == 0)
    label variable pt_0 ///
        "Treat × event=0"
    local postvars pt_0
    local coeflabs `coeflabs' ///
        pt_0 = "0"

    forvalues k = 1/`W' {

        gen byte pt_p`k' = ///
            treat * (event == `k')

        label variable pt_p`k' ///
            "Treat × event=`k'"

        local postvars `postvars' pt_p`k'

        local coeflabs `coeflabs' ///
            pt_p`k' = "`k'"
    }

    local allvars `prevars' `postvars'

    reghdfe LnPatos ///
        `allvars' ///
        $cv, ///
        absorb( ///
            id ///
            ind2code#year ///
            provincecode#year ///
        ) ///
        vce(cluster ind2code)


    tempname premean
    scalar `premean' = 0
    foreach v of local prevars {

        scalar `premean' = ///
            scalar(`premean') + _b[`v']
    }
    local npre : word count `prevars'
    scalar `premean' = ///
        scalar(`premean') / `npre'
    mata: st_numscalar( ///
        "r(mean)", ///
        st_numscalar("`premean'") ///
    )

    local policyline = `W' - 0.5


    *====================
    * 绘制事前平行趋势图
    *====================
    coefplot, ///
        keep(`allvars') ///
        order(`allvars') ///
        coeflabels(`coeflabs') ///
        transform(*=@-r(mean)) ///
        vertical ///
        levels(95) ///
        yline( ///
            0, ///
            lwidth(vthin) ///
            lpattern(dash) ///
            lcolor(black) ///
        ) ///
        xline( ///
            `policyline', ///
            lwidth(vthin) ///
            lpattern(dash) ///
            lcolor(black) ///
        ) ///
        ytitle( ///
            "政策动态效应估计值", ///
            size(medsmall) ///
        ) ///
        xtitle( ///
            "相对政策时点", ///
            size(medsmall) ///
        ) ///
        addplot( ///
            line @b @at, ///
            lcolor(black) ///
            lwidth(medthin) ///
        ) ///
        ciopts( ///
            recast(rcap) ///
            lpattern(solid) ///
            lcolor(black) ///
            lwidth(vthin) ///
        ) ///
        msymbol(circle_hollow) ///
        mcolor(black) ///
        mfcolor(white) ///
        msize(medium) ///
        xlabel(, labsize(small)) ///
        ylabel(, ///
            labsize(small) ///
            angle(horizontal) ///
        ) ///
        graphregion(color(white)) ///
        plotregion(color(white)) ///
        legend(off) ///
        scheme(s1mono) ///
        name(PT_SIM_graph, replace)
