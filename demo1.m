% Info:
%       Demo showing the usage of PU training on a subset of samples
%       from the MNIST database (http://yann.lecun.com/exdb/mnist/)
%       
% Usage:
%       demo
%
% Copyright (C) 2015 by Emanuele Sansone (2015-11-24).

close all; clear all; clc;
addpath(genpath(pwd));
%------------------------------------------------------%
%                       Parameters                     %
%------------------------------------------------------%
% Objective function
lambda = 0.1;
POS_SAMPLES = 20;
SAMPLES = 1000;
POS_CLASS = 0; % Positive class
NEG_CLASS = 1; % Negative class

% Kernel
KERNEL = 'gaussian';
sigma = 2;
a = 1;
b = 0;
c = 3;

%------------------------------------------------------%
%                        Dataset                       %
%------------------------------------------------------%

X = loadMNISTImages('train-images-idx3-ubyte');
labels = loadMNISTLabels('train-labels-idx1-ubyte');
X = X(1:SAMPLES,:);
[~, X, ~] = pca(X);             % Applying PCA
X = X(:,1:2);                   % Taking only the first two features
X = X - repmat(mean(X),SAMPLES,1);
labels = labels(1:SAMPLES);

idp = find(labels == POS_CLASS);
idn = find(labels == NEG_CLASS);

POS_PRIOR = length(idp)/(length(idp) + length(idn)); % True positive class prior

idx = [idp; idn];
idp = idx(1:POS_SAMPLES);
idu = idx(POS_SAMPLES+1:end);
Xu_labels_temp = labels(idu);
Xu_labels = ones(size(idu));
Xu_labels(Xu_labels_temp ~= POS_CLASS) = 0;
Xu_labels(Xu_labels_temp == POS_CLASS) = 1;
Xp_labels = ones(POS_SAMPLES,1);
Xp = X(idp,:);
Xu = X(idu,:);
clear idp idn idu idx POS_SAMPLES SAMPLES;

%------------------------------------------------------%
%                     Configuration                    %
%------------------------------------------------------%
switch KERNEL
    case 'linear'
        kernel_opt = kernel_set(KERNEL);
    case 'polynomial'
        kernel_opt = kernel_set(KERNEL,a,b,c);
    case 'gaussian'
        kernel_opt = kernel_set(KERNEL,sigma);
    otherwise
        error('Type - help kernel_set - to get more information');
end
clear sigma a b c KERNEL


np = size(Xp,1);
nu = size(Xu,1);

c1 = POS_PRIOR/(2*lambda*np);
c2 = 1/(2*lambda*nu);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     USMO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Training
option = option_set(kernel_opt, 'double');

[alpha, b, iter, time_iter, delta] = usmo(Xp,Xu,c1,c2,POS_PRIOR,option);


vars = {Xp Xu alpha b option};
[~, pred_labels, ~] = usmo_test([Xp; Xu], vars);
pred_lab = bsxfun(@plus,pred_labels,1)./2;
result = performance(Xu_labels,pred_lab);
fprintf('F-score: %.2f\n\n', result*100);


%------------------------------------------------------%
%                      Plot results                    %
%------------------------------------------------------%
plot_decision(Xp, Xu, Xp_labels, Xu_labels, ...
              alpha, b, option);

