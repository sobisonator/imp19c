trade_zones = ["india","east_north_america","west_north_america","caribbean","west_south_america","east_south_america","south_east_asia","indo_china","yellow_sea","southern_africa","west_africa","east_africa","middle_east","western_steppe","eastern_steppe","upper_yangtzi","atlantic_seaboard","central_europe","west_mediterranean","baltic","east_europe","east_mediterranean"]
india_regions = ["Ceylon","South_India","Central_India","East_India","Indo-Gangetic_Plain","West_India","Punjab","Nepal","Burma","Eastern_Himalayas","Bay_of_Bengal","Maldives","Kashmir","Lan_Na"]
east_north_america_regions = ["Mid-Atlantic_South","Appalachia","Great_Forests","Great_Lakes","Mid-Atlantic","New_England","Ontario","Quebec","New_Brunswick","Nova_Scotia","Atlantic_Region","Greenland"]
west_north_america_regions = ["Pacific_Mexico","Northern_Mexico","American_Southwest","Great_Plains","Mountain_West","California","Cascadia","Praire_Provinces","British_Columbia","Alaska","Northern_Territories","Hawaii"]
caribbean_regions = ["Deep_South","Cuba","Antilles","Lucayan_Archipelago","Bermuda","Haiti","Eastern_Mexico"]
west_south_america_regions = ["Central_America","Colombia","Peru","Ecuador","Lower_Peru","Chile"]
east_south_america_regions = ["Venezuela","Guyana","North_Brazil","Northeast_Brazil","Center-West_Brazil","Southeast_Brazil","Paraguay","South_Brazil","Uruguay","Argentina","South_Atlantic_Islands","Patagonia"]
south_east_asia_regions = ["South_Island","North_Island","Fiji","Nouvelle-Caledonie","Vanuatu","Salomon_Islands","Tuvalu","Nauru","Gilbert_Islands","Caroline_Islands","Marshall_Islands","Guam","Mariana_Islands","Wake","Marcus_Island","Northern_Territory","South_Australia","Nusa_Tenggara","Tasmania","Western_Australia","Queensland","Johore","Borneo","Sulawesi","Sumatra","Christmas_Island","Palau","Bougainville_Island","New_Britain","New_Guinea","Maluku","Java","Cocos_Islands","Chagos"]
indo_china_regions = ["South_Siam","Tenasserim","Siam","Cambodia","Vietnam","Laos","Guangxi","Sichuan_Kham","Guangdong"]
yellow_sea_regions = ["Jiangxi","Fujian","Zhejiang","Anhui","Jiangsu","Henan","Shandong","Korea","Kyushu","Ezo","Honshu","Shikoku","Taiwan","Okinawa","Iwo_Jima","Mindanao","Visayas","Luzon"]
southern_africa_regions = ["South_Africa","Kalahari","Angola","Zimbabwe"]
west_africa_regions = ["Congo_Basin","Gulf_of_Guinea","Coastal_West_Africa","Sahel","Western_Sahara","Macaronesia","Comoro_Islands"]
east_africa_regions = ["east_africa","Mozambique","Madagascar","Lake_Victoria","Horn_of_Africa","Sudan","Seychelles","Arabian_Sea","Arabia"]
middle_east_regions = ["Eastern_Arabia","Southern_Iran","Arab_Iraq","Azerbaijan","Persian_Iraq","Caspian_Iran","Khurasan","Kerman","Balochistan","Pashtunistan","Tokharistan","Armenia","Bahrain"]
western_steppe_regions = ["Fergana","Bukhara","Turkestan","Khwarezm","Siberia","Kazan","Moscow"]
eastern_steppe_regions = ["Tannu_Tuva","Mongolia","Gansu","Shaanxi","Zhili","Liaoning","Far_East"]
upper_yangtzi_regions = ["Tibet","Shanxi","Qinghai","Yunnan","Guizhou","Hunan","Hubei"]
atlantic_seaboard_regions = ["Portugal","Andalusia","La_Mancha","Leon-Castille","Navarre","Atlantic_France","Grand_Est","Northern_France","Southern_England","Wales_Mercia","Northern_England","Ireland","Scotland","Iceland"]
central_europe_regions = ["Helvetia","Austria","Bavaria","Baden-Wurttemberg","Bohemia","Saxony","Low_Saxony","Brandenburg","Pomerania","Hessen","Westfalen","Low_Countries","Jutland"]
west_mediterranean_regions = ["Cisalpine_Italy","Provence_Liguria","Central_Italy","Corsica_and_Sardinia","Auvergne-Rhone-Alpes","Occitanie","Catalonia-Aragon","Valencia","Morocco","Algeria","Tunisia"]
baltic_regions = ["Denmark","Sweden","Norway","Saapmi","Finland","Sankt-Petersburg","Baltic_states","Prussia","Aland_Islands","Bornholm","Poland"]
east_europe_regions = ["Galicia","Minsk","Kiev","Subcarpathia","Pannonia","Bulgaria","Odessa","Black_Sea","Caucasus","Voiska_Donskova"]
east_mediterranean_regions = ["Illyria","Rumelia","Southern_Italy","Sicily","Libya","Crete","Egypt","Levant","Syria","Anatolia","Cyprus","Cilicia","Aegean","Marmara","Venetia","Malta"]
trade_zones_dict = {'india':[india_regions],
		   		'east_north_america':[east_north_america_regions],
		   		'west_north_america':[west_north_america_regions],
		   		'caribbean':[caribbean_regions],
		   		'west_south_america':[west_south_america_regions],
		   		'east_south_america':[east_south_america_regions],
		   		'south_east_asia':[south_east_asia_regions],
		   		'indo_china':[indo_china_regions],
		   		'yellow_sea':[yellow_sea_regions],
		   		'southern_africa':[southern_africa_regions],
		   		'west_africa':[west_africa_regions],
		   		'east_africa':[east_africa_regions],
		   		'middle_east':[middle_east_regions],
		   		'western_steppe':[western_steppe_regions],
		   		'eastern_steppe':[eastern_steppe_regions],
		   		'upper_yangtzi':[upper_yangtzi_regions],
		   		'atlantic_seaboard':[atlantic_seaboard_regions],
		   		'central_europe':[central_europe_regions],
		   		'west_mediterranean':[west_mediterranean_regions],
		   		'baltic':[baltic_regions],
		   		'east_europe':[east_europe_regions],
		   		'east_mediterranean':[east_mediterranean_regions]}

