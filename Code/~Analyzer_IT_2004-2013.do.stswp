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
global input	"C:\Users\Daniel\Documents\Thesis\Parsed Data"
global output	"C:\Users\Daniel\Documents\Thesis\Out"
global outcomes `" "violenze sessuali" "totale" "furti" "lesioni dolose" "minacce" "ingiurie" "danneggiamenti" "rapine" "'
global measures `" "commessi" "scoperti" "'
global threshold 0.1
*Install packages


if `packages'==1 {
	
	ssc install unique
	ssc install gtools
	ssc install rddensity
}

cd "$input"




/*------------------------------------------------------------------------------
    0 	McCrary Test Check 
-------------------------------------------------------------------------------*/


use final_database, clear

				*Final Sample selection
				drop if gender == gender_second
				drop if gender == "U" | gender_second == "U"
				drop if margin_fem==.
	
	rddensity margin_fem if delitto_name=="violenze sessuali"
	*Bene :D
/*------------------------------------------------------------------------------
    1 	Standard Model - Violenze sessuali - 20% Arbitrary threshold
-------------------------------------------------------------------------------*/


use final_database, clear

				*Final Sample selection
				drop if gender == gender_second
				drop if gender == "U" | gender_second == "U"
				drop if margin_fem==.
	
	
	foreach measure in $measures {
		local y "`measure'_pc_x100000"
		foreach outcome in $outcomes {
				* RDD - No Controls - 20% margin threshold
				

					eststo reg1_1: reg `y'  dummy 1.dummy#c.margin_fem c.margin_fem if delitto_name=="`outcome'" & margin_pct<$threshold
					eststo rob1_1: rdrobust `y' margin_fem if delitto_name=="`outcome'", covs(elettori frac_female) masspoints(adjust)
					*estadd local year_FE "No"
				
				
				
				* RDD - Year FE - 20% margin threshold
							
					eststo reg1_2: reghdfe `y'  dummy 1.dummy#c.margin_fem c.margin_fem if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
					estadd local year_FE "Yes"
					
				
				
				
				*RDD - Year FE, number of electors - 20% margin threshold			
					eststo reg1_3: reghdfe `y'  dummy 1.dummy#c.margin_fem c.margin_fem elettori if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year) 
					estadd local year_FE "Yes"
				
				
				
				*RDD - Year FE, number of electors, female fraction - 20% margin threshold
					eststo reg1_4: reghdfe `y'  dummy 1.dummy#c.margin_fem c.margin_fem elettori frac_female if delitto_name=="`outcome'" & margin_pct<$threshold, absorb(year)
					estadd local year_FE "Yes"
							
				

				
				esttab reg1_1 reg1_2 reg1_3 reg1_4 using "$output/`measure'_`outcome'.tex", stats(N r2 year_FE) star(* 0.10 ** 0.05 *** 0.01) replace se mtitles("RDD" "RDD, year FE" "RDD, year FE controls 1" "RDD, year FE controls 1") title("`outcome'")
			
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



/*------------------------------------------------------------------------------
    1 	D&D - new treatment
-------------------------------------------------------------------------------*/


use final_database, clear
	
	
	
	