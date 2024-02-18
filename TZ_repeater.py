def print_TZ_statement(TZ):
	loc = """#---------------------------------------
#Trade Zone: {tradezone}
#---------------------------------------

{tradezone}_transportation_svalue = {{    
    value = 0
    every_{tradezone}_TZ_region = {{
        if = {{
            limit = {{
                any_region_province = {{
                    OR = {{
                        any_neighbor_province = {{ has_road_towards = PREV }}
                        has_building = port_building
                    }}
                }}
            }}
            every_region_province = {{
                limit = {{
                    any_neighbor_province = {{ has_road_towards = PREV }}
                }}
                add = railway_bonus
            }}
            every_region_province = {{
                limit = {{
                    has_building = port_building
                }}
                add = port_bonus
            }}
        }}
    }}
}}""".format(tradezone=TZ)
	print(loc)

#all_goods = ["grain","fur","industrial_fibres","textile_fibres","wool","silk","wood","stone","sulphur","whales","gems","peat","tin","inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","temperate_fruit","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish","clothing","luxury_clothing","furniture","luxury_furniture","alcohol","glass","chemicals","rare_alloys","construction_materials","early_munitions","late_munitions","naval_supplies","steel_ships","wooden_ships","steel","bronze","machine_parts","early_artillery","late_artillery","electronics","pharmaceuticals","motors","processed_foods","petrochemicals"]
all_TZs = ["india",
           "east_north_america",
           "west_north_america",
           "caribbean",
           "west_south_america",
           "east_south_america",
           "south_east_asia",
           "indo_china",
           "yellow_sea",
           "southern_africa",
           "west_africa",
           "east_africa",
           "middle_east",
           "western_steppe",
           "eastern_steppe",
           "upper_yangtzi",
           "atlantic_seaboard",
           "central_europe",
           "west_mediterranean",
           "baltic",
           "east_europe",
           "east_mediterranean"]

for TZ in all_TZs:
        print_TZ_statement(TZ = TZ)
