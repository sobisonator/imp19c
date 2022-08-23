PROVINCE SETUP EDITOR FOR IMPERATRIX: VICTORIA

Instructions:

Pre-prep (I don't have Python already):
	- Install Python from https://www.python.org/ftp/python/3.9.4/python-3.9.4-amd64.exe
	- Make sure when you install to install pip when prompted, and to add Python to PATH when prompted


1. Installing requirements to run the map editor
	a) With an IDE (advanced)
		i) Open pyParaMapEditor_imp19c as a project. The folder is already set up as a PyCharm project so it should be recognised if you open the folder in PyCharm.
		ii) Install dependencies once you have opened the project, following this tutorial: https://www.jetbrains.com/help/pycharm/managing-dependencies.html
	b) With pip (if you don't have PyCharm)
		i) Open command line and type the following command:
			cd "[path to wherever you put Imperatrix files]map_data\pyParaMapEditor_imp19c"
		ii) Enter the following command in your command line:
			pip install -r requirements.txt
		iii) Launch the script by double clicking it or in the command line.

2. Preparing data (if you are using imp19c, these files should all be there already and you can skip this step!)
	a) All files below simply need to be present in the setup editor's
	b) You will need 3 map files: 
		your province map, (main_input.BMP)
		a map of your land provinces with sea provinces coloured white, (land_input.BMP)
		and a map of your sea provinces with land provinces coloured white. (sea_input.BMP)
	 All of these images must be of the same dimensions.
	c) You may optionally load in an existing definition.csv and existing province_setup.csv, which will be loaded by the setup editor. 
	d) Credentials json file which should be selected when prompted by the program. It should be named "imp19c_credentials.json"
	

3. Using the editor
	 - When you launch the editor you will be prompted to create a new savefile, which you can name whatever you want. This stores the definition file for the mod's map in a database so that the app can reference it quickly. It doesn't contain any setup data
	 	- You may also load a previous save this way. (In imp19c, load the existing "map_imported_file" file)
	 	- The map editor only takes database files in the expected format, so it will encounter an error and close if you try to open any other kind of file.
	 - You will also be prompted to enter a credentials file - select your config json file to link to the Google Sheet. The config json file can be accessed to dev members of the discord here: https://discord.com/channels/666029461795373067/666029463145807893/784059456928743434
	 - Use the middle mouse button and drag the mouse to navigate the map. Alternatively, use the scrollbars around the province map canvas.
	 - Left-click on a province to select it. A crosshair will appear over the selected province while you are editing it.
	 - Click on any field on the right-hand side to edit that field.
	 	A changed field which has not yet been submitted will be coloured yellow.
	 	Press <Return> to submit your change. This will be saved to your file.
	- Your changes are saved whenever you submit them, so there is no need to save before you exit.

Info about fields:

SettlementRank - determines whether a province is a "settlement" (rural) or a "city" (urban)

Industrialisation - This uses the vanilla Civilisation value
