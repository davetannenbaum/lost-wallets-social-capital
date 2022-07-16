** ---------------------------------------------------------------------
** Data Wrangling
** ---------------------------------------------------------------------

** Clear workspace and set current directory
** Note: You will need to change to your current working directory
** ------------------------------------------------
version 16.1
frames reset
snapshot erase _all
cd "~/Github/lost-wallets-social-capital/data/" 

** Load Integrated Values Survey (WVS/EVS combined) data set
** Note that due to size constraints we have restricted the data set to the relevant variables and countries for our analysis
** ------------------------------------------------
use "IVS.dta", clear

** Reverse code civic capital measures
** ------------------------------------------------
foreach var of varlist civic* { 
	replace `var' = 11 - `var'
}

** Append Kenya data
** ------------------------------------------------
append using "Kenya.dta"

** Add country-level variables
** ------------------------------------------------
* placeholder for UAE
set obs `=_N+1'
replace Country = "UAE" if Country == ""

* add Falk et al. Global Preference data
merge m:1 Country using "gps_honesty.dta"
rename trust GPS_trust
rename altruism GPS_altruism
rename posrecip GPS_posrecip
drop if _merge == 2
drop _merge

* add Enke MFQ data
merge m:1 Country using "moral_values_honesty.dta"
rename values_uniform MFQ_genmorality
revrs MFQ_genmorality, replace
drop if _merge == 2
drop _merge

* add government efficiency data
merge m:1 Country using "hall_jones_honesty.dta"
drop if _merge == 2
drop _merge

* add world bank governance indicators
merge m:1 Country using "wgidataset2017.dta"
drop if _merge == 2
drop _merge

* add Government Letter Grade data
merge m:1 Country using "letter_grading.dta"
drop _merge

* fix country codes
replace isocode = "DNK" if Country == "Denmark"
replace isocode = "MYS" if Country == "Malaysia"
replace isocode = "NZL" if Country == "New Zealand"
replace isocode = "NOR" if Country == "Norway"

* add country GDP data from 2017 Penn World Tables
merge m:1 isocode using "pwt91 2017.dta"
drop if _merge == 2
drop _merge
gen log_gdp = ln(rgdpna/pop)
gen log_tfp = ln(ctfp)

* add World Risk Poll data (survey measures of people returning a lost item)
merge m:1 Country using "world risk poll.dta"
drop if _merge == 2
drop _merge

** duplicate dataset
** ------------------------------------------------
frame rename default predictors1
frame copy predictors1 predictors2
frame copy predictors1 predictors3

** standardize country-level predictors (unrestricted data set)
** ------------------------------------------------
frame change predictors1
collapse general_trust general_morality MFQ_genmorality civic1 civic2 civic3 GPS_trust GPS_posrecip GPS_altruism stranger1 stranger2 log_gdp log_tfp gee letter_grading trust_justmet trust_others general_fair general_fair2, by(Country)
pca civic1 civic2 civic3, components(1) // civic norms
predict civic_cooperation, score
foreach var of varlist general_trust general_morality MFQ_genmorality civic_cooperation GPS_trust GPS_posrecip GPS_altruism stranger1 stranger2 trust_justmet trust_others general_fair general_fair2 { 
	ereplace `var' = std(`var')
}
lab var general_trust "Generalized trust"
lab var general_morality "Generalized Morality"
lab var MFQ_genmorality "Universal Moral Values"
lab var civic_cooperation "Civic Cooperation Norms"
lab var GPS_trust "Trust (GPS)"
lab var GPS_posrecip "Positive Reciprocity (GPS)"
lab var GPS_altruism "Altruism (GPS)"
lab var stranger1 "Return Lost Item"

** standardize country-level predictors (restricted data set to more closely approximate lost wallet sample)
** ------------------------------------------------
frame change predictors2
keep if (inlist(employment_status,1,2,3) | inlist(kenya_employment,2,3) | inlist(Country,"UAE")) // employment is full-time, part-time, or self-employed
keep if (inlist(city_size1,7,8)) | (inlist(city_size2,4,5)) | (inlist(city_size3,4,5) | inlist(kenya_urban,1) | inlist(Country,"Israel","UAE")) //  urban or city size greater than 100K (note: Israelis were not asked about city size, and UAE isn't part of the WVS/EVS)
collapse general_trust general_morality MFQ_genmorality civic1 civic2 civic3 GPS_trust GPS_posrecip GPS_altruism stranger1 stranger2 log_gdp log_tfp gee letter_grading trust_justmet trust_others general_fair general_fair2, by(Country)

pca civic1 civic2 civic3, components(1) // civic norms
predict civic_cooperation, score
foreach var of varlist general_trust general_morality MFQ_genmorality civic_cooperation GPS_trust GPS_posrecip GPS_altruism stranger1 stranger2 trust_justmet trust_others general_fair general_fair2 { 
	ereplace `var' = std(`var')
}
lab var general_trust "Generalized trust (WVS)"
lab var general_morality "Generalized Morality (WVS)"
lab var MFQ_genmorality "Universal Moral Values (MFQ)"
lab var civic_cooperation "Civic norms (WVS)"
lab var GPS_trust "Trust (GPS)"
lab var GPS_posrecip "Positive Reciprocity (GPS)"
lab var GPS_altruism "Altruism (GPS)"
lab var stranger1 "Return lost item (WRS)"

