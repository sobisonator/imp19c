import sqlite3, csv, gspread, pandas
from tkinter import filedialog
from tkinter import *
from PIL import Image, ImageTk
from oauth2client.service_account import ServiceAccountCredentials

remote_sheet_exists = False

event2canvas = lambda e, c: (c.canvasx(e.x), c.canvasy(e.y))

im_land = Image.open('land_input.bmp','r')
im_sea = Image.open('sea_input.bmp','r')
im_selector = Image.open("selector.gif", "r")
try:
    province_setup_csv = open('province_setup.csv', 'r',encoding='UTF-8')
except:
    province_setup_csv = False
try:
    definition_csv = open('definition.csv', 'r')
except:
    definition_csv = False

land_colours = im_land.getcolors(maxcolors=100000)

land_provinces = []

for colour in land_colours:
    land_provinces.append(colour[1])
# Ignore white
land_provinces.remove((255,255,255))

# Sea provinces

sea_colours = im_sea.getcolors(maxcolors=100000)

sea_provinces = []

for colour in sea_colours:
    sea_provinces.append(colour[1])
# Ignore white
sea_provinces.remove((255,255,255))

land_sea_provinces = land_provinces + sea_provinces

total_provinces = len(sea_provinces) + len(land_provinces)

print(str(len(sea_provinces)) + " sea provinces found and " +
      str(len(land_provinces)) + " land provinces found.")
print("Total provinces in land sea (may include overlap!) = " + str(total_provinces))

fileselect = Tk()
fileselect.withdraw()
map_file = fileselect.filename = filedialog.asksaveasfilename(initialdir = "./", title="Select or create map editor save file",filetypes = (("all files",""),("all files","*")))
fileselect.destroy()

# This could be determined in a config file for a one-time solution
get_credentials = Tk()
get_credentials.withdraw()
CREDENTIALS = get_credentials.filename = filedialog.askopenfilename(initialdir = "./", title="Select credentials file for remote editing", filetypes = (("json files","*.json"),("json files","*.json")))
get_credentials.destroy()
# Do not try to load an online sheet if no credentials are selected
if str(CREDENTIALS) == "":
    CREDENTIALS = False

# Get sheetname for imp19c - put this in a config file so it's editable
SHEET_NAME = "linked_imp19c_province_setup"


 # https://youtu.be/cnPlKLEGR7E?t=346
class SheetConnection(object):
    def __init__(self):
        self.scope = ["https://spreadsheets.google.com/feeds",
                 "https://www.googleapis.com/auth/spreadsheets",
                 "https://www.googleapis.com/auth/drive.file",
                 "https://www.googleapis.com/auth/drive"]

        self.credentials = ServiceAccountCredentials.from_json_keyfile_name(CREDENTIALS, self.scope)

        self.client = gspread.authorize(self.credentials)

        self.sheet = self.client.open(SHEET_NAME).sheet1

        self.data = self.sheet.get_all_records()

        self.dataframe = pandas.DataFrame(self.data[1:], columns=self.data[0])

        self.column_indices = {
                "ProvID": 1,
                "Culture": 2,
                "Religion": 3,
                "TradeGoods": 4,
                "Citizens": 5,
                "Freedmen": 6,
                "LowerStrata": 7,
                "MiddleStrata": 8,
                "Proletariat": 9,
                "Slaves": 10,
                "Tribesmen": 11,
                "UpperStrata": 12,
                "Industrialisation": 13,
                "SettlementRank": 14,
                "NameRef": 15,
                "AraRef": 16,
                "Terrain":17
        }

    def write_to_sheet(self, provid, column, data):
        # Data is a row from the database
        rownum = int(provid) + 1
        colnum = self.column_indices[column]
        self.sheet.update_cell(rownum, colnum, str(data))

# Only establish a connection if credentials have been provided
if CREDENTIALS:
    remote_sheet = SheetConnection()
    remote_sheet_exists = True

