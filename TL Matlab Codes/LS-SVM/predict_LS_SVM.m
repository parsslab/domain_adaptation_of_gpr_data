function [predicted_label,margins] = predict_LS_SVM_v1_1(K,model)

% K_PREDICT_K Generic prediction function
% [predicted_label,margins] = k_predict_K(Kernel,model)

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


if nargin<3
    average=0;
end

nt = size(K,1); 
max_num_el=50*1024^2/8; %50 Mega of memory as maximum size for K
step=ceil(max_num_el/numel(model.a));
for i=1:step:nt
    if average==0
        margins(:,i:min(i+step-1,nt)) = (K*model.a+model.b)';
    else
        margins(:,i:min(i+step-1,nt)) = (K*model.a+model.b)';
    end
end

if size(model.a,2)>1
    [tmp,predicted_label]=max(margins);
else
    [predicted_label]=sign(margins);
end

