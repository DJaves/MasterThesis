/*******************************************************************************
*                                                                              *
*  NAME:			 CrimeBAse Parser_IT_2004-2013             		           *
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
*  REQUIRES: 		 confinai_merge_reati.dta						                   *
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
global files_path "P:\Thesis_files\Thesis"
global input	"$files_path\Raw Data"
global output	"$files_path\Parsed Data"



cd "$input"


/*-------------------------------------------------------------------------------
    1 Load File
------------------------------------------------------------------------------*/


use "confinati_merge_reati.dta", clear



/*-------------------------------------------------------------------------------
    1 Generate Ssubclass variables
------------------------------------------------------------------------------*/

gen delitto_recoded=delitto_code

	replace delitto_recoded=subinstr(delitto_recoded,"a",".01",.)
	replace delitto_recoded=subinstr(delitto_recoded,"b",".02",.)
	replace delitto_recoded=subinstr(delitto_recoded,"c",".03",.)
	replace delitto_recoded=subinstr(delitto_recoded,"d",".04",.)
	replace delitto_recoded=subinstr(delitto_recoded,"e",".05",.)
	replace delitto_recoded=subinstr(delitto_recoded,"f",".06",.)
	replace delitto_recoded=subinstr(delitto_recoded,"g",".07",.)
	replace delitto_recoded=subinstr(delitto_recoded,"h",".08",.)
	replace delitto_recoded=subinstr(delitto_recoded,"i",".09",.)
	replace delitto_recoded=subinstr(delitto_recoded,"j",".10",.)
	replace delitto_recoded=subinstr(delitto_recoded,"k",".11",.)

	destring delitto_recoded, replace
	
	
	
*Var Creation: Exhaustive Classification

gen exhaustive_class=""
	
	replace exhaustive_class="aggresion" if delitto_recoded==1 | delitto_recoded==8 | delitto_recoded==9 | delitto_recoded==18 
	replace exhaustive_class="murder(and temptative)" if delitto_recoded>=2 & delitto_recoded<=7.2
	replace exhaustive_class="verbal crimes" if delitto_recoded==10 | delitto_recoded==11 
	replace exhaustive_class="sex crimes" if floor(delitto_recoded)==12 | floor(delitto_recoded)==30 | inlist(delitto_recoded,13,14)
	replace exhaustive_class="Theft" if delitto_recoded>=15 & delitto_recoded<=16 
	replace exhaustive_class="Robbery" if floor(delitto_recoded)==17
	replace exhaustive_class="kidnapping" if floor(delitto_recoded)==20
	replace exhaustive_class="property damage" if delitto_recoded>=25 & delitto_recoded<=27
	replace exhaustive_class="drug_crimes" if floor(delitto_recoded)==29
	replace exhaustive_class="other" if delitto_recoded==34
	replace exhaustive_class="(suposed) total" if delitto_recoded==35
	replace exhaustive_class = "trafficking and association crimes" if inlist(delitto_recoded, ///
    19, 19.1, 21, 22, 23, 24,  ///
    28,  ///
    31, 32, 33)

	
	

	
/*-------------------------------------------------------------------------------
    2 Generate Baseline alaysis Database (collapse at exhaustive class level)
------------------------------------------------------------------------------*/

	
	
collapse (sum) delitti_commessi (sum) delitti_scoperti (first) idcomune (first) idregione (first) idprovincia (first) pop_dec_m (first) pop_dec_f (first) pop_dec_tot (first) popstranieri, by (comune provincia regione year exhaustive_class)
	
	
* --- your panel of by vars ---
bys year comune regione provincia: gen tag = _n==1

* get unique lists
preserve
keep year comune regione provincia exhaustive_class idcomune idregione idprovincia pop_dec_m pop_dec_f pop_dec_tot popstranieri
fillin year comune exhaustive_class
tempfile fullpanel
save `fullpanel'
restore

* merge original data to full panel
merge 1:1 year comune regione provincia exhaustive_class using `fullpanel'

* For new rows (_merge==2), outcomes are zero
replace delitti_commessi = 0 if _merge==2
replace delitti_scoperti = 0 if _merge==2

drop _merge


save crime_db.dta, replace

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	