import sqlite3, csv, gspread, configparser, re, glob, codecs
from urllib.parse import _NetlocResultMixinStr
from tkinter import filedialog, messagebox
from tkinter import *
from PIL import Image, ImageTk

# remote_sheet_exists = False # Why is this here? Belongs in a class handling the database and/or cloud integration

class Editor: # Parent class
    def __init__(self):
        print("Starting editor...")
        self.config = configparser.ConfigParser(allow_no_value=True) # no_value must be allowed so that we can read the list of valid pop types, which is just a list of names
        self.config.read('config/MapEditor.ini')

        self.remote_sheet = None # Set later by self.setup_remote_sheet()

        self.has_remote_sheet = True # If true, functions related to getting remote data will be used.

        self.remote_sheet_columns = self.get_remote_sheet_column_indices(self.config.items('AlphanumericColumns')) | self.get_remote_sheet_column_indices(self.config.items('NumericColumns'))
        sorted_tuples = sorted(self.remote_sheet_columns.items(), key=lambda item: item[1])
        self.remote_sheet_columns = {k: v for k, v in sorted_tuples}

        valid_cultures = self.get_valid_cultures("../../common/cultures/")
        valid_religions = self.get_valid_religions("../../common/religions/")
        valid_trade_goods = self.get_valid_trade_goods("../../common/trade_goods/")

        # Declare the credentials var on init, but it will only be given a file at the credentials select stage by the GUI object
        self.remote_credentials = None # NEED TO GET THIS FROM GUI FUNCTION

        self.map_handler = MapHandler("land_input.bmp","sea_input.bmp")
        self.gui = EditorGUI(self.remote_sheet_columns,
            remote_sheet=None, # Remote sheet = none until loaded
            db = None, # Database = none until loaded
            valid_cultures = valid_cultures,
            valid_religions = valid_religions,
            valid_trade_goods = valid_trade_goods,
            config = self.config) 
        # Prompt a selection of the database path
        db_path = self.gui.prompt_file_select()
        self.db = database_connection(self.remote_sheet,db_path)
        self.gui.db = self.db # Load database now that it has been initialised
        self.remote_credentials = self.gui.prompt_remote_credentials() # Get remote credentials
        self.setup_remote_sheet() # Load the remote data now that we have the credentials ready
        self.gui.remote_sheet = self.remote_sheet # Load the remote sheet for reference by GUI functions
        self.gui.start_main_gui()
        
        # Declare the map var on init, but it will only be given a file at the file select stage
        self.editor_file = None # NEED TO GET THIS FROM GUI FUNCTION

    def config_to_dict(self, input_config):
        config_as_dict = {s:dict(input_config.items(s)) for s in input_config.sections()}
        return config_as_dict

    def get_remote_sheet_column_indices(self, input_columns):
        remote_sheet_columns = dict(input_columns)
        for k, v in remote_sheet_columns.items():
            remote_sheet_columns[k] = int(v) # Convert the column indices to integers
        return remote_sheet_columns # Dict

    def setup_remote_sheet(self):
        remote_sheet_name = self.config['RemoteSheet']['SheetName']
        self.remote_sheet = RemoteSheet(
            sheet_name = remote_sheet_name, 
            credentials = self.remote_credentials,
            column_indices = self.remote_sheet_columns
            )
        self.has_remote_sheet = True

    def get_valid_cultures(self, cultures_directory):
        replace_values = {" ": "", "{": "", "}": "", "=": "",
                          "\r": "",
                          "\t": ""}
        replace_values = dict((re.escape(k), v) for k, v in replace_values.items())
        pattern = re.compile("|".join(replace_values.keys()))
        valid_cultures = []
        for cultures_file in glob.glob(cultures_directory+"*.txt"):
            with codecs.open(cultures_file, "r+", "utf-8-sig") as culture_file_data:
                data = culture_file_data.read()
                # Find the bit that says cultures and cut off everything before
                #cultures = data.partition("culture = {")[2]
                cultures = data.partition("culture = {")[2]
                cultures = cultures.partition("barbarian_names")[0]
                cultures = re.sub("#.*", "", cultures)
                cultures = re.sub(".*names", "", cultures)
                cultures = re.sub(".*family", "", cultures)
                cultures = re.sub("\\{(.|\\n|\\r|\\t)*?\\}", "", cultures)
                cultures = pattern.sub(lambda m: replace_values[re.escape(m.group(0))], cultures)
                cultures = cultures.split("\n")
                for culture in cultures:
                    if len(culture) > 0 and culture not in valid_cultures:
                        valid_cultures.append(culture)
                #cultures = cultures.partition("")[1]
                #cultures = regex.sub(br'\{[^()]*+(?:(?R)[^()]*)*+\}', '', cultures)
                #print(cultures)
                culture_file_data.close()
        print("Valid cultures = " + str(valid_cultures))
        return valid_cultures
    
    def get_valid_religions(self, religions_directory):
        replace_values = {" ": "", "{": "", "}": "", "=": "",
                            "\r": "",
                            "\t": "",
                        }
        replace_values = dict((re.escape(k), v) for k, v in replace_values.items())
        pattern = re.compile("|".join(replace_values.keys()))
        valid_religions = []
        for religions_file in glob.glob(religions_directory+"*.txt"):
            with codecs.open(religions_file, "r+", "utf-8-sig") as religion_file_data:
                data = religion_file_data.read()
                # Find the bit that says religions and cut off everything before
                religions = re.sub(" .*", "", data)
                religions = re.sub(" .*", "", religions)
                religions = re.sub("\\{\\{[^}]*\\}\\}", "", religions, re.MULTILINE | re.DOTALL)
                pattern = re.compile("|".join(replace_values.keys()))
                religions = pattern.sub(lambda m: replace_values[re.escape(m.group(0))], religions)
                religions = re.sub("#.*", "", religions)
                religions = religions.split("\n")
                for religion in religions:
                    if len(religion) > 0 and religion not in valid_religions:
                        valid_religions.append(religion)
                #religions = religions.partition("")[1]
                #religions = regex.sub(br'\{[^()]*+(?:(?R)[^()]*)*+\}', '', religions)
                #print(religions)
                religion_file_data.close()
        print("Valid religions = " + str(valid_religions))
        return valid_religions
    
    def get_valid_trade_goods(self, trade_goods_directory):
        replace_values = {" ": "", "{": "", "}": "", "=": "",
                            "\r": "",
                            "\t": "",
                        }
        replace_values = dict((re.escape(k), v) for k, v in replace_values.items())
        pattern = re.compile("|".join(replace_values.keys()))
        valid_trade_goods = []
        for trade_goods_file in glob.glob(trade_goods_directory+"*.txt"):
            with codecs.open(trade_goods_file, "r+", "utf-8-sig") as trade_good_file_data:
                data = trade_good_file_data.read()
                # Find the bit that says trade_goods and cut off everything before
                trade_goods = re.sub(" .*", "", data)
                trade_goods = re.sub("\t.*", "", trade_goods)
                trade_goods = re.sub("\\{\\{[^}]*\\}\\}", "", trade_goods, re.MULTILINE | re.DOTALL)
                pattern = re.compile("|".join(replace_values.keys()))
                trade_goods = pattern.sub(lambda m: replace_values[re.escape(m.group(0))], trade_goods)
                trade_goods = re.sub("#.*", "", trade_goods)
                trade_goods = trade_goods.split("\n")
                for trade_good in trade_goods:
                    if len(trade_good) > 0 and trade_good not in valid_trade_goods:
                        valid_trade_goods.append(trade_good)
                #trade_goods = trade_goods.partition("")[1]
                #trade_goods = regex.sub(br'\{[^()]*+(?:(?R)[^()]*)*+\}', '', trade_goods)
                #print(trade_goods)
                trade_good_file_data.close()
        print("Valid tradegoods = " + str(valid_trade_goods))
        return valid_trade_goods

