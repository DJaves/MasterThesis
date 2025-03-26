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



/*------------------------------------------------------------------------------
    1   Gender addition
------------------------------------------------------------------------------*/
	*Character replacement for accuracy


	
	*Generate first name variable
	split nm_candidato, gen(nm_firstname) l(3)									//Keeping first 3 words for potential improvements on genderit 
	replace nm_firstname1=lower(nm_firstname1)
	
	
	*Error correction for firstname1
	replace nm_firstname1=nm_firstname2 if regexm(nm_firstname1, "^[0-9]{2}")
		
	
	*Generate country code for genderit
	gen ctry="BR"
	
	
	
	*Gender addition
	genderit nm_firstname1 ctry
	

	
	
	
	*Check data state
	tab gender if ds_sit_tot_turno=="ELEITO"