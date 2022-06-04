import codecs, re, os, unidecode
import unicodecsv as csv
import pandas as pd

# Save the file with UTF-8 BOM encoding

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

valid_terrains = ["plains", "farmland", "extreme_mountain", "semi_arid",
                  "low_mountain", "desert", "extreme_desert", "forest",
                  "boreal_forest", "arctic", "dense_jungle", "hills", "tundra",
                  "marsh", "sparse_jungle", "ocean", "coastal_terrain",
                  "constantinople","edo","kyoto","warsaw","riverine_terrain","desert_hills"]

# Data validation for pop types
valid_pops = ["lower_strata","proletariat","middle_strata","upper_strata","slaves","tribesmen","indentured"]

terrain_file = open("province_terrain/00_province_terrain.txt",encoding="utf=8")

if not os.path.exists("setup_exports"):
    os.mkdir("setup_exports")

export_dir = "setup_exports/"

def create_terrain_df(terrain_file):
    terrain_txt = terrain_file.read()
    terrain_dict = {}
    for line in terrain_txt.splitlines(True):
        if line:
            key, value = map(str.strip, line.split("="))
            terrain_dict[key] = value
    # This makes a VERY BIG DICT. Do NOT try to look at it
    # or you will unleash a cosmic terror
    terrain_df = pd.DataFrame(list(terrain_dict.items()), columns=["PROVID","TERRAIN"])
    print(terrain_df)
    return terrain_df

terrain_df = create_terrain_df(terrain_file)

def find_terrain(province_id):
    pass

setup_csv = open("province_setup.csv", "rb")
#reader = csv.reader(setup_csv, delimiter=";")
reader = pd.read_csv(setup_csv, sep=';')
reader = reader.fillna("") # Fill all NaN values with empty strings
print(reader)

non_habitable_provinces = open("../map_data/default.map")
non_habitable_provinces_data = non_habitable_provinces.read()
pattern = "RANGE {(.*)}"
non_habitable_ranges = re.findall(pattern, non_habitable_provinces_data)
non_habitable_ranges = [i.split(" ") for i in non_habitable_ranges]
new_non_habitable_ranges = []
for x in non_habitable_ranges:
    x = [i for i in x if i]
    new_non_habitable_ranges.append(x)
non_habitable_ranges = new_non_habitable_ranges

def check_if_habitable(province_id):
    # Check if the province ID is any of the ranges specified
    try:
        province_id = int(province_id)
    except:
        return False
    for province_range in non_habitable_ranges:
        if province_id >= int(province_range[0]) and province_id <= int(province_range[1]):
            return True
    if " " + str(province_id) not in non_habitable_provinces:
        return True
    else:
        return False

# Sort the provinces by city status, as we're going to ignore the rest
reader = reader.sort_values(area_column)

# Read all areas from the areas column
all_areas = reader[area_column].unique()

# Sanitise strings for filenames
def sanitise_string(input_string):
    output_string = str(input_string).replace(" ", "_").replace(".","_")
    return unidecode.unidecode(output_string)

all_areas = [sanitise_string(item) for item in all_areas]

# Get the total population, N.B. this only gets main culture pops and does not include extra pops.
# Extra pops are added later when they are being processed for the setup writing, to avoid iterating over them twice
def get_total_population(row):
    total_population = int(row.indentured) + int(row.slaves) + int(row.tribesmen) + int(row.lower_strata) + int(row.middle_strata) + int(row.upper_strata) + int(row.proletariat)
    return total_population


for area in all_areas:
    area_name = str(area)
    print(area_name)
    generated_setup = codecs.open(export_dir+"00_"+area_name+"_setup.txt", "w", "utf-8-sig") 
    with generated_setup as f:
        for row in reader.astype(str).itertuples():
            if sanitise_string(row.AREA) == area_name:
                # Ignore seazones, wastelands, impassables, lakes, rivers etc.
                if check_if_habitable(row.PROVID):
                    if row.TERRAIN in valid_terrains:
                        terrain = row.TERRAIN
                    elif row.PROVID in terrain_df[id_column].values:
                        terrain = terrain_df.loc[terrain_df[id_column] == row.PROVID][terrain_column].values[0] # Find the value of the terrain at the index of the current province
                    else:
                        terrain = ""
                    province_rank = row.PROVINCE_RANK
                    if province_rank == "0":
                        province_rank = "settlement"
                    elif province_rank == "1":
                        province_rank = "city"
                    elif province_rank == "2":
                        province_rank = "city_metropolis"

                    total_population = get_total_population(row)
                    
                    f.write(
                row.PROVID + '={ #' + row.NAME + '\n' +
                '   terrain="' + terrain + '"\n' +
                '   culture="' + row.CULTURE + '"\n' +
                '   religion="' + row.Religion + '"\n' +
                '   trade_goods="' + row.TRADEGOOD + '"\n' +
                '   civilization_value=' + row.INDUSTRIALISATION + '\n' +
                '   barbarian_power=' + row.unused + '\n' +
                '   province_rank="' + province_rank + '"\n'
                    )
                    if row.unused != "0":
                        f.write(
                '   citizen={\n' +
                '      amount=' + row.unused + '\n'
                '   }\n'
                        )
                    if row.indentured != "0":
                        f.write(
                '   indentured={\n' +
                '      amount=' + row.indentured + '\n'
                '   }\n' 
                        )
                    if row.slaves != "0":
                        f.write(
                '   slaves={\n' +
                '      amount=' + row.slaves + '\n'
                '   }\n' 
                        )
                    if row.tribesmen != "0":
                        f.write(
                '   tribesmen={\n' +
                '      amount=' + row.tribesmen + '\n'
                '   }\n' 
                        )
                # Below special for 1815 mod
                    if row.lower_strata != "0":
                        f.write(
                '   lower_strata={\n' +
                '      amount=' + row.lower_strata + '\n'
                '   }\n' 
                        )
                    if row.middle_strata != "0":
                        f.write(
                '   middle_strata={\n' +
                '      amount=' + row.middle_strata + '\n'
                '   }\n' 
                        )
                    if row.upper_strata != "0":
                        f.write(
                '      upper_strata={\n' +
                '         amount=' + row.upper_strata + '\n'
                '   }\n' 
                        )
                    if row.proletariat != "0":
                        f.write(
                '   proletariat={\n' +
                '      amount=' + row.proletariat + '\n'
                '   }\n' 
                        )
                # Only look at extra pops if there is data there
                    for extra_pop in extra_pops:
                        if row[extra_pop].replace(" ","_") in valid_pops and len(row[extra_pop]) < 14:
                            total_population = total_population + int(row[extra_pop+size].replace(".0",""))
                            f.write(
                    '   ' + row[extra_pop].replace(" ","_") + '={\n' +
                    '       amount=' + row[extra_pop+size].replace(".0","") + '\n' +
                    '       culture="' + row[extra_pop+culture] + '"\n' +
                    '       religion="' + row[extra_pop+religion] + '"\n' +
                    '   }\n'
                        )
                    f.write(
                '}\n\n'
                    )
            else:
                pass
