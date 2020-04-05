import csv, codecs, re

# These columns may vary depending on what pops you have added to the game
# Change as necessary
id_column = 0
name_column = 11
culture_column = 1
religion_column = 2
tradegoods_column = 3
civilization_column = 8
barbarian_column = 9
province_rank_column = 10
area_column = 12
# Pop values
citizen_column = 4
freemen_column = 5
slaves_column = 6
tribesmen_column = 7

terrain_file = open("province_terrain/00_province_terrain.txt",encoding="utf=8")

def create_terrain_dict(terrain_file):
    terrain_txt = terrain_file.read()
    terrain_dict = {}
    for line in terrain_txt.splitlines(True):
        if line:
            key, value = map(str.strip, line.split("="))
            terrain_dict[key] = value
    return terrain_dict
    # This makes a VERY BIG DICT. Do NOT try to look at it
    # or you will unleash a cosmic terror

terrain_dict = create_terrain_dict(terrain_file)

def find_terrain(province_id):
    pass

setup_csv = open("province_setup.csv")
reader = csv.reader(setup_csv, delimiter=";")

generated_setup = codecs.open("GENERATED_SETUP.txt", "w", "utf-8-sig")

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

with generated_setup as f:
    for row in reader:
        # Ignore seazones, wastelands, impassables, lakes, rivers etc.
        if check_if_habitable(row[id_column]):
            if row[id_column] in terrain_dict:
                terrain = terrain_dict[row[id_column]]
            else:
                terrain = ""
            province_rank = row[province_rank_column]
            if province_rank == "":
                province_rank = "settlement"
            
            f.write(
        row[id_column] + '={ #' + row[name_column] + '\n' +
        '   terrain="' + terrain + '"\n' +
        '   culture="' + row[culture_column] + '"\n' +
        '   religion="' + row[religion_column] + '"\n' +
        '   trade_goods="' + row[tradegoods_column] + '"\n' +
        '   civilization_value=' + row[civilization_column] + '\n' +
        '   barbarian_power=' + row[barbarian_column] + '\n' +
        '   province_rank="' + province_rank + '"\n' +
        '   citizen={\n' +
        '      amount=' + row[citizen_column] + '\n'
        '   }\n' +
        '   freemen={\n' +
        '      amount=' + row[freemen_column] + '\n'
        '   }\n' +
        '   slaves={\n' +
        '      amount=' + row[slaves_column] + '\n'
        '   }\n' +
        '   tribesmen={\n' +
        '      amount=' + row[tribesmen_column] + '\n'
        '   }\n' +
        '}\n\n'
            )
