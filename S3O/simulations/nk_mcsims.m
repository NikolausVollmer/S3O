% Simulate a set of Monte Carlo flowsheet simulation
% by Nikolaus Vollmer, nikov@kt.dtu.dk, 23.03.2021

clear; clc;

addpath("../sampling")
addpath("../models")

rng(42,'twister')

[T, configIDs] = nk_ctable;

cID = 5;    % configuration ID for flowsheet
configID = configIDs{cID}; 
space    = nk_designSpace(configID); show(space);
N        = 500; % number of Monte Carlo Simulations

reduced = 0; % decide whether full input space (0) or reduced space (1) is simulated
red = [4,5,6,9,11]; % indices of variables in reduced simulation, % cID1: [4,5,6,9,11], cID2: [4,5,7,9,10], cID5: [4,5,6,9,11], cID6: [3,4,5,7,9];

% Sampling with boundary points
if reduced == 1
    X = nk_sampleLHS(N,space.LowerBounds(red),space.UpperBounds(red));
    
% Sampling without boundary points
elseif reduced == 0
    X = nk_sampleLHS(N,space.LowerBounds,space.UpperBounds);

end

%% Simulations
mcsfolder = sprintf('c%d_mcsims',cID); % name of the folder where for iters are stored
if ~exist(mcsfolder, 'dir'), mkdir(mcsfolder); end

% Start Aspen
Aspen = StartAspen();

% perform mcsims
for i=1:N
    try
        fprintf('Started run %d.',i);
        filename = fullfile(mcsfolder, sprintf('row%d',i));
        if exist(filename,'file')==2
            continue;
        end

        % nominal variable values for reduced input space
        if reduced == 1
            xr = X(i,:);
            
            xall(1).x = [0.1, 0.025, 15, 186, 0.5, 3, 6, 6, 12, 18, 0.995, 0.5]; %cID1
            xall(2).x = [0.025, 15, 186, 0.5, 3, 6, 12, 18, 0.995, 0.5]; % cID2
            xall(3).x = [0.1, 0.025, 15, 186, 0.5, 3, 6, 6, 12, 18, 0.995]; % cID5
            xall(4).x = [0.1, 15, 186, 0.5, 3, 6, 12, 18, 0.995]; % cID6

            x = xall(red).x;
            x(red) = xr;

        % full input space
        elseif reduced == 0
            x = X(i,:);
        end
        
        KPI = nk_runfs(x,space,configID,Aspen);

        m=matfile(filename,'writable',true); m.KPI=KPI; 
        fprintf('Finished a successful run.\n')
    catch ME
        fprintf('Hit an error.\n')
        rethrow(ME)
    end
end

Aspen.Close;
Aspen.Quit;

save(sprintf("c%d_MCS",cID))

% collect completed sims
for i=1:N
    try
        filename = fullfile(mcsfolder, sprintf('row%d',i));
        m=matfile(filename,'writable',true);
        D(i).KPI = m.KPI;
    catch ME
        D(i).KPI  = NaN;
        %rethrow(ME)
    end
end


% Put all KPIs into a table T
S=struct;
fnames=fields(D(1).KPI);
for i=1:numel(D)
    for j=1:numel(fnames)
        try
            S(i).(fnames{j}) = D(i).KPI.(fnames{j});
        catch
            S(i).(fnames{j}) = NaN;
        end
    end
end
To = struct2table(S) % convert to a table        
Ti = array2table(X,'VariableNames',space.ParNames(red));
% Ti = array2table(X,'VariableNames',space.ParNames);

writetable(Ti,sprintf("C%di_%d.csv",cID,N))
writetable(To,sprintf("C%do_%d.csv",cID,N))
