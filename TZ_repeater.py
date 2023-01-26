def print_TZ_statement(TZ):
	loc = """		if = {{
			limit = {{
				has_variable_list = governorships_in_{TZ}
			}}
			every_in_list = {{
				variable = governorships_in_{TZ}
				remove_from_list = governorships_in_{TZ}
			}}
		}}""".format(TZ=TZ)
	print(loc)

#all_goods = ["grain","fur","industrial_fibres","textile_fibres","wool","silk","wood","stone","sulphur","whales","gems","peat","tin","inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","temperate_fruit","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish","clothing","luxury_clothing","furniture","luxury_furniture","alcohol","glass","chemicals","rare_alloys","construction_materials","early_munitions","late_munitions","naval_supplies","steel_ships","wooden_ships","steel","bronze","machine_parts","early_artillery","late_artillery","electronics","pharmaceuticals","motors","processed_foods","petrochemicals"]
all_TZs = ["india_tradezone",
           "east_north_america_tradezone",
           "west_north_america_tradezone",
           "caribbean_tradezone",
           "west_south_america_tradezone",
           "east_south_america_tradezone",
           "south_east_asia_tradezone",
           "indo_china_tradezone",
           "yellow_sea_tradezone",
           "southern_africa_tradezone",
           "west_africa_tradezone",
           "east_africa_tradezone",
           "middle_east_tradezone",
           "western_steppe_tradezone",
           "eastern_steppe_tradezone",
           "upper_yangtzi_tradezone",
           "atlantic_seaboard_tradezone",
           "central_europe_tradezone",
           "west_mediterranean_tradezone",
           "baltic_tradezone",
           "east_europe_tradezone",
           "east_mediterranean_tradezone"]

for TZ in all_TZs:
        print_TZ_statement(TZ = TZ)
