function [ A ] = antivec( v, m, n )
A = zeros(m,n);
for i = 1:n
    A(:,i) = v(i:i+m-1);
end;
end

