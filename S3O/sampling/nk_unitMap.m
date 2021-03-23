function uMap = nk_unitMap(varargin)
    % Storing Unit data in UnitClass and InputSpace objects
    % all unit operations need to be specified as in the indicated format
    % By Niko 21/08/2020
    
    % Biomass Pretreatment
    PT                     = UnitClass();
    PT.KEY                 = 'PT';
    PT.FullName            = 'Biomass Pretreatment';
    PT.DesignSpace         = InputSpace({'T_PT','t_PT','acid'},[173, 18, 0.5],[195, 30, 2.0]);

    % Upconcentration Hemicellulose
    UCH                     = UnitClass();
    UCH.KEY                 = 'UCH';
    UCH.FullName            = 'Upconcentration Hemicellulose';
    UCH.DesignSpace         = InputSpace({'v_UCH'},[0.4],[0.6]);
    
    % Fermentation Xylitol
    FX                     = UnitClass();
    FX.KEY                 = 'FX';
    FX.FullName            = 'Fermentation Xylitol';
    FX.DesignSpace         = InputSpace({'t_FX','inoc'},[12, 0.5],[48, 3]);
    
    % Evaporation Xylitol
    EX                     = UnitClass();
    EX.KEY                 = 'EX';
    EX.FullName            = 'Evaporation Xylitol';
    EX.DesignSpace         = InputSpace({'v_EX'},[0.99],[0.998]);
    
    % Crystallization Xylitol 1
    CX1                     = UnitClass();
    CX1.KEY                 = 'CX1';
    CX1.FullName            = 'Crystallization Xylitol 1';
    CX1.DesignSpace         = InputSpace({'t_CX1','TC_CX1','FC_CX1'},[2, 15, 0.01],[12, 25, 0.03]);
    
    % Crystallization Xylitol 2
    CX2                     = UnitClass();
    CX2.KEY                 = 'CX2';
    CX2.FullName            = 'Crystallization Xylitol 2';
    CX2.DesignSpace         = InputSpace({'t_CX2','FAS_CX2'},[2, 0.01],[12, 0.2]);

    % bypass
    bypass                  = UnitClass();
    bypass.KEY              = 'bypass';
    bypass.FullName         = 'bypass';
    bypass.DesignSpace      = InputSpace({},[],[]);
    
    % Map of all units
    uKeys={};
    uValues={};
    w = whos; % Looks for all variables
    for i=1:length(w)
        if strcmp(w(i).class,'UnitClass')
            uKeys{end+1}=w(i).name;
            eval(sprintf('uValues{end+1}= %s;',w(i).name));
        end
    end
    uMap    = containers.Map(uKeys,uValues);
end
