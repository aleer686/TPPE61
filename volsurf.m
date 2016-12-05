ops_A = xlsread('data.xlsx', 'frozen_ASK', 'O3:LY600')/100;
ops_B= xlsread('data.xlsx', 'frozen_BID', 'O3:LY600')/100;

Mon = [0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.60, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9];
Mat = [1/12, 1.5/12, 2/12, 3/12, 4/12, 5/12, 6/12, 9/12, 1, 18/12, 2, 3, 4, 5, 6, 7,8,9,10];

%%
%generar egenvektorer
dt = 1/252;
M = (ops_A+ops_B)/2;
[n,m] = size(M);

R = log(M(2:end,:)./M(1:end-1,:));
[Q1,l1] = eig(cov(R));
Q = fliplr(Q1);
Omega = rot90(l1,2);
vec_Omega = diag(Omega);

cum_exp_var = zeros(1,m);

for i = 1:m
    cum_exp_var(i) = sum(vec_Omega(1:i))/sum(vec_Omega);
end;

%varians som skall förklaras
a = 0.95;
k = 1;
while cum_exp_var(k) < a
    k = k + 1;
end;

E = Q(:,1:k);
Omega_k = Omega(1:k,1:k);
C_k = E * Omega_k * E';

s = 100; %antal scenarion
X_next = zeros(m, s);
X_mean = zeros(m,1);
for i = 1:s
    %generar slumptalen runt senaste observerade värdet
    X_next(:,i) = mvnrnd(M(1,:), C_k);
    X_mean = X_mean + 1/s * X_next(:,i);
end;

surf(Mat, Mon, antivec(X_next(:,1),19,17));




%% för att visa egenvektorer som ytor
E1 = antivec(Q(:,1),19,17);
E2 = antivec(Q(:,2),19,17);
E3 = antivec(Q(:,3),19,17);
E4 = antivec(Q(:,4),19,17);

surf(Mat, Mon, E1)

%%

V_M = antivec(M(450,:),19,17);

surf(Mat, Mon, V_M)
%surf(Mat, Mon, V_b)