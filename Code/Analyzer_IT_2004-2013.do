/*******************************************************************************
*                                                                              *
*  NAME:			 Analyzer_IT_2004-2013		             		           *
*																			   *
*																			   *
*  PURPOSE:          Data Analyzer		             		                   *
*                                                                              *
*  OUTLINE:          0 Define locals, directories and packages                 *
*                    1 Import the dataset                         			   *
*                    3 Data Check		                       		      	   *
*                                                                              *
*  REQUIRES: 		 comunali-"".csv						                   *
*                                                                              *
*  OUTPUT:           main_data							                  	   *
*                                                                              *
*                    Last time modified: 10 April 2025 	                       *
*                                                                              *
********************************************************************************


--------------------------------------------------------------------------------
    0   Define locals and directories
------------------------------------------------------------------------------*/



*Macros

local packages 0
global files_path "P:\Thesis_files\Thesis"
global input	"$files_path\Parsed Data"
global output	"$files_path\Out"
global outcomes `" "violenze sessuali" "totale" "furti" "lesioni dolose" "minacce" "ingiurie" "danneggiamenti" "rapine" "'
global measures `" "commessi" "scoperti" "'
global threshold 0.1
*Install packages


if `packages'==1 {
	
	ssc install unique
	ssc install gtools
	ssc install rddensity
	ssc install estout
	ssc install reghdfe
	ssc install ftools
}

cd "$input"




/*------------------------------------------------------------------------------
    0 	McCrary Test Check 
-------------------------------------------------------------------------------*/


use final_database, clear
use final_database_w_civica, clear

				*Final Sample selection
				drop if gender == gender_second
				drop if gender == "U" | gender_second == "U"
				drop if margin_fem==.
	
	rddensity margin_fem if delitto_name=="violenze sessuali"
	*Bene :D
/*------------------------------------------------------------------------------
    1 	Standard Model - Violenze sessuali - 20% Arbitrary threshold
-------------------------------------------------------------------------------*/


use final_database_w_civica, clear


levelsof exhaustive_class, local(outcomes)
				*Final Sample selection
				drop if gender == gender_second
				drop if gender == "U" | gender_second == "U"
				drop if margin_fem==.
				
//				
// 				*Final Sample selection - Civica
// 				drop if dummy_civica==.
// 				*drop if gender == "U" | gender_second == "U"
// 				drop if margin_civica==.
//	
	
	foreach measure in $measures {
		local y "`measure'_pc_x100000"
		foreach outcome in `outcomes' {
				* RDD - No Controls - 20% margin threshold
				

// 					eststo reg1_1: reg `y'  dummy_civica 1.dummy_civica#c.margin_civica c.margin_civica if delitto_name=="`outcome'" & margin_pct<$threshold
					eststo rob1_1: rdrobust `y' margin_fem if exhaustive_class=="`outcome'", covs(elettori frac_female)
					*estadd local year_FE "No"
//				
//				
//				
// 				* RDD - Year FE - 20% margin threshold
//							
// 					eststo reg1_2: reghdfe `y'  dummy_civica 1.dummy_civica#c.margin_civica c.margin_civica if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
// 					estadd local year_FE "Yes"
//					
//				
//				
//				
// 				*RDD - Year FE, number of electors - 20% margin threshold			
// 					eststo reg1_3: reghdfe `y'  dummy_civica 1.dummy_civica#c.margin_fem c.margin_civica elettori if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year) 
// 					estadd local year_FE "Yes"
//				
//				
//				
// 				*RDD - Year FE, number of electors, female fraction - 20% margin threshold
// 					eststo reg1_4: reghdfe `y'  dummy_civica 1.dummy_civica#c.margin_civica c.margin_civica elettori frac_female if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
// 					estadd local year_FE "Yes"
//							
//				
//
//				
 				esttab rob1_1 using "$output/`measure'_`outcome'.tex", stats(N r2 year_FE) star(* 0.10 ** 0.05 *** 0.01) replace se mtitles("RDD" "RDD, year FE" "RDD, year FE controls 1" "RDD, year FE controls 1") title("`outcome'")
			
		}
	
	
	}
	
/*------------------------------------------------------------------------------
    1.2 	Quadratic Model - Violenze sessuali - 20% Arbitrary threshold
-------------------------------------------------------------------------------*/


