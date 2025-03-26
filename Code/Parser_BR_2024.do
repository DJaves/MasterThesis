/*******************************************************************************
*                                                                              *
*  NAME:			 Parser_BR_2024		             		                   *
*																			   *
*																			   *
*  PURPOSE:          Data Parser		             		                   *
*                                                                              *
*  OUTLINE:          0 Define locals, directories and packages                 *
*                    1 Data Preparation                         			   *
*                    2 Data Exploration                         			   *
*                    3 Data Analysis		                       			   *
*                                                                              *
*  REQUIRES: 		 votacao_candidato_munzona_2024_BRASIL.csv                 *
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

local packages 1
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



/*------------------------------------------------------------------------------
    1   Import the dataset
------------------------------------------------------------------------------*/


import delimited votacao_candidato_munzona_2024_BRASIL.csv, clear		
	save "$output\raw_data.dta"


use raw_data, clear
/*------------------------------------------------------------------------------
    1   Gender addition
------------------------------------------------------------------------------*/


	**** STAGE 1 -> Identify based on first name
	
	*Generate first name variable
	replace nm_candidato = lower(nm_candidato)
	split nm_candidato, gen(nm_firstname) l(3)									//Keeping first 3 words for potential improvements on genderit 

	
	
	*Error correction for firstname1
	replace nm_firstname1=nm_firstname2 if regexm(nm_firstname1, "^[0-9]{2}")
	
	
	*Character replacement for accuracy
	/*
	replace nm_firstname1=subinstr(nm_firstname1,"Ã","A",.)
	replace nm_firstname1=subinstr(nm_firstname1,"Ô","O",.)
	
	
	replace nm_firstname1=subinstr(nm_firstname1,"Á","A",.)
	replace nm_firstname1=subinstr(nm_firstname1,"É","E",.)
	replace nm_firstname1=subinstr(nm_firstname1,"Í","I",.)
	replace nm_firstname1=subinstr(nm_firstname1,"Ó","O",.)
	replace nm_firstname1=subinstr(nm_firstname1,"Ú","U",.)
	
	replace nm_firstname1=subinstr(nm_firstname1,"Ç","C",.)
	*/
		
	
	*Generate country code for genderit
	gen ctry="BR"
	
	
	
	*Gender addition
	genderit nm_firstname1 ctry
	

	
	
	
	*Check data state
	tab gender
	
		/*		
		Most likely |
			 gender |
			 (>=.6) |      Freq.     Percent        Cum.
		------------+-----------------------------------
				  F |    198,383       27.76       27.76
				  M |    350,079       48.98       76.74
				  U |    166,267       23.26      100.00
		------------+-----------------------------------
			  Total |    714,729      100.00
		*/

	
	
	
	**** STAGE 2 -> For non identified, go with second word (most likely second name, subject to review)
	
		*renaming first stage vars for command functioning
		rename (gender probF probM probU step) (gender_1 probF_1 probM_1 probU_1 step_1)
		
	*Gender based on second name	
	genderit nm_firstname2 ctry 
	
	
		*renaming for consistency
		rename prob_1 gender_1
		rename (gender probF probM probU step) (gender_2 probF_2 probM_2 probU_2 step_2)
		
		
	*Replace gender_1 with gender_2 for unidentified on first stage
	replace gender_1=gender_2 if gender_1=="U"
	
	
	*Check data state
	tab gender_1
	
		/*		
		Most likely |
			 gender |
			 (>=.6) |      Freq.     Percent        Cum.
		------------+-----------------------------------
				  F |    223,752       31.31       31.31
				  M |    426,636       59.69       91.00
				  U |     64,341        9.00      100.00
		------------+-----------------------------------
			  Total |    714,729      100.00
		*/

	
	
	
	
	