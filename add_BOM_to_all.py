import os, codecs, mimetypes

def addUTF8Bom(filename):
  try:
      f = codecs.open(filename, 'r', 'utf-8-sig')
      content = f.read()
      f.close()
      f2 = codecs.open(filename, 'w', 'utf-8-sig')
      #f2.write(u'\ufeff')
      f2.write(content)
      f2.close()
  except:
      pass

for root,subdirs,files in os.walk("./"):
    for file in files:
        if file.endswith(".yml"):
             addUTF8Bom(os.path.join(root, file))


