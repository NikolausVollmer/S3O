% design space optimization using ANN models with MultiStart/fmincon
% By Resul Al @DTU

clc; clear;

addpath("../modelling_ANN")
addpath("../simulations")

outs =  ["MaxXyoProd"];              % Optimization outputs: "MaxXyoProd", "Max5HMF", "MaxAac", "CO2Ratio"
cIDs = [1,2,5,6];                    % configuration IDs                   
Ns = [500,1000];                     % Number of MC flowsheet samples


for e=1:length(Ns)
    for d=1:length(cIDs)
        
        cID = cIDs(d);
        N = Ns(e);

        load(sprintf("c%d_ANN_%d_opt",cID,N),'mxpANN','hmfANN','aacANN','corANN','mxrANN',...
                                              'mxpMX','mxpMY','mxpSX','mxpSY',...
                                              'hmfMX','hmfMY','hmfSX','hmfSY',...
                                              'aacMX','aacMY','aacSX','aacSY',...
                                              'corMX','corMY','corSX','corSY',...
                                              'mxrMX','mxrMY','mxrSX','mxrSY');
                                          
        load(sprintf("c%d_MCS",cID),'space') % load Input Space from MCS


        for g=1:2
            out = outs(g);
            objANN = mxpANN;
            muX = mxpMX;
            sigX = mxpSX;
            muyObj = mxpMY;
            sigyObj = mxpSY;
            
            con1ANN = hmfANN;
            muyCon1 = hmfMY;
            sigyCon1 = hmfSY;
            
            con2ANN = aacANN;
            muyCon2 = aacMY;
            sigyCon2 = aacSY;
            
            con3ANN = corANN;
            muyCon3 = corMY;
            sigyCon3 = corSY;
          
            % play with the constraint limits
            clims = [0.5, 0.5, 0.1]; % upper bounds of constraints on HMF and Aac, lower bound for CO2Ratio respectively.
            clims(1) = (clims(1) - muyCon1)/sigyCon1;
            clims(2) = (clims(2) - muyCon2)/sigyCon2;
            clims(3) = (clims(3) - muyCon3)/sigyCon3;

            reds = [4,5,6,9,11; 4,5,7,9,10; 4,5,6,9,11; 3,4,5,7,9]; % cID1: [4,5,6,9,11], cID2: [3,4,7,9,10], cID5: [1,3,6,9,11], cID6: [3,4,5,7,9];
            red = reds(d,:);

            %% Using MultiStart
            timer    = tic;
            x0       = (space.LowerBounds(red)+space.UpperBounds(red))/2;
            lbs      = space.LowerBounds(red);
            ubs      = space.UpperBounds(red);

            x0       = (x0 - muX)./sigX;
            lbs      = (lbs - muX)./sigX;
            ubs      = (ubs - muX)./sigX;

            fun      = @(x) -objANN(x')'; % objective for optimization, put minus for maximize 
            cons     = @(x) deal([con1ANN(x')'-clims(1), con2ANN(x')'-clims(2), clims(3)-con3ANN(x')'],[]); % limits are imposed as <=
            opts     = optimoptions('fmincon','Display','None','Algorithm','sqp');
            problem  = createOptimProblem('fmincon','x0',x0,'lb',lbs,'ub',ubs,...
                      'objective',fun,'nonlcon',cons,'options',opts);

            ms       = MultiStart(); % 'UseParallel',true,'Display','none'
            [x,fval,exitflag,output] = run(ms,problem,1000)
            runtime = toc(timer)


            con1 = con1ANN(x')';
            con2 = con2ANN(x')';
            con3 = con3ANN(x')';

            conditions = x.*sigX + muX
            obj = -fval*sigyObj + muyObj
            con1 = con1*sigyCon1 + muyCon1
            con2 = con2*sigyCon2 + muyCon2
            con3 = con3*sigyCon3 + muyCon3

            table(lbs', x', ubs','VariableNames',{'LowerBounds','OptFound','UpperBounds'},'RowNames',space.ParNames(red));
            save(sprintf("c%d_NLP_ANN_%d_%s",cID,N,out))
        end
    end
end