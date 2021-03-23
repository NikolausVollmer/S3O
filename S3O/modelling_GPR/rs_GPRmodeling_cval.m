% Surrogate model training with cross-validation
clear; clc; close all;
addpath("../simulations")

outs =  ["MaxXyoProd", "Max5HMF", "MaxAac", "CO2Ratio"]; % "MaxXyoProd", "Max5HMF", "MaxAac", "CO2Ratio"
cIDs = [1,2,5,6]; % flowsheet configuration ID
Ns = [500,1000]; % MC sample number

for g=1:length(outs)
    for e=1:length(Ns)
        for d=1:length(cIDs)
            cID = cIDs(d);
            N = Ns(e);
            out = outs(g);
            Ti = readtable(sprintf("C%di_%d.csv",cID,N));
            To = readtable(sprintf("C%do_%d.csv",cID,N));

            T = [Ti To];
            T = rmmissing(T); % remove NaNs
            T = rmoutliers(T,'quartiles'); % remove outliers

            % train a GPR model on the entire dataset

            X = T{:,Ti.Properties.VariableNames}; % inputs
            y = T{:,out}; % 'NetEnthalpy' 'MaxXyoProd' 'CO2' 'Max5HMF' 'MaxAac' 'CO2Ratio'

            % train a GPR model on the entire dataset
            myGPR  = fitrgp(X,y,'OptimizeHyperparameters','all');
            [ypred,ysd,yci] = predict(myGPR,X,'Alpha',0.05); % return 95% CI
            gprR2  = corr(y,ypred).^2
            gprRMSE = sqrt(mean((ypred-y).^2))

            % plot predictions with 95%CI
            Y = [y ypred yci(:,1) yci(:,2)]; Y=sortrows(Y,1,'ascend');
            figure();
            hold on;
            plot(Y(:,1),'r.');
            plot(Y(:,1),'r.');
            plot(Y(:,2));
            plot(Y(:,3),'k:');
            plot(Y(:,4),'k:');
            legend('y_{data}','STR predictions','GPR predictions',...
            'Lower prediction limit','Upper prediction limit',...
            'Location','Best');

            hold off
            plot(y,ypred,'ko');

            %% fold into 5 folds and calculate mean testR2 over folds
            rng(42,'twister'); % set the seed for reproducibility
            clear folds
            nobs   = size(X,1); % number of observations
            nfolds = 5; % number of folds
            cvp    = cvpartition(nobs,'KFold',nfolds);

            for f=1:nfolds
                f
                folds(f).X_train = X(cvp.training(f),:);
                folds(f).y_train = y(cvp.training(f),:);
                folds(f).X_test  = X(cvp.test(f),:);
                folds(f).y_test  = y(cvp.test(f),:);
                folds(f).GPR     = fitrgp(folds(f).X_train,folds(f).y_train,'OptimizeHyperparameters','all'); % ,'CategoricalPredictors','all', 'OptimizeHyperparameters','all'
                folds(f).trainR2 = corr(folds(f).y_train, predict(folds(f).GPR,folds(f).X_train)).^2;
                folds(f).testR2  = corr(folds(f).y_test,  predict(folds(f).GPR,folds(f).X_test)).^2;
                folds(f).trainRMSE = sqrt(mean((predict(folds(f).GPR,folds(f).X_train) - folds(f).y_train).^2));
                folds(f).testRMSE = sqrt(mean((predict(folds(f).GPR,folds(f).X_test) - folds(f).y_test).^2));    
            end
            fprintf('Mean training R2 over %d folds: %.2f\n',nfolds,mean([folds.trainR2]))
            fprintf('Mean test R2 over %d folds: %.2f\n',nfolds,mean([folds.testR2]))
            fprintf('Mean training RMSE over %d folds: %.2f\n',nfolds,mean([folds.trainRMSE]))
            fprintf('Mean test RMSE over %d folds: %.2f\n',nfolds,mean([folds.testRMSE]))
            save(sprintf("c%d_GPR_%d_cval_%s",cID,N,out))
            close all;
        end
    end
end