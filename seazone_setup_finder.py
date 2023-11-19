import os, codecs, re

seazone_list = [4706, 2294, 10015, 10014, 4698, 2382, 10008, 4817, 4818, 2283, 7281, 10007, 18312, 13259, 4824, 10039, 4834, 7287, 13243, 4723, 2284, 10040, 10056, 4835, 4722, 4721, 2299, 2395, 10006, 7254, 7305, 7255, 4854, 4848, 4725, 4726, 2415, 4858, 7301, 7296, 4764, 2348, 2410, 10086, 10089, 4769, 10087, 4783, 7272, 2359, 4808, 7256, 2372, 10088, 7273, 4809, 4770, 8702, 7274, 7241, 2417, 4863, 7307, 2304, 10041, 4862, 7306, 10121, 7227, 4684, 7224, 10170, 10169, 10171, 10166, 2396, 2303, 10157, 143000, 11859, 7004, 3151, 9171, 3815, 7164, 1425, 10010, 2, 6229, 3608, 6452, 8594, 2285, 7370, 2596, 1560, 10057, 5044, 7540, 4861, 2471, 5771, 7560, 4536, 158, 6068, 3607, 609, 2420, 1677, 4215, 6066, 1944, 3606, 610, 2799, 1404, 8433, 8327, 9004, 6936, 2891, 7945, 4571, 5800, 1, 2351, 6290, 1665, 2470, 8758, 625, 4720, 1578, 5189, 7113, 6067, 8011, 9228, 6030, 451, 1623, 7783, 611, 10740, 4440, 2307, 2833, 7313, 1301, 6158, 4866, 6007, 7286, 338, 8851, 4168, 7312, 1868, 3231, 640, 6054, 1244, 6527, 4779, 7238, 388, 5574, 9695, 8216]

province_setup_dir = "setup/provinces/"

def check_seazone_setup(seazone, content, file):
	if str(seazone) in content:
		result = re.search("(?s)(\n"+str(seazone)+"={)(.*)(?=barbarian_power)", content)
		if result:
			civilization_value = re.search("civilization_value=(.*)\n",result.group(2))
			if int(civilization_value.group(1)) > 0:
				print(str(seazone) + " has civilization "+ civilization_value.group(1))

def check_seazone_range(start, end, content, file):
	seazone = start
	while seazone < end:
		check_seazone_setup(seazone, content, file)
		seazone = seazone + 1

for file in os.listdir(province_setup_dir):
	if file.endswith(".txt"):
		with codecs.open(province_setup_dir + file, "r", encoding="utf-8") as openfile:
			content = openfile.read()
			for seazone in seazone_list:
				check_seazone_setup(seazone, content, file)
			check_seazone_range(10173, 10738, content, file)
			check_seazone_range(10741, 11858, content, file)
			check_seazone_range(11860, 13258, content, file)