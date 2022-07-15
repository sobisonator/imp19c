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
reader = pd.read_csv(setup_csv, sep=";")
reader = reader.fillna("0")
reader["indentured"] = reader["indentured"].astype("int32")
reader["tribesmen"] = reader["tribesmen"].astype("int32")
reader["slaves"] = reader["slaves"].astype("int32")
reader["upper_strata"] = reader["upper_strata"].astype("int32")
reader["middle_strata"] = reader["middle_strata"].astype("int32")
reader["lower_strata"] = reader["lower_strata"].astype("int32")
reader["proletariat"] = reader["proletariat"].astype("int32")
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
        for row in reader.itertuples():
            if sanitise_string(row.AREA) == area_name:
                # Ignore seazones, wastelands, impassables, lakes, rivers etc.
                if check_if_habitable(row.PROVID):
                    if str(row.TERRAIN) in valid_terrains:
                        terrain = row.TERRAIN
                    elif row.PROVID in terrain_df[id_column].values:
                        terrain = terrain_df.loc[terrain_df[id_column] == row.PROVID][terrain_column].values[0] # Find the value of the terrain at the index of the current province
                    else:
                        terrain = ""
                    province_rank = row.PROVINCE_RANK
                    if int(province_rank) == 0:
                        province_rank = "settlement"
                    elif int(province_rank) == 1:
                        province_rank = "city"
                    elif int(province_rank) == 2:
                        province_rank = "city_metropolis"

                    total_population = get_total_population(row)
                    
                    f.write(
                str(row.PROVID) + '={ #' + row.NAME + '\n' +
                '   terrain="' + str(terrain).replace(" ","") + '"\n' +
                '   culture="' + str(row.CULTURE).replace(" ","") + '"\n' +
                '   religion="' + str(row.Religion).replace(" ","") + '"\n' +
                '   trade_goods="' + str(row.TRADEGOOD).replace(" ","") + '"\n' +
                '   civilization_value=' + str(row.INDUSTRIALISATION).replace(" ","") + '\n' +
                '   barbarian_power=' + str(row.unused).replace(" ","") + '\n' +
                '   province_rank="' + str(province_rank).replace(" ","") + '"\n'
                    )
                    if int(row.unused) != 0:
                        f.write(
                '   citizen={\n' +
                '      amount=' + row.unused.replace(" ","") + '\n'
                '   }\n'
                        )
                    if int(row.indentured) != 0:
                        f.write(
                '   indentured={\n' +
                '      amount=' + str(int(row.indentured)).replace(" ","") + '\n'
                '   }\n' 
                        )
                    if int(row.slaves) != 0:
                        f.write(
                '   slaves={\n' +
                '      amount=' + str(int(row.slaves)).replace(" ","") + '\n'
                '   }\n' 
                        )
                    if int(row.tribesmen) != 0:
                        f.write(
                '   tribesmen={\n' +
                '      amount=' + str(int(row.tribesmen)).replace(" ","") + '\n'
                '   }\n' 
                        )
                # Below special for 1815 mod
                    if int(row.lower_strata) != 0:
                        f.write(
                '   lower_strata={\n' +
                '      amount=' + str(int(row.lower_strata)).replace(" ","") + '\n'
                '   }\n' 
                        )
                    if int(row.middle_strata) != 0:
                        f.write(
                '   middle_strata={\n' +
                '      amount=' + str(int(row.middle_strata)).replace(" ","") + '\n'
                '   }\n' 
                        )
                    if int(row.upper_strata) != 0:
                        f.write(
                '      upper_strata={\n' +
                '         amount=' + str(int(row.upper_strata)).replace(" ","") + '\n'
                '   }\n' 
                        )
                    if int(row.proletariat) != 0:
                        f.write(
                '   proletariat={\n' +
                '      amount=' + str(int(row.proletariat)).replace(" ","") + '\n'
                '   }\n' 
                        )
                # Only look at extra pops if there is data there
                    for extra_pop in extra_pops:
                        if row[extra_pop].replace(" ","_") in valid_pops:
                            total_population = total_population + int(row[extra_pop+size])
                            f.write(
                    '   ' + row[extra_pop].replace(" ","_") + '={\n' +
                    '       amount=' + str(row[extra_pop+size]).replace(".0","") + '\n' +
                    '       culture="' + row[extra_pop+culture] + '"\n' +
                    '       religion="' + row[extra_pop+religion] + '"\n' +
                    '   }\n'
                            )
                    f.write('}\n\n')
            else:
                pass
