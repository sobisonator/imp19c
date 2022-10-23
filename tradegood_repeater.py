def print_out_good(tradegood_name, category_name):
	tradegood = tradegood_name
	category = category_name
	tradegood_caps = tradegood.upper()
	loc = """PROVWINDOW_GOV_{tradegood_caps}_STOCKPILE:0 "[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('GOODS_{tradegood}_stockpile')|0]"
PROVWINDOW_GOV_{tradegood_caps}_PRODUCED_TT:0 "#T {tradegood} produced in [ProvinceWindow.GetState.GetGovernorship.GetName]#!: [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('GOODS_governorship_{tradegood}_produced')|0] \\n\\n #T Current {tradegood} demand#!: [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_{tradegood}')|0] \\n #T {tradegood} available for trade internally last quarter:#! [ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('internal_offered_{tradegood}').GetValue|0] \\n [ProvinceWindow.GetProvince.Custom('internal_trade_scope_custom_loc')] \\n\\n#T Price of {tradegood} here :#! £[ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('trade_center').GetProvince.MakeScope.Var('local_price_{tradegood}').GetValue|3] / unit\\n#T Amount spent on {category} imports last quarter :#! £[ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('governorship_this_quarter_spend_on_{category}').GetValue|3]\\n#T Amount made from {category} exports last quarter :#! £[ProvinceWindow.GetState.GetGovernorship.MakeScope.Var('governorship_this_quarter_income_from_{category}').GetValue|3]"\\n\n\n""".format(tradegood=tradegood,category=category,tradegood_caps = tradegood_caps)
	print(loc)

#all_goods = ["grain","fur","industrial_fibres","textile_fibres","wool","silk","wood","stone","sulphur","whales","gems","peat","tin","inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","temperate_fruit","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish","clothing","luxury_clothing","furniture","luxury_furniture","alcohol","glass","chemicals","rare_alloys","construction_materials","early_munitions","late_munitions","naval_supplies","steel_ships","wooden_ships","steel","bronze","machine_parts","early_artillery","late_artillery","electronics","pharmaceuticals","motors","processed_foods","petrochemicals"]
all_categories = ["essential_goods","luxury_goods","business_goods","military_goods"]

all_spenders = ["upper_strata","middle_strata","lower_strata","proletariat","tribesmen","indentured","slaves","the_state"]

all_goods = {
	"grain":"essential_goods",
	"fish":"essential_goods",
	"livestock":"essential_goods",
	"tropical_fruit":"essential_goods",
	"mediterranean_fruit":"essential_goods",
	"temperate_fruit":"essential_goods",
	"processed_foods":"essential_goods",
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
    print_out_good(tradegood, category)
