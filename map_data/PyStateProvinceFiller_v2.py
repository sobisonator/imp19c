import sqlite3
from tkinter import filedialog
from tkinter import *
from PIL import Image, ImageTk
import numpy
import csv
import re


im_states = Image.open('states.bmp','r')
im_provinces = Image.open('provinces.bmp','r')

states_colours = im_states.getcolors(maxcolors=999999)

states = {}

# Create a dict of states with colour values

i = 1

for colour in states_colours:
    state_name = 'state_' + str(i)
    states[state_name] = colour[1]
    i = i + 1

key_list = list(states.keys()) 
val_list = list(states.values()) 

# Look at definition and find matching RGB, then find the province ID
# Put that into a dict of provinces

provs_colours = im_provinces.getcolors(maxcolors=999999)

provinces = { }

with open ("definition.csv", "r") as f:
    dfn = csv.reader(f)
    for line_num, content in enumerate(dfn):
        prov_num = content[0].split(";")[0]
        result = re.search(prov_num + ';(.*);l',content[0])
        if result != None:
            colour = result.group(1).split(";")
            colour = tuple([int(x) for x in colour])
            provinces[prov_num] = colour


# Now create a dict of coordinates of provinces

#im_prov_array = numpy.asarray(im_provinces, dtype="int64")


im = im_provinces
width, height = im.size

outfile = open("states_output.txt", "w")

set_colours = set(provinces)

state_properties = {}
n = 1
for province in provinces:
    colour = provinces.get(province)
    found_pixels = []
    for i, pixel in enumerate(im.getdata()):
        if pixel in set_colours:
            found_pixels.append(i)
            print(i)
            break
    #found_pixels_coords = [divmod(index, width) for index in found_pixels]
    #coords = found_pixels_coords[0][::-1]
    # State = the state in which the province exists
    # Find colour of the state by coordinates
    state_colour = im_states.getpixel([1,1])
    if state_colour != (255,255,255):
        state_found = key_list[val_list.index(state_colour)]
        # Append to the list belonging to this state's assigned provinces
        # v not finished yet v
        state_properties.setdefault(state_found, [])
        state_properties[state_found].append(province)
    n = n + 1
    print(str(n) + " of " + str(len(provinces)))
    


for key, value in state_properties.items():
        outfile.write(key + " = {\n" +
              '\n'.join(value)
              + " \n} \n ")
outfile.close()
