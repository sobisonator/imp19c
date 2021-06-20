import glob, re, codecs
culture_files = glob.glob("*.txt")

conscripts_folder = "conscripts/"        
    
unit_format = '\ufeff%(culture_group_name)s_conscript_infantry = { \n\
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

levy_template_format = "%(culture_group_name)s_levy_template = {\n\
	default = yes\n\
\n\
	%(culture_group_name)s_conscript_infantry = 1.0\n\
}\n\n"

def write_conscripts(culture_files):
   for file in culture_files:
       with open(file, "r", encoding="utf-8") as f:
           culture_group_name = re.sub(r' #.*', '', f.readline())
           culture_group_name = re.sub('[^a-zA-Z_]+', '', culture_group_name)
           culture_group_name = culture_group_name.replace("\ufeff", "")
           culture_group_name = culture_group_name.replace("-", "")
           f.close()
       with codecs.open("00_imp19c_levy_templates.txt","a", encoding="utf-8-sig") as f:
           f.write(levy_template_format % {"culture_group_name": culture_group_name})
           f.close()
       with open (conscripts_folder+culture_group_name+"_conscript_infantry.txt","w", encoding="utf-8") as conscripts_txt:
           conscripts_txt.write(unit_format % {"culture_group_name": culture_group_name})
           conscripts_txt.close()
       with open(file, "r", encoding="utf-8") as f:
           filedata = f.read()
           filedata = filedata.replace("= {\n	color", "= {\
    \n\
    levy_template = "+culture_group_name+"_levy_template\n\
    \n\
    primary = "+culture_group_name+"_conscript_infantry\n\
    secondary = "+culture_group_name+"_conscript_infantry\n\
    flank = "+culture_group_name+"_conscript_infantry\n\
    \n\
    primary_navy = tetrere\n\
    secondary_navy = octere\n\
    flank_navy = liburnian\n\
    color")
           f.close()
           
       with open(file,"w", encoding="utf-8") as f:
           f.write(filedata)
           f.close()
           
write_conscripts(culture_files)
