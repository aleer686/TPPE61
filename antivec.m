function [ A ] = antivec( v, m, n )
%anv�nd g�rna m = antal strikes och n = antal l�ptider
A = zeros(n,m);
j = 1;
for i = 1:n
    A(i,:) = v(j:j+m-1);
    j = j + m;
end;
end

