import unicodecsv as csv
import pandas as pd

# These columns may vary depending on what pops you have added to the game
# Change as necessary
id_column = "PROVID"
name_column = "NAME"
culture_column = "CULTURE"
religion_column = "Religion"
tradegoods_column = "TRADEGOOD"
civilization_column = "INDUSTRIALISATION"
barbarian_column = "unused"
province_rank_column = "PROVINCE_RANK"
area_column = "AREA"
terrain_column = "TERRAIN"
# Pop values
citizen_column = "unused"
slaves_column = "slaves"
tribesmen_column = "tribesmen"
# Pops for the 1815 mod
indentured_column = "indentured"
lower_strata_column = "lower_strata"
middle_strata_column = "middle_strata"
upper_strata_column = "upper_strata"
proletariat_column = "proletariat"
# Extra minority pops, beginning with pop type column
extra_pop1 = 21
extra_pop2 = 25
extra_pop3 = 29
extra_pop4 = 33
extra_pop5 = 37
extra_pop6 = 41
extra_pop7 = 45
extra_pops = [extra_pop1, extra_pop2, extra_pop3, extra_pop4, extra_pop5, extra_pop6, extra_pop7]
# Add these values to above minority pop columns to get corresponding data
culture = 1
religion = 2
size = 3

# Data validation for pop types
valid_pops = ["lower_strata","proletariat","middle_strata","upper_strata","slaves","tribesmen","indentured"]

terrain_file = open("province_terrain/00_province_terrain.txt",encoding="utf=8")

# OUTPUT FILE
building_list = open("building_list.txt","w",encoding="utf=8")
# INPUT FILE
setup_csv = open("province_setup.csv", "rb")
#reader = csv.reader(setup_csv, delimiter=";")
reader = pd.read_csv(setup_csv, sep=';')
reader = reader.fillna("") # Fill all NaN values with empty strings

# Only list provinces with city status, because we're only going to give them buildings
reader = reader[reader.PROVINCE_RANK != 0]

# Get the total population, N.B. this only gets main culture pops and does not include extra pops.
def get_total_population(row):
    total_population = int(row.indentured) + int(row.slaves) + int(row.tribesmen) + int(row.lower_strata) + int(row.middle_strata) + int(row.upper_strata) + int(row.proletariat)
    for extra_pop in extra_pops:
        if row[extra_pop].replace(" ","_") in valid_pops:
            total_population = total_population + int(row[extra_pop+size].replace(".0",""))
    return total_population

def write_buildings():
    with building_list as f:
        f.write("### BEGIN GENERATED BUILDINGS\n\n")
        for row in reader.astype(str).itertuples():
            total_population = get_total_population(row)
            f.write(
                "   " + row.PROVID + " = {\n" +
                "       URB_residential_district = " + str(round(total_population/10)) + "\n" + 
                "   }\n"
                )
        f.write("###END GENERATED BUILDINGS")
            

write_buildings()
