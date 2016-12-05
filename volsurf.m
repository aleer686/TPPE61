A = xlsread('data.xlsx', 'frozen_ASK', 'C3:NL600');
B = xlsread('data.xlsx', 'frozen_BID', 'C3:NL600');

%%
M = (A+B)/2;
[n,m] = size(M);

R = log(M(2:end,:)./M(1:end-1,:));
Rd = R(2:end) - R(1:end-1);

[Q1,l1] = eig(cov(R));
Q = fliplr(Q1);
lambd = rot90(l1,2);
diaglambda = diag(lambd);

cum_exp_var = zeros(1,m);

for i = 1:m
    cum_exp_var(i) = sum(diaglambda(1:i)/(sum(diaglambda)));
end;




%%
Mon = [0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.60, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9];
Mat = [1/252, 5/252, 10/252, 15/252, 1/12, 1.5/12, 2/12, 3/12, 4/12, 5/12, 6/12, 9/12, 1, 18/12, 2, 3, 4, 5, 6, 7,8,9];
V_a = zeros(17, 22);
V_b = zeros(17, 22);
%%
for i = 1:22:length(A)
    V_a(1+(i-1)/22,:) = A(i:i+21);
    V_b(1+(i-1)/22,:) = B(i:i+21);
end;
surf(Mat, Mon, V_a)
%surf(Mat, Mon, V_b)