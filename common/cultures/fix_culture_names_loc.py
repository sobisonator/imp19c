from unidecode import unidecode
import codecs, os, re

def replace_special(filename):
    f = codecs.open(filename, "r", "utf-8-sig")
    content = f.readlines()
    new_content = []
    for line in content:
        result = re.search("(.*:)", line)
        line = line.replace(result.group(1), unidecode(result.group(1)))
        new_content.append(line)
    f.close()
    f2 = codecs.open(filename, "w", "utf-8-sig")
    for line in new_content:
        f2.write(line)
    f2.close()

replace_special("./cultures_names.txt")
