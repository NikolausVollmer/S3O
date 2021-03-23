clc; clear;
addpath("../simulations")

% read MCS data
cID = 5;  % select configuration
N = 500;
Ti = readtable(sprintf("C%di_%d.csv",cID,N));
To = readtable(sprintf("C%do_%d.csv",cID,N));

% clean data
T = [Ti To];
T = rmmissing(T); % remove NaNs
T = rmoutliers(T,'quartiles'); % remove outliers

% train a GPR model on the entire dataset
X = T{:,Ti.Properties.VariableNames}; % inputs

%% Objective
y = T{:,'MaxXyoProd'}; % objective

[nX,muX,sigX] = standardize(X);
[ny,muyObj,sigyObj] = standardize(y);

[objANN, objstats]  = rs_fitann(nX,ny);
ypred = objANN(nX')';

rypred = restandardize(ypred,muyObj,sigyObj);
objR2  = corr(y,rypred).^2
objRMSE = sqrt(mean((rypred-y).^2))
plot(y,rypred,'bo')


%% Constraint 1
y = T{:,'Max5HMF'}; % constraint 1
[ny,muyCon1,sigyCon1] = standardize(y);

[con1ANN, con1stats]  = rs_fitann(nX,ny);
ypred = con1ANN(nX')'; % return 95% CI

rypred = restandardize(ypred,muyCon1,sigyCon1);
con1R2  = corr(y,rypred).^2
con1RMSE = sqrt(mean((rypred-y).^2))


%% Constraint 2
y = T{:,'MaxAac'}; % constraint 2
[ny,muyCon2,sigyCon2] = standardize(y);

[con2ANN, con2stats]  = rs_fitann(nX,ny);
ypred = con2ANN(nX')'; % return 95% CI

rypred = restandardize(ypred,muyCon2,sigyCon2);
con2R2  = corr(y,rypred).^2
con2RMSE = sqrt(mean((rypred-y).^2))


%% Constraint 3
y = T{:,'CO2Ratio'}; % constraint 3
[ny,muyCon3,sigyCon3] = standardize(y);

[con3ANN, con3stats]  = rs_fitann(nX,ny);
ypred = con3ANN(nX')'; % return 95% CI

rypred = restandardize(ypred,muyCon3,sigyCon3);
con3R2  = corr(y,rypred).^2
con3RMSE = sqrt(mean((rypred-y).^2))

save(sprintf("c%d_ANNs_%d",cID,N))