** standardize country-level predictors (using only most proximal wave of WVS/EVS)
** ------------------------------------------------
frame change predictors3
drop if inlist(Country,"Argentina") & wvs_wave != 6
drop if inlist(Country,"Australia") & wvs_wave != 7
drop if inlist(Country,"Brazil") & wvs_wave != 6
drop if inlist(Country,"Canada") & wvs_wave != 5
drop if inlist(Country,"Chile") & wvs_wave != 7
drop if inlist(Country,"China") & wvs_wave != 6
drop if inlist(Country,"Croatia") & evs_wave != 5
drop if inlist(Country,"Czech Republic") & evs_wave != 5
drop if inlist(Country,"Denmark") & evs_wave != 5
drop if inlist(Country,"France") & evs_wave != 5
drop if inlist(Country,"Germany") & wvs_wave != 6
drop if inlist(Country,"Ghana") & wvs_wave != 6
drop if inlist(Country,"Greece") & wvs_wave != 7
drop if inlist(Country,"India") & wvs_wave != 6
drop if inlist(Country,"Indonesia") & wvs_wave != 7
drop if inlist(Country,"Israel") & wvs_wave != 4
drop if inlist(Country,"Italy") & evs_wave != 5
drop if inlist(Country,"Kazakhstan") & wvs_wave != 7
drop if inlist(Country,"Malaysia") & wvs_wave != 7
drop if inlist(Country,"Mexico") & wvs_wave != 7
drop if inlist(Country,"Morocco") & wvs_wave != 6
drop if inlist(Country,"Netherlands") & wvs_wave != 6
drop if inlist(Country,"New Zealand") & wvs_wave != 7
drop if inlist(Country,"Norway") & evs_wave != 5
drop if inlist(Country,"Peru") & wvs_wave != 7
drop if inlist(Country,"Poland") & wvs_wave != 6
drop if inlist(Country,"Portugal") & evs_wave != 5
drop if inlist(Country,"Romania") & wvs_wave != 6
drop if inlist(Country,"Russia") & wvs_wave != 7
drop if inlist(Country,"Serbia") & wvs_wave != 7
drop if inlist(Country,"South Africa") & wvs_wave != 6 
drop if inlist(Country,"Spain") & evs_wave != 5
drop if inlist(Country,"Sweden") & evs_wave != 5 
drop if inlist(Country,"Switzerland") & evs_wave != 5
drop if inlist(Country,"Thailand") & wvs_wave != 7
drop if inlist(Country,"Turkey") & wvs_wave != 6
drop if inlist(Country,"UK") & evs_wave != 5
drop if inlist(Country,"USA") & wvs_wave != 7
collapse general_trust general_morality MFQ_genmorality civic1 civic2 civic3 GPS_trust GPS_posrecip GPS_altruism stranger1 stranger2 log_gdp log_tfp gee letter_grading trust_justmet trust_others general_fair general_fair2, by(Country)
pca civic1 civic2 civic3, components(1) // civic norms
predict civic_cooperation, score
foreach var of varlist general_trust general_morality MFQ_genmorality civic_cooperation GPS_trust GPS_posrecip GPS_altruism stranger1 stranger2 trust_justmet trust_others general_fair general_fair2 { 
	ereplace `var' = std(`var')
}
lab var general_trust "Generalized trust"
lab var general_morality "Generalized Morality"
lab var MFQ_genmorality "Universal Moral Values"
lab var civic_cooperation "Civic Cooperation Norms"
lab var GPS_trust "Trust (GPS)"
lab var GPS_posrecip "Positive Reciprocity (GPS)"
lab var GPS_altruism "Altruism (GPS)"
lab var stranger1 "Return Lost Item"

** load and merge with behavioral data (unrestricted sample)
** ------------------------------------------------
frame create data1
frame change data1
use "behavioral data.dta"
frlink m:1 Country, frame(predictors1)
frget general_trust general_morality MFQ_genmorality civic_cooperation GPS_trust GPS_posrecip GPS_altruism stranger1 stranger2 log_gdp log_tfp gee letter_grading trust_justmet trust_others general_fair general_fair2, from(predictors1)

** load and merge with behavioral data (restricted sample)
** ------------------------------------------------
frame create data2
frame change data2
use "behavioral data.dta"
frlink m:1 Country, frame(predictors2)
frget general_trust general_morality MFQ_genmorality civic_cooperation GPS_trust GPS_posrecip GPS_altruism stranger1 stranger2 log_gdp log_tfp gee letter_grading trust_justmet trust_others general_fair general_fair2, from(predictors2)

** load and merge with behavioral data (most proximal wave of WVS/EVS)
** ------------------------------------------------
frame create data3
frame change data3
use "behavioral data.dta"
frlink m:1 Country, frame(predictors3)
frget general_trust general_morality MFQ_genmorality civic_cooperation GPS_trust GPS_posrecip GPS_altruism stranger1 stranger2 log_gdp log_tfp gee letter_grading trust_justmet trust_others general_fair general_fair2, from(predictors3)

** final data frames
** -------------------------------------------
frame rename data3 data5
frame rename data2 data3
frame copy data1 data2
frame copy data3 data4
frame copy data5 data6

// data1: unrestricted sample (individual-level)
frame change data1
rename c_GES_email GES_email
drop c_*
rename response wallets

// data2: unrestricted sample (country-level)
frame change data2
drop c_*
rename response wallets
collapse wallets log_gdp log_tfp gee letter_grading general_trust general_morality MFQ_genmorality civic_cooperation GPS_trust GPS_posrecip GPS_altruism stranger1 trust_others trust_justmet general_fair general_fair2, by(country Country)

// data3: restricted sample (individual-level)
frame change data3
drop c_*
rename response wallets

// data4: restricted sample (country-level)
frame change data4
drop c_*
rename response wallets
collapse wallets log_gdp log_tfp gee letter_grading general_trust general_morality MFQ_genmorality civic_cooperation GPS_trust GPS_posrecip GPS_altruism stranger1 trust_others trust_justmet general_fair general_fair2, by(country Country)

// data5: sample using most proximate EVS/WVS wave (individual-level)
frame change data5
rename c_GES_email GES_email
drop c_*
rename response wallets

// data6: sample using most proximate EVS/WVS wave (country-level)
frame change data6
drop c_*
rename response wallets
collapse wallets log_gdp log_tfp gee letter_grading general_trust general_morality MFQ_genmorality civic_cooperation GPS_trust GPS_posrecip GPS_altruism stranger1 trust_others trust_justmet general_fair general_fair2, by(country Country)


// setting graph style (requires `grstyle' package)
grstyle clear
grstyle init newscheme, replace
grstyle color background white
grstyle color major_grid white
grstyle graphsize x 3
grstyle graphsize y 4
grstyle yesno legend_force_nodraw yes
grstyle color p1markline none
grstyle color p1markfill black%50
grstyle color p2markline none
grstyle color p2markfill black
grstyle color p2label black
grstyle color p2lineplot black
grstyle color p3lineplot black
grstyle symbolsize p medlarge
grstyle gsize axis_title_gap small
grstyle color heading black
grstyle gsize heading large
grstyle gsize axis_title medium
grstyle gsize tick zero
grstyle clockdir title_position 12

// taking snapshots of data
frame change data1
snapshot save
frame change data2
snapshot save
frame change data3
snapshot save
frame change data4
snapshot save
frame change data5
snapshot save
frame change data6
snapshot save

