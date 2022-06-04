def print_out_good(goods_name):
	goods_name = goods_name
	loc = """GOODS_governorship_produced_manufactured = (
		industry_assigned = INDUSTRY_factories_assigned_{goods_name}
		amount = GOODS_governorship_{goods_name}_produced
		into_stockpile = {goods_name}_stockpile
	)""".format(goods_name=goods_name)
	print(loc)

all_goods = ["clothing","luxury_clothing","furniture","luxury_furniture","alcohol","household_wares","chemicals","rare_alloys","construction_materials","early_munitions","late_munitions","naval_supplies","steel_ships","wooden_ships","steel","bronze","machine_parts","early_artillery","late_artillery","paper","pharmaceuticals","motors","processed_foods"]

for good in all_goods:
	print_out_good(good)
