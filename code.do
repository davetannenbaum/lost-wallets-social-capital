** Loading Data
** -------------------------------------------
// set current directory
cd "~/GitHub/lost-wallets-social-capital/"

// snapshot 1
snapshot erase _all
use data, replace
snapshot save

// snapshot 2
snapshot restore 1
rename response wallets
foreach v of var * {
	local l`v' : variable label `v'
	if `"`l`v''"' == "" {
		local l`v' "`v'"
	}
}
collapse wallets log_gdp log_tfp log_labor_productivity social_infrastructure GADP open_index letter_grading vae pve gee rqe rle cce trust_general respect MFQ_genmorality index_guiso membership_groups GPS_trust GPS_altruism GPS_posrecip, by(country)
ereplace wallets = std(wallets)
foreach v of var * {
	label var `v' "`l`v''"
}
snapshot save


** External Validation
** -------------------------------------------
// USA
snapshot restore 1
cd tables
keep if Country == "USA"
ereplace r_CFS_eitcbunching_rate = std(r_CFS_eitcbunching_rate)
ereplace r_SIM_convictions_ppe = std(r_SIM_convictions_ppe)

regress response index_usa i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress response r_CFS_eitcbunching_rate i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress response r_SIM_convictions_ppe i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)

// Italy
snapshot restore 1
keep if Country == "Italy"
ereplace revtv_TaxEvasion = std(revtv_TaxEvasion)
ereplace rap_nr = std(rap_nr)
ereplace revgolden_picci = std(revgolden_picci)

regress response index_italy i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress response revtv_TaxEvasion i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress response rap_nr i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress response revgolden_picci i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)


** Validating Survey Measures of Social Capital
** -------------------------------------------
// OLS estimates with baseline controls
snapshot restore 1
generate var_name = ""
generate coefficient = .
generate stderr = .
generate dof = .
generate p = .
local i = 1
local controls "i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond"
foreach var of varlist trust_general respect MFQ_genmorality index_guiso GPS_trust GPS_posrecip GPS_altruism membership_groups {
	replace var_name = "`:var l `var''" in `i' 
	regress response `var' `controls', cluster(country) 
	if _rc == 0 { 
		quietly lincom _b[`var'] 
		quietly replace coefficient = r(estimate) in `i' 
		quietly replace stderr = r(se) in `i' 
		quietly replace dof = r(df) in `i'
		quietly test `var' = 0 
		quietly replace p = r(p) in `i' 
	} 
	local `i++' 
}
keep var_name coefficient stderr dof p
drop if missing(var_name)
generate N_countries = dof + 1 
qqvalue p, method(simes) qvalue(p_FDR) // FDR correction
list var_name coefficient stderr dof p_FDR, sep(8)


// OLS estimates without baseline controls (online appendix)
snapshot restore 1
generate var_name = ""
generate coefficient = .
generate stderr = .
generate dof = .
generate p = .
local i = 1
foreach var of varlist trust_general respect MFQ_genmorality index_guiso GPS_trust GPS_posrecip GPS_altruism membership_groups {
    replace var_name = "`:var l `var''" in `i' 
    regress response `var', cluster(country) 
    if _rc == 0 { 
        quietly lincom _b[`var'] 
        quietly replace coefficient = r(estimate) in `i' 
        quietly replace stderr = r(se) in `i' 
        quietly replace dof = r(df) in `i'
        quietly test `var' = 0 
        quietly replace p = r(p) in `i' 
    } 
    local `i++' 
}
keep var_name coefficient stderr dof p
drop if missing(var_name)
generate N_countries = dof + 1 
qqvalue p, method(simes) qvalue(p_FDR) // FDR correction
list var_name coefficient stderr dof p_FDR, sep(8)

// Probit estimates (online appendix)
snapshot restore 1
generate var_name = ""
generate coefficient = .
generate stderr = .
generate dof = .
generate p = .
local i = 1
foreach var of varlist trust_general respect MFQ_genmorality index_guiso GPS_trust GPS_posrecip GPS_altruism membership_groups {
    replace var_name = "`:var l `var''" in `i' 
    quietly probit response `var' `controls', cluster(country) 
    if _rc == 0 { 
        quietly margins, dydx(`var') post
        quietly lincom _b[`var'] 
        quietly replace coefficient = (r(estimate) * 100) in `i' 
        quietly replace stderr = (r(se) * 100) in `i' 
        quietly test `var' = 0 
        quietly replace p = r(p) in `i' 
    } 
    local `i++' 
}
keep var_name coefficient stderr p
drop if missing(var_name)
qqvalue p, method(simes) qvalue(p_FDR) // FDR correction
list var_name coefficient stderr p_FDR, sep(8)


** Measurement error correction
** -------------------------------------------
// uncorrected correlation
snapshot restore 1
keep if trust_justmet != .
keep if inlist(cond,0,1)
collapse trust_general response, by(country)
pwcorr trust_general response

// ORIV correlation
snapshot restore 1
keep if trust_justmet != .
keep if inlist(cond,0,1)
separate response, by(cond)
collapse trust_general trust_justmet response0 response1, by(country)
ereplace trust_general = std(trust_general)
ereplace trust_justmet = std(trust_justmet)
ereplace response0 = std(response0)
ereplace response1 = std(response1)
gen id =_n
expand 4
sort id

gen replicant = mod(_n,4)
gen dv = response0 if inlist(replicant,0,1)
replace dv = response1 if inlist(replicant,2,3)
gen mainVar = trust_general if inlist(replicant,0,2)
replace mainVar = trust_justmet if inlist(replicant,1,3)
gen instrument = trust_justmet if inlist(replicant,0,3)
replace instrument = trust_general if inlist(replicant,1,2)
forvalues x = 1/4 {
	gen constant`x' = replicant == `x'-1
}
ivregress 2sls dv (mainVar = instrument) constant*, cluster(id) nocons 
local correctedCoefficient = _b[mainVar]
corr response0 response1 if replicant == 0, cov
local correctedYVar = r(cov_12)
corr trust_general trust_justmet if replicant == 0, cov 
local correctedXVar = r(cov_12)
local correctedCorrelation = `correctedCoefficient' * sqrt(`correctedXVar'/`correctedYVar')
display "The ORIV Correlation is: `correctedCorrelation'"

// uncorrected correlation (adjusting for baseline controls)
snapshot restore 1
keep if trust_justmet != .
keep if inlist(cond,0,1)
regress response i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
predict response_resid, resid
sum response
replace response_resid = response_resid + r(mean)
collapse trust_general response_resid, by(country)
pwcorr trust_general response_resid

// ORIV correlation (adjusting for baseline controls)
snapshot restore 1
separate response, by(cond)
regress response0 i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
predict response_resid0, resid
sum response0
replace response_resid0 = response_resid0 + r(mean)
regress response1 i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
predict response_resid1, resid
sum response1
replace response_resid1 = response_resid1 + r(mean)
collapse trust_general trust_justmet response_resid0 response_resid1, by(country)
ereplace trust_general = std(trust_general)
ereplace trust_justmet = std(trust_justmet)
ereplace response_resid0 = std(response_resid0)
ereplace response_resid1 = std(response_resid1)
gen id =_n
expand 4
sort id

gen replicant = mod(_n,4)
gen dv = response_resid0 if inlist(replicant,0,1)
replace dv = response_resid1 if inlist(replicant,2,3)
gen mainVar = trust_general if inlist(replicant,0,2)
replace mainVar = trust_justmet if inlist(replicant,1,3)
gen instrument = trust_justmet if inlist(replicant,0,3)
replace instrument = trust_general if inlist(replicant,1,2)
forvalues x = 1/4 {
	gen constant`x' = replicant == `x'-1
}
ivregress 2sls dv (mainVar = instrument) constant*, cluster(id) nocons 
local correctedCoefficient = _b[mainVar]
corr response_resid0 response_resid1 if replicant == 0, cov
local correctedYVar = r(cov_12)
corr trust_general trust_justmet if replicant == 0, cov 
local correctedXVar = r(cov_12)
local correctedCorrelation = `correctedCoefficient' * sqrt(`correctedXVar'/`correctedYVar')
pwcorr trust* response*
display "The ORIV Correlation is: `correctedCorrelation'"


** Using wallet reporting rates to predict economic and institutional performance
** -------------------------------------------
snapshot restore 2
foreach var of varlist trust_general respect MFQ_genmorality index_guiso GPS_trust GPS_posrecip GPS_altruism membership_groups {
    regress log_gdp `var', robust
    regress log_gdp `var' wallets, robust
    regress log_tfp `var', robust
    regress log_tfp `var' wallets, robust
    regress gee `var', robust
    regress gee `var' wallets, robust
    regress letter_grading `var', robust
    regress letter_grading `var' wallets, robust
}

** Dominance Analysis (requires 'domin' package)
** -------------------------------------------
snapshot restore 2
foreach var of varlist trust_general respect MFQ_genmorality index_guiso GPS_trust GPS_altruism GPS_posrecip membership_groups {
	domin log_gdp wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
	domin log_tfp wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
	domin gee wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
	domin letter_grading wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
}