** ---------------------------------------------------------------------
** Analyses Reported in Main Paper
** ---------------------------------------------------------------------

** Figure 1: Wallet Reporting Rates and Dishonesty
** -------------------------------------------
frame change data1
snapshot restore 1
keep if Country == "USA"
merge m:1 city using "corruption_usa.dta"
pca r_CFS_eitcbunching_rate r_SIM_convictions_ppe, components(1)
predict index_usa, score
ereplace index_usa = std(index_usa)
collapse (mean) wallet index_usa, by(city)
pwcorr wallet index_usa, obs
twoway (scatter wallet index_usa) (lfit wallet index_usa), ///
		title("{bf: USA}") ///
		xtitle("Index of Dishonest Behavior") ///
		ytitle("Wallet Reporting Rate (%)") ///
		ylabel(0(20)100, angle(horizontal)) ///
		text(8 2 "{it:r} = -.370", place(w) size(medlarge)) ///
		text(3 1.8 "{it:N} = 24", place(w) size(medlarge)) ///
		name(w1, replace)

snapshot restore 1
keep if Country == "Italy"
merge m:1 city using "corruption_italy.dta"
rename corruption_index golden_picci
generate tv_TaxEvasion = .
replace tv_TaxEvasion = 75.741867 if City == "Bari"
replace tv_TaxEvasion = 67.609756 if City == "Bologna"
replace tv_TaxEvasion = 41.82111 if City == "Catania"
replace tv_TaxEvasion = 69.881958 if City == "Firenze"
replace tv_TaxEvasion = 77.650955 if City == "Genova"
replace tv_TaxEvasion = 60.016186 if City == "Messina"
replace tv_TaxEvasion = 60.305145 if City == "Milano"
replace tv_TaxEvasion = 38.30178 if City == "Napoli"
replace tv_TaxEvasion = 63.72583 if City == "Padova"
replace tv_TaxEvasion = 44.61322 if City == "Palermo"
replace tv_TaxEvasion = 72.778252 if City == "Roma"
replace tv_TaxEvasion = 73.931519 if City == "Taranto"
replace tv_TaxEvasion = 64.474731 if City == "Torino"
replace tv_TaxEvasion = 69.651314 if City == "Trieste"
replace tv_TaxEvasion = 73.845474 if City == "Venezia"
replace tv_TaxEvasion = 66.68821 if City == "Verona"
revrs tv_TaxEvasion
revrs golden_picci
pca revtv_TaxEvasion rap_nr revgolden_picci, components(1)
predict index_italy, score
ereplace index_italy = std(index_italy)
collapse (mean) wallet index_italy, by(city)
pwcorr wallet index_italy, obs
twoway (scatter wallet index_italy) (lfit wallet index_italy), ///
		title("{bf: Italy}") ///
		xtitle("Index of Dishonest Behavior") ///
		ytitle("") ///
		ylabel(0(20)100, angle(horizontal)) ///
		text(8 2 "{it:r} = -.686", place(w) size(medlarge)) ///
		text(3 1.8 "{it:N} = 16", place(w) size(medlarge)) ///
		name(w2, replace)

graph combine w1 w2, xsize(5) ysize(4) cols(2)
graph export figure1.pdf, replace

** Figure 2: Coverage of Lost Wallet Data
** (requires `spmap' package)
** -------------------------------------------
frame change data1
snapshot restore 1
use "https://www.stathelp.se/data/GIS/idfile.dta", clear
gen sampled = 0
replace sampled = 1 if inlist(country_id,37,67,19,66,72,110,154,157,158,76,77,7,164,37,39,56,169,82,121,40,177,3,90,91,185,186,30,17,21,190,11,198,8,96,5,6,49,99,207,101,20)
spmap sampled using "coord_mercator_world.dta", ///
	id(na_id_world) ///
	fcolor(gs14 ebblue) ///
	osize(vvthin vvthin vvthin vvthin) ///
	ndsize(vvthin) ///
	legend(off)

** Figure 3: Wallet Reporting Rates and Measures of Social Capital
** -------------------------------------------
frame change data1
snapshot restore 1
grstyle clockdir title_position 11
frames change data2
pwcorr  wallet general_trust, obs
twoway 	(scatter wallet general_trust) (lfit wallet general_trust), ///
		title("{bf: A}") ///
		xtitle("Generalized Trust", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.604", place(w)) ///
		text(88 -1 "{it:N} = 39", place(w)) ///
		nodraw ///
		name(g1, replace)

pwcorr 	wallet GPS_trust, obs
twoway 	(scatter wallet GPS_trust) (lfit wallet GPS_trust), ///
		title("{bf: B}") ///
		xtitle("GPS Trust", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.024", place(w)) ///
		text(88 -1 "{it:N} = 36", place(w)) ///
		nodraw ///
		name(g2, replace)

pwcorr 	wallet general_morality, obs
twoway 	(scatter wallet general_morality) (lfit wallet general_morality), ///
		title("{bf: C}") ///
		xtitle("Generalized Morality", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.612", place(w)) ///
		text(88 -1 "{it:N} = 38", place(w)) ///
		nodraw ///
		name(g3, replace)
		
pwcorr 	wallet MFQ_genmorality, obs
twoway 	(scatter wallet MFQ_genmorality) (lfit wallet MFQ_genmorality), ///
		title("{bf: D}") ///
		xtitle("Universal Moral Values", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.461", place(w)) ///
		text(88 -1 "{it:N} = 35", place(w)) ///
		nodraw ///
		name(g4, replace)

pwcorr 	wallet civic_cooperation, obs
twoway 	(scatter wallet civic_cooperation) (lfit wallet civic_cooperation), ///
		title("{bf: E}") ///
		xtitle("Civic Cooperation Norms", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.392", place(w)) ///
		text(88 -1 "{it:N} = 37", place(w)) ///
		nodraw ///
		name(g5, replace)

pwcorr 	wallet GPS_posrecip, obs
twoway 	(scatter wallet GPS_posrecip) (lfit wallet GPS_posrecip), ///
		title("{bf: F}") ///
		xtitle("Positive Reciprocity (GPS)", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.050", place(w)) ///
		text(88 -1 "{it:N} = 36", place(w)) ///
		nodraw ///
		name(g6, replace)

pwcorr 	wallet GPS_altruism, obs
twoway 	(scatter wallet GPS_altruism) (lfit wallet GPS_altruism), ///
		title("{bf: G}") ///
		xtitle("Altruism (GPS)", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = -.214", place(w)) ///
		text(88 -1 "{it:N} = 36", place(w)) ///
		nodraw ///
		name(g7, replace)

pwcorr  wallet stranger1, obs
twoway 	(scatter wallet stranger1) (lfit wallet stranger1), ///
		title("{bf: H}") ///
		xtitle("Return Lost Item", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.645", place(w)) ///
		text(88 -1 "{it:N} = 39", place(w)) ///
		nodraw ///
		name(g8, replace)
		
graph combine g1 g2 g3 g4 g5 g6 g7 g8, xsize(6) ysize(4) cols(4)
graph export figure3.pdf, replace

** OLS Coefficients for Survey Measures and Wallet Reporting Rates
** -------------------------------------------
frame change data1
snapshot restore 1
generate var_name = ""
generate coefficient = .
generate stderr = .
generate dof = .
generate p = .
local i = 1
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
	replace var_name = "`:var l `var''" in `i' 
	regress wallets `var' i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
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
qqvalue p, method(simes) qvalue(p_FDR) svalue(s) rvalue(r) rank(rank)
format coefficient stderr p_FDR %9.3f
list var_name coefficient stderr N_countries p_FDR, sep(8)

** Table 2: Predictive Value of Wallet Reporting Rates
** -------------------------------------------
frame change data2
snapshot restore 2
ereplace wallet = std(wallet)
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
	estimates drop _all
	quietly eststo: regress log_gdp `var', robust
	quietly eststo: regress log_gdp `var' wallets, robust
	quietly eststo: regress log_tfp `var', robust
	quietly eststo: regress log_tfp `var' wallets, robust
	quietly eststo: regress gee `var', robust
	quietly eststo: regress gee `var' wallets, robust
	quietly eststo: regress letter_grading `var', robust
	quietly eststo: regress letter_grading `var' wallets, robust
	esttab est1 est2 est3 est4 est5 est6 est7 est8, drop(_cons) r2(3) aux(se 3)
}

** Table 2 FDR adjusted p-values
** -------------------------------------------
frame change data2
snapshot restore 2
ereplace wallet = std(wallet)
local i = 1
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
    tempfile tf`i'
    parmby "regress log_gdp `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress log_gdp `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress log_tfp `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress log_tfp `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress gee `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress gee `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress letter_grading `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress letter_grading `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'
}
drop _all
forvalues i = 1/64 {
    append using `"`tf`i''"'
}
drop if parm == "_cons"
qqvalue p, method(simes) qvalue(p_FDR)
list idnum parm estimate stderr dof t p_FDR, sep(3)

** Dominance Analysis (requires `domin' package)
** -------------------------------------------
frame change data2
snapshot restore 2
ereplace wallet = std(wallet)
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
	domin log_gdp wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
	domin log_tfp wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
	domin gee wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
	domin letter_grading wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
}


