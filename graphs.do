** Loading Data
** -------------------------------------------
// set current directory
cd "~/GitHub/lost-wallets-social-capital/"

// snapshot 1
snapshot erase _all
use data, clear
label var trust_general "Generalized Trust"
label var respect "Generalized Morality"
label var MFQ_genmorality "Universal Moral Values"
label var index_guiso "Civic Cooperation"
label var membership_groups "Group Membership"
snapshot save

// setting graph style (requires 'grstyle' package)
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
grstyle set color black%50 : axisline
grstyle gsize tick zero

// Figure 1
grstyle clockdir title_position 12
snapshot restore 1
keep if Country == "USA"
regress response i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
predict response_reg, resid
sum response
replace response_reg = response_reg + r(mean)
collapse (mean) response_reg index_usa, by(city City)
pwcorr response_reg index_usa
twoway 	(scatter response_reg index_usa) ///
		(lfit response_reg index_usa), title("{bf: USA}") xtitle("Dishonesty Index") ytitle("Wallet Reporting Rate (%)") ylabel(0(20)100, angle(horizontal)) text(5 2 "{it:r} = -.378", place(w) size(medlarge)) name(w1, replace)

snapshot restore 1
keep if Country == "Italy"
// replace index_italy = index_italy - 3.5
regress response i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(city)
predict response_reg, resid
sum response
replace response_reg = response_reg + r(mean)
collapse (mean) response_reg index_italy, by(city City)
pwcorr response_reg index_italy
twoway 	(scatter response_reg index_italy) ///
		(lfit response_reg index_italy), title("{bf: Italy}") xtitle("Dishonesty Index") ytitle("Wallet Reporting Rate (%)") ylabel(0(20)100, angle(horizontal)) text(5 2 "{it:r} = -.711", place(w) size(medlarge)) name(w2, replace)
graph combine w1 w2, xsize(5) ysize(4) cols(2)
graph export figure1.pdf, replace

// Figure 2
grstyle clockdir title_position 11
snapshot restore 1
graph drop _all

regress response i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond, cluster(country)
predict response2, resid
sum response
replace response2 = response2 + r(mean)

collapse (mean) response2 trust_general respect MFQ_genmorality index_guiso membership_groups GPS_trust GPS_altruism GPS_posrecip, by(country Country)

pwcorr response2 trust_general
twoway 	(scatter response2 trust_general) /// 
		(lfit response2 trust_general), ///
		title("{bf: A}") xtitle("Generalized Trust") ytitle("Wallet Reporting Rate (%)") ylabel(0(20)100, angle(horizontal)) xlabel(-3(1)3) text(5 3.3 "{it:r} = 0.558", place(w)) nodraw name(g1)

pwcorr response2 respect
twoway 	(scatter response2 respect) ///
		(lfit response2 respect), ///
		title("{bf: B}") xtitle("Generalized Morality") ytitle("") ylabel(0(20)100, angle(horizontal)) xlabel(-3(1)3) text(5 3.3 "{it:r} = 0.526", place(w)) nodraw name(g2)

pwcorr response2 MFQ_genmorality
twoway 	(scatter response2 MFQ_genmorality) ///
		(lfit response2 MFQ_genmorality), ///
		title("{bf: C}") xtitle("Universal Moral Values") ytitle("") ylabel(0(20)100, angle(horizontal)) xlabel(-3(1)3) text(5 3.3 "{it:r} = 0.475", place(w)) nodraw name(g3)

pwcorr response2 index_guiso
twoway 	(scatter response2 index_guiso) ///
		(lfit response2 index_guiso), ///
		title("{bf: D}") xtitle("Norms of Civic Cooperation") ytitle("") ylabel(0(20)100, angle(horizontal)) xlabel(-3(1)3) text(5 3.3 "{it:r} = 0.330", place(w)) nodraw name(g4)

pwcorr response2 GPS_trust
twoway 	(scatter response2 GPS_trust) ///
		(lfit response2 GPS_trust), ///
		title("{bf: E}") xtitle("Trust (GPS)") ytitle("Wallet Reporting Rate (%)") ylabel(0(20)100, angle(horizontal)) xlabel(-3(1)3) text(5 3.3 "{it:r} = -.038", place(w)) nodraw name(g5)

pwcorr response2 GPS_posrecip
twoway 	(scatter response2 GPS_posrecip) ///
		(lfit response2 GPS_posrecip), ///
		title("{bf: F}") xtitle("Positive Reciprocity (GPS)") ytitle("") ylabel(0(20)100, angle(horizontal)) xlabel(-3(1)3) text(5 3.3 "{it:r} = 0.032", place(w)) nodraw name(g6)

pwcorr response2 GPS_altruism
twoway 	(scatter response2 GPS_altruism) ///
		(lfit response2 GPS_altruism), ///
		title("{bf: G}") xtitle("Altruism (GPS)") ylabel(0(20)100, angle(horizontal)) xlabel(-3(1)3) text(5 3.3 "{it:r} = -.248", place(w)) nodraw name(g7)

