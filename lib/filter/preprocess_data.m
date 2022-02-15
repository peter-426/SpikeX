function [dvec, args] = preprocess_data(dvec, chan_num, args)


if chan_num ~= args.intra_chan
    if args.filter_data_CB
        dvec     = filter_data(dvec, args);
    else
        dvec = dvec - mean(dvec);
    end
    
    if args.filter_artifacts_CB
        args.mad = mad(dvec);
        dvec     = filter_artifacts(dvec, args);
    end
    
    if args.filter_50_hum_CB
        dvec = filter_50_hum(dvec, args);
    end
else
    dvec = dvec - mean(dvec);  % mean center if intra channel
end

args.mad = mad(dvec);

end