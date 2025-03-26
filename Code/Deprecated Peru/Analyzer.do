/*******************************************************************************
*                                                                              *
*  PURPOSE:          DATA First Analysis			                               *
*                                                                              *
*  OUTLINE:          0 Define the relevant directories                         *
*                    1 Data Preparation                         			   *
*                    2 Data Exploration                         			   *
*                    3 Data Analysis		                       			   *
*																			   *
*  REQUIRES:         team_info.csv				                               *
*                    red_sox_2009			                                   *
*                    red_sox_2010			                                   *
*                    red_sox_2011			                                   *
*                    red_sox_2012			                                   *
*                                                                              *
*  OUTPUT:           main_data							                   *
*                                                                              *
*                    Last time modified: 11 February 2025                       *
*                                                                              *
********************************************************************************


--------------------------------------------------------------------------------
    0   Define locals and directories
------------------------------------------------------------------------------*/




global path "C:\Users\Daniel\Documents\Thesis\Raw Data"
cd "$path"


/*------------------------------------------------------------------------------
    0   Import base
------------------------------------------------------------------------------*/

use final_base,clear




/*------------------------------------------------------------------------------
    0   Initial specification Diff in Diff 2018-2019
------------------------------------------------------------------------------*/

keep if year==2018 | year==2019

encode Sexo, gen(female)
reg cases year##female



