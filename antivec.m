function [ A ] = antivec( v, m, n )
%använd gärna m = antal strikes och n = antal löptider
A = zeros(n,m);
j = 1;
for i = 1:n
    A(i,:) = v(j:j+m-1);
    j = j + m;
end;
end

