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
*                    Last time modified: 26 March 2025 	                       *
*                                                                              *
********************************************************************************


--------------------------------------------------------------------------------
    0   Define locals and directories
------------------------------------------------------------------------------*/



*Macros

local packages 0
global input	"C:\Users\Daniel\Documents\Thesis\Parsed Data"
global output	"C:\Users\Daniel\Documents\Thesis\Out"


*Install packages


if `packages'==1 {
	
	ssc install unique
	ssc install gtools
	
}

cd "$input"




	
/*------------------------------------------------------------------------------
    1 	Standard Model - Violenze sessuali - 20% Arbitrary threshold
-------------------------------------------------------------------------------*/


use final_database, clear

	global outcomes `" "violenze sessuali" "violenza sessuale su maggiori di anni 14" "violenza sessuale in danno di minori di anni 14" "totale" "furti" "'
foreach outcome in $outcomes {
		* RDD - No Controls - 20% margin threshold
		preserve
			drop if gender == gender_second
			
			eststo reg1_1: reg totale_pc_x100000  dummy 1.dummy#c.margin_fem c.margin_fem if delitto_name=="`outcome'" & margin_pct<0.2
			estadd local year_FE "No"
		restore	
		
		
		* RDD - Year FE - 20% margin threshold
		preserve
			drop if gender == gender_second
			
			eststo reg1_2: reghdfe totale_pc_x100000  dummy 1.dummy#c.margin_fem c.margin_fem if delitto_name=="`outcome'" & margin_pct<0.2, absorb(year)
			estadd local year_FE "Yes"
		restore	
			
		
		
		
		*RDD - Year FE, number of electors - 20% margin threshold
		preserve
			drop if gender == gender_second
			
			eststo reg1_3: reghdfe totale_pc_x100000  dummy 1.dummy#c.margin_fem c.margin_fem elettori if delitto_name=="`outcome'" & margin_pct<0.2, absorb(year) 
			estadd local year_FE "Yes"
		restore
		
		
		*RDD - Year FE, number of electors, female fraction - 20% margin threshold
		preserve
			drop if gender == gender_second
			
			eststo reg1_4: reghdfe totale_pc_x100000  dummy 1.dummy#c.margin_fem c.margin_fem elettori frac_female if delitto_name=="`outcome'" & margin_pct<0.2, absorb(year)
			estadd local year_FE "Yes"
		restore
		
		*RDD - Year FE, number of electors, female fraction - 20% margin threshold
		preserve
			drop if gender == gender_second
			
			eststo reg1_4: reghdfe totale_pc_x100000  dummy 1.dummy#c.margin_fem c.margin_fem elettori frac_female  if delitto_name=="`outcome'" & margin_pct<0.2, absorb(year)
			estadd local year_FE "Yes"
		restore
		

		
		esttab reg1_1 reg1_2 reg1_3 reg1_4 using "$output/`outcome'_default.tex", stats(N r2 year_FE) star(* 0.10 ** 0.05 *** 0.01) replace se
	
}
	
/*------------------------------------------------------------------------------
    2 	By years from election - Violenze sessuali - 20% Arbitrary threshold
-------------------------------------------------------------------------------*/


	* RDD - No Controls - 20% margin threshold
	foreach n in 0 1 2 3 4{
		
		preserve
			local re "reg1_1_year_`n'"
			display "year `n'"
			keep if years_from_last_election == `n' 
			drop if gender == gender_second
			
			eststo `re': reg totale_pc_x100000 dummy 1.dummy#c.margin_fem c.margin_fem elettori if delitto_name=="violenze sessuali" & margin_pct<0.2
		restore	
	}
		esttab reg1_1_year_0 reg1_1_year_1 reg1_1_year_2 reg1_1_year_3 reg1_1_year_4 using "$output\table2_1.tex", stats(N r2) star(* 0.10 ** 0.05 *** 0.01) replace se
	
	* RDD - Year FE - 20% margin threshold
	foreach n in 0 1 2 3 4{
		
		preserve
			display "year `n'"
			keep if years_from_last_election == `n' 
			drop if gender == gender_second
			
			reghdfe totale_pc_x100000 dummy dummy#c.margin_fem c.margin_fem if delitto_name=="violenze sessuali" & margin_pct<0.2, absorb(year)
		restore	
	}
	
	
	
	*RDD - Year FE, number of electors - 20% margin threshold
	foreach n in 0 1 2 3 4{
		
		preserve
			display "year `n'"
			keep if years_from_last_election == `n' 
			drop if gender == gender_second
			
			
			reghdfe totale_pc_x100000 dummy dummy#c.margin_fem c.margin_fem elettori if delitto_name=="violenze sessuali" & margin_pct<0.2, absorb(year)
		restore	
	}
	
	*RDD - Year FE, number of electors, female fraction - 20% margin threshold
	foreach n in 0 1 2 3 4{
		
		preserve
			display "year `n'"
			keep if years_from_last_election == `n' 
			drop if gender == gender_second
			
			reghdfe totale_pc_x100000 dummy dummy#c.margin_fem c.margin_fem elettori frac_female if delitto_name=="violenze sessuali" & margin_pct<0.2, absorb(year)
		restore	
	}
	

