function [T, designIDs] = nk_ctable()
    % Returns a table of configurations
    % All processes include pretreatment, optional upstream units, a
    % processing unit, optional upconcentration unit, a crystallization unit
    % and an optional second crystallization unit
    
    pretreatment = {'PT'};
    hf_upstream = {'UCH','bypass'};
    hf_process = {'FX'};
    hf_upconc = {'EX','bypass'};
    hf_purfc = {'CX1'};
    hf_spurfc = {'CX2','bypass'};
    

    designIDs = {};
    for o=1:length(pretreatment)
        for p=1:length(hf_upstream)
            for q=1:length(hf_process)
                for r=1:length(hf_upconc)
                    for s=1:length(hf_purfc)
                        for t=1:length(hf_spurfc)
                            did ={pretreatment{o}, hf_upstream{p}, hf_process{q}, hf_upconc{r}, hf_purfc{s}, hf_spurfc{t}};
                            designIDs{end+1,1} = did; % to get all dids, designIDs{:}
                        end  
                    end
                end
            end
        end
    end
    
    didc = {};
    for d=1:length(designIDs), did=designIDs{d}; didc{d,1}=strjoin(did,'-'); end
    T = table; 
    T.cID=[1:length(didc)]'; 
    T.configID = didc;
    
end