def print_scripted_triggers(trade_zone):
	print("{trade_zone}_tradezone = {{\n    trigger_if = {{\n        limit = {{\n            $PROVINCE$ = yes\n        }}\n        OR = {{\n".format(trade_zone=trade_zone))
	for x in trade_zones_dict.get(trade_zone):
		for i in x:
			print("            is_in_region = {i}".format(i=i))
	print("        }")
	print("    }")
	print("    trigger_else = {\n        limit = {\n            $PROVINCE$ = no\n        }\n        OR = {")
	for x in trade_zones_dict.get(trade_zone):
		for i in x:
			print("            this = region:{i}".format(i=i))
	print("        }")
	print("    }")
	print("}")

def print_goods_produced_values(trade_zone):
	print("{trade_zone}_total_goods = {{\n    value = 0\n".format(trade_zone=trade_zone))
	for x in trade_zones_dict.get(trade_zone):
		for i in x:
			print("    region:{i} = {{\n        every_region_province = {{\n            add = num_goods_produced\n        }}\n    }}".format(i=i))
	print("}")

def print_population_values(trade_zone):
	print("{trade_zone}_total_population = {{\n    value = 0\n".format(trade_zone=trade_zone))
	for x in trade_zones_dict.get(trade_zone):
		for i in x:
			print("    region:{i} = {{\n        every_region_province = {{\n            add = total_population\n        }}\n    }}".format(i=i))
	print("}")

def print_custom_loc(trade_zone):
	x = 0
	print("state_trade_zone_loc = {\n    type = province\n")
	for i in trade_zones:
		x = x + 1
		print("    text = {{\n        localization_key = state_trade_zone_loc_{x}\n        trigger = {{\n            {i}_tradezone = {{ PROVINCE = yes }}\n        }}\n    }}".format(trade_zone=trade_zone,x=x,i=i))
	print("    text = {\n        localization_key = state_trade_zone_loc_fallback\n        trigger = {\n            always = yes\n        }\n    }")
	print("}")
	x = 0
	print("state_trade_zone_value_loc = {\n    type = province\n")
	for i in trade_zones:
		x = x + 1
		print("    text = {{\n        localization_key = state_trade_zone_value_loc_{x}\n        trigger = {{\n            {i}_tradezone = {{ PROVINCE = yes }}\n        }}\n    }}".format(trade_zone=trade_zone,x=x,i=i))
	print("    text = {\n        localization_key = state_trade_zone_value_loc_fallback\n        trigger = {\n            always = yes\n        }\n    }")
	print("}")

def print_tradezone_localization(trade_zones):
	x = 0
	for i in trade_zones:
		caps_name = i.replace("_", " ").title()
		x = x + 1
		print("state_trade_zone_loc_{x}:0 \"{caps_name}\"".format(caps_name=caps_name,x=x))
	print("state_trade_zone_loc_fallback:0 \"0\"\n")
	x = 0
	for i in trade_zones:
		x = x + 1
		print("state_trade_zone_value_loc_{x}:0 \"[GuiScope.SetRoot( Player.MakeScope ).ScriptValue('{i}_total_goods')|0]\"".format(i=i,x=x))
	print("state_trade_zone_value_loc_fallback:0 \"0\"")

#FUNCTION 1: Purpose - Print trade zone scripted triggers
#for trade_zone in trade_zones_dict:
#  print_scripted_triggers(trade_zone)

#FUNCTION 2: Purpose - Print trade zone goods produced script values
#for trade_zone in trade_zones_dict:
#  print_goods_produced_values(trade_zone)

#FUNCTION 3: Purpose - Print trade zone population script values
#for trade_zone in trade_zones_dict:
#  print_population_values(trade_zone)

#FUNCTION 4: Purpose - Print trade zone custom localization
#print_custom_loc(trade_zones)

#FUNCTION 5: Purpose - Print trade zone localization
#print_tradezone_localization(trade_zones)
