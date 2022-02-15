function plot_intra_spikes(args)

% extract waveforms from all selected channels according to intra 
% spike times and plot them, one subplot for each channel.
%
% no classification

param;

if get(args.makeFigure, 'Value')
    figure;
    ttt=sprintf('%s GTEC channel%s', args.filename,   vect2str(args.chan_vec, 'formatstring', '%d'));
    sgtitle(ttt);
end

rows=length(args.chan_vec);
plot_rows=1+floor(length(args.chan_vec)/3);
if plot_rows < 2
    plot_rows=2;
end

%%
if args.intra_chan ~= 0
    spike_struct_gt = get_ground_truth(args);
    %  sum(spike_struct_gt.events);
end

max_amp=-1000000;
min_amp= 1000000;


%%
for row_num=1:rows
        
    chan_num=args.chan_vec(row_num);
               
    [~, max_idx, data_struct] = load_data(chan_num, args);
    
    dvec = get_data_vec(data_struct, max_idx, args);
    
    [dvec,args] = preprocess_data(dvec, chan_num, args);  
   
    spike_features = extract_intra_spikes(spike_struct_gt, dvec, chan_num, args);
     
    %%
    subplot(plot_rows,3, row_num);
    
    num_spikes=length(spike_features.vec);
    spike_len=length(spike_features.vec{1});
    
    spike_matrix=zeros(num_spikes, spike_len);
    
    for spike_num=1:num_spikes    
        plot(spike_features.vec{spike_num}); hold on;
        spike_matrix(spike_num, :)=spike_features.vec{spike_num};
    end
    
    if chan_num ~= args.intra_chan
        mu=mean(spike_matrix);
        plot(mu, 'k', 'Linewidth', 2.0);
    end
    temp=max(spike_matrix(:));
    if max_amp < temp
        max_amp=temp;
    end
    temp=min(spike_matrix(:));
    if min_amp > temp
        min_amp=temp;
    end
    
    if chan_num == args.intra_chan
        true_spike_count=length(spike_features.vec);
        ttt=sprintf('Chan %d, GT IC, spike count=%d \n', chan_num, true_spike_count);
    else
        ttt=sprintf('Chan %d: GT EC \n', chan_num);
    end
    xlim([1, spike_len]);
    xlabel('time steps');
    ylabel('\muV');
    title(ttt);
end


end
