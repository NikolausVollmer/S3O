% simulate a single flowsheet simulation
% by Nikolaus Vollmer, nikov@kt.dtu.dk, 23.03.2021
clear; clc;

addpath("../sampling")
addpath("../models")

rng(42,'twister')

%% Input
d= 3;               % number of cID in the list of configuration IDs
input = [195, 0.8793, 3, 24.2736, 0.998];   % values of variables for single simulation

%% Load Flowsheet
[T, configIDs] = nk_ctable;

cIDs = [1,2,5,6];   % list of configuration IDs

cID = cIDs(d);
configID = configIDs{cID}; 
space    = nk_designSpace(configID); show(space);

%% Variable indices
reds = [4,5,6,9,11; 4,5,7,9,10; 4,5,6,9,11; 3,4,5,7,9]; % number of reduced set of variables for simulation (other variables are simulated with nominal values)
red = reds(d,:);

%% Simulations
% Start Aspen
Aspen = StartAspen();

% perform single sims
try
    % reduced input space
    if d == 1
        x = [0.1, 0.025, 15, 186, 0.5, 3, 6, 6, 36, 18, 0.995, 0.5];
    elseif d == 2
        x = [0.025, 15, 186, 0.5, 3, 6, 36, 18, 0.995, 0.5];
    elseif d == 3
        x = [0.1, 0.025, 15, 186, 0.5, 3, 6, 6, 36, 18, 0.995];
    elseif d == 4
        x = [0.1, 15, 186, 0.5, 3, 6, 36, 18, 0.995];
    end

    x(red) = input;

    % full input space
    % x = X(i,:);
    
    KPI = nk_runfs(x,space,configID,Aspen)
    
catch ME
    fprintf('Hit an error.\n')
    rethrow(ME)
end

Aspen.Close;
Aspen.Quit;
