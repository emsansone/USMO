function [ischanged] = takestep(i1,i2,F2,c2,option)
% TAKESTEP performs a step based on the selected pair of samples
%
% SYNOPSIS: [ischanged] = takestep(i1,i2,F2,c2,option)
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

    global alpha delta sigma fcache Xp Xu Xulog;
    epsilon = 1e-3;
    p = size(Xp,1);
    u = size(Xu,1);
    
    if i1 == i2
       ischanged = 0;
       return;
    end
    alph1 = alpha(p+i1);
    alph2 = alpha(p+i2);
    delt1 = delta(i1);
    delt2 = delta(i2);
    sig1 = sigma(i1);
    sig2 = sigma(i2);
    F1 = fcache(i1);

    % Computation of constant a^k
    const = sig1 + sig2;
    if const <= eps
        ischanged = 0;
        return
    end    
            
    % Compute kernel values and update function cache for i1 and i2
    switch option.kernel_opt.name
        case 'linear'
            k11 = Xu(i1,Xulog(i1,:))*Xu(i1,Xulog(i1,:))';
            k12 = Xu(i1,Xulog(i1,:))*Xu(i2,Xulog(i1,:))';
            k22 = Xu(i2,Xulog(i2,:))*Xu(i2,Xulog(i2,:))';
        case 'polynomial'
            a = option.kernel_opt.params.a;
            bk = option.kernel_opt.params.b;
            c = option.kernel_opt.params.c;
            k11 = (a*Xu(i1,Xulog(i1,:))*Xu(i1,Xulog(i1,:))'+bk)^c;
            k12 = (a*Xu(i1,Xulog(i1,:))*Xu(i2,Xulog(i1,:))'+bk)^c;
            k22 = (a*Xu(i2,Xulog(i2,:))*Xu(i2,Xulog(i2,:))'+bk)^c;
        case 'gaussian'
            si = option.kernel_opt.params.sigma;
            k11 = 1;
            k12 = exp(-(Xu(i1,Xulog(i1,:))*Xu(i1,Xulog(i1,:))' + ...
                        Xu(i2,Xulog(i2,:))*Xu(i2,Xulog(i2,:))' - ...
                        2*Xu(i1,Xulog(i1,:))*Xu(i2,Xulog(i1,:))')/(2*si^2));
            k22 = 1;
        otherwise
            error('Kernel not allowed!');
    end

    eta = -2*k12+k11+k22;

    % Computation of local objective function
    obj = local_func(sig1, sig2, delt1, delt2, ...
                     sig1, sig2, F1, F2, k11, k22, k12);
    
    % Computation of delta2_new for all cases
    sigma2 = zeros(1,4);
    sigma1 = zeros(1,4);
    delta1 = zeros(1,4);
    delta2 = zeros(1,4);
    obj_new = zeros(1,4);
    isvalid = ones(1,4);
    temp = const*(k11-k12)-F1+F2-sig1*k11+sig2*k22-(sig2-sig1)*k12;
    for i = 1:4
        switch i
            case 1
                sigma2(i) = temp/eta;
                lb = max(c2/2,const-c2);
                ub = min(c2,const-c2/2);
                if sigma2(i) > ub-eps || sigma2(i) < lb+eps
                    if sigma2(i) > ub-eps
                        sigma2(i) = ub;
                    end
                    if sigma2(i) < lb+eps
                        sigma2(i) = lb;
                    end
                end
                sigma1(i) = const-sigma2(i);
                delta2(i) = 2*c2 - 2*sigma2(i);
                delta1(i) = 2*c2 - 2*sigma1(i);
                if lb > ub
                    isvalid(i) = 0;
                end
            case 2
                sigma2(i) = (temp+2)/eta;
                lb = max(0,const-c2);
                ub = min(c2/2,const-c2/2);
                if sigma2(i) > ub-eps || sigma2(i) < lb+eps
                    if sigma2(i) > ub-eps
                        sigma2(i) = ub;
                    end
                    if sigma2(i) < lb+eps
                        sigma2(i) = lb;
                    end
                end
                sigma1(i) = const-sigma2(i);
                delta2(i) = 2*sigma2(i);
                delta1(i) = 2*c2 - 2*sigma1(i);
                if lb > ub
                    isvalid(i) = 0;
                end
            case 3
                sigma2(i) = (temp-2)/eta;
                lb = max(c2/2,const-c2/2);
                ub = min(c2,const);
                if sigma2(i) > ub-eps || sigma2(i) < lb+eps
                    if sigma2(i) > ub-eps
                        sigma2(i) = ub;
                    end
                    if sigma2(i) < lb+eps
                        sigma2(i) = lb;
                    end
                end
                sigma1(i) = const-sigma2(i);
                delta2(i) = 2*c2 - 2*sigma2(i);
                delta1(i) = 2*sigma1(i);
                if lb > ub
                    isvalid(i) = 0;
                end
            case 4
                sigma2(i) = temp/eta;
                lb = max(0,const-c2/2);
                ub = min(c2/2,const);
                if sigma2(i) > ub-eps || sigma2(i) < lb+eps
                    if sigma2(i) > ub-eps
                        sigma2(i) = ub;
                    end
                    if sigma2(i) < lb+eps
                        sigma2(i) = lb;
                    end
                end
                sigma1(i) = const-sigma2(i);
                delta2(i) = 2*sigma2(i);
                delta1(i) = 2*sigma1(i);
                if lb > ub
                    isvalid(i) = 0;
                end
        end
        % Computing local objective function
        obj_new(i) = local_func(sig1, sig2, delta1(i), delta2(i), ...
                                sigma1(i), sigma2(i), F1, F2, k11, k22, k12);

    end
     
    % Check box constraints
    temp = find(isvalid == 1);
    best_case = 0;
    obj_temp = obj;
    if isempty(temp)
        %fprintf('\nNo case is valid! Keeping previous solution!\n');
        ischanged = 0;
        return
    else
        len = length(temp);
        for i = 1:len
            if obj_new(temp(i)) < obj_temp
                best_case = temp(i);
                obj_temp = obj_new(temp(i));                
            end
        end
    end
        
    % Choosing the best case
    if best_case == 0
        ischanged = 0;
        return
    else
        delta1 = delta1(best_case);    
        delta2 = delta2(best_case);
        sigma1 = sigma1(best_case);
        sigma2 = sigma2(best_case);
    end
    
    alpha1 = -sigma1;
    alpha2 = -sigma2;
    if (2*abs(alpha2-alph2) < epsilon*(abs(alpha2-alph2)+eps))
       ischanged = 0;
       return;                
    end
        
    % Store values
    sigma(i1) = sigma1;
    sigma(i2) = sigma2;
    delta(i1) = delta1;
    delta(i2) = delta2;
    alpha(i1+p) = alpha1;
    alpha(i2+p) = alpha2;
    
    % Update function cache
    for i = 1:u
        if delta(i) > 0 && delta(i) < c2
            switch option.kernel_opt.name
                case 'linear'
                    k1 = Xu(i1,Xulog(i,:))*Xu(i,Xulog(i,:))';
                    k2 = Xu(i2,Xulog(i,:))*Xu(i,Xulog(i,:))';
                case 'polynomial'
                    a = option.kernel_opt.params.a;
                    bk = option.kernel_opt.params.b;
                    c = option.kernel_opt.params.c;
                    k1 = (a*(Xu(i1,Xulog(i,:))*Xu(i,Xulog(i,:))')+bk)^c;
                    k2 = (a*(Xu(i2,Xulog(i,:))*Xu(i,Xulog(i,:))')+bk)^c;
                case 'gaussian'
                    si = option.kernel_opt.params.sigma;
                    k1 = exp(-((Xu(i1,Xulog(i1,:))*Xu(i1,Xulog(i1,:))')+...
                                (Xu(i,Xulog(i,:))*Xu(i,Xulog(i,:))')-...
                                2*(Xu(i1,Xulog(i,:))*Xu(i,Xulog(i,:))'))/(2*si^2));
                    k2 = exp(-((Xu(i2,Xulog(i2,:))*Xu(i2,Xulog(i2,:))')+...
                                (Xu(i,Xulog(i,:))*Xu(i,Xulog(i,:))')-...
                                2*(Xu(i2,Xulog(i,:))*Xu(i,Xulog(i,:))'))/(2*si^2));
                otherwise
                    error('Kernel not allowed!');
            end             
            fcache(i) = fcache(i) +                                 ...
                        (alpha1-alph1)*k1 +         ...
                        (alpha2-alph2)*k2;
        end
    end

    % Update function cache for i1 and i2
    if delta(i1) == 0 || delta(i1) == c2
        fcache(i1) = fcache(i1) + (alpha1-alph1)*k11 + (alpha2-alph2)*k12;
    end
    if delta(i2) == 0 || delta(i2) == c2
        fcache(i2) = fcache(i2) + (alpha1-alph1)*k12 + (alpha2-alph2)*k22;
    end
        
    % Compute thresholds with I0 and {i1,i2}
    compute_thresholds(i1,i2,c2);
    
    
    ischanged = 1;

    
    