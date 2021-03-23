% collect MCS into a table
clc; clear;

rng(42,'twister')
[T, configIDs] = nk_ctable; 
cID = 8;                                 % change cID
configID = configIDs{cID}; 
space    = nk_designSpace(configID); show(space);
M        = 100;
N        = 500;
X        = nk_sampleLHS(N,space.LowerBounds,space.UpperBounds);
mcsfolder = sprintf('c%d_training',cID); % name of the folder where for iters are stored
if ~exist(mcsfolder, 'dir'), mkdir(mcsfolder); end



% collect completed sims
for j=1:M
    for i=1:N
        try
            filename = fullfile(mcsfolder, sprintf('run%d_row%d',j,i));
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
    Ti = array2table(X,'VariableNames',space.ParNames);

    writetable(Ti,sprintf("run%d.csv",j))
    writetable(To,sprintf("run%d.csv",j))
end