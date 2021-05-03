import unicodecsv as csv

# These columns may vary depending on what pops you have added to the game
# Change as necessary
id_column = 0
name_column = 14

generated_localisation = open("GENERATED_LOCALISATION.yml","w",encoding="utf=8")

setup_csv = open("province_setup.csv", "rb")
reader = csv.reader(setup_csv, delimiter=";")

def write_loc():
    with generated_localisation as f:
        f.write("l_english:\n")
        for row in reader:
            f.write( " PROV" + row[id_column] + ":0 " + '"' + row[name_column] + '"' + "\n" )


write_loc()
