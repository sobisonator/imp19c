def print_out_good(goods_name):
	caps_name = goods_name.upper()
	lowercase_name = goods_name.lower()
	initial_cap_name = goods_name.capitalize()
	loc = """GOODS_update_if_governorship_produces = {
		goods = {goods}
		if_true = produces_{goods}
	}""".format(caps_name=caps_name,lowercase_name=lowercase_name,initial_cap_name=initial_cap_name)
	print(loc)

all_goods = ["inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","temperate_fruit","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish"]

for good in all_goods:
	print_out_good(good)