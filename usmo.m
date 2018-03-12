function [a, b, iter, time_iter, d] = usmo(P,U,c1,c2,prior,option)
% USMO is used to solve the quadratic programming problem associated with 
% positive unlabeled learning where the loss function is the double Hinge
% loss. The algorithm does not require to store the Gram matrix and it is
% very efficient.
%
% SYNOPSIS: [a, b, iter, time_iter, delta] = usmo(P,U,c1,c2,prior,option)
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

    addpath(genpath(pwd))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           VARIABLE INITIALIZATION                %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global alpha delta sigma fcache i1max i2min i3min i3max ...
           m1max m2min m3min m3max Xp Xu X Xplog Xulog Xlog;
    Xp = P; clear P;
    Xu = U; clear U;
    Xplog = (Xp ~= 0);
    Xulog = (Xu ~= 0);
    X = [Xp;Xu];
    Xlog = [Xplog;Xulog];
    p = size(Xp,1);
    u = size(Xu,1);
    alpha = zeros(p+u,1);
    alpha(1:p) = c1;
    b = 0;
    delta = zeros(u,1);
    sigma = zeros(u,1);
    
    tol = 1e-3;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           INITIALIZATION OF ALPHA                %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ONE-CLASS SVM
    switch option.kernel_opt.name
        case 'linear'
            nu_svm_string = ' -q -s 2 -t 0';
        case 'polynomial'
            a = option.kernel_opt.params.a;
            bk = option.kernel_opt.params.b;
            c = option.kernel_opt.params.c;                    
            nu_svm_string = [' -q -s 2 -t 1 -g ',num2str(a),' -r ',num2str(bk),' -d ',num2str(c)];
        case 'gaussian'
            sig = option.kernel_opt.params.sigma;
            nu_svm_string = [' -q -s 2 -t 2 -g ',num2str(1/(2*sig^2))];
    end
    model = svmtrain(ones(p,1), Xp , nu_svm_string);
    [~,~,output_labels] = svmpredict(zeros(u,1), Xu, model); 
    [~, indices] = sort(output_labels,'descend');

    u1 = u-3;
    fun = @(x) (c1*p-x(4)*u1*x(1)-x(5)*u1*x(2)-u1*c2*((1-x(3)-x(4)-x(5))/2+prior*x(3)))^2;
    temp = max([1/((1-prior)*u1),1/(prior*u1)]);
    if temp > 1
        temp = min([1/((1-prior)*u1),1/(prior*u1)]);        
    end
    lb = [eps; c2/2+eps; temp; 1/u1; 1/u1];
    temp = min([1/((1-prior)),1/(prior)]);
    ub = [c2/2-eps;c2-eps;temp;log(u1)/u1;log(u1)/u1];
    A = [0,0,1,1,1];
    b = 1-1/u1;
    x0 = [c2/4;3*c2/4;0.25;0.25;0.25];
    opt = optimoptions('fmincon','Display','off');
    x = fmincon(fun,x0,A,b,[],[],lb,ub,[],opt);    
    
    n2 = floor(x(4)*u1);
    n3 = floor((1-x(3)-x(4)-x(5))*u1);
    n4 = floor(x(5)*u1);
    n5 = floor(prior*x(3)*u1);
    sigma2 = x(1);
    sigma4 = x(2);
    
    % RANKING
    indices5 = indices(1:n5);
    indices4 = indices(n5+1:n5+n4);
    indices3 = indices(n5+n4+1:n5+n4+n3);
    indices2 = indices(n5+n4+n3+1:n5+n4+n3+n2);
    indices2_tmp = indices(n5+n4+n3+n2+1:n5+n4+n3+n2+3);

    %ASSIGNMENT
    sigma(indices2) = sigma2;
    delta(indices2) = 2*sigma2;
    sigma(indices3) = c2/2;
    delta(indices3) = c2;
    
    sigma(indices4) = sigma4;
    delta(indices4) = 2*c2-2*sigma4;
    sigma(indices5) = c2;
    alpha(p+1:end) = -sigma;
    
    sum_alpha = sum(alpha);
    if abs(sum_alpha) > tol
        if sum_alpha > 0 && sum_alpha < 3*c2
            sigma_temp = sum(alpha)/3;
            sigma(indices2_tmp) = sigma_temp;
            if sigma_temp > c2/2
                delta(indices2_tmp) = 2*c2 - 2*sigma_temp; 
            else
                delta(indices2_tmp) = 2*sigma_temp;            
            end
            alpha(p+1:end) = -sigma;
        end
        if sum_alpha < 0 && sum_alpha > -3*c2
            fun = @(x) (p*c1-sigma2*x(1)*n2-c2/2*x(1)*n3-sigma4*x(1)*n4-c2*x(1)*n5)^2;
            x = fmincon(fun,0.5,[],[],[],[],0,1,[],opt);
            sigma = x*sigma;
            alpha(p+1:end) = -sigma;
            temp = (sigma < c2/2);
            delta(temp) = 2*sigma(temp);
            delta(~temp) = bsxfun(@minus,2*c2,2*sigma(~temp));
        end
        if sum_alpha < 3*c2 + tol && sum_alpha > 3*c2 - tol
            sigma(indices2_tmp) = c2;
            delta(indices2_tmp) = 0; 
            alpha(p+1:end) = -sigma;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %             UPDATE FUNCTION CACHE                %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:u
        if delta(i) > 0 && delta(i) < c2
            fcache(i) = func(Xu(i,:),Xulog(i,:),X,alpha,option);   
        end
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %               COMPUTE THRESHOLDS                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    compute_thresholds(0,0,c2);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                   MAIN ROUTINE                   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numchanged = 0;
    examineall = 1;
    iter = 0;
    time_iter = [];
    while(numchanged > 0 || examineall)
        numchanged = 0;
        tmp = tic;
        if examineall
            for i = 1:u
                numchanged = numchanged + examineexample(i,c2,tol,option);
            end
        else
            inner_loop_success = 1;
            while((m1max-m3min > 2*tol || m3max-m2min > 2*tol ...
                  || m1max-m2min+2 > 2*tol) && inner_loop_success ~= 0)
                dist = [m1max-m3min,m3max-m2min,m1max-m2min+2];
                [~,index] = max(dist);
                switch index
                    case 1
                        inner_loop_success = takestep(i1max,i3min,m3min,c2,option);
                    case 2
                        inner_loop_success = takestep(i3max,i2min,m2min,c2,option);           
                    case 3
                        inner_loop_success = takestep(i1max,i2min,m2min,c2,option);
                end
            end
        end
        
        if examineall
            examineall = 0;
        else
            examineall = 1;
        end
        iter = iter + 1;
        time_iter = [time_iter, toc(tmp)];
    end
        
    a = alpha;
    b = 0;
    index = 0;
    tol = 1e-8;
    for i = 1:u
        if delta(i) > tol && delta(i) < c2-tol
            if sigma(i) < c2/2
                b = b - 1 - fcache(i); 
            else
                b = b + 1 - fcache(i);
            end
            index = index+1;
        end
    end
    b = b/index;
    if index == 0
        b = 0;
    end
    d = delta;