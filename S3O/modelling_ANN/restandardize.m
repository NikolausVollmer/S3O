function rData = restandardize(nData,muData,sigmaData)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

rData = sigmaData .* nData + muData;

end

