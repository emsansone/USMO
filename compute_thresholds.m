function compute_thresholds(i1,i2,c2)
% COMPUTE THRESHOLDS computes the upper and the lower thresholds
%
% SYNOPSIS: compute_thresholds(i1,i2,c2)
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

    global fcache i1max i2min i3min i3max m1max m2min m3min m3max delta sigma;
    u = length(delta);
    
    m1max = -realmax;
    m2min = realmax;
    m3min = realmax;
    m3max = -realmax;
    
    for i = 1:u
        if ((delta(i) > 0 && delta(i) < c2) || i == i1 || i == i2)
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

            temp = fcache(i);
            switch CASE
                case 1
                    if temp > m1max
                        m1max = temp; i1max = i;
                    end
                case 2
                    if temp > m1max
                        m1max = temp; i1max = i;
                    end
                    if temp > m3max
                        m3max = temp; i3max = i;
                    end
                    if temp < m3min
                        m3min = temp; i3min = i;
                    end
                case 3
                    if temp > m3max
                        m3max = temp; i3max = i;
                    end
                    if temp < m3min
                        m3min = temp; i3min = i;
                    end
                case 4
                    if temp < m2min
                        m2min = temp; i2min = i;
                    end
                    if temp > m3max
                        m3max = temp; i3max = i;
                    end
                    if temp < m3min
                        m3min = temp; i3min = i;
                    end
                case 5
                    if temp < m2min
                        m2min = temp; i2min = i;
                    end
            end
        end
    end  