# MapHandler deals with the map image files
class MapHandler:
    def __init__(self, img_land, img_sea):
        # Images for the land and sea maps. These contain the colours of provinces and searegions
        self.img_land = Image.open(img_land,"r") # Should be PNG to save space
        self.img_sea = Image.open(img_sea,"r") # Should be PNG to save space

        # Create lists of colours in each file, which we can use to iterate through all the provinces/searegions
        # Each colour is effectively a unique ID for the province/searegion
        # Maxcolors set to 100,000 to exceed the default maximum, as we have over 10,000 provinces
        self.land_colours = self.img_land.getcolors(maxcolors=100000)
        self.sea_colours = self.img_sea.getcolors(maxcolors=100000)

        # List of colours in the land provinces file
        # Each item is a tuple of the RGB value of a land province's colour
        self.land_provinces = []
        # Add colours to the list. Index [1] of each is a tuple with the RGB value
        for colour in self.land_colours:
            self.land_provinces.append(colour[1])
        # Ignore white, which we use in the input images to delineate sea and land.
        self.land_provinces.remove((255,255,255))

        # List of colours in the sea provinces file
        # See above land provinces
        self.sea_provinces = []
        for colours in self.sea_provinces:
            self.sea_provinces.append(colour[1])

        # Get the total number of provinces
        # Why do we need this again?
        self.total_provinces = len(self.sea_provinces) + len(self.land_provinces)

        # Read back the lengths to the user
        print(str(len(self.sea_provinces)) + " sea provinces found and " +
            str(len(self.land_provinces)) + " land provinces found.")
        print("Total provinces in land and sea: " + str(self.total_provinces))

        # Get the definition CSV file. If there isn't one, one will be generated on the first time it's loaded.
        try:
            self.definition_csv = open("definition.csv","r")
        except:
            self.definition_csv = False
       
        # Check for a local setup file - maybe not necessary if we're just pulling from the remote
        try:
            self.province_setup_csv = open("province_setup.csv",'r',encoding='UTF-8')
        except:
            self.province_setup_csv = False


        
