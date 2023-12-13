file1 = "regions.txt"
file2 = "areas.txt"
file3 = "areas_old.txt"

f1 = open(file1, "r")
f2 = open(file2, "r")
f3 = open(file3, "r")

regions_c = f1.readlines()
areas_c = f2.readlines()
areas_o_c = f3.readlines()

words_r = []
words_a = []
words_match = []
words_nomatch = []

for line in regions_c:
    if line.find("	") !=-1 or line.find("    ") !=-1 and line.find("#") ==-1:
        for word in line.split():
            if word not in words_r:
                words_r.append(word)

for line in areas_c:
    if line.find("#") ==-1:
        for word in line.split():
            if word not in words_a and not word.isnumeric():
                words_a.append(word)

for word in words_a:
    if word in words_r and word.find("#") ==-1:
        words_match.append(word)
    elif word.find("#") ==-1:
        words_nomatch.append(word)

area_provs = []
area_provs_old = []

for line in areas_o_c:
    for word in line.split():
        if word.isnumeric():
            area_provs_old.append(word)

for line in areas_c:
    for word in line.split():
        if word.isnumeric():
            if word not in area_provs_old:
                print("Alert!: " + word + " not matching!")
            area_provs.append(word)

print(len(area_provs))
print(len(area_provs_old))
