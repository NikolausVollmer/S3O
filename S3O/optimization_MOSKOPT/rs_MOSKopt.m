% Before running this code, make sure MOSKopt is installed.
clc; clear; rng(0,'twister');
addpath("../simulations")

cID = 2;  % select configuration
load(sprintf("../simulations/c%d_MCS",cID),'space') % load Input Space from MCS

reds(1).x = [4,5,6,9,11]; % input variable indices for cID 1
reds(2).x = [4,5,7,9,10]; % input variable indices for cID 2
reds(5).x = [4,5,6,9,11]; % input variable indices for cID 5
reds(6).x = [3,4,5,7,9]; % input variable indices for cID 6
red = reds(cID).x;

% Optimization: Define an optimization problem structure p, and call the interface to the optimizer.
p        = struct;
p.cID    = cID; % configuration ID
p.red    = red; % reduced input indices
p.x0     = [0.7624, 1.4929, 46.4266, 0.9968, 0.5196]; % starting values from SSO
p.lbs    = space.LowerBounds(p.red); % lower bounds
p.ubs    = space.UpperBounds(p.red); % upper bounds
p.dim    = numel(p.x0);       % dimensionality
p.m      = 100;               % # of samples for MC-based uncertainty analysis.
p.k      = 5*p.dim;           % initial design size
Nmax     = 75;                % MaxFunEval (SK iterations) 
p.clims  = [0.5, 0.5, 0.1];   % upper bounds of constraints on HMF and ACC, lower bound for CO2Ratio.

% InitialX
Xp = lhsdesign(p.k,p.dim);
for i=1:p.dim, InitialX(:,i) = unifinv(Xp(:,i),p.lbs(i),p.ubs(i)); end 

[InitialObjectiveObservations, InitialConstraintObservations] = rs_simulate(InitialX,p);
save(sprintf('INdata_cID%d',cID), 'InitialObjectiveObservations', 'InitialConstraintObservations');
% load INdata_cID5

% Prepare variables and the objective function for SK optimization.
vars=[];
for i=1:p.dim
    eval(sprintf("x%d = optimizableVariable('x%d',[%d,%d]);",i,i,p.lbs(i),p.ubs(i)));
    eval(sprintf("vars = [vars x%d];",i));
end

fun = @(xx) myObj(xx,p); 
[x,fval,results] = MOSKopt(fun,vars,'Verbose',1,...
                            'SaveEachNiters',1,...
                            'MaxObjectiveEvaluations',Nmax,...
                            'NumSeedPoints',p.k,...
                            'NumRepetitions',p.m,...
                            'InitialX',array2table(InitialX),...                            
                            'InitialObjectiveObservations',InitialObjectiveObservations,...
                            'InitialConstraintObservations',InitialConstraintObservations,...
                            'NumCoupledConstraints',3,...
                            'CoupledConstraintTolerances',1e-3*ones(1,3),...
                            'InfillCriterion','mcFEI',... % ['FEI', 'mcFEI', 'cAEI']
                            'InfillSolver','particleswarm',... %  [GlobalSearch, MultiStart]
                            'UncertaintyHedge','Mean') % [MeanPlusSigma, UCI95, Mean, PF80]

save(sprintf("c%d_simopt",cID))


function [f,g,UserData] = myObj(xx,p) 
    % Handle of the black-box simulation which returns the objective and
    % the constraints observations (each with m repititions). 
    % 
    % No user modifications needed.
    
    x=[];
    for i=1:p.dim
        eval(sprintf("x = [x ; xx.x%d];",i))
    end
    [f_observations, g_observations] = rs_simulate(x',p);
  
    % means
    f = nanmean(f_observations,2); 
    g = cellfun(@(X) nanmean(X,2), g_observations ,'UniformOutput',false); 
    
    UserData.ObjectiveObservations    = f_observations; % will be used for FVarTrain
    UserData.ConstraintObservations   = g_observations; % will be used for GVarTrain
end

