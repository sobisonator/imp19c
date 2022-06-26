def print_out_good(goods_name):
	caps_name = goods_name.upper()
	lowercase_name = goods_name.lower()
	initial_cap_name = goods_name.capitalize()
	loc = """PROVWINDOW_GOV_{caps_name}_STOCKPILE:0 "[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('GOODS_{lowercase_name}_stockpile')|0]"
PROVWINDOW_GOV_{caps_name}_NUM_FACTORIES:0 "x[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('INDUSTRY_{lowercase_name}_factories')|0]"
PROVWINDOW_GOV_{caps_name}_PRODUCED_TT:0 "#T {initial_cap_name} produced in [ProvinceWindow.GetState.GetGovernorship.GetName]#!: [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('GOODS_governorship_{lowercase_name}_produced')|0]\n""""".format(caps_name=caps_name,lowercase_name=lowercase_name,initial_cap_name=initial_cap_name)
	print(loc)

all_goods = ["clothing","luxury_clothing","furniture","luxury_furniture","alcohol","glass","chemicals","rare_alloys","construction_materials","early_munitions","late_munitions","naval_supplies","steel_ships","wooden_ships","steel","bronze","machine_parts","early_artillery","late_artillery","electronics","pharmaceuticals","motors","processed_foods","petrochemicals"]

for good in all_goods:
	print_out_good(good)