# Database connection class
class database_connection(object):
    def __init__(self):
        db_path = map_file
        self.connection = sqlite3.connect(db_path)
        self.cursor = self.connection.cursor()
        
        self.load_db()

        self.checksum_query = "INSERT OR IGNORE INTO province_checksums(province_checksum) VALUES (:checksum)"

        self.definition_query = "INSERT OR IGNORE INTO definition(Province_id, R, G, B, Name, x) VALUES (?,?,?,?,?,?)"
        self.setup_query = "INSERT OR IGNORE INTO province_setup(ProvID, Culture, Religion, TradeGoods, Citizens, Freedmen, LowerStrata, MiddleStrata, Proletariat, Slaves, Tribesmen, UpperStrata, Civilization, SettlementRank, NameRef, AraRef, Terrain, isChanged) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"

        # A list to hold new provinces with checksums not existing in the current save
        self.new_sea_provinces = []
        self.new_land_provinces = []

        # A list of free province IDs which can be re-used when provinces are deleted
        self.free_ids = []

    def db_fetchone(self):
        return self.cursor.fetchone()

    def setup_update_query(self, row):
        for item in row:
            row[item] = str(row[item])
            if row[item] == "":
                row[item] = "0"
        query = "UPDATE province_setup SET Culture ='" + row["CULTURE"]+"'," \
        " Religion ='" + row["Religion"]+"'," \
        " TradeGoods ='" + row["TRADEGOOD"]+"'," \
        " Citizens =" + row["unused"]+"," \
        " Freedmen =" + row["indentured"]+"," \
        " LowerStrata =" + row["lower_strata"]+"," \
        " MiddleStrata =" + row["middle_strata"]+"," \
        " Proletariat =" + row["proletariat"]+"," \
        " Slaves =" + row["slaves"]+"," \
        " Tribesmen =" + row["tribesmen"]+"," \
        " UpperStrata =" + row["upper_strata"]+"," \
        " Civilization =" + row["INDUSTRIALISATION"]+"," \
        " SettlementRank =" + row["PROVINCE RANK"]+"," \
        " NameRef ='" + row["NAME"].replace("'","’")+"'," \
        " AraRef ='" + row["AREA"].replace("'","’")+"'," \
        " Terrain ='" + row["TERRAIN"].replace("'", "’") + "' WHERE ProvID = " + row["PROVID"]
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
                if provtype == "landprov":
                    setup_params = (str(i), "roman", "roman_pantheon", "cloth", "1", "1", "1", "1", "40", "0", "landprov"+str(i), "noregion", "plains")
                elif provtype == "seaprov":
                    setup_params = (str(i), "", "", "", "0", "0", "0", "0", "0", "0", "seaprov"+str(i), "", "ocean")
                self.query(self.setup_query, setup_params)
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

    def import_remote_sheet(self):
        # Import a remote sheet
        if remote_sheet_exists:
            rows = remote_sheet.data[1:]
            for row in rows:
                print(row)
                self.setup_update_query(row)
            self.connection.commit()

    def import_setup(self):
        # Import setup
        if province_setup_csv:
            rows = list(csv.reader(province_setup_csv, delimiter=";"))
            for i, row in enumerate(rows):
                rows[i] = list(row)
            for row in rows:
                print(row)
                self.query(self.setup_query, (row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16], "FALSE"))
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

    def default_setup(self):
        i = 1
        while i < total_provinces:
            try:
                for province in land_provinces + new_land_provinces:
                    params = (str(i), "roman", "roman_pantheon", "cloth", "1", "1", "1", "1", "40", "0", "landprov"+str(i), "noregion")
                    query = "INSERT OR IGNORE INTO province_setup(ProvID, Culture, Religion, TradeGoods, Citizens, Freedmen, Slaves, Tribesmen, Civilization, Barbarian, NameRef, AraRef, Terrain) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"
                    self.query(query, params)
                    # print("Created default province setup for land province " + str(i))
                    i = i + 1
                for province in sea_provinces + new_sea_provinces:
                    params = (str(i), "", "", "", "0", "0", "0", "0", "0", "0", "seaprov"+str(i), "")
                    query = "INSERT OR IGNORE INTO province_setup(ProvID, Culture, Religion, TradeGoods, Citizens, Freedmen, Slaves, Tribesmen, Civilization, Barbarian, NameRef, AraRef, Terrain) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"
                    self.query(query, params)
                    # print("Created default province setup for sea province " + str(i))
                    i = i + 1
            finally:
                self.db_commit("")
            break

    def export_to_csv(self):
        print("Exporting to CSV")
        select_setup = "SELECT * FROM province_setup;"
        self.query(select_setup, "")
        with open("pyParaMapEditor_OUTPUT.csv","w", newline="",encoding="UTF-8") as csv_file:
            csv_writer = csv.writer(csv_file)
            csv_writer.writerow([i[0] for i in self.cursor.description])
            for row in self.cursor:
                # print(row)
                csv_writer.writerow(row)


