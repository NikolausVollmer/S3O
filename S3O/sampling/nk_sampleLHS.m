function X = nk_sampleLHS(N,lb,ub,dist)
    % Returns an LHS sampled input matrix X of size N between bounds lb and
    % ub
    if nargin<4, dist='uniform'; end
    
    if strcmpi(dist,'uniform')
        % can also work with InputSpace objects.
        if nargin==2 && strcmp(class(lb),'InputSpace')
            ub = lb.UpperBounds;
            lb = lb.LowerBounds;
        end

        d = numel(lb);
        Xp=lhsdesign(N,d); % sampling in unit probability space
        % convert probability space to real value space via inverse distribution
        lowerbounds = lb(:)'; L=repmat(lowerbounds,N,1);
        upperbounds = ub(:)'; U=repmat(upperbounds,N,1);
        X = unifinv(Xp,L,U); 
    end
end