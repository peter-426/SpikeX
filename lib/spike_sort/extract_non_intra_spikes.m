function spike_features = extract_non_intra_spikes(chan_num, dvec, intra_spike_features, args)

param;
      
% [max_time, max_idx, data_struct] = load_data(chan_num, args);
% 
% if endsWith(args.filename, 'nwb')
%     dvec=data_struct;
%     %size(dvec)
% else
%     dvec = get_data_vec(data_struct, max_idx, args);
% end
% 
% [dvec,args] = preprocess_data(dvec, chan_num, args);  % <<<<<<<<<<<<<<<<<<<<<<<<<<<<

% fprintf('detect_spikes,  mad = %0.3f \n', spike_features.mad);
        
spike_features.mad = args.mad;
spike_features.thr = p.threshold_extra * args.mad;

spike_features.chan_num=chan_num;   % number
spike_features.chan_numbers=[];

spike_features.th  =[];
spike_features.idx0=[];

spike_number=0;

% 10 step per ms if sampling at 10000 Hz
offset1_steps=round(p.offset1 * args.Fs/1000.0);  
offset2_steps=round(p.offset2 * args.Fs/1000.0);  


%%%%%%%%%%%%% detect spikes %%%%%%%%%%%%%%%%%%%%%%%%%%%%
spike = detect_spikes( dvec, args );

% delete detected intra spikes, reveal non intra spikes
for ii=1:length(intra_spike_features.idx3)
    peak_idx=intra_spike_features.idx3(ii);
    spike.events(peak_idx-10:peak_idx+10)=0;
end


% fprintf('extract_spikes = %d\n', spike.count);

spike_features.count  = spike.count;
spike_features.events = spike.events;
spike_features.num_to_event_idx = spike.num_to_event_idx;

%% spike extraction
for spikeIndex=1:length(spike.events)
    
    if spike.events(spikeIndex) == 0  % spike_times{1}(spikeIndex);
        continue;
    end
    
    % might lose a few spikes close to the end of this segment, i.e. 
    % if waveform extends past end of segment 
    if (spikeIndex-offset1_steps) < 1 || (spikeIndex+offset2_steps) > length(dvec)
        continue;
    end
    
    peak_idx=spike.amplitudes_idx(spikeIndex); % index of peak within waveform
    
    wave_indices=(peak_idx - offset1_steps):(peak_idx+offset2_steps);    
    
    if wave_indices(1) < 1 % || xxx2(1) < 1
        continue;
    end

    if wave_indices(end) > length(dvec) % || xxx2(end) > length(dvec)
        msgbox('Frame size too big.  Decrease frame or increase window size.');
        return
    end

    wave_vec=dvec( wave_indices );
   
    spike_number = spike_number+1; % <<<<<<<<<<<<<<<<<<
    spike_features.vec_idx{spike_number} = wave_indices;  % record indices of this waveform
    spike_features.chan_numbers(spike_number) = chan_num;  % need to tag spike with elec number for spike aggregation
    spike_features.amplitudes_idx(spike_number) = spike.amplitudes_idx(spikeIndex); % record amplitude feature of waveform

    idx3=offset1_steps + 1;

    spike_features.vec{spike_number} = wave_vec;
    spike_features.idx0(spike_number)= spikeIndex;
            
    spike_features.idx3(spike_number)= idx3;  % index of peak within waveform
end

%fprintf('detect_spikes spk num %d\n',spike_number);

if isfield(spike_features, 'vec')
   % fprintf('spike features vec length = %d \n', length(spike_features.vec));
else
    % fprintf('spike features vec does not exists. \n');
    return;
end

spike_features.data_length=length(dvec);

end