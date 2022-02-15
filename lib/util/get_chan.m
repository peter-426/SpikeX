function chan=get_chan(selected_mapObj)

chan='';

if isempty( selected_mapObj )
    return
end
key=keys(selected_mapObj);
[~, n]=size(key);
if n > 1
    chan=[];
else
    chan= selected_mapObj(key{1});
end
end