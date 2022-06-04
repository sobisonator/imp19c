import tempfile, os
from pydub import AudioSegment

with os.scandir('.') as d:
   for f in d:
      if f.name.endswith(".ogg") and f.is_file():
         data = open(f)
         new_f = tempfile.NamedTemporaryFile(delete=False)
         new_f.write(data)
         AudioSegment.from_ogg(new_f.name).export(f+".mp3", format="mp3")
         new_f.close()
