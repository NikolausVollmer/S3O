function varargout = struct2vars(S)
    % Create variables in the caller workspace named same as fieldnames of a given struct S.
    % By Resul
    fieldNames = fieldnames(S)';
    for f = 1:length(fieldNames)
        assignin('caller',fieldNames{f},S.(fieldNames{f}));
    end
end