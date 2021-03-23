% design space optimization using GPR models with MultiStart/fmincon
% By Resul Al @DTU

clc; clear;

addpath("../modelling_GPR")
addpath("../simulations")

outs =  ["MaxXyoProd"];              % Optimization outputs: "MaxXyoProd", "Max5HMF", "MaxAac", "CO2Ratio"
cIDs = [1,2,5,6];                    % configuration IDs                   
Ns = [500,1000];                     % Number of MC flowsheet samples


for e=1:length(Ns)
    for d=1:length(cIDs)
        
        cID = cIDs(d);
        N = Ns(e);

        load(sprintf("c%d_GPR_%d_opt",cID,N),'mxpGPR','hmfGPR','aacGPR','corGPR')
        load(sprintf("c%d_MCS",cID),'space') % load Input Space from MCS

        for g=1:length(outs);
            clims = [0.5, 0.5, 0.1]; % upper bounds of constraints on HMF and Aac, lower bound of CO2Ratio respectively.
            
            out = outs(g);
            
            objGPR = mxpGPR;
            con1GPR = hmfGPR;
            con2GPR = aacGPR;
            con3GPR = corGPR;

            reds = [4,5,6,9,11; 4,5,7,9,10; 4,5,6,9,11; 3,4,5,7,9]; % cID1: [4,5,6,9,11], cID2: [3,4,7,9,10], cID5: [1,3,6,9,11], cID6: [3,4,5,7,9];
            red = reds(d,:);

            %% Using MultiStart
            timer    = tic;
            x0       = (space.LowerBounds(red)+space.UpperBounds(red))/2;
            lbs      = space.LowerBounds(red);
            ubs      = space.UpperBounds(red);

            fun      = @(x) -predict(objGPR,x); % objective for optimization, put minus for maximize 
            cons     = @(x) deal([predict(con1GPR,x)-clims(1), predict(con2GPR,x)-clims(2), clims(3)-predict(con3GPR,x)],[]); % limits are imposed as <=
            opts     = optimoptions('fmincon','Display','None','Algorithm','sqp');
            problem  = createOptimProblem('fmincon','x0',x0,'lb',lbs,'ub',ubs,...
                      'objective',fun,'nonlcon',cons,'options',opts);

            ms       = MultiStart(); % 'UseParallel',true,'Display','none'
            [x,fval] = run(ms,problem,1000)
            runtime = toc(timer)

            con1 = predict(con1GPR,x)
            con2 = predict(con2GPR,x)
            con3 = predict(con3GPR,x)

            table(lbs', x', ubs','VariableNames',{'LowerBounds','OptFound','UpperBounds'},'RowNames',space.ParNames(red))
            save(sprintf("c%d_NLP_GPR_%d_%s",cID,N,out))
        end
    end
end