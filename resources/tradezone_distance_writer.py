import pandas as pd

df = pd.read_csv("imp19c trade zone distances.csv", sep=";").fillna(0)

for column in df:
    i = 1
    for item in df[column]:
        if column != df["TZ"][i-1]: # Don't get distance to self
            try:
                print(column + " to " + df["TZ"][i-1])
                print(int(item))
            except:
                pass
        i = i + 1

