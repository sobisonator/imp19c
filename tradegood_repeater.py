def print_out_good(goods_name, category_name):
	goods_name = goods_name
	category_name = category_name
	loc = """TRADE_governorship_export_cap_{goods_name} = {{ # The upper limit over which a governorship is NOT allowed to export any of this good. Should be derived from a variable
# FOR NOW, THIS IS JUST A TEST AND HAS NO VARIABLE FROM WHICH IT DERIVES
	value = 100
}}\n""".format(goods_name=goods_name,category_name=category_name)
	print(loc)

#all_goods = ["grain","fur","industrial_fibres","textile_fibres","wool","silk","wood","stone","sulphur","whales","gems","peat","tin","inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","temperate_fruit","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish","clothing","luxury_clothing","furniture","luxury_furniture","alcohol","glass","chemicals","rare_alloys","construction_materials","early_munitions","late_munitions","naval_supplies","steel_ships","wooden_ships","steel","bronze","machine_parts","early_artillery","late_artillery","electronics","pharmaceuticals","motors","processed_foods","petrochemicals"]
#all_categories = ["essentials","luxuries","business_goods","military"]

all_goods = {
	"grain":"essentials",
	"fish":"essentials",
	"livestock":"essentials",
	"tropical_fruit":"essentials",
	"mediterranean_fruit":"essentials",
	"temperate_fruit":"essentials",
	"processed_foods":"essentials",
	"clothing":"essentials",
	"furniture":"essentials",
	"pharmaceuticals":"essentials",
	"coal":"essentials",
	"whales":"essentials",
	"alcohol":"luxuries",
	"gems":"luxuries",
	"opium":"luxuries",
	"tobacco":"luxuries",
	"chocolate":"luxuries",
	"coffee":"luxuries",
	"tea":"luxuries",
	"spices":"luxuries",
	"sugar":"luxuries",
	"luxury_clothing":"luxuries",
	"luxury_furniture":"luxuries",
	"glass":"luxuries",
	"motors":"luxuries",
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
