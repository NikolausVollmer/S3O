function KPI = nk_runSBO(x,xu,space,configID,Aspen)
    % simulate a single row
    addpath(genpath('../models'))
    designrow = table2struct(array2table(x, 'VariableNames', space.ParNames));
    struct2vars(designrow);
    
    m = 0;
    c = [];
    
    KPI.NetEnthalpy = 0;
    KPI.NetHeatFlux = 0;
    Time = 0;
    
    for i = 1:length(configID)
        model = cell2mat(configID(i));
    
        switch model
            case 'PT'
                m_biomass = 50000;
                c_PT_in   = [31.3 0 42.7 0 2.6 0 5 0 0 0 0 18.4 0 0 0];
                stats_PT = [T_PT,t_PT,acid,0.1];
                pars_PT = pretreatment_pars();
                pars_PT(9:16) = xu;
                
                [m_PT_l_out,c_PT_l_out,m_PT_s_out,c_PT_s_out,H_ext_PT] = pretreatment_model(m_biomass,c_PT_in,stats_PT,pars_PT);
                
                m = m_PT_l_out;
                c = c_PT_l_out;
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_PT;
                KPI.NetHeatFlux = KPI.NetHeatFlux + H_ext_PT/(t_PT/60);
                Time = Time + t_PT/60;
                
            case 'FX'
                m_FX_in = m;
                c_FX_in = c;
                stats_FX = [t_FX,inoc];
                               
                [m_FX_out, c_FX_out, M_O2_in, M_CO2_out, M_nitro, M_titr, H_ext_FX] = fermentation_model_xylitol(m_FX_in,c_FX_in,stats_FX);
                
                m = m_FX_out;
                c = c_FX_out;
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_FX;
                KPI.NetHeatFlux = KPI.NetHeatFlux + H_ext_FX/t_FX;
                Time = Time + t_FX;
                
            case 'EX'
                m_EX_in = m;
                c_EX_in = c;
                stats_EX = [t_EX,vfrac,Tpre_EX];                
                
                [m_EX_l_out, c_EX_l_out, m_EX_v_out, c_EX_v_out, H_ext_EX] = evaporation_model(m_EX_in,c_EX_in,stats_EX,Aspen);
                
                m = m_EX_l_out;
                c = c_EX_l_out;
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_EX;
                KPI.NetHeatFlux = KPI.NetHeatFlux + H_ext_EX/t_EX;
                Time = Time + t_EX;
                
            case 'CX'
                m_CX_in = m;
                c_CX_in = c;
                
                F_C = 0.14;
                T0_C = 10;
                stats_CX = [t_CX,Ti_CX,Tf_CX,FAS_CX,F_C,T0_C];
                
                [m_CX_out, c_CX_out, m_cryst, H_ext_CX] = crystallization_xylitol(m_CX_in, c_CX_in, stats_CX);
                
                m = m_CX_out;
                c = c_CX_out;
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_CX;
                KPI.NetHeatFlux = KPI.NetHeatFlux + H_ext_CX/t_CX;
                KPI.Max5HMF = c_CX_out(10);
                KPI.MaxAac = c_CX_out(9);
                Time = Time + t_CX;

            case 'blank'
                
        end    
    end
    
% KPI.XylitolFinal = m_cryst;
%KPI.XylitolProductionRate = m_cryst/Time;    

 
end