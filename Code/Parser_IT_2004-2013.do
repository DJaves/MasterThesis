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
*  REQUIRES: 		comunali-"".csv							                   *
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


if `packages'==0 {
	
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

foreach date in `dates' {
	local election "comunali-`date'.txt"
	import delimited `election' , clear
	gen date="`date'"
	tempfile data_`date'
	save "data_`date'", replace
	
}


clear



foreach date in `dates' {
	append using "data_`date'"
}


/*------------------------------------------------------------------------------
    2   Generating winning election vars
------------------------------------------------------------------------------*/




/*------------------------------------------------------------------------------
    2   Generating winning election vars
------------------------------------------------------------------------------

 
	