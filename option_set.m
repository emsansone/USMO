function option = option_set(kernel_opt, loss_name, varargin)

% Info:
%       Set a struct with options for PU classification, namely information
%       about the kernel and the loss function. Available loss functions 
%       are:
%       - double hinge loss,             l(z) = max(-z, max(0, 0.5-0.5*z))
%       - generalized ramp loss,         l(z) = max(0, min(1, 0.5-rtheta*z))
%
% Usage:
%       option_set(kernel_opt, loss_name, ...)
%
% Examples:
%       option_set(kernel_opt, 'double')
%       option_set(kernel_opt, 'gramp', rtheta)
%
% Input:
%       'kernel_opt' is a struct variable containing info about the kernel
%       function. Use kernel_set.m to get it!
%
%       'loss_name' is a string variable used to choose the loss function
%       - 'double', for choosing the double hinge loss
%       - 'gramp', for choosing the generalized ramp loss
%
%       'theta' is the smoothness parameter of the emamoid loss function 
%       (theta > 0)
%
%       'eta' is the level parameter of the emamoid loss function 
%       (eta > 0)
%
%       'rtheta' is the steepness of the generalized ramp loss function 
%       (rtheta > 0)
%
% Output:
%       struct with information of PU classification
%
% Copyright (C) 2015 by Emanuele Sansone (2015-11-24).

    switch nargin
        case 0
            error('Type - help option_set - to get more information');

        case 1
            error('Type - help option_set - to get more information');

        case 2
            switch loss_name
                case 'double'
                    fprintf('Double Hinge loss is selected!\n');
                    loss_opt = struct(              ...
                                      'name',       ...
                                      loss_name     ...
                                     );
                    option = struct(                ...
                                    'kernel_opt',   ...
                                    kernel_opt,     ...
                                    'loss_opt',     ...
                                    loss_opt        ...
                                   );
                otherwise
                    error('Type - help option_set - to get more information');                
            end

        case 3
            switch loss_name
                case 'gramp'
                    fprintf('Generalized Ramp loss is selected!\n');
                    params = struct(                ...
                                    'rtheta',       ...
                                    varargin{1}     ...
                                   );
                    loss_opt = struct(              ...
                                      'name',       ...
                                      loss_name,    ...
                                      'params',     ...
                                      params        ...
                                     );
                    option = struct(                ...
                                    'kernel_opt',   ...
                                    kernel_opt,     ...
                                    'loss_opt',     ...
                                    loss_opt        ...
                                   );                
                otherwise
                    error('Type - help option_set - to get more information');
            end


        otherwise
            error('Type - help option_set - to get more information');

    end

