IRS = xlsread('portfolioManagerV3_P4.xls', 'reuters', 'H4:Y2854')./100;
IRS = flipud(IRS);
govbond = xlsread('portfolioManagerV3_P4.xls', 'reuters', 'W4:W2854');
r_b = log(govbond(2:end)./govbond(1:end-1));
%%
[n,trash] = size(IRS);
m = 30;
IRS_inter = zeros(n, 30);
for i = 1 : n
    IRS_inter(i,:) = [IRS(i,1:14), csapi([15,20,25,30], IRS(i,15:18), [15:30])];
end



%%
zc = zeros(n,m);
zc(:,1) = IRS_inter(:,1);

for i=2:m
    for j=1:n
        divsum = 0;
        for k=1:i-1
            divsum = divsum + 1/(1+zc(j,k))^k;
        end;
        zc(j,i) = ((1+IRS_inter(j,i))/(1-IRS_inter(j,i)*divsum))^(1/i)-1;
    end;
end;

%%
tic
ZC_inter = zeros(n, m*365);
for i = 1 : n
    ZC_inter(i,:) = csapi(1:m, zc(i,:), 1/365:1/365:m);
end
toc


%%
tic
r_z = log(1+ZC_inter);
rz_diff = r_z(2:end,:)-r_z(1:end-1,:);


[Q1,l1] = eig(cov(rz_diff));
Q = fliplr(Q1);
lambda = rot90(l1,2);

dlam = diag(lambda);
cev = zeros(1,m);

for i = 1:m
    cev(i) = sum(dlam(1:i))/(sum(dlam));
end;
toc

%%
k = 3;

p = zeros(n,k);

for i=1:k
    p(:,i) = Q(:,i)'*r_z';
end;

%%
t = 1:30;
t = t - (1-0.675);

c = zeros(30,4);
c(1:2,1)  = ones(2,1)*0;
c(1:3,2)  = ones(3,1)*0.0125;
c(1:20,3) = ones(20,1)*0.04;
c(1:30,4) = ones(30,1)*0.0275;
c(2,1)    = c(2,1)+1;
c(3,2)    = c(3,2)+1;
c(20,3)   = c(20,3)+1;
c(30,4)   = c(30,4)+1;

P_sens = zeros(3,4);
for l = 1:4
    for j=1:k
        for i = t
            P_sens(j,l) = P_sens(j,l) - Q(round(i*365),j)*i*c(round(i),l)*exp(-ZC_inter(end,round(i*365))*i);
        end;
    end;
end;

%%
c_s = xlsread('portfoliomanagerV3_P4.xls', 'swapflows', 'B3:S4')/100;

%%
t = zeros(1,size(c_s,2));
t = [1:15, 20, 25, 30];

%262 dagar per år i datan ungefär
y = 262;

swap_sens = zeros(k, size(c_s,2));

for i = 1:size(swap_sens,2)
    for j = 1:k
        for l = 1:t(i)
            swap_sens(j,i) = swap_sens(j,i)- Q(round((l-0.5)*y),j)*(l-0.5)*c_s(1,i)*exp(-ZC_inter(end-2,round((l-0.5)*y))*(l-0.5));
            swap_sens(j,i) = swap_sens(j,i)- Q(round(l*y),j)*l*c_s(2,i)*exp(-ZC_inter(end-2,round(l*y))*l);
        end;
    end;
end;

%%
xlswrite('portfoliomanagerV3_P4.xls', swap_sens, 'priskanslighet2', 'J3:AA5')


%%
V_fix = zeros(1,18);
c_f = -c_s(2,:)+c_s(1,:);
N = 100;
%från excel
V_float = 99.99758521;

for i = 1:15
    for j=1:i
        V_fix(i) = V_fix(i) + N*c_f(i)*exp(-ZC_inter(end,round(j*365))*j);
    end;
end;

for j = 1:20
    V_fix(16) = V_fix(16) + N*c_f(16)*exp(-ZC_inter(end, round(j*365))*j);
end;

for j = 1:25
    V_fix(17) = V_fix(17) + N*c_f(17)*exp(-ZC_inter(end, round(i*365))*i);
end;

for j = 1:30
    V_fix(18) = V_fix(18) + N*c_f(18)*exp(-ZC_inter(end, round(i*365))*i);
end;

for i=1:15
    V_fix(i) = V_fix(i) +  N*exp(-ZC_inter(end, round(i*365))*i);
end;
    V_fix(16:18) = V_fix(16:18) + [N*exp(-ZC_inter(end, round(20*365))*20),
        N*exp(-ZC_inter(end, round(25*365))*25),
        N*exp(-ZC_inter(end, round(30*365))*30)]';
    
IRS = V_float - V_fix;




%%

model = LinearModel.fit(p, govbond, 'linear');

beta = model.Coefficients.Estimate(2:end);



%%
%producerar märkliga resultat, används ej
tic
M = 1:30;
T0 = 1:1/360:30;
NS = @(b,T)  b(1) + b(2)*(1-exp(-T/b(4)))/(T/b(4))+b(3)*((1-exp(-T/b(4)))/(T/b(4)) - exp(-T/b(4)));
ZC_inter = zeros(n,length(T0));
options.Algorithm = 'levenberg-marquardt';
options.Display = 'off';

for i = 1:n
    f = @(b)(NS(b,M)-zc(i,:));

    start  = [1,1,1,1]';
    
    res = lsqnonlin(f, start, [],[], options);
    
    ZC_inter(i,:) = NS(res, T0);
end
toc
