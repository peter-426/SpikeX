function  dvec = get_data_vec(data_struct, max_idx, args)

dvec=[];

start_idx = args.start;

if start_idx < 1
    start_idx = 1;
end

end_idx = args.end;

if end_idx > max_idx
    end_idx = max_idx;
end

if start_idx > end_idx
    return;
end

if endsWith(args.filename, 'mat')
    dvec = data_struct.data(1,start_idx:end_idx);
elseif endsWith(args.filename, 'dat')
    dvec = data_struct(1,start_idx:end_idx);    
end


end