** ---------------------------------------------------------------------
** Analyses Reported in Online Appendix
** ---------------------------------------------------------------------

** Section 3. Robustness Checks on Lost Wallet Data
** -------------------------------------------

* Legal Regulations for Lost Property (analysis 1)
frame change data1
snapshot restore 1
keep if Country == "USA"
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond i.r_PL_propertylaw, cluster(city)

* Legal Regulations for Lost Property (analysis 2)
frame change data1
snapshot restore 1
keep if Country == "USA"
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
predict uncorrected, residual
summarize wallets
replace uncorrected = uncorrected + r(mean)
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond i.r_PL_propertylaw, cluster(city)
predict corrected, residual
summarize wallets
replace corrected = corrected + r(mean)
collapse corrected uncorrected, by(city) 
spearman uncorrected corrected

* Cross-Country Variation in Legal Traditions (analysis 1)
frame change data1
snapshot restore 1
merge m:1 Country using "juriglobe.dta"
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond i.FEE_civil_law, cluster(city)

* Cross-Country Variation in Legal Traditions (analysis 2)
frame change data1
snapshot restore 1
merge m:1 Country using "juriglobe.dta"
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
predict uncorrected, residual
summarize wallets
replace uncorrected = uncorrected + r(mean)
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond i.FEE_civil_law, cluster(city)
predict corrected, residual
summarize wallets
replace corrected = corrected + r(mean)
collapse corrected uncorrected, by(country) 
spearman uncorrected corrected

* Fear of Detection: Security Cameras (analysis 1)
frame change data1
snapshot restore 1
areg wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond i.security_cam, absorb(city) robust

* Fear of Detection: Security Cameras (analysis 2)
frame change data1
snapshot restore 1
drop if missing(security_cam)
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
predict uncorrected, residual
summarize wallets
replace uncorrected = uncorrected + r(mean)
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond i.security_cam, cluster(city)
predict corrected, residual
summarize wallets
replace corrected = corrected + r(mean)
preserve
collapse corrected uncorrected, by(country) 
spearman uncorrected corrected
restore
collapse corrected uncorrected, by(city) 
spearman uncorrected corrected

* Fear of Detection: Other Witnesses (analysis 1)
frame change data1
snapshot restore 1
areg wallets i.male i.above40 i.computer i.institution i.cond i.coworkers i.other_bystanders, absorb(city) robust

* Fear of Detection: Other Witnesses (analysis 2)
frame change data1
snapshot restore 1
drop if missing(other_bystanders)
drop if missing(coworkers)
regress wallets i.male i.above40 i.computer i.institution i.cond, cluster(city)
predict uncorrected, residual
summarize wallets
replace uncorrected = uncorrected + r(mean)
regress wallets i.male i.above40 i.computer i.institution i.cond i.coworkers i.other_bystanders, cluster(city)
predict corrected, residual
summarize wallets
replace corrected = corrected + r(mean)
preserve
collapse corrected uncorrected, by(country) 
spearman uncorrected corrected
restore
collapse corrected uncorrected, by(city) 
spearman uncorrected corrected

* Differences in Email Usage (analysis 1)
frame change data1
snapshot restore 1
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.cond, cluster(city) robust
predict full_sample, residual
summarize wallets
replace full_sample = full_sample + r(mean)
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.cond if institution == 3, cluster(city) robust
predict hotels, residual
summarize wallets
replace hotels = hotels + r(mean)
replace hotels = . if institution ~= 3
collapse full_sample hotels, by(country) 
spearman full_sample hotels