*use final_database, clear

	
	foreach measure in $measures {
		
		local y "`measure'_pc_x100000"
		foreach outcome in $outcomes {
				* RDD - No Controls - 20% margin threshold
				eststo reg1_1: reg `y'  dummy 1.dummy#c.margin_fem c.margin_fem margin_femSQRD dummyXmargin_femSQRD if delitto_name=="`outcome'" & margin_pct<$threshold
					estadd local year_FE "No"
				
				
				* RDD - Year FE - 20% margin threshold
				eststo reg1_2: reghdfe `y'  dummy 1.dummy#c.margin_fem c.margin_fem margin_femSQRD dummyXmargin_femSQRD  if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
					estadd local year_FE "Yes"
		
					
				
				
				
				*RDD - Year FE, number of electors - 20% margin threshold

					eststo reg1_3: reghdfe `y'  dummy 1.dummy#c.margin_fem c.margin_fem elettori margin_femSQRD dummyXmargin_femSQRD  if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year) 
					estadd local year_FE "Yes"
				
				
				*RDD - Year FE, number of electors, female fraction - 20% margin threshold
				eststo reg1_4: reghdfe `y'  dummy 1.dummy#c.margin_fem c.margin_fem elettori frac_female margin_femSQRD dummyXmargin_femSQRD  if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
					estadd local year_FE "Yes"
				
				

				
				esttab reg1_1 reg1_2 reg1_3 reg1_4 using "$output/`measure'_squared_`outcome'.tex", stats(N r2 year_FE) star(* 0.10 ** 0.05 *** 0.01) replace se mtitles("RDD" "RDD, year FE" "RDD, year FE controls 1" "RDD, year FE controls 1") title("`outcome'")
			
		}
		
	}
	
/*------------------------------------------------------------------------------
    2 	By years from election - Violenze sessuali - 20% Arbitrary threshold
-------------------------------------------------------------------------------*/


	foreach measure in $measures {
		local y "`measure'_pc_x100000"
		foreach outcome in $outcomes {
			* RDD - No Controls - 20% margin threshold
			foreach n in 0 1 2 3 4{
				
				preserve
					local re "reg1_1_year_`n'"
					display "year `n'"
					keep if years_from_last_election == `n' 
					
					eststo `re': reg `y' dummy 1.dummy#c.margin_fem c.margin_fem if delitto_name=="`outcome'" & margin_pct<$threshold
				restore	
			}
				esttab reg1_1_year_0 reg1_1_year_1 reg1_1_year_2 reg1_1_year_3 reg1_1_year_4 using "$output/Het_`measure'_`outcome'_YearsFromElect_1.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles("Year 0" "Year 1" "Year 2" "Year 3" "Year 4") title("`outcome', by years from last election") replace se
			
			
			* RDD - Year FE - 20% margin threshold
			foreach n in 0 1 2 3 4{
				
				preserve
					local re "reg1_1_year_`n'"
					display "year `n'"
					keep if years_from_last_election == `n' 
					eststo `re': reg `y' dummy 1.dummy#c.margin_fem c.margin_fem if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
				restore	
			}
				esttab reg1_1_year_0 reg1_1_year_1 reg1_1_year_2 reg1_1_year_3 reg1_1_year_4 using "$output/Het_`measure'_`outcome'YearsFromElect_2.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles("Year 0" "Year 1" "Year 2" "Year 3" "Year 4") title("`outcome', by years from last election") replace se
			
			*RDD - Year FE, number of electors - 20% margin threshold
				foreach n in 0 1 2 3 4{
				
				preserve
					local re "reg1_1_year_`n'"
					display "year `n'"
					keep if years_from_last_election == `n' 
					eststo `re': reg `y' dummy 1.dummy#c.margin_fem c.margin_fem elettori if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
				restore	
			}
				esttab reg1_1_year_0 reg1_1_year_1 reg1_1_year_2 reg1_1_year_3 reg1_1_year_4 using "$output/Het_`measure'_`outcome'_YearsFromElect_3.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles("Year 0" "Year 1" "Year 2" "Year 3" "Year 4") title("Het_`outcome', by years from last election") replace se
			
			*RDD - Year FE, number of electors, female fraction - 20% margin threshold
			foreach n in 0 1 2 3 4{
				
				preserve
					local re "reg1_1_year_`n'"
					display "year `n'"
					keep if years_from_last_election == `n' 
					eststo `re': reg `y' dummy 1.dummy#c.margin_fem c.margin_fem elettori frac_female if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
				restore	
			}
				esttab reg1_1_year_0 reg1_1_year_1 reg1_1_year_2 reg1_1_year_3 reg1_1_year_4 using "$output/Het_`measure'_`outcome'_YearsFromElect_4.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles("Year 0" "Year 1" "Year 2" "Year 3" "Year 4") title("`outcome', by years from last election") replace se

		}
		
		
	}	
		
	
/*------------------------------------------------------------------------------
    2 	By calendar year
-------------------------------------------------------------------------------*/


	foreach measure in $measures {
		
		local y "`measure'_pc_x100000"
		foreach outcome in $outcomes {
			* RDD - No Controls - 20% margin threshold
			foreach n in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {
				
				preserve
					local re "reg1_1_`n'"
					display "`n'"
					keep if year == `n' 
					
					
					eststo `re': reg `y' dummy 1.dummy#c.margin_fem c.margin_fem if delitto_name=="`outcome'" & margin_pct<$threshold
				restore	
			}
				esttab reg1_1_2004 reg1_1_2005 reg1_1_2006 reg1_1_2007 reg1_1_2008 reg1_1_2009 reg1_1_2010 reg1_1_2011 reg1_1_2012 reg1_1_2013 using "$output/Het_`measure'_`outcome'_Year_1.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles("2004" "2005" "2006" "2007" "2008" "2009" "2010" "2011" "2012" "2013") title("`outcome', by year") replace se
			
			
			* RDD - Year FE - 20% margin threshold
			foreach n in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 {
				
				preserve
					local re "reg1_1_`n'"
					display "`n'"
					keep if year == `n' 
					eststo `re': reg `y' dummy 1.dummy#c.margin_fem c.margin_fem if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
				restore	
			}
				esttab reg1_1_2004 reg1_1_2005 reg1_1_2006 reg1_1_2007 reg1_1_2008 reg1_1_2009 reg1_1_2010 reg1_1_2011 reg1_1_2012 reg1_1_2013 using "$output/Het_`measure'_`outcome'_Year_2.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles("2004" "2005" "2006" "2007" "2008" "2009" "2010" "2011" "2012" "2013") title("`outcome', by year") replace se
			
			*RDD - Year FE, number of electors - 20% margin threshold
				foreach n in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013{
				
				preserve
					local re "reg1_1_`n'"
					display "`n'"
					keep if year == `n' 
					eststo `re': reg `y' dummy 1.dummy#c.margin_fem c.margin_fem elettori if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
				restore	
			}
				esttab reg1_1_2004 reg1_1_2005 reg1_1_2006 reg1_1_2007 reg1_1_2008 reg1_1_2009 reg1_1_2010 reg1_1_2011 reg1_1_2012 reg1_1_2013 using "$output/Het_`measure'_`outcome'_Year_3.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles("2004" "2005" "2006" "2007" "2008" "2009" "2010" "2011" "2012" "2013") title("`outcome', by year") replace se
			
			*RDD - Year FE, number of electors, female fraction - 20% margin threshold
			foreach n in 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013{
				
				preserve
					local re "reg1_1_`n'"
					display "`n'"
					keep if year == `n'  
					eststo `re': reg `y' dummy 1.dummy#c.margin_fem c.margin_fem elettori frac_female if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
				restore	
			}
				esttab reg1_1_2004 reg1_1_2005 reg1_1_2006 reg1_1_2007 reg1_1_2008 reg1_1_2009 reg1_1_2010 reg1_1_2011 reg1_1_2012 reg1_1_2013 using "$output/Het_`measure'_`outcome'_Year_4.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles("2004" "2005" "2006" "2007" "2008" "2009" "2010" "2011" "2012" "2013") title("`outcome', by year") replace se

		}
		
	}
	
	
/*------------------------------------------------------------------------------
    1 	Event Study 
-------------------------------------------------------------------------------*/


use final_database, clear
	
	
	gen treated=0
		replace treated=1 if gender=="F"
		
		
	gsort provincia comune delitto_name year
	bys provincia comune delitto_name: gen cum=sum(treated)
	
	
	replace treated=. if treated==0 & cum>0
		replace cum=. if treated==.
		
	gen treated_year = year if cum==1
		
	bys provincia comune delitto_name: egen treatment_year=max(treated_year)
	bys provincia comune delitto_name: egen always_takers_id=max(cum)
	
	gen timing_treatment = year-treatment_year
	
	levelsof timing_treatment, local(stags)
	
	foreach stag in `stags' {
		if `stag'<0{
			local value=abs(`stag')
			gen b_bef`value'=1 if timing_treatment==`stag'
				replace b_bef`value'=0 if b_bef`value'==.
		}
		
		else {
			local value `stag'
			gen b_aft`value'=1 if timing_treatment==`stag'
				replace b_aft`value'=0 if b_aft`value'==.
		}
		
		
	}
	
	drop b_bef1
	
	
	
	
	
	*Drop always takers
