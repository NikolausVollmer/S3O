% script to transfer cross-validated GPRs into the necessary form for the NLP optimization
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

            load(sprintf("c%d_GPR_%d_cval_%s",cID,N,out),'myGPR','gprR2','gprRMSE')
            
            if out == "MaxXyoProd"
                mxpGPR = myGPR;
                mxpR2 = gprR2;
                mxpRMSE = gprRMSE;
            elseif out == "Max5HMF"
                hmfGPR = myGPR;
                hmfR2 = gprR2;
                hmfRMSE = gprRMSE;
            elseif out == "MaxAac"
                aacGPR = myGPR;
                aacR2 = gprR2;
                aacRMSE = gprRMSE;
            elseif out == "CO2Ratio"
                corGPR = myGPR;
                corR2 = gprR2;
                corRMSE = gprRMSE;
            end          

        end
        
       save(sprintf("c%d_GPR_%d_opt",cID,N),'mxpGPR','mxpR2','mxpRMSE',...
                                            'hmfGPR','hmfR2','hmfRMSE',...
                                            'aacGPR','aacR2','aacRMSE',...
                                            'corGPR','corR2','corRMSE');
        
    end
end

        