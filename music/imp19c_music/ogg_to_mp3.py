import tempfile, os
from pydub import AudioSegment

with os.scandir('.') as d:
   for f in d:
      if f.name.endswith(".mp3") and f.is_file():
         data = open(f, "rb").read()
         new_f = tempfile.NamedTemporaryFile(delete=False)
         new_f.write(data)
         AudioSegment.from_mp3(new_f.name).export(str(f.name)+".wav", format="wav")
         new_f.close()
