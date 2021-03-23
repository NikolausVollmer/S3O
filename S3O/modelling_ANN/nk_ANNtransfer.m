% script to transfer cross-validated ANNs into the necessary form for the NLP optimization
clear; clc; close all;

outs =  ["MaxXyoProd", "Max5HMF", "MaxAac","CO2Ratio"]; % "MaxXyoProd", "Max5HMF", "MaxAac", "CO2Ratio"
cIDs = [1,2,5,6];
Ns = [500,1000];

for d=1:length(cIDs)
    for e=1:length(Ns)
        for g=1:length(outs)
            cID = cIDs(d);
            N = Ns(e);
            out = outs(g);

            load(sprintf("c%d_ANNs_%d_cval_%s",cID,N,out),'myANN','annR2','annRMSE',...
                                                          'muX','sigX','muy','sigy');
            
            if out == "MaxXyoProd"
                mxpANN= myANN;
                mxpR2 = annR2;
                mxpRMSE = annRMSE;
                mxpMX = muX;
                mxpMY = muy;
                mxpSX = sigX;
                mxpSY = sigy;
                
            elseif out == "Max5HMF"
                hmfANN = myANN;
                hmfR2 = annR2;
                hmfRMSE = annRMSE;
                hmfMX = muX;
                hmfMY = muy;
                hmfSX = sigX;
                hmfSY = sigy;
                
            elseif out == "MaxAac"
                aacANN = myANN;
                aacR2 = annR2;
                aacRMSE = annRMSE;
                aacMX = muX;
                aacMY = muy;
                aacSX = sigX;
                aacSY = sigy;
                
            elseif out == "CO2Ratio"
                corANN = myANN;
                corR2 = annR2;
                corRMSE = annRMSE;
                corMX = muX;
                corMY = muy;
                corSX = sigX;
                corSY = sigy;          
                
            end          

        end
        
       save(sprintf("c%d_ANN_%d_opt",cID,N),'mxpANN','mxpR2','mxpRMSE',...
                                            'mxpMX','mxpMY','mxpSX','mxpSY',...
                                            'hmfANN','hmfR2','hmfRMSE',...
                                            'hmfMX','hmfMY','hmfSX','hmfSY',...
                                            'aacANN','aacR2','aacRMSE',...
                                            'aacMX','aacMY','aacSX','aacSY',...
                                            'corANN','corR2','corRMSE',...
                                            'corMX','corMY','corSX','corSY');
        
    end
end

        