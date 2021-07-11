import re

non_area_provinces = open("../../map_data/default.map")
non_area_provinces_data = non_area_provinces.read()
pattern = "RANGE {(.*)}"
non_area_ranges = re.findall(pattern, non_area_provinces_data)
non_area_ranges = [i.split(" ") for i in non_area_ranges]
new_non_area_ranges = []
for x in non_area_ranges:
    x = [i for i in x if i]
    new_non_area_ranges.append(x)
non_area_ranges = new_non_area_ranges

def check_if_province_habitable(province_id):
    # Check if the province ID is any of the ranges specified
    try:
        province_id = int(province_id)
    except:
        return False
    for province_range in non_area_ranges:
        if province_id >= int(province_range[0]) and province_id <= int(province_range[1]):
            return False
    if " " + str(province_id) + " " not in non_area_provinces_data:
        return True
    else:
        return False

setup_main = open("00_default.txt")
setup_data = setup_main.read()
pattern_provinces = "(\d+)"
all_provinces = re.findall(pattern_provinces, setup_data)

for province in all_provinces:
    if not check_if_province_habitable(province):
        print(province)
