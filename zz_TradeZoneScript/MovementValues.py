import TradeZones #Import the trade zones dictionary and list.

f = open("movementvalues_output.txt","w")
f2 = open("connectionvalues_output.txt","w")

def print_trade_zone_header(trade_zone,file_given):
	caps_name = trade_zone.replace("_", " ").title()
	trade_zone_header = "\n#---------------------------------------\n#Trade Zone: {caps_name}\n#---------------------------------------\n".format(caps_name=caps_name)
	print(trade_zone_header,file=file_given)

def print_trade_zone_connection_values(trade_zone, trade_zone_2,file_given):
	zone_1 = trade_zone.lower()
	zone_2 = trade_zone_2.lower()
	trade_zone_connections = """{zone_1}_x_{zone_2}_svalue = {{
	value = 100 #Base Value
	subtract = {zone_1}_transportation_svalue
	subtract = {zone_2}_transportation_svalue
}}""".format(zone_1=zone_1,zone_2=zone_2)
	print(trade_zone_connections,file=file_given)

def print_movement_script_values(trade_zone):
	print_trade_zone_header(trade_zone,f)
	print("{trade_zone}_transportation_svalue = {{\n    value = 0".format(trade_zone=trade_zone),file=f)
	for x in TradeZones.trade_zones_dict.get(trade_zone):
		for i in x:
			print("""    region:{i} = {{
			if = {{            
				limit = {{               
					any_region_province = {{                   
						OR = {{                       
							any_neighbor_province = {{ has_road_towards = PREV }}                       
							has_building = port_building                   
						}}               
					}}            
				}}            
				every_region_province = {{                
					limit = {{                    
						any_neighbor_province = {{ has_road_towards = PREV }}                
						}}                
					add = railway_bonus            
				}}\n            
				every_region_province = {{                
					limit = {{                    
						has_building = port_building\n                
					}}                
				add = port_bonus           
			}}        
		}}    
	}}""".format(i=i),file=f)
	print("}",file=f)

def connection_values(trade_zone_list):
	done_zones = []
	for zone in trade_zone_list:
		print_trade_zone_header(zone,f2)
		for regions in trade_zone_list:
			if ( regions != zone and regions not in done_zones):
				print_trade_zone_connection_values(zone, regions,f2)
		done_zones.append(zone)
	#NOTE: This is the function that needs fixed. It currently prints connections that are repetitions but idk how to fix it yet.


#FUNCTION 1: Purpose - Print all base movement values
for trade_zone in TradeZones.trade_zones_dict:
  print_movement_script_values(trade_zone)

#FUNCTION 2: Purpose - Print all conncection movement values
connection_values(TradeZones.trade_zones)