function rData = renormalize(nData,minData,maxData)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

rData = nData .* (maxData - minData) + minData;

end