class RemoteSheet:
     # https://youtu.be/cnPlKLEGR7E?t=346
    def __init__(self, sheet_name, credentials, column_indices):
        self.credentials = credentials # Credentials are loaded from a separate file, selected when the user is prompted on startup
    
        client = gspread.service_account(filename=credentials)
        
        self.sheet = client.open(sheet_name).sheet1 # Sheet name is passed from config by the parent class

        self.column_indices = column_indices

    def write_to_sheet(self, provid, column, data):
        # Data is a row from the database
        rownum = int(provid) + 1
        column = column + 1 # Google sheets counts from 1. Great job, Google sheets.   
        # colnum = self.column_indices[column]
        self.sheet.update_cell(rownum, column, str(data))
    
    def get_province_data(self, provid):
        # THOUGHTS:
        # Is it best to read straight from the sheet, and not rely on anything local at all?
        # We could just read one row at a time when we click on the corresponding province
        #
        # Process is as follows:
        # 1) Get the PROVID locally, from the save file using the RGB comparison
        # 2) Lookup the PROVID on the spreadsheet
        # 3) Return the data from that PROVID as a tuple/list
        province_data = self.sheet.row_values(int(provid) + 1) # Add one, as the first row is used by columns
        return province_data

# Database connection class
# Only needed for the definition reading so we can interpret the province map
# As we will be reading directly from the remote sheet at all times
class database_connection(object):
    def __init__(self, column_indices, db_path):
        self.connection = sqlite3.connect(db_path)
        self.cursor = self.connection.cursor()
        
        self.load_db()

        self.checksum_query = """INSERT OR IGNORE INTO province_checksums(province_checksum)
                                    VALUES (:checksum)"""

        self.definition_query = """INSERT OR IGNORE INTO definition(
                                        Province_id,
                                        R,
                                        G,
                                        B,
                                        Name,
                                        x
                                    )
                                    VALUES (
                                        ?,
                                        ?,
                                        ?,
                                        ?,
                                        ?,
                                        ?
                                    )"""

        # A list to hold new provinces with checksums not existing in the current save
        self.new_sea_provinces = []
        self.new_land_provinces = []

        # A list of free province IDs which can be re-used when provinces are deleted
        self.free_ids = []

        self.column_indices = column_indices

    def db_fetchone(self):
        return self.cursor.fetchone()

    def setup_update_query(self, row):
        # Instead of defining the columns individually, just get their column index by the name
        for item in row:
            if item == "":
                item = "0"
        query = "UPDATE province_setup SET Culture ='" + row[self.column_indices("Culture")]+"'," \
        " Religion ='" + row[self.column_indices("Religion")]+"'," \
        " TradeGoods ='" + row[self.column_indices("Culture")]+"'," \
        " Citizens =" + row[self.column_indices("Culture")]+"," \
        " Freedmen =" + row[self.column_indices("Culture")]+"," \
        " LowerStrata =" + row[self.column_indices("Culture")]+"," \
        " MiddleStrata =" + row[self.column_indices("Culture")]+"," \
        " Proletariat =" + row[self.column_indices("Culture")]+"," \
        " Slaves =" + row[self.column_indices("Culture")]+"," \
        " Tribesmen =" + row[self.column_indices("Culture")]+"," \
        " UpperStrata =" + row[self.column_indices("Culture")]+"," \
        " Civilization =" + row[self.column_indices("Culture")]+"," \
        " SettlementRank =" + row[self.column_indices("Culture")]+"," \
        " NameRef ='" + row[self.column_indices("Culture")].replace("'","’")+"'," \
        " AraRef ='" + row[self.column_indices("Culture")].replace("'","’")+"'," \
        " Terrain ='" + row[self.column_indices("Culture")].replace("'", "’") + "' WHERE ProvID = " + row[provid_col]
        return self.cursor.execute(query, "")

    def db_fetchall(self):
        return self.cursor.fetchall()

    def query(self,query,params):
        # For functions that don't need to create any new fields
        return self.cursor.execute(query,params)

    def commit_many(self,query,params):
        # For functions that create many new fields
        self.cursor.executemany(query, params)
        self.connection.commit()

    def db_commit(self,query):
        # For functions that need to create a new field
        self.cursor.execute(query)
        self.connection.commit()

    def load_db(self):
        # Populate a database with default province IDs
        db_schema = "province_setup_schema.sql"
        #Read the schema file and output it as a string
        all_schema_contents = str(open(db_schema).read())

        #Separate the schema contents into separate commands by semicolons
        individual_schema_contents = all_schema_contents.split(';')
        #Get rid of newline and tab indicators from the raw string
        for schema_command in individual_schema_contents:
            for ch in ["\n", "\t"]:
                schema_command.replace(ch, "")
        for schema_command in individual_schema_contents:
            self.db_commit(schema_command + ";")

    def province_checksum(self,province):
        R = province[0]
        G = province[1]*1000
        B = province[2]*1000000
        province_checksum = R + G + B
        return str(province_checksum)


    def clear_old_provinces(self, provinces):
        RGB_query = "SELECT R, G, B FROM definition;"
        self.query(RGB_query, "")
        RGBs = self.db_fetchall()
        for RGB in RGBs:
            if RGB not in provinces:
                params = RGB
                search_query = "SELECT Province_ID FROM definition WHERE R=? AND G=? AND B=?;"
                self.query(search_query,params)
                province_id = str(self.db_fetchone()[0])
                print("Province " + province_id + " no longer exists")
                self.free_ids.append(province_id)
                deletion_params = (province_id,)
                definition_deletion = "DELETE FROM definition WHERE Province_ID = ?;"
                self.query(definition_deletion,deletion_params)
                setup_deletion = "DELETE FROM province_setup WHERE ProvID = ?;"
                self.query(setup_deletion,deletion_params)
                # Also delete checksum from checksums table
                checksum_params = (self.province_checksum(RGB),)
                checksum_deletion = "DELETE FROM province_checksums WHERE province_checksum = ?;"
                self.query(checksum_deletion,checksum_params)
        if len(self.free_ids) > 0:
            self.db_commit("")
                # Free up this RGB's Province ID
                # Add it to a list of free Province IDs to be assigned to new provinces
                # And make sure that other province IDs above it are shifted down

    def checksum_search(self, province):
        checksum = self.province_checksum(province)
        search_checksum_query = "SELECT * FROM province_checksums WHERE province_checksum = " + checksum + ";"
        self.query(search_checksum_query,"")
        if self.db_fetchone() != None:
            # print("Checksum " + checksum + " verified")
            return True
        else:
            # print("No previously existing province with checksum " + checksum)
            return False 

    def submit_province(self, province, provtype, new_province,i):
        R = str(province[0])
        G = str(province[1])
        B = str(province[2])
        # If the checksum does not exist, create the province
        if self.checksum_search(province) == False:
            if new_province == True:
                definition_params = (str(i), R, G, B, provtype+str(i),"x")
                definition_query = self.definition_query
                self.query(definition_query, definition_params)
                checksum_params = {"checksum":self.province_checksum(province)}
                checksum_query = self.checksum_query
                self.query(checksum_query, checksum_params)
                # print("Created definition for province " + str(i))
                return True
            elif new_province == False:
                if provtype == "seaprov":
                    self.new_sea_provinces.append(province)
                    return False
                elif provtype == "landprov":
                    self.new_land_provinces.append(province)
                    return False

    def import_definition(self):
        # Import definition
        if definition_csv:
            rows = list(csv.reader(definition_csv, delimiter=";"))
            for i, row in enumerate(rows):
                rows[i] = list(row)
            for row in rows:
                # print(row)
                self.query(self.definition_query, (row[0], row[1], row[2], row[3], row[4], row[5]))
            self.connection.commit()

    def fill_definition(self):
        self.clear_old_provinces(land_sea_provinces)
        self.compensate_for_deleted_provinces()
        self.query("SELECT max(rowid) from definition;","")
        num_defined_provinces = self.db_fetchone()[0]
        if num_defined_provinces != None:
            i = num_defined_provinces + 1
            # print("Found " + str(i - 1) + " provinces already defined.")
        else:
            i = 1
        while i < total_provinces:
            try:
                for province in land_provinces:
                    if self.submit_province(province, "landprov", True,i) == True:
                        i = i+1
                for province in sea_provinces:
                    if self.submit_province(province, "seaprov", True,i) == True:
                        i = i+1
                for province in self.new_land_provinces:
                    self.submit_province(province, "landprov", False,i)
                    i = i+1
                for province in self.new_sea_provinces:
                    self.submit_province(province, "seaprov", False,i)
                    i = i+1
            finally:
                self.db_commit("")
            break

    def compensate_for_deleted_provinces(self):
        for free_id in self.free_ids:
            params = (free_id,)
            definition_query = "UPDATE definition SET Province_id = (Province_id - 1) WHERE Province_id > ?;"
            self.query(definition_query,params)
            province_setup_query = "UPDATE province_setup SET ProvID = (ProvID - 1) WHERE ProvID > ?;"
            self.query(province_setup_query,params)
        self.db_commit("")

    def export_to_csv(self): # Rework - needs to export to CSV from sheet
        print("Exporting to CSV")
        select_setup = "SELECT * FROM province_setup;"
        self.query(select_setup, "")
        with open("pyParaMapEditor_OUTPUT.csv","w", newline="",encoding="UTF-8") as csv_file:
            csv_writer = csv.writer(csv_file)
            csv_writer.writerow([i[0] for i in self.cursor.description])
            for row in self.cursor:
                # print(row)
                csv_writer.writerow(row)

