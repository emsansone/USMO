clear all; close all; clc;

DATASETS = {'australian',0.56;'clean1',0.44;'diabetes',0.35;...
            'heart',0.44; 'heart-statlog',0.44; 'house',0.47;...
            'house-votes',0.61; 'ionosphere',0.64; 'isolet', 0.50;...
            'krvskp',0.48;'liverDisorders',0.58;'spectf',0.73};
NUM_DATASETS = size(DATASETS,1);
KERNEL = 'linear';
LAMBDA = [0.0001,0.001,0.01,0.1];
PERCENTAGE = 0.2; % Percentage of positive samples

addpath(genpath(pwd))

index = 1;
for i = 1:NUM_DATASETS
    for j = 1:length(LAMBDA)
        % LOAD DATASET
        load([DATASETS{i,1},'.mat']);
        id = (labels == 1);
        temp = 0;
        POS = size(X,1)*DATASETS{i,2};
        NUM_POS = POS*PERCENTAGE;
        for k = randperm(length(id))
            if labels(k) == 1
                temp = temp + 1;
                if temp > NUM_POS
                    id(k) = ~id(k);
                end
            end
        end
        save(['smalldata/',DATASETS{i,1},'_small_',KERNEL,'.mat'],'id');
        
        Xp = X(id,:);
        Xu = X(~id,:);
        Xu_labels = labels(~id);
        np = size(Xp,1);
        nu = size(Xu,1);

        c1 = DATASETS{i,2}/(2*LAMBDA(j)*np);
        c2 = 1/(2*LAMBDA(j)*nu);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                     USMO
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        switch KERNEL
            case 'linear'
                kernel_opt = kernel_set(KERNEL);
            otherwise
                error('Type - help kernel_set - to get more information');                
        end

        % Training
        option = option_set(kernel_opt, 'double');
        [alpha, b, iter, time_iter, delta] = usmo(Xp,Xu,c1,c2,DATASETS{i,2},option);

        index = index + 1;

        vars = {Xp Xu alpha b option};
        [~, pred_labels, ~] = usmo_test(X, vars);
        pred_lab = bsxfun(@plus,pred_labels,1)./2;
        result = performance(Xu_labels,pred_lab);
        fprintf('Dataset: %s\n', DATASETS{i,1});       
        fprintf('Lambda: %.4f\n', LAMBDA(j));
        fprintf('F-score: %.2f\n\n', result(6)*100);

    end
end
clear all; clc;