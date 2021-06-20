import glob, re
culture_files = glob.glob("*.txt")
        
    
unit_format = '%(culture_group_name)s_conscript_infantry = { \n\
    army = yes\n\
	assault = yes\n\
\n\
	levy_tier = basic\n\
\n\
	maneuver = 1\n\
	movement_speed = 2.4\n\
\n\
	build_time = 45\n\
	light_infantry = 1.25\n\
	heavy_infantry = 1.10\n\
	heavy_cavalry = 0.90\n\
	warelephant = 1.0\n\
	horse_archers = 1.0\n\
	archers = 1.0\n\
	camels = 0.9\n\
	light_cavalry = 0.9\n\
\n\
	supply_train = 2.0\n\
\n\
	attrition_weight = 0.9\n\
\n\
	morale_damage_taken = 1.3\n\
\n\
\n\
	attrition_loss = 0.07\n\
	ai_max_percentage = 15\n\
	build_cost = {\n\
		gold = 5\n\
		manpower = 1\n\
	}\n\
	food_consumption = 0.1\n\
	food_storage = 2.2\n\
}\n\n'

def write_conscripts(culture_files):
    for file in culture_files:
        with open(file, "r", encoding="utf-8") as f:
            filedata = f.read()
            filedata = filedata.replace("}\n\n	male_names", "}\n\
\n\
    levy_template = levy_conscripts\n\
\n\
    primary = conscripts\n\
    secondary = conscripts\n\
    flank = conscripts\n\
\n\
    primary_navy = tetrere\n\
    secondary_navy = octere\n\
    flank_navy = liburnian\n\
    male_names")
            f.close()
        with open(file, "w", encoding="utf-8") as f:
            f.write(filedata)
            f.close()
                           
write_conscripts(culture_files)
