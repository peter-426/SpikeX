% function plot_gt_v_extra_spikes_neural_net_days_1D_b(args)


% load data from multiple experiments (days)
% extract gt spike from each day,
% train on GT waveforms, and test 1 set of new GT waveform

param;


%% get true spike times from intracelluar spike times
if args.intra_chan ~= 0
    spike_struct_gt = get_ground_truth(args);
    %   sum(spike_struct_gt.events)
end

%% extract spike wavefoms from each channel
%
channel_count=length(args.chan_vec);

for idx=1:channel_count
    
    chan_num=args.chan_vec(idx);
    
    if chan_num == args.intra_chan
        continue;
    end
    
    [~, max_idx, data_struct] = load_data(chan_num, args);
    
    dvec = get_data_vec(data_struct, max_idx, args);
    
    [dvec,args] = preprocess_data(dvec, chan_num, args);
    
    spike_features{expt,chan_num} = extract_intra_spikes(spike_struct_gt, dvec, chan_num, args);
    
    
    %%
    plot_number=plot_number+1;
    subplot(plot_rows, 4, plot_number);
    
    num_spikes=length(spike_features{expt,chan_num}.vec);
    spike_len=length(spike_features{expt,chan_num}.vec{1});
    spike_matrix=zeros(num_spikes, spike_len);
    
    num_spikes=100;
    
    % plot each waveform recorded by this channel
    for spike_num=1:num_spikes
        if min_amp > min( spike_features{expt,chan_num}.vec{spike_num} )
            min_amp =  min( spike_features{expt,chan_num}.vec{spike_num} );
        end
        
        if max_amp < max( spike_features{expt,chan_num}.vec{spike_num} )
            max_amp =  max( spike_features{expt,chan_num}.vec{spike_num} );
        end
        
        plot(spike_features{expt,chan_num}.vec{spike_num}); hold on;
        spike_matrix(spike_num, :)= spike_features{expt,chan_num}.vec{spike_num};
    end
    
    % plot mean waveform for this channel
    if chan_num ~= args.intra_chan
        mu=mean(spike_matrix(1:num_spikes, :));
        plot(mu, 'k', 'Linewidth', 2.0);
    end
    
    if chan_num == args.intra_chan
        true_spike_count=length(spike_features{expt,chan_num}.vec);
        ttt=sprintf('Chan %d, intra spikes=%d', chan_num, true_spike_count);
    else
        ttt=sprintf('Chan %d, true spikes=%d', chan_num, num_spikes);
    end
    
    title(ttt);
    ylabel('\muV');
    xlim([0, spike_len]);
end


% for ii=1:plot_number
%     subplot(plot_rows,4,ii)
%
%     ylim([min_amp, max_amp]);
% end


