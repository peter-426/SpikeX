
function vec = my_symbols( n )

syms={ '.', '+', 'd', 's', '*', 'd', '^', 'o', };

idx = 1+ mod(n, length(syms));

vec = syms{idx};

end

