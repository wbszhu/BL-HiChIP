import pandas as pd
import numpy as np
import sys

input_file = sys.argv[1]
out_file = sys.argv[2]
sheet_nm = sys.argv[3]
rows = []
with open(input_file) as f:
    for line in f:
        itms = line.strip().split("\t")
        if itms[0] == "Total PETs:":
            itms[0] = "Trim adapter"
        elif itms[0] == "Valid PETs:":
            itms[0] = "Trim linker"
        itms[0] = itms[0].rstrip(":")
        rows.append([itms[0], int(itms[1])])
df = pd.DataFrame(rows)
df.columns = ['stat', 'count']
df.index = df.pop('stat')
total = float(df.loc['Total_pairs_processed'])
df['percent'] = df['count'] / total
df['percent'] = df['percent'].apply(lambda x: format(x, '.2%'))
df['percent']['Total reads processed'] = ""
df['percent']['Trim adapter'] = ""
df['percent']['Trim linker'] = ""
df1 = df.rename(columns={'Total PETs:':'Trim Adaptor','Valid PETs:':'Trim Linker'}).T
df1['Linker %'] = df1['Trim linker']['count'] /df1['Trim adapter']['count']
df1['Linker %']= df1['Linker %'].apply(lambda x: format(x, '.2%'))
df1.to_excel(out_file,sheet_name=sheet_nm,index=False)
