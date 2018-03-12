function [value] = func(x,xlog,X,alpha,option)
% FUNC computes the value of the function for a specific vector point
%
% SYNOPSIS: [value] = func(x,xlog,X,alpha,option)
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

    x = x(:);
    kernel = option.kernel_opt.name;
    switch kernel
        case 'linear'
            value = alpha'*(X(:,xlog)*x(xlog));
            
        case 'polynomial'
            a = option.kernel_opt.params.a;
            bk = option.kernel_opt.params.b;
            c = option.kernel_opt.params.c;

            value = alpha'*(bsxfun(@plus,a*(X(:,xlog)*x(xlog)),bk).^c);
            
        case 'gaussian'
            sigma = option.kernel_opt.params.sigma;
            
            dist = bsxfun(@plus,sum(bsxfun(@times,X,X),2),x'*x) - 2*(X(:,xlog)*x(xlog));
            value = (alpha'*exp(-dist/(2*sigma^2)));
            
        otherwise
            error('This kernel is not allowed!');
    end
end