preserve

	*Sample Filters
	drop if treatment_year==2004
	drop if pop_dec_tot<5000


	
foreach measure in $measures {
		local y "`measure'_pc_x100000"
		foreach outcome in $outcomes {			
				
				
				* 	DID - Year Province FE 
							
					eststo reg1_1: reghdfe `y'   b_bef* b_aft* if delitto_name=="`outcome'", absorb(year provincia)
					estadd local year_FE "Yes"
					
				
				
				
				*	DID - Year FE, number of electors - 20% margin threshold			
					eststo reg1_2: reghdfe `y'  b_bef* b_aft* elettori if delitto_name=="`outcome'" , absorb(year provincia)
					estadd local year_FE "Yes"
				
				
				
				*	DID - Year FE, number of electors, female fraction - 20% margin threshold
					eststo reg1_3: reghdfe `y'  b_bef* b_aft* elettori frac_female if delitto_name=="`outcome'" , absorb(year provincia)
					estadd local year_FE "Yes"
							
				

				
				esttab reg1_1 reg1_2 reg1_3 using "$output/DiD_`measure'_`outcome'_popfilter.tex", stats(N r2 year_FE) star(* 0.10 ** 0.05 *** 0.01) replace se mtitles( "DiD, year FE" "DiD, year FE controls 1" "DiD, year FE controls 2" ) title("`outcome'")
				
				
				coefplot reg1_1 reg1_2 reg1_3, keep(b_bef* b_aft*) xtitle("Years (until / after) having a woman as a mayor") ytitle("Estimated Effect") title("Event Study - `outcome' - `measure'") vertical xlabel(, angle(vertical)) yline(0) levels(90)
		graph export "$output/DiD_`measure'_`outcome'_popfilter.pdf", replace
			
		}
	
	
	}
	
