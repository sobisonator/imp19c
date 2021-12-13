import re, io
lines = io.open('00_default.txt', 'r').readlines()

out  = open('setup_uniques.txt', 'w')

provinces_counted = set()
provinces_duplicates = []

special_keys = ("=")

for line in reversed(lines):
    if not any(key in line for key in special_keys):
        words = re.split('([\s.,;()]+)', line)
        for word in words:
            if word.isnumeric():
                if word not in provinces_counted:
                    provinces_counted.add(word)
                else:
                    provinces_duplicates.append(word)

# List of provinces that are duplicates that have been passed over once
# So we know when to write when we hit it a second time
duplicates_passed = []

for line in lines:
    if any(key in line for key in special_keys):
        out.write(line)
    else:
        words = re.split('([\s.,;()]+)', line)
        for word in words:
            if word not in provinces_duplicates or word in duplicates_passed:
                out.write(word)
            elif word in provinces_duplicates and not word in duplicates_passed:
                #out.write("EXPUNGED")
                duplicates_passed.append(word)

# You need to write only the LAST instance of each item in provinces_duplicates
# So set up a counter to count how many times it's been passed
# then write it out when you hit the last one
# so check first how many you expect, then when counter = expected, write it.
