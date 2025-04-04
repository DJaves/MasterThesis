/*******************************************************************************
*                                                                              *
*  NAME:			 Parser_IT_2004-2013		             		           *
*																			   *
*																			   *
*  PURPOSE:          Data Parser		             		                   *
*                                                                              *
*  OUTLINE:          0 Define locals, directories and packages                 *
*                    1 Appending Electoral Data                   			   *
*                    2 Reduce to Final Election base               			   *
*                    3 Gender imputing	                         			   *
*                    4 Generate key variables for analysis        			   *
*                    5 Sigla data                         					   *
*                    6 Sigla with provincia merge                  			   *
*                    7 Big merge time	                        			   *
*                    8 Final var generation                      			   *
*																			   *
*                                                                              *
*  REQUIRES: 		 comunali-"".csv						                   *
*                                                                              *
*  OUTPUT:           final_database.dta					                  	   *
*                                                                              *
*                    Last time modified: 04 April 2025 	                       *
*                                                                              *
********************************************************************************


--------------------------------------------------------------------------------
    0   Define locals and directories
------------------------------------------------------------------------------*/



*Macros

local packages 0
global input	"C:\Users\Daniel\Documents\Thesis\Raw Data"
global output	"C:\Users\Daniel\Documents\Thesis\Parsed Data"


*Install packages


if `packages'==1 {
	
	*Genderit
	*net from "https://raw.githubusercontent.com/IES-platform/r4r_gender/master/genderit/STATA/"
	*net install genderit
	
	ssc install unique
	ssc install gtools
	
}

cd "$input"


local dates 20040612 20040626 20050403 20050417 20050508 20051127 20060528 20060604 20060611 20060618 20060709 20060716 20061001 20070527 20070610 20070617 20070715 20080413 20080427 20080608 20080615 20090607 20091129 20100328 20100411 20100418 20100530 20101128 20110515 20110522 20111127 20120506 20120610 20120617 20120624 20121028 20130526 20131117





/*------------------------------------------------------------------------------
    1   Appending Electoral Data
------------------------------------------------------------------------------*/

** Save dta for every election day
foreach date in `dates' {
	local election "comunali-`date'.txt"
	import delimited `election' , clear
	
	*Gen date variable for ID
	gen date="`date'"
	tempfile data_`date'
	save `data_`date'', replace
	
}

** Back to a clean dataset
clear


** Append all dates together
foreach date in `dates' {
	append using `data_`date''
}

** Store dataset

	save "$output\electoral_main.dta", replace
	
	
/*------------------------------------------------------------------------------
    2   Reduce to final election base
------------------------------------------------------------------------------*/
** Import dataset refined
use "$output\electoral_main.dta", clear

sort regione provincia comune date turno 

	* Keep only final turno database
	by regione provincia comune date: egen max_turno=max(turno) 
	drop if max_turno!=turno
	
	
	
	* Keep only candidates level
	duplicates report regione provincia comune date turno cognome nome 
	duplicates drop regione provincia comune date turno cognome nome, force
	
	* Get margin of victory
	gsort regione provincia comune date turno - voti_candidato 
	bys regione provincia comune date turno: gen rank = _n						// Candidate ranking on final list 
	
	
	bys regione provincia comune date turno: gen margin = voti_candidato[_n] - voti_candidato[_n+1]
		gen margin_pct = margin/elettori


		
	*Computing descriptives
	tabstat margin_pct if rank==1, s(n mean sd min max p10 p25 p50 p75 p90)

/*    Variable |         N      Mean        SD       Min       Max       p10       p25       p50       p75       p90
-------------+----------------------------------------------------------------------------------------------------
  margin_pct |     14007  .1508535  .1273005         0      .875  .0206573  .0510256   .116603  .2176658   .334704
------------------------------------------------------------------------------------------------------------------*/



/*------------------------------------------------------------------------------
    3   Gender imputing
-------------------------------------------------------------------------------*/

	*split nome
	replace nome = lower(nome)
	split nome
	
	
	gen ctry="IT"
	
	genderit nome1 ctry
	
	tab gender if rank==1

	*** NOTE: Some names are getting assigned when they should be undetermined: "Andrea" and "Mattia" for example
	*** Pending: Gender refinement