db = database_connection()

if remote_sheet_exists:
    db.import_remote_sheet()
elif province_setup_csv:
    db.import_setup()

if not remote_sheet_exists:
    if definition_csv:
        db.import_definition()
    else:
        db.fill_definition()

root = Tk()

#setting up a tkinter canvas with scrollbars
frame = Frame(root, bd=2, relief=SUNKEN)
frame.grid_rowconfigure(0, weight=1)
frame.grid_columnconfigure(0, weight=1)
xscroll = Scrollbar(frame, orient=HORIZONTAL)
xscroll.grid(row=1, column=0, sticky=E+W)
yscroll = Scrollbar(frame)
yscroll.grid(row=0, column=1, sticky=N+S)
canvas = Canvas(frame, bd=0, xscrollcommand=xscroll.set, yscrollcommand=yscroll.set)
canvas.grid(row=0, column=0, sticky=N+S+E+W)
xscroll.config(command=canvas.xview)
yscroll.config(command=canvas.yview)

editorframe = Frame(frame, bd=2, relief=SUNKEN, padx=110)
editorframe.grid(row=0, column=2)

def export_to_csv():
    db.export_to_csv()

export_button = Button(frame, command= lambda: export_to_csv(), text="Export to CSV", bd=4, height=2, padx=2, bg="deep sky blue")
export_button.grid(row=1, column=2)

def makeentry(parent, caption, rownum, **options):
    Label(parent, text=caption, pady=10).grid(row = rownum, column = 0)
    entry = Entry(parent, width=16, font=("Arial 18"), **options)
    entry.grid(row = rownum, column = 1)
    return entry

fields = [
    "ProvID",
    "Culture",
    "Religion",
    "TradeGoods",
    "Citizens",
    "Indentured",
    "LowerStrata",
    "MiddleStrata",
    "Proletariat",
    "Slaves",
    "Tribesmen",
    "UpperStrata",
    "Industrialisation",
    "SettlementRank",
    "NameRef",
    "AraRef",
    "Terrain"
]

frame.pack(fill=BOTH,expand=1)

# If name changes, it also needs to change in the definition.csv
def change_name(submission):
    # definition.csv puts semicolons between spaces in names
    csv_submission = str(submission).replace(" ",";")
    extra_query = "UPDATE definition SET 'Name'='" + csv_submission + "' WHERE Province_id = "+ list_of_entries[0].get() +";"
    db.db_commit(extra_query)
    print("Name changed in definition")

def submit_entry(event, fields):
    #try:
    submission = event.widget.get()
    print("Submitting " + submission)
    event.widget.config({"background":"lime"})
    widget_id = fields[list_of_entries.index(event.widget)].replace("Indentured","Freedmen")
    # Now find the field that corresponds to the widget
    submission_query = "UPDATE province_setup SET '" + widget_id + "'='" + str(submission) + "', 'isChanged' = 'TRUE' WHERE ProvID = "+ list_of_entries[0].get() +";"
    print(submission_query)
    db.db_commit(submission_query)
    if widget_id == "NameRef":
        change_name(submission)
    if remote_sheet_exists:
        # Send the submission to the database at the correct PROVID (list of entries 0) and column (widget_id)
        remote_sheet.write_to_sheet(list_of_entries[0].get(), widget_id, submission)
    #except Exception as ex:
    #    print("Unacceptable input. Ignoring submission.")
    #    print(ex)

