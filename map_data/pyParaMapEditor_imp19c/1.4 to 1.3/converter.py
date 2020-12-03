import os, csv, re, json
# Progress Bars
import time, sys

PROVINCE_JSON_FILE = "json_province_format.json"

def has_ignore_keywords(line):
    IGNORE_LIST = ["holy_site", "blah"]
    for ignore_keyword in IGNORE_LIST:
        if ignore_keyword in line:
            return True
    return False

def end_of_block(line):
    #print('next line is ' + line) #Debugging
    end_of_block_check = re.search(r'\s*}', line)
    if end_of_block_check is not None:
        #print('found pattern, returning True') #Debugging
        return True
    #elif has_ignore_keywords(line): #Debugging
    #    return True
    else:
        #print('didnt find pattern, returning False') #Debugging
        return False

def convert_to_json(input_file, province_data_json):
    # STEPS:
    # 1. Grab the # comments as names
    # 2. search for patterns (variable=) --> ("variable":)
    # 3. add commas after every key-value pair
    # 4. ignore lines with IGNORE_LIST keywords
  
    provinces_lines = input_file.readlines()
    provinces_lines = [line for line in provinces_lines if not line.isspace() and not has_ignore_keywords(line)]
    line_counter = 0
    for line in provinces_lines:
        #"province_rank":"settlement"
        debug = False
        if "province_rank" in line and "settlement" in line:
            debug = True
            raw_line = line
        # STEP 1
        compile_comment = re.compile(r'#.*|ï»¿')
        line = compile_comment.sub("", line)

        # STEP 2
        line = line.replace(" =", "=")
        line = line.replace("= ", "=")
        compile_vars = re.compile(r'(ï»¿)* *([0-9 A-Za-z_]+) *=')
        line = compile_vars.sub(r'"\2":', line)
        
        #STEP 3
        compile_curly_brackets = re.compile(r'}')
        not_end_of_block = line_counter + 1 < len(provinces_lines) and\
           not end_of_block(provinces_lines[line_counter + 1])
           
        if not_end_of_block and line_counter < len(provinces_lines):
            line = compile_curly_brackets.sub(r'},', line)
        compile_keyvalues = re.compile(r'(\"[A-Za-z_]+\"):([0-9 ]+|\".*\")')
            
        if not_end_of_block:
            debug_line = line
            line = compile_keyvalues.sub(r'\1:\2,', line)

        # STEP 4
        if not has_ignore_keywords(line):
            province_data_json.write("    "+line)
        line_counter = line_counter + 1

def progress_bar(progress, max_progress_bar_length):
    barLength = max_progress_bar_length # Modify this to change the length of the progress bar
    status = ""
    if isinstance(progress, int):
        progress = float(progress)
    if not isinstance(progress, float):
        progress = 0
        status = "error: progress var must be float\r\n"
    if progress < 0:
        progress = 0
        status = "Halt...\r\n"
    if progress >= 1:
        progress = 1
        status = "Done...\r\n"
    block = int(round(barLength*progress))
    text = "\rPercent: [{0}] {1}% {2}".format( "#"*block + "-"*(barLength-block), round(progress*100, 2), status)
    sys.stdout.write(text)
    sys.stdout.flush()

def province_format_to_json():
    province_data_json = open(PROVINCE_JSON_FILE, 'w+', encoding="utf-8")
    province_data_json.write("{\n")
    
    PATH = "provinces/"
    province_list = os.listdir(PATH)
    #province_list = province_list[:2]
    max_progress_bar_length = len(province_list)
    progress = 0.0
    province_file_counter = 0
    for every_province_file in province_list:
        progress = progress + float(1/max_progress_bar_length)
        if every_province_file.endswith('.txt'):
            with open(PATH + every_province_file, 'r+') as input_file:
                province_file_counter = province_file_counter + 1
                convert_to_json(input_file, province_data_json)
                if province_file_counter < len(province_list):
                    province_data_json.write(",\n")
        progress_bar(progress, max_progress_bar_length)
    province_data_json.write("}\n")

def json_to_csv():
    province_file_output = open("z_output/province_setup.csv", 'w+', encoding="utf-8")
    province_terrain_output = open("z_output/00_province_terrain.txt", 'w+', encoding="utf-8-sig")
    #setup = open("setup.txt", 'w+', encoding="utf-8-sig")
    province_file_output.write("#ProvID, Culture, Religion, TradeGoods, Citizens, Freedmen, Slaves, Tribesmen, Civilization, Barbarian Power , City Status, NameRef,AraRef,\n")
    csv_writer = csv.writer(province_file_output)
    with open(PROVINCE_JSON_FILE) as json_file:
        try:
            for province_id, entry in json.load(json_file):
                csv_writer.writerow([
                    province_id,
                    entry["culture"],
                    entry["religion"],
                    entry["trade_goods"],
                    entry["civilization_value"],
                    entry["barbarian_power"],
                    entry["province_rank"],
                    entry["citizen"]["amount"],
                    entry["freemen"]["amount"],
                    entry["slaves"]["amount"],
                    entry["tribesmen"]["amount"],
                    entry["civilization_value"],
                    entry["barbarian_power"],
                    entry["province_rank"]
                    # Gonna have to get the name from comments or from localisation
                ])
        except Exception as ex:
            print("\n Error: could not complete conversion: " + str(ex))

def on_action():
    province_format_to_json()
    json_to_csv()

if __name__ == "__main__":
    on_action()