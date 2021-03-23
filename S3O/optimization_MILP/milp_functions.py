"""
FUNCTIONS
Created on Tue Oct 06 2020
@author: nikov@kt.dtu.dk

File containing functions for the MILP solution to superstructure optimization

Functions:
- Data import - "import_csv"
"""

import pandas as pd
import numpy as np


## 1. DATA IMPORT
def import_csv(dictData):
    filepath_s = dictData["filepath_s"]
    filepath_p = dictData["filepath_p"]
    dim = dictData["dim"]

    frame_s = pd.read_csv(filepath_s)
    frame_px = pd.read_csv(filepath_p[0])
    frame_py = pd.read_csv(filepath_p[1])

    dictData["frame_px"] = frame_px.columns.values
    dictData["frame_py"] = frame_py.columns.values

    # read data from csv file: indices, input (X), output for objective(Y), output for constraints(C)
    setS = frame_s.to_numpy()[:,1:]

    setP_x = frame_px.to_numpy()[:, 0:1+dim[0]]
    setP_y = frame_py.to_numpy()[:, [1,3,4,6]]
    setP = np.hstack((setP_x, setP_y))

    # store data in dictionary

    dictData["simplices"] = setS

    dictData["points"] = setP
    dictData["xpoints"] = setP_x
    dictData["ypoints"] = setP_y

    return dictData

def export_csv(dictData):
    frame_rx = pd.DataFrame.from_dict(data=dictData["rX"])
    frame_ry = pd.DataFrame.from_dict(data=dictData["rY"])
    frame_time = pd.DataFrame(data=dictData["time"])

    frame_rx.to_csv(dictData["filepath_x"])
    frame_ry.to_csv(dictData["filepath_y"])
    frame_time.to_csv(dictData["filepath_t"])