* Differences in Email Usage (analysis 2)
frame change data1
snapshot restore 1
drop if missing(GES_email)
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
predict uncorrected, residual
summarize wallets
replace uncorrected = uncorrected + r(mean)
regress wallets i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond c.GES_email, cluster(city)
predict corrected, residual
summarize wallets
replace corrected = corrected + r(mean)
collapse corrected uncorrected, by(country) 
spearman uncorrected corrected

* Returning the Wallet but Pocketing the Money 
frame change data1
snapshot restore 1
keep if inlist(cond,0,1)
separate wallets, by(cond)
collapse wallets0 wallets1, by(country)
spearman wallets0 wallets1
use "pickup data.dta", clear 
summarize amount_ratio if country=="Switzerland"
summarize amount_ratio if country=="Czech Republic"
ranksum amount_ratio, by(country)

** Section 4. External Validation of Wallet Reporting Rates
** -------------------------------------------

* Table A1: Wallet Reporting Rates and Dishonesty (USA)
frame change data1
snapshot restore 1
keep if Country == "USA"
merge m:1 city using "corruption_usa.dta"
pca r_CFS_eitcbunching_rate r_SIM_convictions_ppe, components(1)
predict index_usa, score
ereplace index_usa = std(index_usa)
ereplace r_CFS_eitcbunching_rate = std(r_CFS_eitcbunching_rate)
ereplace r_SIM_convictions_ppe = std(r_SIM_convictions_ppe)

regress wallets index_usa i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress wallets r_CFS_eitcbunching_rate i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress wallets r_SIM_convictions_ppe i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)

* Table A2: Wallet Reporting Rates and Dishonesty (Italy)
frame change data1
snapshot restore 1
keep if Country == "Italy"
merge m:1 city using "corruption_italy.dta"
rename corruption_index golden_picci
generate tv_TaxEvasion = .
replace tv_TaxEvasion = 75.741867 if City == "Bari"
replace tv_TaxEvasion = 67.609756 if City == "Bologna"
replace tv_TaxEvasion = 41.82111 if City == "Catania"
replace tv_TaxEvasion = 69.881958 if City == "Firenze"
replace tv_TaxEvasion = 77.650955 if City == "Genova"
replace tv_TaxEvasion = 60.016186 if City == "Messina"
replace tv_TaxEvasion = 60.305145 if City == "Milano"
replace tv_TaxEvasion = 38.30178 if City == "Napoli"
replace tv_TaxEvasion = 63.72583 if City == "Padova"
replace tv_TaxEvasion = 44.61322 if City == "Palermo"
replace tv_TaxEvasion = 72.778252 if City == "Roma"
replace tv_TaxEvasion = 73.931519 if City == "Taranto"
replace tv_TaxEvasion = 64.474731 if City == "Torino"
replace tv_TaxEvasion = 69.651314 if City == "Trieste"
replace tv_TaxEvasion = 73.845474 if City == "Venezia"
replace tv_TaxEvasion = 66.68821 if City == "Verona"
revrs tv_TaxEvasion
revrs golden_picci
pca revtv_TaxEvasion rap_nr revgolden_picci, components(1)
predict index_italy, score
ereplace index_italy = std(index_italy)
ereplace revtv_TaxEvasion = std(revtv_TaxEvasion)
ereplace rap_nr = std(rap_nr)
ereplace revgolden_picci = std(revgolden_picci)

regress wallets index_italy i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress wallets revtv_TaxEvasion i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress wallets rap_nr i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
regress wallets revgolden_picci i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)

** Section 5. Pairwise Correlations Between Survey Measures of Social Capital
** -------------------------------------------

* Table A3: Country-level Pairwise Correlations
frame change data2
snapshot restore 2
pwcorr general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism

** Section 6. Survey Measures and Wallet Reporting Rates
** -------------------------------------------

* Table A4: Survey Measures and Wallet Reporting Rates
frame change data1
snapshot restore 1
generate var_name = ""
generate coefficient = .
generate stderr = .
generate dof = .
generate p = .
local i = 1
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
	replace var_name = "`:var l `var''" in `i' 
	regress wallets `var' i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
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
qqvalue p, method(simes) qvalue(p_FDR) svalue(s) rvalue(r) rank(rank)
format coefficient stderr p_FDR %9.3f
list var_name coefficient stderr N_countries p_FDR, sep(8)

