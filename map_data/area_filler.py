import re, numbers

with open("all_province_id_list.txt") as f:
    all_provs = [line.rstrip('\n') for line in f]
    with open("areas.txt") as f2:
        areas = [re.sub('[\\t\\n]','',line) for line in f2]
        areas = [x for x in areas if x.isdigit()]
        provs_sans_areas = [x for x in all_provs if x not in areas]
        for prov in provs_sans_areas:
            print(prov)
                
