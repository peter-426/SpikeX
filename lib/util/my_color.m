function vec = my_color( n )

clr={ [ 1 0 0],  [0 0 1],  [ 0 0 0], [0 1 0], [ .5 .4 .3 ], [ .3 .4 .5 ], [ .4 .5 .3 ],  [ .3 .5 .7 ], [.7 .3 .3] };

idx = 1+ mod(n, length(clr));

vec = clr{idx};

end