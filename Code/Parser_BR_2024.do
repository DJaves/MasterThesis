net from "https://raw.githubusercontent.com/IES-platform/r4r_gender/master/genderit/STATA/"
net install genderit



cd "C:\Users\Daniel\Documents\Thesis\Raw Data"

import delimited votacao_candidato_munzona_2024_BRASIL.csv, clear

	*Generate first name variabkle
	split nm_candidato, gen(nm_firstname)
	
	gen ctry="BR"
	replace nm_firstname1=lower(nm_firstname1)
	genderit nm_firstname1 ctry

	
	
	tab gender if ds_sit_tot_turno=="ELEITO"