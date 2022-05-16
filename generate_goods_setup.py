def print_out_good(goods_name):
	goods_name = goods_name
	loc = """	if = {{
		limit = {{
			has_variable = produces_{goods_name}
		}}
		set_variable = {{
			name = {goods_name}_stockpile
			value = GOODS_governorship_{goods_name}_produced
		}}
	}}
	else = {{
		set_variable = {{
			name = {goods_name}_stockpile
			value = 0
		}}
	}}""".format(goods_name=goods_name)
	print(loc)

all_goods = ["grain","fur","industrial_fibres","textile_fibres","wool","silk","wood","stone","sulphur","whales","gems","peat","tin","inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","temperate_fruit","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish"]

for good in all_goods:
	print_out_good(good)
