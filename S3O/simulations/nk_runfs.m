% function for Monte Carlo simulations to simulate a single flowsheet
% evaluation
function KPI = nk_runfs(x,space,configID,Aspen)
    addpath(genpath('../models'))
    designrow = table2struct(array2table(x, 'VariableNames', space.ParNames))
    struct2vars(designrow)
    
    m = 0;
    c = [];
    Stats = []; % Temperature
    
    KPI.NetEnthalpy = 0;
    KPI.MaxXyoProd = 0;
    KPI.CO2 = 0;
    Time = 0;
    
    % CO2 Calculations
    h_lp = 2733.4; % kJ/kg from VDI
    h_mp = 2803.1; % kJ/kg from VDI
    co2eq = 0.22;  % kg CO2/ kg steam
    
    for i = 1:length(configID)
        model = cell2mat(configID(i));
    
        switch model
            case 'PT'
                m_biomass = 1000; %
                c_PT_in   = [31.3 0 42.7 0 2.6 0 5 0 0 0 0 18.4 0 0 0];
                
                phi_PT = 0.1;
                
                stats_PT_in = [T_PT,t_PT,acid,phi_PT];
                pars_PT = pretreatment_pars();
                
                [m_PT_l_out,c_PT_l_out,m_PT_s_out,c_PT_s_out,stats_PT_out,H_ext_PT] = pretreatment_model(m_biomass,c_PT_in,stats_PT_in,pars_PT);
                
                m = m_PT_l_out;
                c = c_PT_l_out;
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_PT;
                KPI.CO2 = KPI.CO2 + H_ext_PT / h_mp * co2eq;
                Time = Time + t_PT/60;
                Stats(1) = 30;
                
            case 'UCH'
                m_UCH_in = m;
                c_UCH_in = c;
                
                t_UCH = 1;
                T_in_UCH = 40;
                T_out_UCH = 30;
                
                stats_UCH_in = [t_UCH,v_UCH,T_in_UCH,T_out_UCH];                
                
                [m_UCH_l_out, c_UCH_l_out, m_UCH_v_out, c_UCH_v_out, stats_UCH_out, H_ext_UCH] = evaporation_model(m_UCH_in,c_UCH_in,stats_UCH_in,Aspen);
                
                m = m_UCH_l_out;
                c = c_UCH_l_out;
                Tl_UCH = stats_UCH_out(1);
                Tv_UCH = stats_UCH_out(2);
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_UCH;
                time_uch = -H_ext_UCH / (0.5e8 * 3.6);
                Time = Time + time_uch;
                
            case 'FX'
                m_FX_in = m;
                c_FX_in = c;
                
                stats_FX = [t_FX,inoc];
                               
                [m_FX_out, c_FX_out, M_O2_in, M_CO2_out, M_nitro, M_titr, H_ext_FX] = fermentation_model_xylitol(m_FX_in,c_FX_in,stats_FX);
                
                m = m_FX_out;
                c = c_FX_out;
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_FX;
                Time = Time + t_FX;
                
            case 'EX'
                m_EX_in = m;
                c_EX_in = c;
                
                t_EX = 1;
                T_EX_in = 30;
                T_EX_out = 40;
                
                stats_EX_in = [t_EX,v_EX,T_EX_in,T_EX_out];                
                
                [m_EX_l_out, c_EX_l_out, m_EX_v_out, c_EX_v_out, stats_EX_out, H_ext_EX] = evaporation_model(m_EX_in,c_EX_in,stats_EX_in,Aspen);
                
                m = m_EX_l_out;
                c = c_EX_l_out;
                
                Tl_EX = stats_EX_out(1);
                Tv_EX = stats_EX_out(2);
                
                F_steam = 0.1; %kg/s
                Qf_steam = F_steam * h_lp;
                
                time_ex = -H_ext_EX / Qf_steam / 3600;
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_EX;
                KPI.CO2 = KPI.CO2 + H_ext_EX / h_lp * co2eq;
                
                Time = Time + time_ex;
                Stats(1) = Tl_EX;
                
            case 'CX1'
                m_CX_in = m;
                c_CX_in = c;
                
                Ti_CX1 = Stats(1);
                FAS_CX1 = 0;
                
                stats_CX = [t_CX1,Ti_CX1,TC_CX1,FC_CX1,FAS_CX1];
                
                [m_CX1_out, c_CX1_out, m_cryst1, stats_CX1_out, H_ext_CX1] = crystallization_xylitol(m_CX_in, c_CX_in, stats_CX);
                
                m = m_CX1_out;
                c = c_CX1_out;
                Tf_CX1 = stats_CX1_out(1);
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_CX1;
                KPI.MaxXyoProd = KPI.MaxXyoProd + m_cryst1;
                KPI.Max5HMF = c_CX1_out(10);
                KPI.MaxAac = c_CX1_out(9);
                Time = Time + t_CX1;
                Stats(1) = Tf_CX1;
                
                
                
            case 'CX2'
                m_CX_in = m;
                c_CX_in = c;
                
                Ti_CX2 = Stats(1);
                TC_CX2 = Stats(1);
                FC_CX2 = 0;
                
                stats_CX = [t_CX2,Ti_CX2,TC_CX2,FC_CX2,FAS_CX2];
                
                [m_CX2_out, c_CX2_out, m_cryst2, stats_CX2_out, H_ext_CX2] = crystallization_xylitol(m_CX_in, c_CX_in, stats_CX);
                
                m = m_CX2_out;
                c = c_CX2_out;
                
                KPI.NetEnthalpy = KPI.NetEnthalpy + H_ext_CX2;
                KPI.MaxXyoProd = KPI.MaxXyoProd + m_cryst2;
                KPI.Max5HMF = c_CX2_out(10);
                KPI.MaxAac = c_CX2_out(9);
                Time = Time + t_CX2;
                
                Tf_CX2 = stats_CX2_out(1);

            case 'blank'
                
        end    
    end
    
KPI.MaxXyoRate = KPI.MaxXyoProd / Time;
KPI.CO2Ratio = KPI.MaxXyoProd / KPI.CO2;

end