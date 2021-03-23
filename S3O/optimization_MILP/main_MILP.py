"""
MAIN_MILP

Created on Tue Oct 06 2020
@author: nikov@kt.dtu.dk

Main script for performing superstructure optimization by reducing the MINLP to a MILP with Delaunay triangulation regression surrogate models

Routine containing the following files & functions:
main_MILP.py


"""
## Initialization
from pyomo.environ import *
from pyomo.core import *
import pandas as pd
from milp_functions import import_csv, export_csv
import numpy as np
import os
from time import perf_counter

cIDs = [1,2,5,6]
Ns = [500,1000]

for N in Ns:
    for cID in cIDs:
        t1 = perf_counter()

        path = os.getcwd()
        filepath_s = os.path.dirname(path)+"\modelling_DTR\C{}dtr_{}.csv".format(cID,N)
        filepath_p = [os.path.dirname(path)+"\simulations\C{}i_{}.csv".format(cID,N),
                      os.path.dirname(path)+"\simulations\C{}o_{}.csv".format(cID,N)]

        filepath_x = os.path.dirname(path)+"optimization_MILP\C{}_x_{}.csv".format(cID,N)
        filepath_y = os.path.dirname(path)+"optimization_MILP\C{}_y_{}.csv".format(cID,N)
        filepath_t = os.path.dirname(path)+"optimization_MILP\C{}_time_{}.csv".format(cID,N)

        dim = (5,4)
        solver = "gurobi"
        error = 0.001

        ylconstraints = np.array([0., 0., 0., 0.1])
        yuconstraints = np.array([100, 0.5, 0.5, 5])
        yOBJ = 1 # Pyomo Index, not python

        ## initialize main dictionary "dictData"
        dictData = dict()
        dictData["filepath_p"] = filepath_p
        dictData["filepath_s"] = filepath_s
        dictData["filepath_x"] = filepath_x
        dictData["filepath_y"] = filepath_y
        dictData["filepath_t"] = filepath_t

        dictData["dim"] = dim
        dictData["solver"] = solver


        ## 1. IMPORT DATA
        dictData = import_csv(dictData)

        #plot_tri(dictData)

        ## Number of Simplices and Points
        NSimplices = len(dictData["simplices"])
        NPoints = len(dictData["xpoints"])

        ## Dimensions of input and output
        XDim = dictData["dim"][0]
        YDim = dictData["dim"][1]

        ## Simplex and point data
        simplices = dictData["simplices"]
        xpoints = dictData["xpoints"]
        ypoints = dictData["ypoints"]


        ## 2. OPTIMIZATION PROBLEM
        model = ConcreteModel()

        ## 2.1 Sets
        model.S = RangeSet(1, NSimplices)
        model.P = RangeSet(1, NPoints)
        model.SP = RangeSet(1, XDim+1)
        model.dX = RangeSet(1, XDim)
        model.dY = RangeSet(1, YDim)

        ## 2.2 Parameters & Data
        ## Big M parameters for vector combinations
        MX = dict()
        for j in range(dim[0]):
            MX[j+1] = np.amax(xpoints[:, j])

        MY = dict()
        for j in range(dim[1]):
            MY[j+1] = yuconstraints[j]

        model.bigMX = Param(model.dX, within=NonNegativeReals, initialize=MX)
        model.bigMY = Param(model.dY, within=NonNegativeReals, initialize=MY)

        ## Points
        def initPoints(points):
            dictPoints= dict()

            for i in range(len(points)):
                for d in range(len(points[i])):
                    dictPoints[i+1,d+1] = points[i][d]

            return dictPoints

        Xdict = initPoints(xpoints)
        Ydict = initPoints(ypoints)

        model.XPoints = Param(model.P, model.dX, within=NonNegativeReals, initialize=Xdict)
        model.YPoints = Param(model.P, model.dY, within=NonNegativeReals, initialize=Ydict)

        ## Simplices
        def initSimplices(simplices):
            dictSimplices = dict()

            for i in range(len(simplices)):
                simplex = list()
                for s in range(len(simplices[i])):
                    simplex.append(simplices[i][s]+1)

                dictSimplices[i+1] = simplex


            return dictSimplices

        Sdict = initSimplices(simplices)

        model.Simplices = Set(model.S, within=Integers, initialize=Sdict)

        ## 2.3 VARIABLES
        ## Variable for X
        lbx = dict()
        ubx = dict()

        for j in range(dim[0]):
            lbx[j+1] = np.amin(xpoints[:, j])
            ubx[j+1] = np.amax(xpoints[:, j])


        def Xbounds(model, i):
           return (lbx[i], ubx[i])

        model.X= Var(model.dX, domain=NonNegativeReals, bounds=Xbounds)

        ## Variable for Y
        lby = dict()
        uby = dict()

        for j in range(dim[1]):
            lby[j+1] = ylconstraints[j]
            uby[j+1] = yuconstraints[j]


        def Ybounds(model, i):
           return (lby[i], uby[i])

        model.Y = Var(model.dY, domain=NonNegativeReals, bounds=Ybounds)

        ## Variable for vector combinations
        model.a = Var(model.S, model.SP, domain=PercentFraction)

        ## Variable for set activation
        model.ys = Var(model.S, domain=Binary)

        ## Combined variable for X and ys
        model.p = Var(model.S, model.dX, domain=NonNegativeReals)

        ## Combined variable for a and ys
        model.q = Var(model.S, model.SP, domain=PercentFraction)

        ## Combined variable for Y and ys
        model.r = Var(model.S, model.dY, domain=NonNegativeReals)


        ## 2.4 CONSTRAINTS
        ## Linear equation for vector combination for X
        def X_vector_combination_constraint(model, s, d):
            # return model.p[s,d] == sum(model.q[s,p] * xpoints[simplices[s-1][p-1]][d-1] for p in model.SP)
            return model.p[s,d] == sum(model.q[s,p] * model.XPoints[model.Simplices[s][p],d] for p in model.SP)

        model.XVecCombConstr = Constraint(model.S, model.dX, rule=X_vector_combination_constraint)

        ## Linear equation for vector combination for Y
        def Y_vector_combination_constraint(model, s, d):
            return model.r[s,d] == sum(model.q[s,p] * model.YPoints[model.Simplices[s][p],d] for p in model.SP)

        model.YVecCombConstr = Constraint(model.S, model.dY, rule=Y_vector_combination_constraint)

        ## Normation equation for vector combination
        def sum_affine_coefficients_constraint(m,s):
            return sum(model.a[s,p] for p in model.SP) == 1

        model.AffnCombConstr = Constraint(model.S, rule=sum_affine_coefficients_constraint)

        ## Sum constraint for binary variables
        def sum_ys_constraint(m):
            return sum(m.ys[s] for s in m.S) == 1

        model.SumYsConstr = Constraint(rule = sum_ys_constraint)

        ## Big M notation for p
        def BigM_1_p_constraint(m,s,d):
            return model.p[s,d] <= model.bigMX[d] * model.ys[s]

        def BigM_2_p_constraint(m,s,d):
            return model.p[s,d] <= model.X[d]

        def BigM_3_p_constraint(m,s,d):
            return model.p[s,d] >= model.X[d] - model.bigMX[d]*(1-model.ys[s])

        def BigM_4_p_constraint(m,s,d):
            return model.p[s,d] >= 0

        model.M1pConstr = Constraint(model.S, model.dX, rule=BigM_1_p_constraint)
        model.M2pConstr = Constraint(model.S, model.dX, rule=BigM_2_p_constraint)
        model.M3pConstr = Constraint(model.S, model.dX, rule=BigM_3_p_constraint)
        model.M4pConstr = Constraint(model.S, model.dX, rule=BigM_4_p_constraint)

        ## Big M notation for q
        def BigM_1_q_constraint(m,s,p):
            return model.q[s,p] <= model.ys[s]

        def BigM_2_q_constraint(m,s,p):
            return model.q[s,p] <= model.a[s,p]

        def BigM_3_q_constraint(m,s,p):
            return model.q[s,p] >= model.a[s,p] - (1 - model.ys[s])

        def BigM_4_q_constraint(m,s,p):
            return model.q[s,p] >= 0

        model.M1qConstr = Constraint(model.S, model.SP, rule=BigM_1_q_constraint)
        model.M2qConstr = Constraint(model.S, model.SP, rule=BigM_2_q_constraint)
        model.M3qConstr = Constraint(model.S, model.SP, rule=BigM_3_q_constraint)
        model.M4qConstr = Constraint(model.S, model.SP, rule=BigM_4_q_constraint)

        ## Big M notation for r
        def BigM_1_r_constraint(m,s,d):
            return model.r[s,d] <= model.bigMY[d] * model.ys[s]

        def BigM_2_r_constraint(m,s,d):
            return model.r[s,d] <= model.Y[d]

        def BigM_3_r_constraint(m,s,d):
            return model.r[s,d] >= model.Y[d] - model.bigMY[d]*(1 - model.ys[s])

        def BigM_4_r_constraint(m,s,d):
            return model.r[s,d] >= 0

        model.M1rConstr = Constraint(model.S, model.dY, rule=BigM_1_r_constraint)
        model.M2rConstr = Constraint(model.S, model.dY, rule=BigM_2_r_constraint)
        model.M3rConstr = Constraint(model.S, model.dY, rule=BigM_3_r_constraint)
        model.M4rConstr = Constraint(model.S, model.dY, rule=BigM_4_r_constraint)

        # # Concentration Constraints
        # def C1_constraint(m):
        #     return model.Y[4] >= 0.1
        #
        # model.C1Constr = Constraint(rule=C1_constraint)
        #
        # def C2_constraint(m):
        #     return model.Y[3] <= 1.
        #
        # model.C2Constr = Constraint(rule=C2_constraint)

        ## 2.5 Objective function
        model.Obj = Objective(expr=model.Y[yOBJ], sense=maximize)


        ## 3. Solution
        solver_factory= SolverFactory(solver)
        solver_factory.options['LogFile'] = "MILP_cID_{}_{}".format(cID,N)

        t2 = perf_counter()
        print("Elapsed time to set up model in PYOMO: ", t2-t1, "sec")

        results = solver_factory.solve(model, tee=True)

        model.X.pprint()
        model.Y.pprint()

        t3 = perf_counter()
        print("Elapsed time to solve model with", solver, ": ", t3-t2, "sec")
        print("Elapsed total time to solve MILP: ", t3-t1, "sec")

        ## 4. Output
        rxdict = dict()
        rydict = dict()
        for i in range(dim[0]):
            rxdict[dictData["frame_px"][i]] = [model.X[i+1].value]
        for i in range(dim[1]):
            rydict[dictData["frame_py"][i]] =[model.Y[i+1].value]

        dictData["time"] = np.array([t1,t2,t3])
        dictData["rX"] = rxdict
        dictData["rY"] = rydict

        export_csv(dictData)