pwcorr response2 membership_groups
twoway 	(scatter response2 membership_groups) ///
		(lfit response2 membership_groups), ///
		title("{bf: H}") xtitle("Group Membership") ytitle("") ylabel(0(20)100, angle(horizontal)) xlabel(-3(1)3) text(5 3.3 "{it:r} = 0.276", place(w)) nodraw name(g8)

graph combine g1 g2 g3 g4 g5 g6 g7 g8, xsize(6) ysize(4) cols(4)
graph export figure2.pdf, replace


// Coeff Plot (OLS with vs without controls)
grstyle graphsize x 6
grstyle graphsize y 3
grstyle yesno legend_force_nodraw no
snapshot restore 1
local controls "i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond"
eststo clear
foreach var of varlist trust_general respect MFQ_genmorality index_guiso GPS_trust GPS_posrecip GPS_altruism membership_groups {
	eststo: regress response `var' `controls', cluster(country)
	eststo: regress response `var', cluster(country)	
}

graph drop _all
coefplot 	(est1, offset(.1) mlabposition(12)) (est2, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est3, offset(.1) mlabposition(12)) (est4, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est5, offset(.1) mlabposition(12)) (est6, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est7, offset(.1) mlabposition(12)) (est8, offset(-.1) mfcolor(white) mlabposition(6)), ///
			keep(trust_general respect MFQ_genmorality index_guiso) order(trust_general respect MFQ_genmorality index_guiso) mcolor(black) ciopts(color(black)) xline(0, lcolor(black) lpattern(dash)) xscale(range(-10 15)) xlabel(-10(5)15, format(%9.0f)) legend(order(2 "including controls" 4 "not including controls")) mlabel format(%9.1f) mlabgap(*2) mlabcolor(black) name(g1) nodraw
coefplot 	(est9, offset(.1)  mlabposition(12)) (est10, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est11, offset(.1) mlabposition(12)) (est12, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est13, offset(.1) mlabposition(12)) (est14, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est15, offset(.1) mlabposition(12)) (est16, offset(-.1) mfcolor(white) mlabposition(6)), ///
			keep(GPS_trust GPS_posrecip GPS_altruism membership_groups) order(GPS_trust GPS_posrecip GPS_altruism membership_groups) mcolor(black) ciopts(color(black)) xline(0, lcolor(black) lpattern(dash)) xscale(range(-10 15)) xlabel(-10(5)15, format(%9.0f)) legend(off) mlabel format(%9.1f) mlabgap(*2) mlabcolor(black) name(g2) nodraw
grc1leg g1 g2, legendfrom(g1)


// Coeff Plot (OLS vs Probit)
grstyle graphsize x 6
grstyle graphsize y 3
grstyle yesno legend_force_nodraw no
snapshot restore 1
local controls "i.male i.above40 i.computer i.coworkers i.other_bystanders i.institution i.cond"
eststo clear
gen response2 = response
replace response2 = 1 if response2 == 100
foreach var of varlist trust_general respect MFQ_genmorality index_guiso GPS_trust GPS_posrecip GPS_altruism membership_groups {
	regress response `var' `controls', cluster(country)
	eststo: margins, dydx(`var') post
	replace `var' = `var' * .01 
	probit response2 `var' `controls', cluster(country)
	eststo: margins, dydx(`var') post
}

graph drop _all
coefplot 	(est1, offset(.1) mlabposition(12)) (est2, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est3, offset(.1) mlabposition(12)) (est4, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est5, offset(.1) mlabposition(12)) (est6, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est7, offset(.1) mlabposition(12)) (est8, offset(-.1) mfcolor(white) mlabposition(6)), ///
			keep(trust_general respect MFQ_genmorality index_guiso) order(trust_general respect MFQ_genmorality index_guiso) mcolor(black) ciopts(color(black)) xline(0, lcolor(black) lpattern(dash)) xscale(range(-10 15)) xlabel(-10(5)15, format(%9.0f)) legend(order(2 "OLS estimates" 4 "Probit estimates")) mlabel format(%9.1f) mlabgap(*2) mlabcolor(black) name(g1) nodraw
coefplot 	(est9, offset(.1)  mlabposition(12)) (est10, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est11, offset(.1) mlabposition(12)) (est12, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est13, offset(.1) mlabposition(12)) (est14, offset(-.1) mfcolor(white) mlabposition(6)) ///
			(est15, offset(.1) mlabposition(12)) (est16, offset(-.1) mfcolor(white) mlabposition(6)), ///
			keep(GPS_trust GPS_posrecip GPS_altruism membership_groups) order(GPS_trust GPS_posrecip GPS_altruism membership_groups) mcolor(black) ciopts(color(black)) xline(0, lcolor(black) lpattern(dash)) xscale(range(-10 15)) xlabel(-10(5)15, format(%9.0f)) legend(off) mlabel format(%9.1f) mlabgap(*2) mlabcolor(black) name(g2) nodraw
grc1leg g1 g2, legendfrom(g1)