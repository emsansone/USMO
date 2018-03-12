function kernel_opt = kernel_set(varargin)

% Info:
%       Set a struct with kernel information. Available kernels are:
%       - linear kernel,             k(x,y) = <x,y>              (b>=0)
%       - polynomial kernel,         k(x,y) = (a*<x,y> + b)^c    (b>=0)
%       - Gaussian kernel,           k(x,y) = exp(-<x-y,x-y> / (2*sigma^2))
%
% Usage:
%       kernel_set(name, ...)
%
% Examples:
%       kernel_set('linear')
%       kernel_set('gaussian', sigma)
%       kernel_set('polynomial', a, b, c)
%
% Input:
%       'name' is a string variable used to choose the desired kernel
%       - 'linear', for choosing the linear kernel
%       - 'gaussian', for choosing the Gaussian kernel
%       - 'polynomial', for choosing the polynomial kernel
%
%       'sigma' is the width of the Gaussian kernel
%
%       'b' is a nonnegative parameter
%
%       'a','c' are the parameters of the polynomial kernel (a > 0) 
%
% Output:
%       struct with information about the chosen kernel
%
% Copyright (C) 2015 by Emanuele Sansone (2015-11-24).

    switch nargin
        case 0
            error('Type - help kernel_set - to get more information');

        case 1
            switch varargin{1}
                case 'linear'
                    fprintf('Linear kernel is selected!\n');
                    kernel_opt = struct(                    ...
                                        'name',             ...
                                        varargin{1}         ...
                                        );                    
                otherwise
                    error('Type - help kernel_set - to get more information');
                   
            end

        case 2
            switch varargin{1}
                case 'gaussian'
                    fprintf('Gaussian kernel with kernel width %.2f is selected!\n',...
                            varargin{2});
                    kernel_opt = struct(                    ...
                                        'name',             ...
                                        varargin{1},        ...
                                        'params',           ...
                                        struct(                 ...
                                               'sigma',         ...
                                               varargin{2}      ...
                                              )             ...
                                       );                    
                otherwise
                    error('Type - help kernel_set - to get more information');
                   
            end
            
        case 3
            error('Type - help kernel_set - to get more information');

        case 4
            if strcmp(varargin{1},'polynomial') == 0
                error('Type - help kernel_set - to get more information');
            end
            fprintf('Polynomial kernel is selected!\n');
            kernel_opt = struct(                    ...
                                'name',             ...
                                varargin{1},        ...
                                'params',           ...
                                struct(                 ...
                                       'a',             ...
                                       varargin{2},     ...
                                       'b',             ...
                                       varargin{3},     ...
                                       'c',             ...
                                       varargin{4}      ...
                                      )             ...
                               );                        

        otherwise
            error('Type - help kernel_set - to get more information');

    end

