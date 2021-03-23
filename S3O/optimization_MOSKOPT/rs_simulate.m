function [f_observations, g_observations] = rs_simulate(X,p,Aspen)
    % simulates the black-box m times and returns the values of objective and constraints in row vectors.
    f  = @mysimulator;
    k  = size(X,1); % # of design points
    d  = size(X,2); % dim
    m  = p.m;
%     cv = p.cv; % coefficient of variation
    
    if isfield(p,'seed'), rng(p.seed,'Twister'); end
   
    % Aspen
    Aspen = StartAspen();
    %% Create uncertainty samples
    xu_init = [31.3, 42.7, 18.4]; % initial composition feedstock

    % LHS Uniform Sampling
    perc = [0.05, 0.05]; % 5% variation
    lperc = length(perc);
        
    perclo = ones(1,lperc) - perc;
    perchi = ones(1,lperc) + perc;
    
    parlo = xu_init(1:lperc) .* perclo;
    parhi = xu_init(1:lperc) .* perchi;
    
    X_p = lhsdesign(m,lperc);
    
    X_p_lo = ones(m,1)*parlo;
    X_p_hi = ones(m,1)*parhi;
    Xu = unifinv(X_p, X_p_lo, X_p_hi); % uniform distribution
    Xsum = sum(xu_init) - Xu(:,1) - Xu(:,2);
    Xu = horzcat(Xu,Xsum);
    
    %% Run simulations
    count = 0;
    for j = 1:k
        x = X(j,:);
        
        if p.cID == 1 % variables depending on cID
            xfull = [0.1, 0.025, 15, 186, 0.5, 3, 6, 6, 36, 18, 0.995, 0.5];
        elseif p.cID == 2
            xfull = [0.025, 15, 186, 0.5, 3, 6, 36, 18, 0.995, 0.5];
        elseif p.cID == 5
            xfull = [0.1, 0.025, 15, 186, 0.5, 3, 6, 6, 36, 18, 0.995];
        elseif p.cID == 6
            xfull = [0.1, 15, 186, 0.5, 3, 6, 36, 18, 0.995];
        end
        
        xfull(p.red) = x;
        x = xfull;
        
        
        for i=1:p.m
            count = count + 1
            xu = Xu(i,:);
            output = mysimulator(x,xu,p,Aspen);
            f_observations(j,i) = output(1);
            g1_observations(j,i) = output(2);
            g2_observations(j,i) = output(3);
            g3_observations(j,i) = output(4);
        end
        
        
    end
    
    % scale objective
    f_observations = f_observations / 50;
    
    g_observations={g1_observations, g2_observations, g3_observations};
    
    % end aspen
    Aspen.Close
    Aspen.Quit
    
end