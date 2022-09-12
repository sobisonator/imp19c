def shorten(tradezone):
        return tradezone.replace("_tradezone","")

def print_out_TZ(TZ_in, all_TZ):
	from_region = TZ_in
	all_TZ = all_TZ
	loc = """			{from_region} = {{""".format(from_region=from_region)
	print(loc)
	for TZ in all_TZ:
				if TZ != from_region:
					loc = """				set_variable = {{
						name = travel_cost_{to_region}
						value = {from_region}_to_{to_region}_svalue
					}}""".format(from_region=shorten(from_region), to_region=shorten(TZ))
					print(loc)
	print("			}")

all_TZ = ["india_tradezone",
		  "east_north_america_tradezone",
		  "west_north_america_tradezone",
		  "caribbean_tradezone",
		  "west_south_america_tradezone",
		  "east_south_america_tradezone",
		  "south_east_asia_tradezone",
		  "indo_china_tradezone",
		  "yellow_sea_tradezone",
		  "southern_africa_tradezone",
		  "west_africa_tradezone",
		  "east_africa_tradezone",
		  "middle_east_tradezone",
		  "western_steppe_tradezone",
		  "eastern_steppe_tradezone",
		  "upper_yangtzi_tradezone",
		  "atlantic_seaboard_tradezone",
		  "central_europe_tradezone",
		  "west_mediterranean_tradezone",
		  "baltic_tradezone",
		  "east_europe_tradezone",
		  "east_mediterranean_tradezone",]

for TZ in all_TZ:
	print_out_TZ(TZ, all_TZ)