restore


/*-------------------------------------------------------------------------------

    1 	New Model
-------------------------------------------------------------------------------*/
use final_database_w_civica, clear

replace scoperti_pc_x100000=0 if scoperti_pc_x100000==.
replace commessi_pc_x100000=0 if commessi_pc_x100000==.

replace exhaustive_class=subinstr(exhaustive_class," ","_",.)
replace exhaustive_class=subinstr(exhaustive_class,"(","",.)
replace exhaustive_class=subinstr(exhaustive_class,")","",.)
replace exhaustive_class=subinstr(exhaustive_class,"trafficking_and_association_crimes","traficking",.)



levelsof exhaustive_class, local(outcomes)
global outcomes `outcomes'
				*Final Sample selection
				drop if gender == gender_second
				drop if gender == "U" | gender_second == "U"
				drop if margin_fem==.
				
	
	foreach measure in $measures {
		local y "`measure'_pc_x100000"
		foreach outcome in `outcomes' {
				* RDD - No Controls - 20% margin threshold
				

// 					eststo reg1_1: reg `y'  dummy_civica 1.dummy_civica#c.margin_civica c.margin_civica if delitto_name=="`outcome'" & margin_pct<$threshold
					eststo `outcome': rdrobust `y' margin_fem if exhaustive_class=="`outcome'", covs(elettori frac_female) & pop_dec_tot
					

		}
	
	
	 		esttab `outcomes' using "$output/`measure'_all_outcomes.tex", stats(N r2 year_FE) star(* 0.10 ** 0.05 *** 0.01) replace se mtitles(`outcomes') title("RDD results")
	
	
	
	
	    * ---- one GRAPH per measure: all outcomes ----
    coefplot `outcomes', ///
        vertical          ///
        drop(_cons)       ///
        xline(0, lpattern(dash)) ///
        xlabel(, angle(45)) ///
        title("RD estimates for `measure'") ///
        subtitle("All exhaustive classes") ///
        ytitle("Effect at cutoff") ///
        xtitle("Outcome")

    graph export "$output/`measure'_all_outcomes.pdf", replace
	
	}
	
	

	
/*------------------------------------------------------------------------------
    2 	 New Outcomes By years from election - All outcomes
-------------------------------------------------------------------------------*/

levelsof exhaustive_class, local(outcomes)
global outcomes `outcomes'

	foreach measure in $measures {
		local y "`measure'_pc_x100000"
		foreach outcome in `outcomes' {
			* RDD - No Controls - 20% margin threshold
			local regs
			foreach n in 0 1 2 3 4{
				
				preserve
					local re "`outcome'_year_`n'"
					display "year `n'"
					keep if years_from_last_election == `n' 
					
					eststo `re': rdrobust `y' margin_fem if exhaustive_class=="`outcome'", covs(elettori frac_female)
				restore
				local regs "`regs' `re'"
			}
				
				esttab `regs' using "$output/Het_`measure'_`outcome'_YearsFromElect_1.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) mtitles("Year 0" "Year 1" "Year 2" "Year 3" "Year 4") title("`outcome', `measure' by years from last election") replace se
	
	
		}
	}
	
	
