![S3O](https://user-images.githubusercontent.com/70581811/112120867-ef505b00-8bbe-11eb-8487-3c22f860cbca.jpg)

### Overview
Synergistic optimization-based framework for the conceptual design of bioprocesses

S3O facilitates & expedites conceptual process design for bioprocesses by synergistically:
- selecting product(s), feedstock and process unit operations in a bottom-up manner
- performing surrogate-assisted superstructure optimization to determine candidate process topologies
- performing simulation-based optimization for consolidating an optimal process design for the candidates under uncertainty

### Workflow
![Workflow_S3O_ppt](https://user-images.githubusercontent.com/70581811/112149248-0d2db800-8bdf-11eb-87e8-c8c27154b1ba.png)

### Employment
The repository contains the following folders:

- **\_data**: all the sampling data and models, presented in the according publication
- **easyGSA**: empty folder to install the easyGSA toolbox
- **modelling_ANN**: folder with the functions/scripts for fitting ANN surrogate models and transferring the models to the optimization problem (main script: *rs_ANNmodeling_cval.m*,*nk_ANNtransfer.m*)
- **modelling_DTR**: folder with the functions/scripts for fitting DTR surrogate models (main script: *main_DTR.py*)
- **modelling_GPR**: folder with the functions/scripts for fitting GPR surrogate models and transferring the models to the optimization problem (main script: *rs_GPRmodeling_cval.m*,*nk_GPRtransfer.m*)
- **models**: the high-fidelity models for the case study presented in the according publications (these are interchangeable with other models for other case studies)
- **MOSKopt**: empty folder to install the MOSKopt solver
- **optimization_MILP**: folder with the functions/scripts for the MILP (main script: *main_MILP.py*)
- **optimization_MINLP**: folder with the functions/scripts for the MINLP (main script: *main_MINLP.py*)
- **optimization_MOSKOPT**: folder with the functions/scripts for the simulation-based optimization (main script: *rs_MOSKopt.m*)
- **optimization_NLP**: folder with the functions/scripts for the series of NLP (main script: *rs_MultiStart_ANN.m*, *rs_MultiStart_GPR.m*)
- **sampling**: folder with functions belonging to the SPDlab toolbox for flowsheet simulations 
- **sensitivity**: folder with the functions/scripts for performing the flowsheet sensitivity analysis (main script: *rs_performGSA.m*)
- **simulations**: folder with the functions/scripts for performing single or Monte Carlo flowsheet simulations (built upon the functions of the SPDlab toolbox) (main script: *nk_mcsims.m*)

### Prerequisites
- MATLAB 2020b or higher        (https://www.mathworks.com/)
- Python 3.7.9 or higher        (https://www.python.org/)
- ASPEN Plus 11 or higher       (https://www.aspentech.com/)
- ALAMO Surrogate Modelling     (https://minlp.com/alamo)
- BARON Solver                  (https://minlp.com/baron)
- Gurobi Solver 9.10 or higher  (https://www.gurobi.com/)

The frameworke furthermore utilizes the easyGSA toolbox and the MOSKopt solver developed by Resul Al (resal@kt.dtu.dk). They are available on the GSI-Lab GitHub page:
- easyGSA (https://github.com/gsi-lab/easyGSA)
- MOSKopt (https://github.com/gsi-lab/MOSKopt)

### Developer
Nikolaus Vollmer (nikov@kt.dtu.dk) - PROSYS Research Center, Department of Chemical and Biochemical Engineering, Technical University of Denmark

### Acknowledgements
This work is part of the Fermentation-Based Biomanufacturing Initiative (http://www.fbm.dtu.dk) at the Technical University of Denmark and received funding by the Novo Nordisk Foundation (Grant no. NNF17SA0031362)
