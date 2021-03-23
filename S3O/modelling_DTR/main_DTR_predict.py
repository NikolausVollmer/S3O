"""
MAIN

Created on Tue Sep 15 2020
@author: nikov@kt.dtu.dk

Main script for creating piecewise linear surrogate models for superstructure optimization

Routine containing the following files & functions:
main.py
pslm.py
-import_csv
-triangulation
-export_csv

"""
## Initialization
from dtr_functions import import_csv, triangulation, export_csv
import numpy as np

filepath_in = [r'M:\4 Modelling\2 Framework\6 Superstructure Optimization\C{}i_{}.csv'.format(cID,N),
               r'M:\4 Modelling\2 Framework\6 Superstructure Optimization\C{}o_{}.csv'.format(cID,N)]
filepath_out = r'M:\4 Modelling\2 Framework\6 Superstructure Optimization\C{}dtr_{}.csv'.format(cID,N)
dim = (5,4)
error = 0.001

x = np.array([0.9078, 1.769, 42.588, 0.9975, 0.4778]) # input variables for predicted point


## initialize main dictionary "dictData"
dictData = dict()
dictData["error"] = error
dictData["filepath_in"] = filepath_in
dictData["filepath_out"] = filepath_out
dictData["dim"] = dim

## IMPORT Data
dictData = import_csv(dictData)

## TRIANGULATE Data
dictData = triangulation(dictData)

## REDUCE Mesh
def barycentric_coordinates(simplex, vertex):
    A = simplex[:] - vertex
    A = np.hstack((A,np.ones((simplex.shape[0],1))))

    b = np.zeros(simplex.shape[1])
    b = np.append(b, [1.])

    bcc = np.linalg.solve(A.T,b)

    return bcc

sx = dictData["triangulation_0"].find_simplex(x)
bcc = barycentric_coordinates(dictData["X"][dictData["sindices_0"][sx]], x)

y0_pred = np.sum(np.multiply(bcc, dictData["Y"][dictData["sindices_0"][sx], 0]))
print(y0_pred)
y1_pred = np.sum(np.multiply(bcc, dictData["Y"][dictData["sindices_0"][sx], 1]))
print(y1_pred)
y2_pred = np.sum(np.multiply(bcc, dictData["Y"][dictData["sindices_0"][sx], 2]))
print(y2_pred)
y3_pred = np.sum(np.multiply(bcc, dictData["Y"][dictData["sindices_0"][sx], 3]))
print(y3_pred)
