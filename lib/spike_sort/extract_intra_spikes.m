function spike_features = extract_intra_spikes(data_struct_gt, dvec, chan_number, args)

param;
      
% [max_time, max_idx, data_struct] = load_data(chan_number, args);
% 
% if endsWith(args.filename, 'nwb')
%     dvec=data_struct;
%     %size(dvec)
% else
%     dvec = get_data_vec(data_struct, max_idx, args);
% end
% 
% [dvec,args] = preprocess_data(dvec, chan_number, args);  % <<<<<<<<<<<<<<<<<<<<<<<<<<<<

% fprintf('detect_spikes,  mad = %0.3f \n', spike_features.mad);
        
spike_features.mad = args.mad;

if chan_number == args.intra_chan
    spike_features.thr = p.threshold_intra * args.mad;
else
    spike_features.thr = p.threshold_extra * args.mad;
end

spike_features.chan_num=chan_number;   % number
spike_features.chan_numbers=[];

spike_features.th  =[];
spike_features.idx0=[];

spike_number=0;

% 10 step per ms if sampling at 10000 Hz
offset1_steps=round(p.offset1 * args.Fs/1000.0);  
offset2_steps=round(p.offset2 * args.Fs/1000.0);  

%%%%%%%%%%%%% extract spikes at time of intra spike peaks %%%%%%%%%%%%%%


spike_features.count  = data_struct_gt.count;
spike_features.events = data_struct_gt.events;

% fprintf('extract_intra_spikes, count=%d\n', sum(spike_features.events));


%% spike extraction
for spikeIndex=1:length(spike_features.events)
    
    if spike_features.events(spikeIndex) == 0  % spike_times{1}(spikeIndex);
        continue;
    end
    
    % might lose a few spikes close to the end of this segment, i.e. 
    % if waveform extends past end of segment 
    if (spikeIndex-offset1_steps) < 1 || (spikeIndex+offset2_steps) > length(dvec)
        continue;
    end
  
    peak_idx=data_struct_gt.amplitudes_idx(spikeIndex); % index of peak within waveform
   
    wave_indices=(peak_idx - offset1_steps):(peak_idx+offset2_steps);    
   
    
    if wave_indices(1) < 1 % || xxx2(1) < 1
        continue;
    end

    if wave_indices(end) > length(dvec) % || xxx2(end) > length(dvec)
        msgbox('Extract_intra_spikes: out of bounds.');
        return
    end
  
    %center the extracted waveform at it's minimum "peak" 
    if chan_number ~= args.intra_chan
        wave_vec=dvec( wave_indices );
        [~,temp_idx]=min(wave_vec);
        
        shift_amt=round(temp_idx-((offset1_steps+offset2_steps)/2));
        
        peak_idx=peak_idx+shift_amt;
        wave_indices=(peak_idx - offset1_steps):(peak_idx+offset2_steps);
        
        % boundary check again
        if wave_indices(1) < 1 % || xxx2(1) < 1
            continue;
        end
        
        if wave_indices(end) > length(dvec) % || xxx2(end) > length(dvec)
            msgbox('Extract_intra_spikes: out of bounds.');
            return
        end
    end
    
    wave_vec=dvec( wave_indices );
        
    spike_number=spike_number+1; % <<<<<<<<<<<<<<<<<<
    spike_features.vec_idx{spike_number} = wave_indices;  % record indices of this waveform
    spike_features.chan_numbers(spike_number)=chan_number;  % need to tag spike with elec number for spike aggregation
  %  spike_features.amplitudes_idx(spike_number)=spike.amplitudes_idx(spikeIndex); % record amplitude feature of waveform

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