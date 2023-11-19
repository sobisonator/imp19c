from unidecode import unidecode
import codecs, os

def replace_special(filename):
    f = codecs.open(filename, "r", "utf-8-sig")
    content = f.read()
    f.close()
    f2 = codecs.open(filename, "w", "utf-8-sig")
    content = unidecode(content)
    f2.write(content)
    f2.close()

for root, subdirs, files in os.walk("./"):
    for file in files:
        if file.endswith(".txt"):
            replace_special(os.path.join(root, file))
