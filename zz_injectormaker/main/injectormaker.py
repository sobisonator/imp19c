# -*- coding: utf-8 -*-
"""
Created on Mon May  3 16:08:23 2021

@author: Tobias Grøsfjeld
"""
# Fetch hardcoded database of strings such as radiant trait names
from .injectortemplates import *

# Reads files and outputs the expected keys
def injector_reader(filepath, should_read):
    keylist = []
    with open(filepath,"r",encoding='utf-8-sig') as injectorfile:
        for line in (y for y in injectorfile.readlines() if should_read(y)):                                # Identify the files that have keys we care about:
            keylist += [line.split("=").pop(0).replace(" ", "").replace("\t", "")]                          # Clear away any spaces or tabs gunking up the key
    return keylist

# Reads a list of files
def injector_reader_list(*args):
    local_arg_list = []
    for x in args:                                                                                          # Unwrap list of lists
        for main_key, secondary_key, filepath, should_read in x:                                            # Format keys in list
            local_arg_list += [[main_key, secondary_key, injector_reader(filepath,should_read)]]            # Store formatted key list
    return local_arg_list

# Makes a single file
def injector_maker(main_key,secondary_key,iterant_keys):
    final_string = ""                                                                                       # Initialize local string
    wrapping_string = wrapping_template.replace("MAIN_KEY",main_key).replace("SECONDARY_KEY",secondary_key) # Parse wrapping string
    iterant_string = iterant_template.replace("SECONDARY_KEY",secondary_key)                                # Partially parse iterant string
    for key in iterant_keys:
        final_string += iterant_string.replace("ITERANT_KEY",key)                                           # Add parsed iterant_string to final_string
    return wrapping_string.replace("ITERANT",final_string)                                                  # Insert iterant string into the wrapping string

# Make a single file from a data triplet
def injector_maker_triplet(*args):
    local_string = ""
    for [a,b,c] in args:
        local_string += injector_maker(a,b,c)
    return local_string
# Makes a file for every triplet in list
def injector_maker_list(x):
    local_string = ""
    for i in x:
        local_string += injector_maker_triplet(i)
    return local_string

def filter_duplicate_keys(unfiltered_list):
    filtered_list = []
    # List main keys
    main_keys = [a for a,b,*c in unfiltered_list[:]]
    # Eliminate duplicate main keys by converting to dictionary and back
    main_keys = list(dict.fromkeys(main_keys))
    # Fetch iterant keys corresponding to each duplicate main key
    iterant_keys = []
    for i in main_keys:
        secondary_keys = [b for a,b,c in unfiltered_list[:] if a == i]
        iterant_keys   = [c for a,b,c in unfiltered_list[:] if a == i]
        iterant_keys   = [a for b in iterant_keys for a in b]
        filtered_list += [[i,secondary_keys[0],iterant_keys]]
    return filtered_list