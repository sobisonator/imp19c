def print_out_good(tradegood_name, category_name):
	tradegood = tradegood_name
	category = category_name
	tradegood_caps = tradegood.upper()
	loc = '''PROVWINDOW_GOV_{tradegood_caps}_STOCKPILE:0 "[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('GOODS_governorship_{tradegood}_produced')|0]"
PROVWINDOW_GOV_{tradegood_caps}_PRODUCED_TT:0 "#T {tradegood} produced in [ProvinceWindow.GetState.GetGovernorship.GetName]:#! #G [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('GOODS_governorship_{tradegood}_produced')|0] #! \\n #T Current unfulfilled food demand:#! #X [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_unfulfilled_food_need_governorship')|0]#! \\n #T Current demand for {tradegood}:#! #X [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_actual_{tradegood}')|0]#! \\n #T Trade balance:#! [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_difference_{tradegood}')|0+=] \\n #T Price of {tradegood} compared to average food cost :#! [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_{tradegood}_price_diff_to_food_avg')|%] \\n #T Mean Absolute Deviation from average food cost :#! £[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_food_price_MAD')|3] \\n #T MAD weighted average food cost :#! £[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_food_avg_price_normalised')|3] \\n #T Average food cost :#! £[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_food_avg_price')|3] / unit \\n \\n#T Price of {tradegood} here :#! £[ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('price_{tradegood}').GetValue|3] / unit\\n#T Amount spent on essential_goods imports last quarter :#! \\n#X £[ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('governorship_this_quarter_spend_on_essential_goods').GetValue|3]#!\\n    #T Of which tax:#! #X £[ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('governorship_quarterly_revenue_from_internal_sales_tax_essential_goods').GetValue|3]#! #T at #![ProvinceWindow.GetProvince.GetOwner.MakeScope.Var('internal_sales_tax_rate').GetValue|%] #T tax rate #!\\n#T Amount made from essential_goods exports last quarter :#! \\n#G £[ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('governorship_this_quarter_income_from_essential_goods').GetValue|3] #! \\n ITS {tradegood} available [ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('internal_trade_scope').GetCountry.MakeScope.Var('supply_ITS_{tradegood}').GetValue|3] \\n Base trade wealth balance for {tradegood}: £[ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('this_quarter_balance_{tradegood}').GetValue|3]\\n Consumer demand for {tradegood}: [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_consumer_{tradegood}')|0] "'''.format(tradegood=tradegood,category=category,tradegood_caps = tradegood_caps)
	print(loc)


#all_goods = ["grain","fur","industrial_fibres","textile_fibres","wool","silk","wood","stone","sulphur","whales","gems","peat","tin","inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","temperate_fruit","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish","clothing","luxury_clothing","furniture","luxury_furniture","alcohol","glass","chemicals","rare_alloys","construction_materials","early_munitions","late_munitions","naval_supplies","steel_ships","wooden_ships","steel","bronze","machine_parts","early_artillery","late_artillery","electronics","pharmaceuticals","motors","processed_foods","petrochemicals"]
all_categories = ["food","essential_goods","luxury_goods","business_goods","military_goods"]

all_spenders = ["upper_strata","middle_strata","lower_strata","proletariat","tribesmen","indentured","slaves","the_state"]

all_goods = {
	"grain":"food",
	"fish":"food",
	"livestock":"food",
        "vegetables":"food",
	"tropical_fruit":"food",
	"mediterranean_fruit":"food",
	"temperate_fruit":"food",
	"processed_foods":"food",
	"clothing":"essential_goods",
	"furniture":"essential_goods",
	"pharmaceuticals":"essential_goods",
	"coal":"essential_goods",
	"whales":"essential_goods",
	"alcohol":"luxury_goods",
	"gems":"luxury_goods",
	"opium":"luxury_goods",
	"tobacco":"luxury_goods",
	"chocolate":"luxury_goods",
	"coffee":"luxury_goods",
	"tea":"luxury_goods",
	"spices":"luxury_goods",
	"sugar":"luxury_goods",
	"luxury_clothing":"luxury_goods",
	"luxury_furniture":"luxury_goods",
	"glass":"luxury_goods",
	"motors":"luxury_goods",
	"fur":"business_goods",
	"industrial_fibres":"business_goods",
	"textile_fibres":"business_goods",
	"wool":"business_goods",
	"silk":"business_goods",
	"wood":"business_goods",
	"stone":"business_goods",
	"sulphur":"business_goods",
	"peat":"business_goods",
	"tin":"business_goods",
	"inorganic_compounds":"business_goods",
	"copper":"business_goods",
	"iron":"business_goods",
	"gold":"business_goods",
	"silver":"business_goods",
	"dye":"business_goods",
	"lead":"business_goods",
	"oil":"business_goods",
	"hardwood":"business_goods",
	"rubber":"business_goods",
	"salt":"business_goods",
	"electronics":"business_goods",
	"construction_materials":"business_goods",
	"steel":"business_goods",
	"bronze":"business_goods",
	"machine_parts":"business_goods",
	"chemicals":"business_goods",
	"naval_supplies":"business_goods",
	"steel_ships":"business_goods",
	"wooden_ships":"business_goods",
	"petrochemicals":"business_goods",
	"early_munitions":"military",
	"late_munitions":"military",
	"early_artillery":"military",
	"late_artillery":"military"
        }

for tradegood, category in all_goods.items():
        if category == "food":
                print_out_good(tradegood, category)
