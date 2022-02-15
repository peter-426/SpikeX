function p_vec = make_p_vec(y, row_num, num_spikes)

first=1;  last=num_spikes; 
yya=mean(y( row_num,first:last));

first=first+num_spikes;  last=first+num_spikes-1;
yyb=mean(y( row_num,first:last));

first=first+num_spikes;  last=first+num_spikes-1;
yyc=mean(y( row_num,first:last));

first=first+num_spikes;  last=first+num_spikes-1;
yyd=mean(y( row_num,first:end));

p_vec=[yya,yyb,yyc,yyd];

end