/*------------------------------------------------------------------------------
    4   Generate key variables for analysis
-------------------------------------------------------------------------------*/


	* Generate year 
	generate year = substr(date,1,4)
		destring year, replace
		
	* Generate gender of second place
	gsort regione provincia comune date turno - voti_candidato 
	
	gen gender_second = gender[_n+1] if rank == 1
	
	gen cognome_second = cognome[_n+1] if rank == 1
	
	
	
	*lower geographical for matching
	replace regione = lower(regione)
	replace provincia = lower(provincia)
	replace comune = lower(comune)
	
	replace provincia = "reggio emilia" if provincia=="reggio nell'emilia"
	replace provincia = "reggio calabria" if provincia=="reggio di calabria"

	
	*Export for merge
	keep if rank==1
	save "$output\electoral_main_2.dta", replace
	
	use "$output\electoral_main_2.dta", clear
	
	gsort regione provincia comune date turno - voti_candidato year
	
	gen last_election_year = year
	


	
	*** Data expansion
	* Step 1: Create panel identifier
	egen id = group(regione provincia comune)
	
	**** CORRECT THIS FIX LATER!!!!!!!!!!!!!
	duplicates drop id year, force

	* Step 2: Set as panel data
	xtset id year

	* Step 3: Fill in missing years (2004–2013)
	tsfill, full

	
	* Step 1: Create a local with the variables to recover
	ds id year, not
	local vars `r(varlist)'

	* Step 2: Loop over the variables and recover values
	foreach var of local vars {
		bysort id (year): replace `var' = `var'[_n-1] if missing(`var')
	}

	
	* Backward filling for provincia and comune 
	gsort id -year
	by id: gen aux = _n
	

	foreach var of varlist provincia comune {
    
    bys id (aux): replace `var' = `var'[_n-1] if missing(`var')
}
	



	

	*replace comune = ustrregexra(comune, "\uFFFD", "")

	save "$output\electoral_main_expanded.dta", replace


	
/*------------------------------------------------------------------------------
    5   sigla data
-------------------------------------------------------------------------------*/
	
	
	


	*Import the data
	import excel "provincia_data.xlsx", clear firstrow
		replace provincia = lower(provincia)
		
		
	save "provincia_data.dta", replace
	

	
/*------------------------------------------------------------------------------
    6   sigla with provincia merge
-------------------------------------------------------------------------------*/

	use confinati_merge_reati, clear
	rename provincia sigla
	merge m:1 sigla using provincia_data, keepusing(provincia) nogen
	
	/// All matched, we ball!
	
	replace provincia = lower(provincia)
	
	//Handling provincia issue with badchar
	/*
		replace comune = subinstr(comune,"a'","",.)
		replace comune = subinstr(comune,"e'","",.)
		replace comune = subinstr(comune,"i'","",.)
		replace comune = subinstr(comune,"o'","",.)
		replace comune = subinstr(comune,"u'","",.)
	*/
	
/*------------------------------------------------------------------------------
    7   Big merge time
-------------------------------------------------------------------------------*/

rename anno year

	save pre_merge, replace
	
	use pre_merge, clear
	
		
	
	merge m:1 year provincia comune using "$output\electoral_main_expanded.dta", keepusing(margin_pct gender gender_second last_election_year id elettori)
	
	
/*


    Result                      Number of obs
    -----------------------------------------
    Not matched                       376,468
        from master                   371,528  (_merge==1)
        from using                      4,940  (_merge==2)

    Matched                         2,190,370  (_merge==3)
    -----------------------------------------




	
	Observations with no sigla: 25 670
Expected unmatched (on average municipalities unmatched): 301 203
unmatched municipalities from electoral data: 582

*/

** Next step: Checking unmatched for corrections. Most likely: unrecognized characters from crime data. 
	
sort regione provincia comune
*br regione provincia comune if _merge==1 & year==2004

* Check for bad char error size
gen has_badchar = ustrregexm(comune, "\uFFFD")
	tab has_badchar if _merge == 1
	
	
/*
has_badchar |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    343,128       88.28       88.28
          1 |     45,550       11.72      100.00
------------+-----------------------------------
      Total |    388,678      100.00
	  
	  11.72% of unmatched obs is most likely due to the badchar issue
*/

	
	
	br regione provincia comune if _merge==1 & year==2004 & has_badchar == 0
	
	
/*	* List of unmatched communes NOT DUE to the varchar issue
	preserve
		keep if _merge==1 & year==2004 & has_badchar == 0
		keep regione provincia comune
		duplicates drop
		export excel using "$output\unmatching_municipalities_crime.xlsx", replace firstrow(variables)
	restore
	
	
	preserve
		keep if _merge==2 & year==2004 & has_badchar == 0
		keep regione provincia comune
		duplicates drop
		export excel using "$output\unmatching_municipalities_electoral.xlsx", replace firstrow(variables)
	restore
*/	
	
	
	

	* List of unmatched communes DUE to the varchar issue
	preserve
		keep if _merge==1 & year==2004 & has_badchar == 1
		keep regione provincia comune
		duplicates drop
		export excel using "$output\unmatching_municipalities_crime_badchar.xlsx", replace firstrow(variables)
	restore
	
	
	
	*unique comune if _merge==1 & year==2004 & has_badchar == 0
	
	/*
	Number of unique values of comune is  1059
	Number of records is  34147

	Approximate number of unmatched municipalities not explained by the bad_char issue
	
	The unique comunes difference in both datasets is 860. Therefore, should aim to get the previous number to this. 
	*/
	
	save "$output\merged_progress.dta", replace

	
	
/*------------------------------------------------------------------------------
    8   Final var generation
-------------------------------------------------------------------------------*/

	use "$output\merged_progress.dta", clear

	
	
	
	*Keep only matched observations
	keep if _merge==3
	
	
	*Dummy for Main Analysis
	gen dummy = 1 if gender=="F"
		replace dummy = 0 if gender =="M"

	
	*Margin fem, for running variable generation
	gen margin_fem = margin_pct
		replace margin_fem = -margin_pct if gender_second == "F"
		
		
	*Relevant outcomes and control variables
	gen delitti_totale = delitti_commessi + delitti_scoperti					// All crime commited
	gen totale_pc_x100000 = delitti_totale/pop_dec_tot*100000					// Crime per 100k habitants
	gen frac_female = pop_dec_f/pop_dec_tot										// Fraction of female in the municipality
	gen years_from_last_election = year - last_election_year					// Years from last election, key heterogeneity analysis factor
		
	save "$output\final_database.dta", replace 
	
	

	
	
	
	
	