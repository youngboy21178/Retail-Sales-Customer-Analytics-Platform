import os
import pandas as pd

folder = "/home/maksymm/Documents/OwnProjects/DataAnalyst2/Data/raw"
files = [os.path.join(folder, f) for f in os.listdir(folder)]
print(f"Total files count {len(files)}")

data_frames: dict = {}
data_frames = {f"{f}" : pd.read_csv(str(f)) for f in files}

import io

def get_info_str(df):
    buffer = io.StringIO()
    df.info(buf=buffer)
    return buffer.getvalue()

data_frames_info = {f: get_info_str(data_frames[f]) for f in data_frames}

# тепер можна дивитись коли завгодно
for name, info in data_frames_info.items():
    print(name)
    print(info)
    print("---")

print("_______")
print(data_frames_info["/home/maksymm/Documents/OwnProjects/DataAnalyst2/Data/raw/product_category_name_translation.csv"])