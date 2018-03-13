function plot_decision(Xp, Xu, Xp_labels, Xu_labels, alpha, b, option)

% Info:
%       Plot data and decision boundary according to the selected kernel
%       and each loss function. Available kernels are:
%       - linear kernel,             k(x,y) = <x,y> + b          (b>=0)
%       - polynomial kernel,         k(x,y) = (a*<x,y> + b)^c    (b>=0)
%       - Gaussian kernel,           k(x,y) = exp(-<x-y,x-y> / (2*sigma^2))
%       Available loss functions are:
%       - double hinge loss,           l(z) = max(-z, max(0, 0.5-0.5*z))
%       - ramp loss,                   l(z) = 0.5*max(0, min(2, 1-z))

%
% Usage:
%       plot_decision(X, labels, alpha, option)
%
% Input:
%
%       'Xp' is a (p+u)-by-2 matrix containing positive samples on its
%       rows.
%
%       'Xu' is a (p+u)-by-2 matrix containing unlabeled samples on its
%       rows.
%
%       'Xp_labels' is a p-by-1 vector containing the labels associated to
%       'Xp'. The allowed labels are +1 or 0.
%
%       'Xu_labels' is a u-by-1 vector containing the labels associated to
%       'Xu'. The allowed labels are +1 or 0.
%
%       'alpha' is the result of PU training. Use pu_train.m to compute it!
%
%       'option' is a struct variable containing info about PU
%       classification. Use option_set.m to get it!
%
%       'b' kernel bias.
%
% Copyright (C) 2015 by Emanuele Sansone (2015-11-24).

    X = [Xp; Xu];
    labels = [Xp_labels; Xu_labels];

    if size(X,2) ~= 2
        fprintf('Not possible to visualize the data!\n');
        return
    end
        
    idp = find(Xu_labels == 1);
    idn = find(Xu_labels == 0);
    
    figure;
    hold on;
    plot(Xp(:,1),Xp(:,2),'r^','MarkerSize',8);
    plot(Xu(idp,1),Xu(idp,2),'r*');
    plot(Xu(idn,1),Xu(idn,2),'k*');
           
    title('USMO')

    up = max(X);
    lb = min(X);
    step_size = 80;
    
    v = linspace(lb(1),up(1),step_size);
    w = linspace(lb(2),up(2),step_size);
    z = zeros(length(v), length(w));
    switch option.kernel_opt.name
        case 'linear'
            for i = 1:length(v)
               for j = 1:length(w)
                   z(i,j) = alpha'*linear(X, [v(i),w(j)], b);
               end
            end
        case 'polynomial'
            a = option.kernel_opt.params.a;
            b = option.kernel_opt.params.b;
            c = option.kernel_opt.params.c;
            for i = 1:length(v)
               for j = 1:length(w)
                   z(i,j) = alpha'*polynomial(X, [v(i),w(j)], a, b, c);
               end
            end
        case 'gaussian'
            sigma = option.kernel_opt.params.sigma;
            for i = 1:length(v)
               for j = 1:length(w)
                   z(i,j) = alpha'*gaussian(X, [v(i),w(j)], sigma);
               end
            end
        otherwise
            error('Type - help plot_decision - to get more information');
    end
    z = z'; % important to transpose z before calling contour
    contour(v, w, z, 'ShowText','on');
end

function K = linear(X, y, b)
    n = size(X, 1);
    K = X*y' + b*ones(n,1);
end

function K = polynomial(X, y, a, b, c)
    n = size(X, 1);
    K = (a*(X*y') + b*ones(n,1)).^c;
end

function K = gaussian(X, y, sigma)
    n = size(X,1);
    Y = repmat(y,n,1);
    K = exp(-diag((X - Y)*(X - Y)')/(2*sigma^2));
end

