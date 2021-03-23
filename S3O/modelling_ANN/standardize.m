function [nData,muData,sigmaData] = standardize(Data)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

muData = mean(Data);
sigmaData = std(Data);
nData = (Data - muData)./sigmaData;

end

