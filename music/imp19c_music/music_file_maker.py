import glob
music_files = glob.glob("*.mp3") + glob.glob("*.ogg")

track_format = 'track%(trackno)d = { \n    music = "file:/music/imp19c_music/%(trackname)s" \n    weight = 25 \n    mood = yes \n    can_be_interrupted = yes \n}\n'

def write_music(music_files):
   with open ("music.txt","w") as music_txt:
      i = 1
      for file in music_files:
           music_txt.write(track_format % {"trackno": i, "trackname": file})
           i = i+1
                           
write_music(music_files)
