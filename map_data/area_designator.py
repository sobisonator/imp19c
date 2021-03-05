import pandas as pd
import unicodedata

# Input file
SETUP_CSV = "province_setup.csv"
# Output file
f_area = open("areas_output.txt", "w")
f_region = open("regions_output.txt", "w")

# Turn the province_setup CSV into a dataframe
df = pd.read_csv(
    SETUP_CSV,
    sep=';',
    low_memory=False
)

# Get a list of all areas in your CSV
areas = df.AREA.unique().tolist()

# Function to print to a text file all provinces in an area in the Imperator
# format
def output_area(area, provinces):
    f_area.write(area + " = {\n" +
            "   provinces = {\n")
    provids_list = provinces['PROVID'].tolist()
    for provid in provids_list:
        f_area.write("      " + str(provid) + "\n")
    f_area.write("   }\n}\n\n")

def sanitise_string(input_string):
    output_string = str(input_string).replace(" ", "_").replace(".","_")
    return ''.join(c for c in unicodedata.normalize('NFD', output_string)
                  if unicodedata.category(c) != 'Mn')

# Get all the provinces in each area
for area in areas:
    provinces = df.loc[df['AREA'] == area]
    # Sanitise the area string
    area = sanitise_string(area)
    output_area(str(area), provinces)

# Now generate a regions file with every area as a region to avoid errors
for area in areas:
    # Sanitise the area string
    area = sanitise_string(area)
    f_region.write("region_" + str(area) + " = {\n" +
                   "    areas = {\n" +
                   "        " + str(area) + "\n    }\n}\n"
                   )

f_area.close()
f_region.close()
