import pandas as pd

df = pd.read_csv("imp19c trade zone distances.csv", sep=";").fillna(0)

for column in df:
    column_ = column.replace(" ", "_")
    i = 1
    print(f"""---------------------------------------
#Trade Zone: {column_}
---------------------------------------""")
    for item in df[column]:
        if column != df["TZ"][i-1]: # Don't get distance to self
            try:
                print(f"""{column_}_to_{df["TZ"][i-1]}_svalue = {{
    value = {int(item)} #Base Value
    subtract = {column_}_transportation_svalue
    subtract = {df["TZ"][i-1]}_transportation_svalue
    min = 1
}}\n""")
                #print(column + " to " + df["TZ"][i-1])
                #print(int(item))
            except:
                pass
        i = i + 1

