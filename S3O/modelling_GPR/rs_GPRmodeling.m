% Surrogate model training for full data set without cross-validation
clc; clear; close all;
addpath("../data/simulations")

% read MCS data
cID = 2;  % select configuration ID for flowsheet
N = 500;  % select MC sample size
Ti = readtable(sprintf("C%di_%d.csv",cID,N));
To = readtable(sprintf("C%do_%d.csv",cID,N));

% clean data
T = [Ti To];
T = rmmissing(T); % remove NaNs
T = rmoutliers(T,'quartiles'); % remove outliers

% train a GPR model on the entire dataset

%% Objective
X = T{:,Ti.Properties.VariableNames}; % inputs
y = T{:,'MaxXyoProd'}; % objective

objGPR  = fitrgp(X,y,'OptimizeHyperparameters','all'); % 'BasisFunction' 'KernelFunction' 'KernelScale' 'Sigma' 'Standardize'}
[ypred,ysd,yci] = predict(objGPR,X,'Alpha',0.05); % return 95% CI
objR2  = corr(y,ypred).^2
objRMSE = sqrt(mean((ypred-y).^2))

y = T{:,'Max5HMF'}; % constraint 1
con1GPR  = fitrgp(X,y,'OptimizeHyperparameters','all');
[ypred,ysd,yci] = predict(con1GPR,X,'Alpha',0.05); % return 95% CI
con1R2  = corr(y,ypred).^2
con1RMSE = sqrt(mean((ypred-y).^2))

y = T{:,'MaxAac'}; % constraint 2
con2GPR  = fitrgp(X,y,'OptimizeHyperparameters','all');
[ypred,ysd,yci] = predict(con2GPR,X,'Alpha',0.05); % return 95% CI
con2R2  = corr(y,ypred).^2
con2RMSE = sqrt(mean((ypred-y).^2))

y = T{:,'CO2Ratio'}; % constraint 3
con3GPR  = fitrgp(X,y,'OptimizeHyperparameters','all');
[ypred,ysd,yci] = predict(con3GPR,X,'Alpha',0.05); % return 95% CI
con3R2  = corr(y,ypred).^2
con3RMSE = sqrt(mean((ypred-y).^2))

save(sprintf("c%d_GPRb_%d",cID,N))