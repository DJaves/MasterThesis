/*******************************************************************************
*                                                                              *
*  NAME:			 Parser_IT_2004-2013		             		           *
*																			   *
*																			   *
*  PURPOSE:          Data Parser		             		                   *
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
global input	"C:\Users\Daniel\Documents\Thesis\Raw Data"
global output	"C:\Users\Daniel\Documents\Thesis\Out"


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
	
	*Export for merge
	save "$output\electoral_main.dta", replace
	
	
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
	merge m:1 sigla using provincia_data, keepusing(provincia)
	
	/// All matched, we ball!
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	