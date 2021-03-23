function output = mysimulator(x,xu,p,Aspen)
% function to call single flowsheet simulation and handle output
addpath("../simulations")

cID = p.cID;  % select configuration
load(sprintf("../simulations/c%d_MCS",cID),'space') % load Input Space from MCS
addpath(genpath('../simulations'))
addpath(genpath('../sampling'))


[T, configIDs] = nk_ctable; 
configID = configIDs{cID};

KPI = nk_runfsu(x,xu,space,configID,Aspen);

output = [-KPI.MaxXyoProd, KPI.Max5HMF-p.clims(1), KPI.MaxAac-p.clims(2), p.clims(3) - KPI.CO2Ratio];

end