class EditorGUI():
    def __init__(self, column_indices, remote_sheet, db, valid_cultures, valid_religions, valid_trade_goods, config):
        self.root = Tk()

        self.im_selector = Image.open("selector.gif", "r")

        self.config = config # In order to get column identities
        self.minority_pop_start_column = self.config['MinorityPopDef']['StartColumn'] # Column where the first minority pop is defined
        self.minority_pop_columns = self.config['MinorityPopColumns']
        self.columns_per_minority = len(self.config.items('MinorityPopColumns')) # Number of columns to iterate per minority pop
        self.valid_pop_types = self.config['ValidPopTypes']

        self.remote_sheet = remote_sheet
        self.db = db # Reference to database for picking out province ID from RGB values on the image

        # Take the column names and use them for editable fields on the GUI. The names are stored as keys in the indices dict
        # Unpack the dict into a list literal
        self.data_fields = [*column_indices]

        # Get lists of valid cultures, religions and tradegoods in the mod so we can refuse to submit an invalid culture
        self.valid_cultures = valid_cultures
        self.valid_religions = valid_religions
        self.valid_trade_goods = valid_trade_goods

    def start_main_gui(self): # Called by main Editor class when it's time to call up the main view
        self.create_mapview()
        self.create_minorities_button()
        self.frame.pack(fill=BOTH,expand=1)
        self.add_map_canvas()

        self.list_of_entries = self.create_fields()
        self.create_minority_pop_fields()

        # Empty value for comparing when field values are changed
        self.entry_value = None

        # Empty value for comparing the previous selected province
        self.prevprovince = None

        self.selector_img = ImageTk.PhotoImage(Image.open("selector.gif").convert("RGBA"))

        #mouseclick event definitions
        self.canvas.bind_all("<ButtonPress-2>", self._on_mousewheel_dn)
        self.canvas.bind_all("<ButtonRelease-2>", self._on_mousewheel_up)
        self.canvas.bind_all("<Motion>",self.scan)
        self.canvas.bind_all("<Return>", lambda event, fieldvar=self.list_of_entries:self.submit_entry(event, fieldvar))
        self.canvas.bind("<ButtonPress-1>", self.getprovince)
        # self.canvas.bind("<MouseWheel>", self.zoom_view) # TODO

        self.root.mainloop()
    
    def prompt_file_select(self): # Select the local database, used for loading and saving map data. Data will also be saved to the remote sheet if there is one
        # We have to initialise Tkinter so we can create GUI, but we'll just use the default file select function
        file_select = Tk()
        # Hide the default Tkinter window, as we'll be popping up a file select dialog
        file_select.withdraw()
        file_name = filedialog.asksaveasfilename( # Use saveas as this allows the user to create a new file if there isn't one, or to load & overwrite an existing one
            initialdir = "./",
            title = "Select or create map editor save file",
            filetypes = (("all files",""),("all files","*"))
        )
        # Update the class attribute to select the database
        database_file = file_name
        file_select.destroy()
        return database_file # Pass this back to the main Editor class

    def prompt_remote_credentials(self): # Get the JSON credentials for connecting to the Google Sheet
        # We have to initialise Tkinter so we can create GUI, but we'll just use the default file select function
        credentials_select = Tk()
        # Check if the user wants to connect to the remote sheet
        file_name = filedialog.askopenfilename(
            initialdir = "./",
            title = "Select credentials for remote editing. Cancel to edit remotely",
            filetypes = (("json files","*.json"),("json files","*.json"))
        )
        # Update the class attribute if a file was selected
        if str(file_name) != "":
            self.remote_credentials = file_name
        credentials_select.destroy()
        return(self.remote_credentials) # Flag that we are indeed using remote credentials

    def create_mapview(self):
        #setting up a tkinter canvas with scrollbars
        self.frame = Frame(self.root, bd=2, relief=SUNKEN)
        self.frame.grid_rowconfigure(0, weight=1)
        self.frame.grid_columnconfigure(0, weight=1)
        xscroll = Scrollbar(self.frame, orient=HORIZONTAL)
        xscroll.grid(row=1, column=0, sticky=E+W)
        yscroll = Scrollbar(self.frame)
        yscroll.grid(row=0, column=1, sticky=N+S)
        self.canvas = Canvas(self.frame, bd=0, xscrollcommand=xscroll.set, yscrollcommand=yscroll.set)
        self.canvas.grid(row=0, column=0, sticky=N+S+E+W)
        xscroll.config(command=self.canvas.xview)
        yscroll.config(command=self.canvas.yview)

        self.editorframe = Frame(self.frame, bd=2, relief=SUNKEN, padx=30) # Main frame for basisc province data on the right of the map
        self.editorframe.grid(row=0, column=2)
        self.minoritiesframe = Frame (self.frame, bd=2, relief=SUNKEN, pady=30)# Extra frame for minority pop fields at the bottom
        self.minoritiesframe.grid(row=2, column = 0) # Beneath the map and X-axis scrollbar

        self.event2canvas = lambda e, c: (c.canvasx(e.x), c.canvasy(e.y))

        self.mousewheel = 0 # Mousewheel press status

    def export_to_csv(self):
        pass
        # Get data from Google Sheets API

    def create_minority_pop_fields(self):
        self.minority_pop_entries = []
        # Create 7 columns of 4 entry fields to populate each with the 4 minority pop columns
        entry_fields = self.config.items('MinorityPopColumns')
        num_minority_pops = self.config['MinorityPopDef']['NumMinorityPops']
        i = 1 # Value for column placement in the GUI
        ref_column = 0
        while i < ( int(num_minority_pops) * 2 ) + 1: # Double these to add space for labels between each column, and add one for space for the first label
            for field, value in entry_fields:
                self.make_minority_entry(self.minoritiesframe,field,value,i,str(int(value)+ref_column))
            ref_column = ref_column + self.columns_per_minority
            i = i+2
    
    def make_minority_entry(self, parent, caption, row_num, col_num, ref_column, **options):
        Label(parent, text=caption, pady=10).grid(row = row_num, column = str(int(col_num)-1))
        entry = Entry(parent, width=10, font=("Arial 18"), **options)
        entry.category = "minority_province_data"
        entry.row = row_num
        entry.column = ref_column # Get the number of the column to search from in the remote sheet
        entry.name = caption
        entry.grid(row = row_num, column = col_num)
        self.minority_pop_entries.append(entry)
        return entry

    def get_minority_pop_entry_column(self, entry):
        column = int(self.minority_pop_start_column) + int(entry.column)
        return column
    
    def refresh_minority_pop_entry(self, entry):
        entry.config(state="normal")
        entry.config({"background":"yellow"})
        entry.delete(0,999) # Clear the contents of the entry widget
        try:
            entry.insert(0,self.province_data[self.get_minority_pop_entry_column(entry)]) # Get the cell data from the remote sheet
        except Exception as ex: # If there is no data
            pass
        entry.config({"background":"white"}) # Reset colour as it may have been yellow or green when edited
    
    def create_fields(self):
        i = 1
        list_of_entries = []
        for field in self.data_fields:
            setting = "normal"
            if field == "PROVID":
                setting = "readonly"
            entry = self.make_entry(self.editorframe, field, i, state=setting)
            entry.bind("<KeyPress>", self.entry_changing)
            entry.bind("<KeyRelease>", self.entry_changed)
            list_of_entries.append(entry) # Appends in column order
            i += 1
        return list_of_entries
    
    # These two functions handle how a field shows that its value has been edited but not submitted, or edited and submitted
    def entry_changing(self, event):
        value = event.widget.get()
        self.entry_value = value

    def entry_changed(self, event):
        value = event.widget.get()
        if value != self.entry_value:
            event.widget.config({"background":"yellow"})
    
    def create_minorities_button(self):
        minorities_button = Button(self.frame, command= lambda: self.view_minority_pops(), text="View minority pops", bd=4, height=2, padx=2, bg="deep sky blue")
        minorities_button.grid(row=1, column=2)

    # If name changes, it also needs to change in the definition.csv
    def change_name(self,submission):
        # definition.csv puts semicolons between spaces in names
        csv_submission = str(submission).replace(" ",";")
        extra_query = "UPDATE definition SET 'Name'='" + csv_submission + "' WHERE Province_id = "+ self.list_of_entries[0].get() +";"
        self.db.db_commit(extra_query)
        print("Name changed in definition")

    def make_entry(self, parent, caption, rownum, **options):
        Label(parent, text=caption, pady=10).grid(row = rownum, column = 0)
        entry = Entry(parent, width=16, font=("Arial 18"), **options)
        entry.category = "main_province_data"
        entry.name = str(caption)
        entry.grid(row = rownum, column = 1)
        return entry

    def province_submission_warning(self, messagetitle, messagetext):
        messagebox.showwarning(messagetitle, messagetext)
        print(messagetitle + " " + messagetext)


    def validate_culture(self, event, submission):
        if submission not in self.valid_cultures:
            event.widget.config({"background":"orange"})
            self.province_submission_warning("Unrecognised culture", "The culture '" + submission + "' which you entered is invalid. Check for typos, or add the culture to the mod files before proceeding.")
            return False
    
    def validate_religion(self, event, submission):
        if submission not in self.valid_religions:
            event.widget.config({"background":"orange"})
            self.province_submission_warning("Unrecognised religion", "The religion '" + submission + "' which you entered is invalid. Check for typos, or add the religion to the mod files before proceeding.")
            return False

    def validate_trade_goods(self, event, submission):
        if submission not in self.valid_trade_goods:
            event.widget.config({"background":"orange"})
            self.province_submission_warning("Unrecognised tradegood", "The tradegood '" + submission + "' which you entered is invalid. Check for typos, or add the tradegood to the mod files before proceeding.")
            return False
    
    def validate_numeric_only(self, event, submission):
        if not submission.isnumeric():
            event.widget.config({"background":"orange"})
            self.province_submission_warning("Value must be a number", "The value for this field must always be a number")
            return False

    def validate_pop_type(self, event, submission):
        if submission not in self.valid_pop_types:
            event.widget.config({"background":"orange"})
            self.province_submission_warning("Invalid pop type", "The pop type '" + submission + "' which you entered is invalid. Check for typos.")
            return False

    def submit_main_province_data(self, event, submission, fields):
        self.widget_id = fields.index(event.widget) # Get column number
        print("Attempting to submit value " + submission + " in field " + event.widget.name)
        if event.widget.name == "culture":
            if self.validate_culture(event, submission) == False:
                return False
        elif event.widget.name == "religion":
            if self.validate_religion(event, submission) == False:
                return False
        elif event.widget.name == "tradegoods":
            if self.validate_trade_goods(event, submission) == False:
                return False
        elif event.widget.name == "nameref":
            self.change_name(submission)
        elif event.widget.name in {k.lower(): v for k, v in self.config.items('NumericColumns')}: # All others must only accept numeric data
            if self.validate_numeric_only(event, submission) == False:
                return False
        self.remote_sheet.write_to_sheet(provid = self.list_of_entries[0].get(), column = self.widget_id, data = submission)
        print("Submission successful")

    def submit_minority_province_data(self, event, submission):
        print("Attempting to submit value " + submission + " in minority pop field " + event.widget.name)
        if event.widget.name == "culture":
            if self.validate_culture(event, submission) == False:
                return False
        elif event.widget.name == "religion":
            if self.validate_religion(event, submission) == False:
                return False
        elif event.widget.name == "size":
            if self.validate_numeric_only(event, submission) == False:
                return False
        elif event.widget.name == "poptype":
            if self.validate_pop_type(event, submission) == False:
                return False
        self.remote_sheet.write_to_sheet(provid = self.list_of_entries[0].get(), column = self.get_minority_pop_entry_column(event.widget), data = submission)
        print("Submission successful")
    
    def submit_entry(self, event, fields): # Refactored - write to remote only
        try:
            submission = event.widget.get()
            # Now find the field that corresponds to the widget
            # If event widget is in main province data
            if event.widget.category == "main_province_data":
                if self.submit_main_province_data(event, submission, fields) == False:
                    return False # The submit data function will return False if the submission was erroneous, do not continue.
            # If the event widget is in minority pops
            elif event.widget.category == "minority_province_data":
                if self.submit_minority_province_data(event, submission) == False:
                    return False # The submit data function will return False if the submission was erroneous, do not continue.
            # Send the submission to the database at the correct PROVID (list of entries 0) and column (widget_id)
            event.widget.config({"background":"lime"})
        except Exception as ex:
            print("Submission failed.")
            print(ex)
            event.widget.config({"background":"red"})
    
    def add_map_canvas(self):
        self.canvas_img = ImageTk.PhotoImage(file='main_input.png', size=(1024,768))
        pxdata = Image.open('main_input.png','r')
        self.px = pxdata.load()
        self.canvas.create_image(0, 0, image=self.canvas_img, anchor="nw")
        self.canvas.config(scrollregion=self.canvas.bbox(ALL))

    #function to be called when mouse is clicked
    def getprovince(self,event):
        #outputting x and y coords to console
        cx, cy = self.event2canvas(event, self.canvas)
        print ("click at (%d, %d) / (%d, %d)" % (event.x,event.y,cx,cy))
        colour = self.px[cx,cy]
        params = colour # Pass the RGB colour as a database query to find the PROVID
        self.refresh_selector_position(cx, cy) # Redraw selector and canvas, prevents lag
        province = self.lookup_province_rgb(params)
        # Do not refresh / overwrite the contents of data entry fields if the province is already selected
        if province != self.prevprovince:
            self.refresh_province_data_fields(province)
    
    def refresh_selector_position(self, cx, cy):
        # Clear the canvas and draw a selector where you last clicked
        self.canvas.delete("all")
        self.canvas.create_image(0, 0, image=self.canvas_img, anchor="nw")
        self.canvas.create_image((cx, cy), image=self.selector_img)
    
    def lookup_province_rgb(self, params):# Look in definition first to get the province ID from RGB
        search_query = "SELECT Province_ID FROM definition WHERE R=? AND G=? AND B=?;"
        self.db.query(search_query,params)
        province = str(self.db.db_fetchone()[0])
        return province
    
    def refresh_province_data_fields(self,province):
        self.prevprovince = province
        print("province ID is " + province)
        # Below three lines are obsolete, as we will read directly from the remote sheet
        # province_data_query = "SELECT * FROM province_setup WHERE ProvID = " + province + ";"
        # self.db.query(province_data_query, "")
        # province_data = self.db.db_fetchone()
        # TODO
        self.province_data = self.remote_sheet.get_province_data(province) # Get the row's data for this province from the remote spreadsheet
        for index, entry in enumerate(self.list_of_entries): # Load the new data for the relevant province from the province data sheet
            self.refresh_entry(index, entry)
        for entry in self.minority_pop_entries:
            self.refresh_minority_pop_entry(entry)
        print(self.province_data)

    def refresh_entry(self, index, entry):
        entry.config(state="normal")
        entry.delete(0,999) # Clear the contents of the entry widget
        try:
            entry.insert(0,self.province_data[index]) # Get the cell data from the remote sheet
        except: # If there is no data
            pass
        entry.config({"background":"white"}) # Reset colour as it may have been yellow or green when edited
        if index == 0:
            entry.config(state="readonly")
    
    def _on_mousewheel_dn(self, event):
        self.mousewheel = 1
        self.canvas.scan_mark(event.x, event.y)

    def _on_mousewheel_up(self, event):
        self.mousewheel = 0

    def scan(self, event):
        if self.mousewheel == 1:
            self.canvas.scan_dragto(event.x,event.y, gain = 1)


editor = Editor()