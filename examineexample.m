function [ischanged] = examineexample(i,c2,tol,option)
% EXAMINEEXAMPLE checks first which kind of example is considered and then chooses the second example based on the maximum violating pair principle to perform a step
%
% SYNOPSIS: [ischanged] = examineexample(i,c2,tol,option)
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

    global fcache i1max i2min i3min i3max m1max m2min m3min m3max Xu Xulog X alpha delta sigma;

    if delta(i) == 0
        if sigma(i) == 0
            CASE = 1;
        else
            CASE = 5;
        end
    else
        if delta(i) < c2
            if sigma(i) < c2/2
                CASE = 2;
            else
                CASE = 4;
            end
        else
            CASE = 3;
        end
    end
    
    % Updating function cache and thresholds
    if CASE == 2 || CASE == 4
        F2 = fcache(i);
    else
        fcache(i) = func(Xu(i,:),Xulog(i,:),X,alpha,option);
        F2 = fcache(i);
    end
    switch CASE
        case 1
            if F2 > m1max
                m1max = F2; i1max = i;
            end
        case 2
            if F2 > m1max
                m1max = F2; i1max = i;
            end
            if F2 > m3max
                m3max = F2; i3max = i;
            end
            if F2 < m3min
                m3min = F2; i3min = i;
            end
        case 3
            if F2 > m3max
                m3max = F2; i3max = i;
            end
            if F2 < m3min
                m3min = F2; i3min = i;
            end
        case 4
            if F2 < m2min
                m2min = F2; i2min = i;
            end
            if F2 > m3max
                m3max = F2; i3max = i;
            end
            if F2 < m3min
                m3min = F2; i3min = i;
            end
        case 5
            if F2 < m2min
                m2min = F2; i2min = i;
            end
    end
    
    % Choosing the second example
    optimality = 1;
    switch CASE
        case 1
            dist = [F2-m3min,F2-m2min+2];
            [dist, index] = max(dist);
            if dist > 2*tol
                optimality = 0;
                switch index
                    case 1
                        i1 = i3min;
                    case 2
                        i1 = i2min;
                end
            end
        case 2
            dist = [F2-m3min,F2-m2min+2,m1max-F2];
            [dist, index] = max(dist);
            if dist > 2*tol
                optimality = 0;
                switch index
                    case 1
                        i1 = i3min;
                    case 2
                        i1 = i2min;
                    case 3
                        i1 = i1max;
                end
            end
        case 3
            dist = [m1max-F2,F2-m2min];
            [dist, index] = max(dist);
            if dist > 2*tol
                optimality = 0;
                switch index
                    case 1
                        i1 = i1max;
                    case 2
                        i1 = i2min;
                end
            end
        case 4
            dist = [F2-m2min,m3max-F2,m1max-F2+2];
            [dist, index] = max(dist);
            if dist > 2*tol
                optimality = 0;
                switch index
                    case 1
                        i1 = i2min;
                    case 2
                        i1 = i3max;
                    case 3
                        i1 = i1max;
                end
            end
        case 5
            dist = [m3max-F2,m1max-F2+2];
            [dist, index] = max(dist);
            if dist > 2*tol
                optimality = 0;
                switch index
                    case 1
                        i1 = i3max;
                    case 2
                        i1 = i1max;
                end
            end
    end

    if optimality
        ischanged = 0;
        return;
    end
    ischanged = takestep(i1,i,F2,c2,option);