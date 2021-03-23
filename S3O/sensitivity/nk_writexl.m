clear
clc

cIDs = 8;
output = "Xyo";

for cID = 1:cIDs
    load(sprintf("c%d_GSA_%s",cID,output),'S','ST');
    
    writetable(S,sprintf("c%d_GSA_%s_S.csv",cID,output),'WriteRowNames',true);
    writetable(ST,sprintf("c%d_GSA_%s_ST.csv",cID,output),'WriteRowNames',true);
    clear S ST
end