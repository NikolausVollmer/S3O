function [myANN,stats] = rs_fitann(X,y)
    % Fits an ANN model into a given dataset (X,y) using grid search
    % approach.
    % By Resul Al @DTU
    [myANN,stats] = rs_gridsearch(X',y');
end

function [myANN,stats] = rs_gridsearch(x,t,IOpts)
    % The grid search approach for finding the best network configuration.
    %
    % By Resul Al @DTU

    % get the data
    if nargin<3, IOpts=struct; end

    % options to grid-search
    if ~isfield(IOpts,'rseed'),             IOpts.rseed             = 0;     end
    if ~isfield(IOpts,'hiddenLayerSize'),   IOpts.hiddenLayerSize   = 5:15;  end  % just one layer with 5:15 neurons
    if ~isfield(IOpts,'trainFunctions'),    IOpts.trainFunctions    = {'trainlm','trainbr','trainscg','traincgb'}; end% 
    if ~isfield(IOpts,'transferFunctions'), IOpts.transferFunctions = {'purelin','tansig', 'logsig','poslin','radbas'}; end
    if ~isfield(IOpts,'errorgoal'),         IOpts.errorgoal         = 1e-3; end
    if ~isfield(IOpts,'Nepochs'),           IOpts.Nepochs           = 1e3; end
    % see train functions
    % https://se.mathworks.com/help/deeplearning/ug/choose-a-multilayer-neural-network-training-function.html#bss4gz0-28

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    combinations = struct;
    id = 0;
    for r=IOpts.rseed
        rng(r);
        for s=IOpts.hiddenLayerSize
            hiddenLayerSize = s;
            for k=1:length(IOpts.trainFunctions)
                trainFcn = IOpts.trainFunctions{k};
                net = fitnet(hiddenLayerSize,trainFcn);
                for m=1:length(IOpts.transferFunctions)
                    transferFcn = IOpts.transferFunctions{m};
                    net.layers{1}.transferFcn = transferFcn;
                    % Setup Division of Data for Training, Validation, Testing
                    % divide data for training, validation and testing (help nndivide)
                    net.divideFcn = 'dividerand';  % 'dividerand' Divide data randomly
                    net.divideMode = 'sample';  % Divide up every sample
                    net.divideParam.trainRatio = 70/100; % 70% for training
                    net.divideParam.valRatio = 20/100; % 15% for validation
                    net.divideParam.testRatio = 10/100; % 15% for test
                    
                    % performance function
                    net.performFcn = 'mse';
                    net.trainParam.goal=IOpts.errorgoal;
                    net.trainParam.epochs=IOpts.Nepochs;
                    net.trainParam.showWindow = false;
                    
                    % choose plot functions (help nnplot)
                    net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
                                    'plotregression', 'plotfit'};

                    % Train the Network
                    [net,tr,y,e] = train(net,x,t); % y = net(x); e = gsubtract(t,y);

                    id = id+1;
                    combinations(id).rmse = sqrt(perform(net,t,y));
                    combinations(id).hiddenLayerSize = s;
                    combinations(id).trainFcn = trainFcn;
                    combinations(id).transferFcn = transferFcn;
                    combinations(id).network = net;
                    combinations(id).tr = tr;
                    combinations(id).outputs = y;
                    combinations(id).inputs = x;
                    combinations(id).seedR = r;
                end
            end
        end
    end

    [m,ii]   = min([combinations.rmse]);
    myANN    = combinations(ii).network;
    y_ann    = combinations(ii).outputs;
    stats.tr = combinations(ii).tr;
    stats.R2 = corr(t',y_ann').^2;
end
