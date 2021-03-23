clear; clc; close all;
addpath("../simulations")

outs =  ["MaxXyoProd", "Max5HMF", "MaxAac", "CO2Ratio"];
cIDs = [1,2,5,6];
Ns = [500,1000];

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

            % train an ANN model on the entire dataset

            X = T{:,Ti.Properties.VariableNames}; % inputs
            y = T{:,out}; % 'MaxXyoProd' 'Max5HMF' 'MaxAac' 'CO2Ratio'

            % standardize data with zero mean and one variance
            [nX,muX,sigX] = standardize(X);
            [ny,muy,sigy] = standardize(y);

            % train a GPR model on the entire dataset
            [myANN, stats]= rs_fitann(nX,ny);
            ypred = myANN(nX')';

            rypred = restandardize(ypred,muy,sigy);
            annR2  = corr(y,rypred).^2
            annRMSE = sqrt(mean((rypred-y).^2))

            % plot predictions with 95%CI
            Y = [y ypred]; Y=sortrows(Y,1,'ascend');
            figure();
            hold on;
            plot(Y(:,1),'r.');
            plot(Y(:,2));
            legend('y_{data}','ANN predictions');
            hold off
            plot(y,rypred,'ko');

            %% fold into 5 folds and calculate mean testR2 over folds
            rng(42,'twister'); % set the seed for reproducibility
            clear folds
            nobs   = size(X,1); % number of observations
            nfolds = 5; % number of folds
            cvp    = cvpartition(nobs,'KFold',nfolds);

            % k-fold cross validation with standardized data
            for f=1:nfolds
                f
                folds(f).nX_train = nX(cvp.training(f),:);
                folds(f).ny_train = ny(cvp.training(f),:);
                folds(f).y_train = y(cvp.training(f),:);
                folds(f).nX_test  = nX(cvp.test(f),:);
                folds(f).ny_test  = ny(cvp.test(f),:);
                folds(f).y_test  = y(cvp.test(f),:);

                folds(f).ANN     = rs_fitann(folds(f).nX_train,folds(f).ny_train);
                folds(f).ypred_train = folds(f).ANN(folds(f).nX_train')';
                folds(f).rypred_train = restandardize(folds(f).ypred_train,muy,sigy);
                folds(f).ypred_test = folds(f).ANN(folds(f).nX_test')';
                folds(f).rypred_test = restandardize(folds(f).ypred_test,muy,sigy);


                folds(f).trainR2 = corr(folds(f).y_train, folds(f).rypred_train).^2;
                folds(f).testR2  = corr(folds(f).y_test,  folds(f).rypred_test).^2;
                folds(f).trainRMSE = sqrt(mean((folds(f).rypred_train - folds(f).y_train).^2));
                folds(f).testRMSE = sqrt(mean((folds(f).rypred_test - folds(f).y_test).^2));  
            end

            fprintf('Mean training R2 over %d folds: %.4f\n',nfolds,mean([folds.trainR2]))
            fprintf('Mean test R2 over %d folds: %.4f\n',nfolds,mean([folds.testR2]))
            fprintf('Mean training RMSE over %d folds: %.4f\n',nfolds,mean([folds.trainRMSE]))
            fprintf('Mean test RMSE over %d folds: %.4f\n',nfolds,mean([folds.testRMSE]))
            save(sprintf("c%d_ANNs_%d_cval_%s",cID,N,out))
            
        end
    end
end

