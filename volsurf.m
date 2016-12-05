ops_A = xlsread('data.xlsx', 'frozen_ASK', 'O3:LY600');
ops_B= xlsread('data.xlsx', 'frozen_BID', 'O3:LY600');

Mon = [0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.60, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9];
Mat = [1/12, 1.5/12, 2/12, 3/12, 4/12, 5/12, 6/12, 9/12, 1, 18/12, 2, 3, 4, 5, 6, 7,8,9,10];

%%
%generar egenvektorer
M = (ops_A+ops_B)/2;
[n,m] = size(M);

R = log(M(2:end,:)./M(1:end-1,:));
Rd = R(2:end,:) - R(1:end-1,:);

[Q1,l1] = eig(cov(Rd));
Q = fliplr(Q1);
lambd = rot90(l1,2);
diaglambda = diag(lambd);

cum_exp_var = zeros(1,m);

for i = 1:m
    cum_exp_var(i) = sum(diaglambda(1:i)/(sum(diaglambda)));
end;
%%
E1 = antivec(Q(:,1),19,17);
E2 = antivec(Q(:,2),19,17);
E3 = antivec(Q(:,3),19,17);
E4 = antivec(Q(:,4),19,17);

surf(Mat, Mon, E1)

%%
V_a = zeros(17, 19);
V_b = zeros(17, 19);

%generar volytor
for i = 1:19:length(ops_A)
    V_a(1+(i-1)/19,:) = ops_A(i:i+18);
    V_b(1+(i-1)/19,:) = ops_B(i:i+18);
end;
surf(Mat, Mon, V_a)
%surf(Mat, Mon, V_b)