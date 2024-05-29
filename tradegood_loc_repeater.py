def print_out_good(tradegood_name):
  tradegood = tradegood_name
  tradegood_caps = tradegood.upper()
  loc = '''#{tradegood}									
									industrial_goods_widget = {{
									    blockoverride "Icon"
									    {{
									        texture = "gfx/interface/icons/tradegoods/{tradegood}.dds"
									    }}
									    blockoverride "VisibleTrigger"
									    {{
									    	visible = "[GreaterThan_CFixedPoint( ProvinceWindow.GetState.GetGovernorship.MakeScope.GetVariable('INDUSTRY_factories_assigned_{tradegood}').GetValue, '(CFixedPoint)0' )]"
									    }}
									    blockoverride "AssignedText"
									    {{
									    	text = "#T [ProvinceWindow.GetState.GetGovernorship.MakeScope.GetVariable('INDUSTRY_factories_assigned_{tradegood}').GetValue|0]"
									    }}
									    blockoverride "ButtonTooltip"
									    {{
									    	tooltip = "PROVWINDOW_GOV_{tradegood_caps}_PRODUCED_TT"
									    }}
									    blockoverride "StockpileText"
									    {{
									        text = "PROVWINDOW_GOV_{tradegood_caps}_STOCKPILE"
									    }}
									    blockoverride "BalanceTooltip"
									    {{
									    	tooltip = "Stockpile: #H [ProvinceWindow.GetState.GetGovernorship.MakeScope.GetVariable('{tradegood}_stockpile').GetValue|0] #! Demand: #R [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_{tradegood}')|0] #!/ Production: #G [GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('GOODS_governorship_{tradegood}_produced')|0]"
									    }}
									    blockoverride "CashBalanceText"
									    {{
									    	text = "£[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('TRADE_governorship_cash_balance_{tradegood}')|3+=]"
									    }}
									    blockoverride "CashBalanceTooltip"
									    {{
									    	tooltip = "Imports: #R [ProvinceWindow.GetState.GetGovernorship.MakeScope.GetVariable('order_size_{tradegood}').GetValue|0] #!Exports: #G [ProvinceWindow.GetState.GetGovernorship.MakeScope.GetVariable('amount_exported_{tradegood}').GetValue|0]"
									    }}
									    blockoverride "BalanceText"
									    {{
									    	text = "[GuiScope.SetRoot(ProvinceWindow.GetState.GetGovernorship.MakeScope).ScriptValue('DEMAND_difference_{tradegood}')|0+=]"
									    }}
									    blockoverride "On_click"
									    {{
									       enabled = "[EqualTo_CFixedPoint( GuiScope.SetRoot(ProvinceWindow.GetProvince.GetOwner.MakeScope).ScriptValue('INDUSTRY_unlocked_{tradegood}'), '(CFixedPoint)1' )]"
									        onclick = "[GetScriptedGui('add_{tradegood}_button').Execute( GuiScope.SetRoot( ProvinceWindow.GetState.GetGovernorship.MakeScope ).AddScope('player', Player.MakeScope ).End )]"
									    }}
									    blockoverride "On_rightclick"
									    {{
									        onrightclick = "[GetScriptedGui('remove_{tradegood}_button').Execute( GuiScope.SetRoot( ProvinceWindow.GetState.GetGovernorship.MakeScope ).AddScope('player', Player.MakeScope ).End )]"
									    }}										
									}}'''.format(tradegood=tradegood, tradegood_caps=tradegood.upper())
  print(loc)


#all_goods = ["grain","fur","industrial_fibres","textile_fibres","wool","silk","wood","stone","sulphur","whales","gems","peat","{tradegood}","inorganic_compounds","copper","iron","gold","silver","lead","coal","oil","tea","coffee","opium","tobacco","sugar","hardwood","rubber","dye","spices","temperate_fruit","tropical_fruit","mediterranean_fruit","chocolate","livestock","salt","fish","clothing","luxury_clothing","furniture","luxury_furniture","alcohol","glass","chemicals","rare_alloys","construction_materials","early_munitions","late_munitions","naval_supplies","steel_ships","wooden_ships","steel","bronze","machine_parts","early_artillery","late_artillery","electronics","pharmaceuticals","motors","processed_foods","petrochemicals"]
industrial_goods = ["clothing", "luxury_clothing", "furniture", "luxury_furniture",
                    "alcohol", "glass", "pharmaceuticals", "processed_foods",
                    "motors", "electronics", "rare_alloys", "construction_materials",
                    "steel", "bronze", "machine_parts", "chemicals",
                    "early_munitions", "late_munitions", "naval_supplies", "steel_ships",
                    "wooden_ships", "early_artillery", "late_artillery", "petrochemicals", ]

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

for tradegood in industrial_goods:
        print_out_good(tradegood)
