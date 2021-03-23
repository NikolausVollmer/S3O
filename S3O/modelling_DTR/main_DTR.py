"""
MAIN

Created on Tue Sep 15 2020
@author: nikov@kt.dtu.dk

Main script for creating Delaunay triangulation surrogate models for superstructure optimization

Routine containing the following files & functions:
main.py
dtr_functions.py
-import
-triangulation
-export

"""
## Initialization
import os
from dtr_functions import import_csv, triangulation, export_csv

cIDs = [1,2,5,6]
Ns = [500, 1000]

for cID in cIDs: # configuration ID
   for N in Ns:  # MC flowsheet sampling number

        path = os.getcwd()
        filepath_in = [os.path.dirname(path)+"\simulations\C{}i_{}.csv".format(cID,N),
                       os.path.dirname(path)+"\simulations\C{}o_{}.csv".format(cID,N)]
        filepath_out = os.path.dirname(path)+"\modelling_DTR\C{}dtr_{}.csv".format(cID,N)
        dim = (5,4) # (input,output)
        error = 0.001


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

        ## EXPORT Data
        export_csv(dictData)
