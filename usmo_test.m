function [values, labels, t] = usmo_test(Xtest, vars)
% USMO_TEST predicts the labels for the desired data
%
% SYNOPSIS: [values, labels, t] = usmo_test(Xtest, vars)
%
% INPUT 
%
% OUTPUT 
%
% REMARKS
%
% created with MATLAB ver.: 8.4.0.150421 (R2014b)
% on Mac OS X  Version: 10.10.5 Build: 14F1021 
%
% created by: Emanuele Sansone
% DATE: 23-Apr-2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [Xp,Xu,alpha,b,option] = vars{:};

    X = [Xp;Xu];
    
    n = size(Xtest,1);
    values = zeros(n,1);

    Start = tic;
    for i = 1:n
        xlog = (Xtest(i,:) ~= 0);
        values(i) = func(Xtest(i,:),xlog,X,alpha,option) + b;
    end
    idv = find(values == 0);
    values(idv) = eps;
    labels = sign(values);
    t = toc(Start);
