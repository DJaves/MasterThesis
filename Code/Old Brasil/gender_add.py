## Packages

import os
import pandas as pd
import gender_guesser.detector as gd

new_directory = 'C:/Users/Daniel/Documents/Thesis/Raw Data'
os.chdir(new_directory)
## Data Import

data = pd.read_csv('votacao_candidato_munzona_2024_BRASIL.csv', sep=";", encoding='ISO-8859-1')

### ADD First name var
data['first_name'] = data['NM_CANDIDATO'].str.split(' ').str[0]

## Decap first names for gender (but keeping first letter capital)
data['first_name'] = data['first_name'].str.capitalize()

## Gender add
d = gd.Detector()




