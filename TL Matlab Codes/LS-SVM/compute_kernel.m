function K = compute_kernel(in1,in2,in3,in4)

%COMPUTE_KERNEL    Calculates the kernel matrix
%   K = COMPUTE_KERNEL(X,IND1,IND2,KERNEL_PARAMS)
%   K = COMPUTE_KERNEL(X1,X2,KERNEL_PARAMS)

% This code is part of the supplementary material to the CVPR 2010 paper
% "Safety in Numbers: Learning Categories from Few Examples with Multi 
% Model Knowledge Trasfer", T. Tommasi, F. Orabona, B. Caputo.

% Copyright (C) 2009-2010, Tatiana Tommasi
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Contact the author: ttommasi [at] idiap.ch


if nargin==4
  X=in1;
  ind1=in2;
  ind2=in3;
  hp=in4;
  X1=X(:,ind1);
  X2=X(:,ind2);
else
  X1=in1;
  X2=in2;
  hp=in3;
end

if size(X1,2)==0
    K = [];
    return;
end

switch hp.type
   case 'linear'
    K = X1'*X2;
    
   case 'poly'
    K = (hp.gamma*X1'*X2+hp.coef0).^hp.degree;
      
   case 'rbf'
    normX = sum(X1.^2,1);
    normY = sum(X2.^2,1);
    K = exp(-hp.gamma*(repmat(normX' ,1,size(X2,2)) + ...
                           repmat(normY,size(X1,2),1) - ...
                           2*X1'*X2));

   case 'rbf_bias'
    normX = sum(X1.^2,1);
    normY = sum(X2.^2,1);
    K = exp(-hp.gamma*(repmat(normX' ,1,size(X2,2)) + ...
                           repmat(normY,size(X1,2),1) - ...
                           2*X1'*X2))+hp.coef0;
                       
   case 'forest'
    for i=1:size(X1,2)
       normX(i) = forest_lin(X1(:,i),X1(:,i));
    end
    for i=1:size(X2,2)
       normY(i) = forest_lin(X2(:,i),X2(:,i));
    end
    K = exp(-(repmat(normX' ,1,size(X2,2)) + ...
                           repmat(normY,size(X1,2),1) - ...
                           2*forest_lin(X1,X2)));
    
   case 'triangular'
    normX = sum(X1.^2,1);
    normY = sum(X2.^2,1);
    K = 1-sqrt(repmat(normX',1,size(X2,2)) + repmat(normY,size(X1,2),1) - 2*X1'*X2)/hp.gamma;

   case 'sigmoid'
    K = tanh(hp.gamma*X1'*X2+hp.coef0);
    
   case 'expchi2'
    K=zeros(size(X1,2),size(X2,2));
    for i=1:size(X1,2)
        h1=X1(:,i);
        for j=1:size(X2,2)
           h2=X2(:,j);
           %tmp=sum(((h1-h2).^2)./(h1+h2+eps));
           tmp=chisquare_sparse(h1,h2);
           K(i,j) = exp(-hp.gamma*tmp );
       end
    end
 
   case 'intersection'
    K=zeros(size(X1,2),size(X2,2));
    for i=1:size(X1,2)
        h1=X1(:,i);
        for j=1:size(X2,2)
           h2=X2(:,j);
           %K(i,j) = sum(min(h1,h2));
           K(i,j) = hist_intersection_sparse(h1,h2);
        end
    end

   case 'same'
    K=zeros(size(X1,2),size(X2,2));
    for i=1:size(X1,2)
        for j=1:size(X2,2)
           K(i,j) = (X1(:,i)==X2(:,j));
       end
    end
    %K=(1+1/(hp.n_class-1))*K-1/(hp.n_class-1);
    
   otherwise
    error('Unknown kernel');
end

function out=forest_lin(a,b)
for j=1:size(a,2)
    for i=1:size(b,2)
        out(j,i)=a(1:10,j)'*b(1:10,i);
        if a(11,j)==b(11,i)
            out(j,i)=out(j,i)+2;
        end
        if a(12,j)==b(12,i)
            out(j,i)=out(j,i)+2;
        end
    end
end