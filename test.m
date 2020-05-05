clear all;
A = [ 1 2 3 4 5 6 6.5 7 8 8.5 9 10 4 1 2 3 6 9];
length(A)
for i = 1: length(A) - 4
    k = length(A);
   if((A(i +2) - A(i+1)) ~= (A(i +1) - A(i))) 
      A(i+2) =[];  
   end
end