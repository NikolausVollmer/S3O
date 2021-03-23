function [nData,minData,maxData] = normalize(Data)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

maxData = max(Data);
minData = min(Data);
nData = (Data - minData)./(maxData - minData);

end

