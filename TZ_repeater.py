def print_TZ_statement(TZ):
	loc = """SHIPPING_earned_from_{tradezone} = {{
	value = 0
	global_var:global_{tradezone}_tradezone = {{
		if = {{
			limit = {{
				any_in_list = {{
					variable = shipping_power_list
					var:tracking_TZ_shipping_for_tag = ROOT
				}}
			}}
			add = var:TZ_this_quarter_transport_pool
			random_in_list = {{
				variable = shipping_power_list
				limit = {{
					var:tracking_TZ_shipping_for_tag = ROOT
				}}
				multiply = SHIPPING_percentage_in_TZ
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
