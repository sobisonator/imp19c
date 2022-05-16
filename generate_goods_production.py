def print_out_good(goods_name):
	goods_name = goods_name
	loc = """	GOODS_governorship_produce = {{
		do_if = produces_{goods_name}
		amount = GOODS_governorship_{goods_name}_produced
		into_stockpile = {goods_name}_stockpile
	}}""".format(goods_name=goods_name)
	print(loc)

all_goods = ["grain","fur","industrial_fibres","textile_fibres","wool","silk","wood","stone","sulphur","whales","gems","peat","tin","inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","temperate_fruit","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish"]

for good in all_goods:
	print_out_good(good)
