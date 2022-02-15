function spike_struct_gt = get_ground_truth(args)

[~, max_idx, data_struct] = load_data(args.intra_chan, args);
dvec = get_data_vec(data_struct, max_idx, args);

% fprintf('get_GT 1 %d \n', sum(dvec));

% just mean center if intra channel data
[dvec,args] = preprocess_data(dvec, args.intra_chan, args);

% fprintf('get_GT 2 %d \n', sum(dvec));

spike_struct_gt = detect_spikes(dvec, args);

fprintf('get ground truth: spk count = %d \n', sum(spike_struct_gt.events));

end