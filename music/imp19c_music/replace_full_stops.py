import os

with os.scandir('.') as d:
   for f in d:
      if f.name.endswith(".ogg") and f.is_file():
          head, tail = os.path.split(f)
          os.rename(f, tail.replace(" ","_"))
