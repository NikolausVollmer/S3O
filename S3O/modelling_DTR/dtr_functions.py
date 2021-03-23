"""
PIECEWISE LINEAR SURROGATE MODELS

Created on Wed Sep 16 2020
@author: nikov@kt.dtu.dk

File containing functions for the algorithm to create Delaunay triangulation surrogate models by triangulation
and subsequent mesh reduction by incremental edge contraction based on quadric error metrics and external error calculation

Functions:
- import_csv
- export_csv
- Triangulation

"""
import numpy as np
import pandas as pd
from scipy.spatial import Delaunay, ConvexHull



## IMPORT function
def import_csv(dictData):
    filepath1 = dictData["filepath_in"][0]
    filepath2 = dictData["filepath_in"][1]
    dim = dictData["dim"]

    frame1 = pd.read_csv(filepath1)
    frame2 = pd.read_csv(filepath2)

    # read data from csv file: indices, input (X), output for objective(Y), output for constraints(C)
    setx = frame1.to_numpy()[:, :dim[0]]
    sety = frame2.to_numpy()[:, [3,4,5,6]]
    indices = np.arange(len(setx))

    # store data in dictionary
    dictData["indices"] = indices
    dictData["X"] = setx
    dictData["Y"] = sety


    return dictData

## EXPORT function
def export_csv(dictData):
    filepath = dictData["filepath_out"]
    simplices = dictData["sindices_0"]

    pd.DataFrame(simplices).to_csv(filepath)

    return


## TRIANGULATION function
def triangulation(dictData):
    data = dictData["X"]
    prediction = dictData["Y"]
    xy = np.hstack((data,prediction))

    # triangulate input data with Delaunay function, obtain simplices and convex hull
    tridata = Delaunay(data)
    dictData["triangulation_0"] = tridata

    # assign vertices to dictData
    dictData["vindices_0"] = list(range(len(data)))
    dictData["vertices_0"] = data
    dictData["yvertices_0"] = xy

    # assign simplices to dictData
    dictData["sindices_0"] = tridata.simplices

    # predicion values
    dictData["prediction_0"] = prediction

    return dictData