def create_fields():
    i = 1
    list_of_entries = []
    for field in fields:
        setting = "normal"
        if field == "ProvID":
            setting = "readonly"
        entry = makeentry(editorframe, field, i, state=setting)
        entry.bind("<KeyPress>", entry_changing)
        entry.bind("<KeyRelease>", entry_changed)
        list_of_entries.append(entry)
        i = i + 1
    return list_of_entries

entry_value = None

def entry_changing(event):
    global entry_value
    value = event.widget.get()
    entry_value = value

def entry_changed(event):
    global entry_value
    value = event.widget.get()
    if value != entry_value:
        event.widget.config({"background":"yellow"})

list_of_entries = create_fields()

#adding the image
canvas_img = ImageTk.PhotoImage(file='main_input.png', size=(1024,768))
pxdata = Image.open('main_input.png','r')
px = pxdata.load()
canvas.create_image(0, 0, image=canvas_img, anchor="nw")
canvas.config(scrollregion=canvas.bbox(ALL))

prevprovince = None
selector_img = ImageTk.PhotoImage(file="selector.gif", master=root)

#function to be called when mouse is clicked
def getprovince(event):
    global prevprovince
    #outputting x and y coords to console
    cx, cy = event2canvas(event, canvas)
    print ("click at (%d, %d) / (%d, %d)" % (event.x,event.y,cx,cy))
    colour = px[cx,cy]
    params = colour
    # Clear the canvas and draw a selector where you last clicked
    canvas.delete("all")
    canvas.create_image(0, 0, image=canvas_img, anchor="nw")
    canvas.create_image((cx, cy), image=selector_img)
    # Look in definition first to get the province ID from RGB
    search_query = "SELECT Province_ID FROM definition WHERE R=? AND G=? AND B=?;"
    db.query(search_query,params)
    province = str(db.db_fetchone()[0])
    # Do not repeat all this if the province is already selected
    if province != prevprovince:
        prevprovince = province
        print("province ID is " + province)
        province_data_query = "SELECT * FROM province_setup WHERE ProvID = " + province + ";"
        db.query(province_data_query, "")
        province_data = db.db_fetchone()
        for index, entry in enumerate(list_of_entries):
            entry.config(state="normal")
            entry.delete(0,999)
            entry.insert(0,province_data[index])
            entry.config({"background":"white"})
            if index == 0:
                entry.config(state="readonly")
        print(province_data)

# Export to CSV
# definition.csv has 0 in first row.
# header rows need to be commented out
# ;;;;;;;;;;;;;;;;; after each x

# province_setup.csv
# Use commas to separate fields
# Use semicolons to separate headers
# ,,,,,,,,,,,, after AraRef

mousewheel = 0

def _on_mousewheel_dn(event):
    global mousewheel
    global scan_anchor
    mousewheel = 1
    print(event)
    canvas.scan_mark(event.x, event.y)

def _on_mousewheel_up(event):
    global mousewheel
    mousewheel = 0
    print(event)

def scan(event):
    global mousewheel
    global scan_anchor
    if mousewheel == 1:
        print(event)
        canvas.scan_dragto(event.x,event.y, gain = 1)
    
#mouseclick event
canvas.bind_all("<ButtonPress-2>", _on_mousewheel_dn)
canvas.bind_all("<ButtonRelease-2>", _on_mousewheel_up)
canvas.bind_all("<Motion>",scan)
canvas.bind_all("<Return>", lambda event, fieldvar=fields:submit_entry(event, fieldvar))
canvas.bind("<ButtonPress-1>", getprovince)

# Replace spaces with semicolons for input to definition.csv province names

root.mainloop()
