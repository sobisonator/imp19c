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
#reader = reader[reader.PROVINCE_RANK != 0]

# Get the total population, N.B. this only gets main culture pops and does not include extra pops.
def get_total_population(row):
    try:
        total_population = int(row.indentured) + int(row.slaves) + int(row.tribesmen) + int(row.lower_strata) + int(row.middle_strata) + int(row.upper_strata) + int(row.proletariat)
        for extra_pop in extra_pops:
            if row[extra_pop].replace(" ","_") in valid_pops:
                total_population = total_population + row[extra_pop+size]
        return total_population
    except:
        return 0

def write_buildings():
    with building_list as f:
        f.write("### BEGIN GENERATED BUILDINGS\n\n")
        for row in reader.itertuples():
            total_population = get_total_population(row)

            if total_population > 0:
            
                f.write("   " + str(row.PROVID) + " = {\n" )
                residential = str(int(round(int(total_population/10)*0.8)*((3*int(row.INDUSTRIALISATION)) / 100)))
                if int(residential) > 0:
                    f.write("       URB_residential_district = " + residential + "\n")
                administration = str(int(round(int(row.middle_strata) / 5))) 
                if int(administration) > 0:
                    f.write("       URB_administration_district = " + administration + "\n")
                commerce = str(int(round((int(row.middle_strata) + int(row.upper_strata)) / 10)))
                if int(commerce) > 0:
                    f.write("       URB_commerce_district = " + commerce + "\n") 
                cultural = str(int(round((int(row.middle_strata) + int(row.upper_strata)) / 13)))
                if int(cultural) > 0:
                    f.write("       URB_cultural_district = " + cultural + "\n") 
                school = str(int(round(int(row.middle_strata) / 4.25)*(int(row.INDUSTRIALISATION) / 30)))
                if row.PROVINCE_RANK > 0:
                    school = str(int(school)+1)
                if row.upper_strata > 0:
                    school = str(int(school)+1)
                if int(school) > 0:
                    f.write("       EDU_school = " + school + "\n") 
                sewer = str(int(round((total_population/30)*(int(row.INDUSTRIALISATION) / 100))))
                if int(sewer) > 0:
                    f.write("       INF_sewer_infrastructure = " + sewer + "\n" )
                RGO = str(int(round(2 *((0.3*int(row.INDUSTRIALISATION)) ))))
                if int(RGO) > 0:
                    f.write("       IND_resource_gathering_operation = " + RGO + "\n" )
                depot = str(int(round((total_population/20)*((3*int(row.INDUSTRIALISATION)) / 50))))
                if int(depot) > 0:
                    f.write("       INF_depot = " + depot + "\n" )
                hospital = str(int(round((int(row.middle_strata)/5)*(int(row.INDUSTRIALISATION) / 100))))
                if int(hospital) > 0:
                    f.write("       INF_hospital = " + hospital + "\n" )
                f.write("   }\n")
                
        f.write("###END GENERATED BUILDINGS")
            

write_buildings()
