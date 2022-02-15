function chan_vec=get_chan_vec(selected_mapObj)

chan_vec=[];

if isempty( selected_mapObj )
    return
end

key=keys(selected_mapObj);

for ii=1:length(key)
    chan_vec(ii)=selected_mapObj(key{ii});
end
end