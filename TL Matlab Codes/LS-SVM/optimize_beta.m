function [model, beta, loss] = adapt_beta_v1_3(model,y_head)


n = size(model.K,1);

srcCount = size(y_head,2);

index_p = find(model.Y == 1);
count_p = numel(index_p);

index_n = find(model.Y == -1);
count_n=numel(index_n);

zita=zeros(1,n);
zita(index_p) = n/(2*count_p);
zita(index_n) = n/(2*count_n);


if numel(model.C)==1
    adj = (1/model.C)*(diag(1./zita)); 
else
    adj = diag(1./model.C);
end

M = [model.K+adj, ones(n,1); ...
     ones(1,n),          0];

P = pinv(M);

coeffs = P * [model.Y';0];

a_prime = coeffs(1:end-1);
b_prime = coeffs(end);

Pii = diag(P);

for j=1:srcCount
    
    %if numel(y_head{j})==0, continue; end
    coeffs = P*[y_head(:,j);0];
    aj_dub_prime{j} = coeffs(1:end-1);
    bj_dub_prime{j} = coeffs(end); 

end

A_mat = [];

for j= 1:srcCount
    
    A_mat = [A_mat; aj_dub_prime{j}'];
    
end

beta = zeros(srcCount,1);

for iter=1:(100)
    
    y_tilda = model.Y-(a_prime' - beta'*A_mat)./Pii(1:end-1)';
    loss(:,iter) = zita.* (ones(1,n) - model.Y.*y_tilda);
    % loss = zita'.*(model.Y'.*(a_prime - A_mat*beta')./Pii(1:end-1));
    
    % grad = - (((loss>0)'.*zita.*model.Y)*A_mat)./Pii(1:end-1))';
    
    for i = 1:n
        grad(:,i) = (loss(i,iter)>0)*(-zita(i)*model.Y(i)*A_mat(:,i))/Pii(i);
    end
    
    gradTot = sum(grad,2);
    
    beta_one = beta-gradTot/(sqrt(iter));
    % beta_one = beta-gradTot/(sqrt(iter)*numel(model.Y));
    
    beta_two = beta_one;
    
    index_n = find(beta_one<0);
    
    beta_two(index_n) = 0;
%     beta_two(useless)=0;
    
    if(norm(beta_two))>1
        beta_two = beta_two/(sum(beta_two));
    end
     
    beta = beta_two;

  
end

coeffs_final = P * [model.Y' - y_head*beta; 0];

%coeffs_final = [a_prime; b_prime] - A_mat * beta';
model.a = coeffs_final(1:end-1);
model.b =  coeffs_final(end);     
    
loss = loss;    
    
end  

% n = size(model.K,1);
% 
% model.K=[model.K ones(n,1); ones(1,n) 0];
% 	
% index_p=find(model.Y==1);
% l_p=numel(index_p);
% index_m=find(model.Y==-1);
% l_m=numel(index_m);
% zita=zeros(1,numel(model.Y));
% zita(index_p)=numel(model.Y)/(2*l_p);
% zita(index_m)=numel(model.Y)/(2*l_m);
% 
% if numel(model.C)==1
%     id=1/model.C*diag(1./zita); 
%     id=[id zeros(n,1)];
%     id=[id ; zeros(1,n+1)];
%     id(end,end)=0;
% else
%     id=diag(1./model.C); id(end+1,end+1)=0;
% end
% G=pinv(model.K+id);
% dd=diag(G);
% 
% x1=G*[model.Y';0];
% model.beta = x1(1:end-1);
% model.b = x1(end);
% 
% loo_pred=model.Y'-model.beta./dd(1:end-1);
%    
% 
% for j=1:numel(y_head)
%     if numel(y_head{j})==0, continue; end
%     x2=G*[y_head{j};0];
% 
%     term_prev{j}=x2(1:end-1)./dd(1:end-1);
%     beta_prev{j}=x2;
% end
% 
% 
% t=zeros(1,numel(y_head)); 

% for idx_modello=1:numel(y_head)
%     if numel(y_head{idx_modello})==0, break; end
% end
% useless=idx_modello;
% 
% term_prev_mat=zeros(numel(y_head),numel(model.Y));
% for idx_modello=1:numel(y_head)
%     if idx_modello==useless, continue;end
%     term_prev_mat(idx_modello,:)=term_prev{idx_modello}';
% end
% 
% for ITER=1:(10000)
%     S=t*term_prev_mat;
%     
%     part=zita'.*(model.Y'.*(model.beta./dd(1:end-1)-S'));
%     
%     deriv= - ((part'>0).*zita.*model.Y)*term_prev_mat';
%     t_one=t-deriv/(sqrt(ITER)*numel(model.Y));
% 
%     t_two=t_one;
%     index_NEG=find(t_one<0);
%     t_two(index_NEG)=0;
%     t_two(useless)=0;
%     
%      if(norm(t_two))>1
%          t_two=t_two/(norm(t_two));
%      end
%     t=t_two;
% 
%   
% end
% 
% 
% coeff=t;
% 
% Sloss=zeros(numel(model.Y),1);
% Sf=zeros(numel(model.Y)+1,1);
% for idx_modello=1:numel(y_head)
%     if numel(y_head{idx_modello})==0, continue; end
%     Sf=Sf+coeff(idx_modello)*beta_prev{idx_modello};
%    Sloss=Sloss+coeff(idx_modello)*term_prev{idx_modello};
% end
% 
% LOSS=zita'.*(model.Y'.*(model.beta./dd(1:end-1)-Sloss));
% 
% model.beta=model.beta-Sf(1:end-1);
% model.b=model.b-Sf(end);








