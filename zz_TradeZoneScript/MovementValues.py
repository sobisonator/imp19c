import TradeZones #Import the trade zones dictionary and list.

def print_trade_zone_header(trade_zone):
	caps_name = trade_zone.replace("_", " ").title()
	trade_zone_header = "\n#---------------------------------------\n#Trade Zone: {caps_name}\n#---------------------------------------\n".format(caps_name=caps_name)
	print(trade_zone_header)

def print_trade_zone_connection_values(trade_zone, trade_zone_2):
	zone_1 = trade_zone.lower()
	zone_2 = trade_zone_2.lower()
	trade_zone_connections = "{zone_1}_to_{zone_2}_svalue = {{\n    value = 100 #Base Value\n    subtract = {zone_1}_transportation_svalue\n    subtract = {zone_2}_transportation_svalue\n}}".format(zone_1=zone_1,zone_2=zone_2)
	print(trade_zone_connections)

def print_movement_script_values(trade_zone):
	print_trade_zone_header(trade_zone)
	print("{trade_zone}_transportation_svalue = {{\n    value = 0".format(trade_zone=trade_zone))
	for x in TradeZones.trade_zones_dict.get(trade_zone):
		for i in x:
			print("    region:{i} = {{\n        if = {{\n            limit = {{\n                any_region_province = {{\n                    OR = {{\n                        any_neighbor_province = {{ has_road_towards = PREV }}\n                        has_building = port_building\n                    }}\n                }}\n            }}\n            every_region_province = {{\n                limit = {{\n                    any_neighbor_province = {{ has_road_towards = PREV }}\n                }}\n                add = railway_bonus\n            }}\n            every_region_province = {{\n                limit = {{\n                    has_building = port_building\n                }}\n                add = port_bonus\n            }}\n        }}\n    }}".format(i=i))
	print("}")

def connection_values(trade_zone_list):
	for zone in trade_zone_list:
		print_trade_zone_header(zone)
		for regions in trade_zone_list:
			if ( regions != zone ):
				print_trade_zone_connection_values(zone, regions)
	#NOTE: This is the function that needs fixed. It currently prints connections that are repetitions but idk how to fix it yet.


#FUNCTION 1: Purpose - Print all base movement values
for trade_zone in TradeZones.trade_zones_dict:
  print_movement_script_values(trade_zone)

#FUNCTION 2: Purpose - Print all conncection movement values
#connection_values(TradeZones.trade_zones)