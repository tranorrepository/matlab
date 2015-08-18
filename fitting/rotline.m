function lineOut = rotline(lineIn,theta)
x = lineIn.x;
y = lineIn.y;

z = (x + y*1i).* exp(theta*1i);

lineOut.x = real(z);
lineOut.y = imag(z);  
end 