* Figure A2: OLS vs. Probit Estimates (requires `coefplot' package)
frame change data1
snapshot restore 1
grstyle graphsize x 6
grstyle graphsize y 3
grstyle yesno legend_force_nodraw no
frame change data1
snapshot restore 1
eststo clear
gen wallets2 = wallets
replace wallets2 = 1 if wallets2 == 100
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
	regress wallets `var' i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
	eststo: margins, dydx(`var') post
	replace `var' = `var' * .01 
	probit wallets2 `var' i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
	eststo: margins, dydx(`var') post
}
graph drop _all
coefplot (est1, offset(.1) mlabposition(12)) (est2, offset(-.1) mfcolor(white) mlabposition(6)) ///
	(est3, offset(.1) mlabposition(12)) (est4, offset(-.1) mfcolor(white) mlabposition(6)) ///
	(est5, offset(.1) mlabposition(12)) (est6, offset(-.1) mfcolor(white) mlabposition(6)) ///
	(est7, offset(.1) mlabposition(12)) (est8, offset(-.1) mfcolor(white) mlabposition(6)), ///
	keep(general_trust GPS_trust general_morality MFQ_genmorality) order(general_trust GPS_trust general_morality MFQ_genmorality) mcolor(black) ciopts(color(black)) xline(0, lcolor(black) lpattern(dash)) xscale(range(-10 15)) xlabel(-10(5)15, format(%9.0f)) legend(order(2 "OLS estimates" 4 "Probit estimates")) mlabel format(%9.1f) mlabgap(*2) mlabcolor(black) name(g1) nodraw
coefplot (est9, offset(.1)  mlabposition(12)) (est10, offset(-.1) mfcolor(white) mlabposition(6)) ///
	(est11, offset(.1) mlabposition(12)) (est12, offset(-.1) mfcolor(white) mlabposition(6)) ///
	(est13, offset(.1) mlabposition(12)) (est14, offset(-.1) mfcolor(white) mlabposition(6)) ///
	(est15, offset(.1) mlabposition(12)) (est16, offset(-.1) mfcolor(white) mlabposition(6)), ///
	keep(civic_cooperation GPS_posrecip GPS_altruism stranger1) order(civic_cooperation GPS_posrecip GPS_altruism stranger1) mcolor(black) ciopts(color(black)) xline(0, lcolor(black) lpattern(dash)) xscale(range(-10 15)) xlabel(-10(5)15, format(%9.0f)) legend(off) mlabel format(%9.1f) mlabgap(*2) mlabcolor(black) name(g2) nodraw
grc1leg g1 g2, legendfrom(g1)

* Figure A3: OLS Estimates With Controls vs. Without Controls (requires `coefplot' package)
frame change data1
snapshot restore 1
grstyle graphsize x 6
grstyle graphsize y 3
grstyle yesno legend_force_nodraw no
eststo clear
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
	eststo: regress wallets `var' i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
	eststo: regress wallets `var', cluster(country)	
}
graph drop _all
coefplot (est1, offset(.1) mlabposition(12)) (est2, offset(-.1) mfcolor(white) mlabposition(6)) ///
		(est3, offset(.1) mlabposition(12)) (est4, offset(-.1) mfcolor(white) mlabposition(6)) ///
		(est5, offset(.1) mlabposition(12)) (est6, offset(-.1) mfcolor(white) mlabposition(6)) ///
		(est7, offset(.1) mlabposition(12)) (est8, offset(-.1) mfcolor(white) mlabposition(6)), ///
		keep(general_trust GPS_trust general_morality MFQ_genmorality) order(general_trust GPS_trust general_morality MFQ_genmorality) mcolor(black) ciopts(color(black)) xline(0, lcolor(black) lpattern(dash)) xscale(range(-10 15)) xlabel(-10(5)15, format(%9.0f)) legend(order(2 "including controls" 4 "excluding controls")) mlabel format(%9.1f) mlabgap(*2) mlabcolor(black) name(g1) nodraw
coefplot (est9, offset(.1)  mlabposition(12)) (est10, offset(-.1) mfcolor(white) mlabposition(6)) ///
		(est11, offset(.1) mlabposition(12)) (est12, offset(-.1) mfcolor(white) mlabposition(6)) ///
		(est13, offset(.1) mlabposition(12)) (est14, offset(-.1) mfcolor(white) mlabposition(6)) ///
		(est15, offset(.1) mlabposition(12)) (est16, offset(-.1) mfcolor(white) mlabposition(6)), ///
		keep(civic_cooperation GPS_posrecip GPS_altruism stranger1) order(civic_cooperation GPS_posrecip GPS_altruism stranger1) mcolor(black) ciopts(color(black)) xline(0, lcolor(black) lpattern(dash)) xscale(range(-10 15)) xlabel(-10(5)15, format(%9.0f)) legend(off) mlabel format(%9.1f) mlabgap(*2) mlabcolor(black) name(g2) nodraw
grc1leg g1 g2, legendfrom(g1)

** Section 7. Robustness Test: Most Proximate EVS/WVS Wave For Each Country
** -------------------------------------------

* Figure A4: Wallet Reporting Rates and Measures of Social Capital (All Waves vs One Wave)
frame change data2
snapshot restore 2
xframeappend data6, generate(restricted)
grstyle graphsize x 3
grstyle graphsize y 4
grstyle clockdir title_position 12

preserve
keep if restricted == 0
pwcorr  wallet general_trust, obs
twoway 	(scatter wallet general_trust) (lfit wallet stranger1), ///
		title("{bf: All Waves}") ///
		xtitle("Generalized Trust", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.604", place(w)) ///
		text(91 -1.7 "{it:N} = 39", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g1, replace)
restore
preserve
keep if restricted == 1
pwcorr  wallet general_trust, obs
twoway 	(scatter wallet general_trust) (lfit wallet stranger1), ///
		title("{bf: One Wave}") ///
		xtitle("Generalized Trust", size(medsmall)) ///
		ytitle("") ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.629", place(w)) ///
		text(91 -1.7 "{it:N} = 39", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g2, replace)
restore
preserve
keep if restricted == 0
pwcorr  wallet general_morality, obs
twoway 	(scatter wallet general_morality) (lfit wallet stranger1), ///
		title("") ///
		xtitle("Return Lost Item", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.612", place(w)) ///
		text(91 -1.7 "{it:N} = 38", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g3, replace)
restore
preserve
keep if restricted == 1
pwcorr  wallet general_morality, obs
twoway 	(scatter wallet general_morality) (lfit wallet stranger1), ///
		title("") ///
		xtitle("Return Lost Item", size(medsmall)) ///
		ytitle("") ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.661", place(w)) ///
		text(91 -1.7 "{it:N} = 38", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g4, replace)
restore
preserve
keep if restricted == 0
pwcorr  wallet civic_cooperation, obs
twoway 	(scatter wallet civic_cooperation) (lfit wallet stranger1), ///
		title("") ///
		xtitle("Civic Cooperation Norms", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.392", place(w)) ///
		text(91 -1.7 "{it:N} = 37", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g5, replace)
restore
preserve
keep if restricted == 1
pwcorr  wallet civic_cooperation, obs
twoway 	(scatter wallet civic_cooperation) (lfit wallet stranger1), ///
		title("") ///
		xtitle("Civic Cooperation Norms", size(medsmall)) ///
		ytitle("") ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.367", place(w)) ///
		text(91 -1.7 "{it:N} = 37", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g6, replace)
restore
graph combine g1 g2 g3 g4 g5 g6, xsize(3.5) ysize(6) cols(2)

* Table A5: Predictive Value of Wallet Reporting Rates (One Wave Per Country)
frame change data6
snapshot restore 6
ereplace wallet = std(wallet)
foreach var of varlist general_trust general_morality civic_cooperation {
	estimates drop _all
	quietly eststo: regress log_gdp `var', robust
	quietly eststo: regress log_gdp `var' wallets, robust
	quietly eststo: regress log_tfp `var', robust
	quietly eststo: regress log_tfp `var' wallets, robust
	quietly eststo: regress gee `var', robust
	quietly eststo: regress gee `var' wallets, robust
	quietly eststo: regress letter_grading `var', robust
	quietly eststo: regress letter_grading `var' wallets, robust
	esttab est1 est2 est3 est4 est5 est6 est7 est8, drop(_cons) r2(3) aux(se 3)
}

* Table A5 FDR correction
frame change data6
snapshot restore 6
ereplace wallet = std(wallet)
local i = 1
foreach var of varlist general_trust general_morality civic_cooperation {
    tempfile tf`i'
    parmby "regress log_gdp `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress log_gdp `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress log_tfp `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress log_tfp `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress gee `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress gee `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress letter_grading `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress letter_grading `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'
}
drop _all
forvalues i = 1/24 {
    append using `"`tf`i''"'
}
drop if parm == "_cons"
qqvalue p, method(simes) qvalue(p_FDR)
list idnum parm estimate stderr dof t p_FDR, sep(3)

** Section 8. Robustness Test: Restricting EVS/WVS Respondents to More Closely Match Lost Wallet Data
** -------------------------------------------

* OLS Coefficients (Restricted Sample)
frame change data3
snapshot restore 3
generate var_name = ""
generate coefficient = .
generate stderr = .
generate dof = .
generate p = .
local i = 1
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
	replace var_name = "`:var l `var''" in `i' 
	regress wallets `var' i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
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
qqvalue p, method(simes) qvalue(p_FDR) svalue(s) rvalue(r) rank(rank)
list var_name coefficient stderr N_countries p_FDR, sep(8)

* Figure A5: Wallet Reporting Rates and Measures of Social Capital (Full vs Restricted Sample). Requires `xframeappend' package
frame change data2
snapshot restore 2
xframeappend data4, generate(restricted)
grstyle graphsize x 3
grstyle graphsize y 4
grstyle clockdir title_position 12

preserve
keep if restricted == 0
pwcorr  wallet general_trust, obs
twoway 	(scatter wallet general_trust) (lfit wallet stranger1), ///
		title("{bf: Full Sample}") ///
		xtitle("Generalized Trust", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.604", place(w)) ///
		text(91 -1.7 "{it:N} = 39", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g1, replace)
restore
preserve
keep if restricted == 1
pwcorr  wallet general_trust, obs
twoway 	(scatter wallet general_trust) (lfit wallet stranger1), ///
		title("{bf: Restricted Sample}") ///
		xtitle("Generalized Trust", size(medsmall)) ///
		ytitle("") ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.643", place(w)) ///
		text(91 -1.7 "{it:N} = 39", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g2, replace)
restore
preserve
keep if restricted == 0
pwcorr  wallet general_morality, obs
twoway 	(scatter wallet general_morality) (lfit wallet stranger1), ///
		title("") ///
		xtitle("Return Lost Item", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.612", place(w)) ///
		text(91 -1.7 "{it:N} = 38", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g3, replace)
restore
preserve
keep if restricted == 1
pwcorr  wallet general_morality, obs
twoway 	(scatter wallet general_morality) (lfit wallet stranger1), ///
		title("") ///
		xtitle("Return Lost Item", size(medsmall)) ///
		ytitle("") ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.630", place(w)) ///
		text(91 -1.7 "{it:N} = 38", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g4, replace)
restore
preserve
keep if restricted == 0
pwcorr  wallet civic_cooperation, obs
twoway 	(scatter wallet civic_cooperation) (lfit wallet stranger1), ///
		title("") ///
		xtitle("Civic Cooperation Norms", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.392", place(w)) ///
		text(91 -1.7 "{it:N} = 37", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g5, replace)
restore
preserve
keep if restricted == 1
pwcorr  wallet civic_cooperation, obs
twoway 	(scatter wallet civic_cooperation) (lfit wallet stranger1), ///
		title("") ///
		xtitle("Civic Cooperation Norms", size(medsmall)) ///
		ytitle("") ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -1.15 "{it:r} = 0.191", place(w)) ///
		text(91 -1.7 "{it:N} = 37", place(w)) ///
		legend(off) ///
		nodraw ///
		name(g6, replace)
restore
graph combine g1 g2 g3 g4 g5 g6, xsize(3.5) ysize(6) cols(2)

* Table A6: Predictive Value of Wallet Reporting Rates (Restricted Sample)
frame change data4
snapshot restore 4
ereplace wallet = std(wallet)
foreach var of varlist general_trust general_morality civic_cooperation {
	estimates drop _all
	quietly eststo: regress log_gdp `var', robust
	quietly eststo: regress log_gdp `var' wallets, robust
	quietly eststo: regress log_tfp `var', robust
	quietly eststo: regress log_tfp `var' wallets, robust
	quietly eststo: regress gee `var', robust
	quietly eststo: regress gee `var' wallets, robust
	quietly eststo: regress letter_grading `var', robust
	quietly eststo: regress letter_grading `var' wallets, robust
	esttab est1 est2 est3 est4 est5 est6 est7 est8, drop(_cons) r2(3) aux(se 3)
}

* Table A6 FDR correction
frame change data4
snapshot restore 4
ereplace wallet = std(wallet)
local i = 1
foreach var of varlist general_trust general_morality civic_cooperation {
    tempfile tf`i'
    parmby "regress log_gdp `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress log_gdp `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress log_tfp `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress log_tfp `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress gee `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress gee `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress letter_grading `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress letter_grading `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'
}
drop _all
forvalues i = 1/24 {
    append using `"`tf`i''"'
}
drop if parm == "_cons"
qqvalue p, method(simes) qvalue(p_FDR)
list idnum parm estimate stderr dof t p_FDR, sep(3)

** Section 9. Robustness Test: Excluding China and Kazakhstan
** -------------------------------------------

* Figure A6: Wallet Reporting Rates and Measures of Social Capital (Excluding China and Kazakhstan)
frames change data2
snapshot restore 2
grstyle graphsize x 3
grstyle graphsize y 4
grstyle yesno legend_force_nodraw yes
grstyle clockdir title_position 11

drop if inlist(Country,"China","Kazakhstan")
pwcorr  wallet general_trust, obs
twoway 	(scatter wallet general_trust) (lfit wallet general_trust), ///
		title("{bf: A}") ///
		xtitle("Generalized Trust", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.757", place(w)) ///
		text(88 -1 "{it:N} = 37", place(w)) ///
		nodraw ///
		name(g1, replace)

pwcorr 	wallet GPS_trust, obs
twoway 	(scatter wallet GPS_trust) (lfit wallet GPS_trust), ///
		title("{bf: B}") ///
		xtitle("GPS Trust", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.177", place(w)) ///
		text(88 -1 "{it:N} = 34", place(w)) ///
		nodraw ///
		name(g2, replace)

pwcorr 	wallet general_morality, obs
twoway 	(scatter wallet general_morality) (lfit wallet general_morality), ///
		title("{bf: C}") ///
		xtitle("Generalized Morality", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.565", place(w)) ///
		text(88 -1 "{it:N} = 36", place(w)) ///
		nodraw ///
		name(g3, replace)
		
pwcorr 	wallet MFQ_genmorality, obs
twoway 	(scatter wallet MFQ_genmorality) (lfit wallet MFQ_genmorality), ///
		title("{bf: D}") ///
		xtitle("Universal Moral Values", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.390", place(w)) ///
		text(88 -1 "{it:N} = 34", place(w)) ///
		nodraw ///
		name(g4, replace)

pwcorr 	wallet civic_cooperation, obs
twoway 	(scatter wallet civic_cooperation) (lfit wallet civic_cooperation), ///
		title("{bf: E}") ///
		xtitle("Civic Cooperation Norms", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.390", place(w)) ///
		text(88 -1 "{it:N} = 35", place(w)) ///
		nodraw ///
		name(g5, replace)

pwcorr 	wallet GPS_posrecip, obs
twoway 	(scatter wallet GPS_posrecip) (lfit wallet GPS_posrecip), ///
		title("{bf: F}") ///
		xtitle("Positive Reciprocity (GPS)", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.183", place(w)) ///
		text(88 -1 "{it:N} = 34", place(w)) ///
		nodraw ///
		name(g6, replace)

pwcorr 	wallet GPS_altruism, obs
twoway 	(scatter wallet GPS_altruism) (lfit wallet GPS_altruism), ///
		title("{bf: G}") ///
		xtitle("Altruism (GPS)", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = -.112", place(w)) ///
		text(88 -1 "{it:N} = 34", place(w)) ///
		nodraw ///
		name(g7, replace)

pwcorr  wallet stranger1, obs
twoway 	(scatter wallet stranger1) (lfit wallet stranger1), ///
		title("{bf: H}") ///
		xtitle("Return Lost Item", size(medsmall)) ///
		ytitle("Wallet Reporting Rate (%)", size(medsmall)) ///
		ylabel(0(20)100, angle(horizontal)) ///
		xlabel(-3(1)3) ///
		text(98 -.2 "{it:r} = 0.706", place(w)) ///
		text(88 -1 "{it:N} = 37", place(w)) ///
		nodraw ///
		name(g8, replace)
graph combine g1 g2 g3 g4 g5 g6 g7 g8, xsize(6) ysize(4) cols(4)

* Table A7: Predictive Value of Wallet Reporting Rates (Excluding China and Kazakhstan)
frames change data2
snapshot restore 2
keep if ~inlist(Country,"China","Kazakhstan")
ereplace wallet = std(wallet)
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
	estimates drop _all
	quietly eststo: regress log_gdp `var', robust
	quietly eststo: regress log_gdp `var' wallets, robust
	quietly eststo: regress log_tfp `var', robust
	quietly eststo: regress log_tfp `var' wallets, robust
	quietly eststo: regress gee `var', robust
	quietly eststo: regress gee `var' wallets, robust
	quietly eststo: regress letter_grading `var', robust
	quietly eststo: regress letter_grading `var' wallets, robust
	esttab est1 est2 est3 est4 est5 est6 est7 est8, drop(_cons) r2(3) aux(se 3)
}

* Table A7 FDR adjusted p-values
frames change data2
snapshot restore 2
keep if ~inlist(Country,"China","Kazakhstan")
ereplace wallet = std(wallet)
local i = 1
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
    tempfile tf`i'
    parmby "regress log_gdp `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress log_gdp `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress log_tfp `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress log_tfp `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress gee `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress gee `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'

    tempfile tf`i'
    parmby "regress letter_grading `var', robust", lab saving(`"`tf`i''"',replace) idn(1)
    local `i++'
    tempfile tf`i'
    parmby "regress letter_grading `var' wallets, robust", lab saving(`"`tf`i''"',replace) idn(2)
    regress log_gdp `var' wallets, robust
    local `i++'
}
drop _all
forvalues i = 1/64 {
    append using `"`tf`i''"'
}
drop if parm == "_cons"
qqvalue p, method(simes) qvalue(p_FDR)
list idnum parm estimate stderr dof t p_FDR, sep(3)

** Section 10. Correcting for Measurement Error
** -------------------------------------------
* uncorrected correlation
frame change data1
snapshot restore 1
drop if trust_justmet == .
keep if inlist(cond,0,1)
collapse general_trust wallet, by(country)
pwcorr general_trust wallet, obs

* ORIV correlation
snapshot restore 1
keep if inlist(cond,0,1)
separate wallets, by(cond) generate(response)
collapse general_trust trust_justmet response0 response1, by(country)
ereplace general_trust = std(general_trust)
ereplace trust_justmet = std(trust_justmet)
ereplace response0 = std(response0)
ereplace response1 = std(response1)
gen id =_n
expand 4
sort id

gen replicant = mod(_n,4)
gen dv = response0 if inlist(replicant,0,1)
replace dv = response1 if inlist(replicant,2,3)
gen mainVar = general_trust if inlist(replicant,0,2)
replace mainVar = trust_justmet if inlist(replicant,1,3)
gen instrument = trust_justmet if inlist(replicant,0,3)
replace instrument = general_trust if inlist(replicant,1,2)
forvalues x = 1/4 {
	gen constant`x' = replicant == `x'-1
}
ivregress 2sls dv (mainVar = instrument) constant*, cluster(id) nocons 
local correctedCoefficient = _b[mainVar]
corr response0 response1 if replicant == 0, cov
local correctedYVar = r(cov_12)
corr general_trust trust_justmet if replicant == 0, cov 
local correctedXVar = r(cov_12)
local correctedCorrelation = `correctedCoefficient' * sqrt(`correctedXVar'/`correctedYVar')
display "The ORIV Correlation is: `correctedCorrelation'"

** Section 11. Dominance Analysis (requires `domin' package)
** -------------------------------------------
frame change data2
snapshot restore 2
ereplace wallet = std(wallet)
foreach var of varlist general_trust GPS_trust general_morality MFQ_genmorality civic_cooperation GPS_posrecip GPS_altruism stranger1 {
	domin log_gdp wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
	domin log_tfp wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
	domin gee wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
	domin letter_grading wallets `var', reg(reg,robust) fitstat(e(r2)) noconditional nocomplete
}