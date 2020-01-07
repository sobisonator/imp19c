import re

with open("provs_without_areas.txt","r") as f:
    lines = [line.rstrip('\n') for line in f]
    for line in lines:
        print(line[line.find("(")+len("("):line.rfind(")")])
    
