
function spike = detect_spikes(data_vec, args)

param;

spike.events=[];
spike.amplitudes=[];
spike.amplitudes_idx=[];
spike.thr=0;
spike.cluster_num=[];
spike.num_to_event_idx=[];
spike_count=0;

if args.chan_num == args.intra_chan
    spike.thr=(p.threshold_intra*args.mad);
    disp('>> detect intra');
else
    spike.thr=(p.threshold_extra*args.mad);
    disp('>> detect extra');
end

% refractory period in ms * steps per ms
refractory_steps = round(p.refractory * args.Fs/1000);

if spike.thr < 0
    spike.events = data_vec < spike.thr;
else
    spike.events = data_vec > spike.thr;
end

idx=1;
maxIdx=length(spike.events);

% fprintf('detect spikes 1 %d \n', sum(spike.events) );

spike.amplitudes    =zeros( 1, maxIdx );
spike.amplitudes_idx=zeros( 1, maxIdx );
spike.cluster_num   =zeros( 1, maxIdx );
spike.num_to_event_idx=[];
                    
while idx < maxIdx
    
    if spike.events(idx) == 1
        mark=idx;                      % time of spike detection
        spike.amplitudes(mark) = data_vec(idx);
        spike.amplitudes_idx(mark) = idx;
        widthCount = 1;
        idx = idx+1;
        
        while(idx <= maxIdx && spike.events(idx) == 1)
            spike.events(idx)=0;  % just want first 1 in spike, zero out rest
            widthCount = widthCount + 1;
            
            % finding max +amplitude of this spike, record index of max
            if spike.thr > 0
                if spike.amplitudes(mark) < data_vec(idx)
                    spike.amplitudes(mark)     = data_vec(idx);
                    spike.amplitudes_idx(mark) = idx;
                end
            else % find max -amplitude
                if spike.amplitudes(mark) > data_vec(idx)
                    spike.amplitudes(mark)     = data_vec(idx);
                    spike.amplitudes_idx(mark) = idx;
                end
            end
            idx=idx+1;
        end
        
        if widthCount < p.min_width
            spike.events(mark)=0;
            spike.amplitudes(mark)=0;
            spike.amplitudes_idx(mark)=0;
        else
            spike_count = spike_count + 1;
            spike.num_to_event_idx(spike_count)=mark;
            
            spike.events(idx:idx+refractory_steps)=0; % no spike during ref period
            idx=idx+refractory_steps;
        end
    end
    
    idx=idx+1;
end

spike.count = sum(spike.events);

% fprintf('detect spikes 2 %d \n', sum(spike.events) );

if spike_count ~= spike.count
    disp('detect_spikes:  spike count error');
end


end