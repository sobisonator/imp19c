def print_out_good(goods_name):
	caps_name = goods_name.upper()
	lowercase_name = goods_name.lower()
	initial_cap_name = goods_name.capitalize()
	loc = """\nPROVWINDOW_GOV_{caps_name}_STOCKPILE:0 "[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('GOODS_{lowercase_name}_stockpile')|0]"\nPROVWINDOW_GOV_{caps_name}_PRODUCED_TT:0 "#T {initial_cap_name} produced in [ProvinceWindow.GetState.GetGovernorship.GetName]#!: [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('GOODS_governorship_{lowercase_name}_produced')|0]"\n""".format(caps_name=caps_name,lowercase_name=lowercase_name,initial_cap_name=initial_cap_name)
	print(loc)

all_goods = ["inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish"]

for good in all_goods:
	print_out_good(good)