clc; clear;
addpath("../easyGSA")
addpath("../simulations")

cIDs = [1,2,5,6]; % choose respective flowsheet(s)

for d = 1:length(cIDs) % change iteration according to flowsheets
    % read MCS data
    cID = cIDs(d);  % select configuration
    Ti = readtable(sprintf("C%di.csv",cID))
    To = readtable(sprintf("C%do.csv",cID))

    % clean data
    T = [Ti To];
    T = rmmissing(T); % remove NaNs
    T = rmoutliers(T,'quartiles'); % remove outliers


    %% perform GSA for the selected output
    output    = 'MaxXyoProd'; % select the output 'MaxXyoProd', 'CO2', ...

    Data.X = T{:,Ti.Properties.VariableNames}; % inputs
    Data.Y = T{:,output}; % output

    % GPRindicies
    [gprSi,gprSTi,gpr_results] = easyGSA('UserData',Data) % uses GPR models by default.
    gpr_results.GPRstats

    % ANNindices
    [annSi,annSTi,ann_results] = easyGSA('UserData',Data,'UseSurrogate','ANN')
    ann_results.ANNstats

    S  = array2table([gprSi,annSi],"VariableNames",{'gprSi','annSi'},...
                    "RowNames",Ti.Properties.VariableNames)

    ST = array2table([gprSTi,annSTi],"VariableNames",{'gprSTi','annSTi'},...
                    "RowNames",Ti.Properties.VariableNames)

    fprintf("\nThe important decision variables for the output %s in configuration %d are the following:\n",output,cID)
    disp(S) 
    disp(ST)

    if output == "MaxXyoProd"
        save(sprintf("c%d_GSA_Xyo",cID))
    elseif output == "CO2"
        save(sprintf("c%d_GSA_CO2",cID))
    end
    
    writetable(S,sprintf("C%d_S_2000.csv",cID),'WriteRowNames',true)
    writetable(ST,sprintf("C%d_ST_2000.csv",cID),'WriteRowNames',true)
end
