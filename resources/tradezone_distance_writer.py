import pandas as pd

df = pd.read_csv("imp19c trade zone distances.csv", sep=";")

for column in df:
    i = 1
    if column != "TZ":
        for item in df[column]:
            if str(item) != "nan": # Don't get distance to self
                try:
                    print(column + " to " + df["TZ"][i])
                    print(int(item))
                    i = i + 1
                except:
                    pass