/*-------------------------------------------------------------------------------

    3 	Heterogeneity analysis - Under 5k pop
-------------------------------------------------------------------------------*/





use final_database_w_civica, clear

replace scoperti_pc_x100000=0 if scoperti_pc_x100000==.
replace commessi_pc_x100000=0 if commessi_pc_x100000==.

replace exhaustive_class=subinstr(exhaustive_class," ","_",.)
replace exhaustive_class=subinstr(exhaustive_class,"(","",.)
replace exhaustive_class=subinstr(exhaustive_class,")","",.)
replace exhaustive_class=subinstr(exhaustive_class,"trafficking_and_association_crimes","traficking",.)



levelsof exhaustive_class, local(outcomes)
global outcomes `outcomes'
				*Final Sample selection
				drop if gender == gender_second
				drop if gender == "U" | gender_second == "U"
				drop if margin_fem==.
				drop if pop_dec_tot<5000 
				
	
	foreach measure in $measures {
		local y "`measure'_pc_x100000"
		foreach outcome in `outcomes' {
				* RDD - No Controls - 20% margin threshold
				

// 					eststo reg1_1: reg `y'  dummy_civica 1.dummy_civica#c.margin_civica c.margin_civica if delitto_name=="`outcome'" & margin_pct<$threshold
					eststo `outcome': rdrobust `y' margin_fem if exhaustive_class=="`outcome'", covs(elettori frac_female)
					

		}
	
	
	 		esttab `outcomes' using "$output/`measure'_under5k_all_outcomes.tex", stats(N r2 year_FE) star(* 0.10 ** 0.05 *** 0.01) replace se mtitles(`outcomes') title("RDD results")
	
	
	
	
	    * ---- one GRAPH per measure: all outcomes ----
    coefplot `outcomes', ///
        vertical          ///
        drop(_cons)       ///
        xline(0, lpattern(dash)) ///
        xlabel(, angle(45)) ///
        title("RD estimates for `measure'") ///
        subtitle("All exhaustive classes") ///
        ytitle("Effect at cutoff") ///
        xtitle("Outcome")

    graph export "$output/`measure'__under5K_all_outcomes.pdf", replace
	
	}
	
	
	

/*-------------------------------------------------------------------------------

    3 	Heterogeneity analysis - Over 5k pop
-------------------------------------------------------------------------------*/





use final_database_w_civica, clear

replace scoperti_pc_x100000=0 if scoperti_pc_x100000==.
replace commessi_pc_x100000=0 if commessi_pc_x100000==.

replace exhaustive_class=subinstr(exhaustive_class," ","_",.)
replace exhaustive_class=subinstr(exhaustive_class,"(","",.)
replace exhaustive_class=subinstr(exhaustive_class,")","",.)
replace exhaustive_class=subinstr(exhaustive_class,"trafficking_and_association_crimes","traficking",.)



levelsof exhaustive_class, local(outcomes)
global outcomes `outcomes'
				*Final Sample selection
				drop if gender == gender_second
				drop if gender == "U" | gender_second == "U"
				drop if margin_fem==.
				drop if pop_dec_tot>5000 
				
	
	foreach measure in $measures {
		local y "`measure'_pc_x100000"
		foreach outcome in `outcomes' {
				* RDD - No Controls - 20% margin threshold
				

// 					eststo reg1_1: reg `y'  dummy_civica 1.dummy_civica#c.margin_civica c.margin_civica if delitto_name=="`outcome'" & margin_pct<$threshold
					eststo `outcome': rdrobust `y' margin_fem if exhaustive_class=="`outcome'", covs(elettori frac_female)
					

		}
	
	
	 		esttab `outcomes' using "$output/`measure'_over5k_all_outcomes.tex", stats(N r2 year_FE) star(* 0.10 ** 0.05 *** 0.01) replace se mtitles(`outcomes') title("RDD results")
	
	
	
	
	    * ---- one GRAPH per measure: all outcomes ----
    coefplot `outcomes', ///
        vertical          ///
        drop(_cons)       ///
        xline(0, lpattern(dash)) ///
        xlabel(, angle(45)) ///
        title("RD estimates for `measure'") ///
        subtitle("All exhaustive classes") ///
        ytitle("Effect at cutoff") ///
        xtitle("Outcome")

    graph export "$output/`measure'_over5K_all_outcomes.pdf", replace
	
	}
	
	