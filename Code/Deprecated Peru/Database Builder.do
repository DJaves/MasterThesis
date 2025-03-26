/*******************************************************************************
*                                                                              *
*  PURPOSE:          DATABASE BUILDING			                               *
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
*                    Last time modified: 10 February 2025                       *
*                                                                              *
********************************************************************************


--------------------------------------------------------------------------------
    0   Define locals and directories
------------------------------------------------------------------------------*/




global path "C:\Users\Daniel\Documents\Thesis\Raw Data"
cd "$path"

/*--------------------------------------------------------------------------------
    1   Import and append data at the CEM case level
------------------------------------------------------------------------------*/

foreach file in CEM17 CEM18 CEM19 CEM20 CEM21s1 CEM22 CEM22s2 CEM23s1 CEM23s2 {
	
	import spss `file',clear
	tempfile `file'
	save ``file''
}

foreach file in CEM17 CEM18 CEM19 CEM20 CEM21s1 CEM22 CEM22s2 CEM23s1 {

	append using ``file'', force

}


/*--------------------------------------------------------------------------------
    2   Export case level database
------------------------------------------------------------------------------*/

save case_base, replace



/*--------------------------------------------------------------------------------
    3   Generate district level database
------------------------------------------------------------------------------*/
use case_base,clear

	gen date_daily = dofc(FECHA_INGRESO)  // Convert datetime to daily date
	format date_daily %td        // Apply proper date format



	gen year = yofd(date_daily)
	format year %ty  // Stata's monthly date format

*District-base database gen
gen cases=1
collapse (count) cases, by(year DIST_DOMICILIO PROV_DOMICILIO DPTO_DOMICILIO)

gen ubigeo=DPTO_DOMICILIO+PROV_DOMICILIO+DIST_DOMICILIO

save district_base, replace


/*--------------------------------------------------------------------------------
    4   Import population database
------------------------------------------------------------------------------*/


import excel using "geodir-ubigeo-inei.xlsx", clear firstrow
rename Ubigeo ubigeo

merge 1:m ubigeo using district_base
keep if _merge==3


* Generate main outcome variable

gen cases_pt=cases/Poblacion*1000

save dist_level, replace




/*--------------------------------------------------------------------------------
    5   Import 2023 Mayor database
------------------------------------------------------------------------------*/


import excel using "3908763-directorio-nacional-de-municipalidades-provinciales-y-distritales-enero-2025", clear firstrow

keep if Cargo=="Alcalde Distrital"
rename Ubigeo ubigeo

gen year=2023


merge 1:m ubigeo year using dist_level, nogen keep (2 3)


save temp2023, replace

/*--------------------------------------------------------------------------------
    5   Import 2019-2022 Mayor database
------------------------------------------------------------------------------*/
clear

import excel using "Directorio-de-municipalidades-provinciales-y-distritales_06_09_2021", clear firstrow

keep if Cargo=="Alcalde Distrital"
rename UBIGEO ubigeo

expand 4

bys ubigeo: gen year=2018+_n



merge 1:m ubigeo year using temp2023, nogen keep (2 3)


save temp2019, replace
/*--------------------------------------------------------------------------------
    6   Import 2017-2018 Mayor database
------------------------------------------------------------------------------*/
clear

import excel using "directorio-de-municipalidades-provinciales-y-distritales_09-01-2017", clear firstrow

keep if Cargo=="Alcalde Distrital"
rename UBIGEO ubigeo

**Recoding of Genero
rename Género genero
gen Sexo="Hombre" if genero=="Masculino"
replace Sexo="Mujer" if genero=="Femenino"

expand 2

bys ubigeo: gen year=2016+_n


merge 1:m ubigeo year using temp2019, nogen keep (2 3)



/*--------------------------------------------------------------------------------
    6   Export Final Database 2017-2018 Mayor database
------------------------------------------------------------------------------*/


save final_base, replace