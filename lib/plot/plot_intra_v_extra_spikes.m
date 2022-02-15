function plot_intra_v_extra_spikes(args)

param;


if get(args.makeFigure, 'Value')

    ss = get(0,'ScreenSize');
    pos1 = ss .* 0.8;
    pos1(1) = pos1(1) + pos1(3)*0.15 ;
    pos1(2) = pos1(2) + pos1(3)*0.1 ;
    
    figure('NumberTitle','off', 'Visible', 'on', 'OuterPosition', pos1);
    ttt=sprintf('%s GT vs not GT EC spikes, channel%s', args.filename,   vect2str(args.chan_vec, 'formatstring', '%d'));
    sgtitle(ttt);
end

%% get true spike times from intracelluar spike times
if args.intra_chan ~= 0
    args.chan_num=args.intra_chan;
    spike_struct_gt = get_ground_truth(args);
    %  sum(spike_struct_gt.events);
end

min_amp=0;  max_amp=0;

gt_spike_features={};
non_gt_spike_features={};

plot_rows=2;

%% extract spike wavefoms from each channel
%
channel_count=length(args.chan_vec);

for idx=1:channel_count
        
    chan_num=args.chan_vec(idx);
    args.chan_num=chan_num;
    
    if chan_num == args.intra_chan
        continue;
    end
               
    [~, max_idx, data_struct] = load_data(chan_num, args);
    
    dvec = get_data_vec(data_struct, max_idx, args);
    
    [dvec,args] = preprocess_data(dvec, chan_num, args);  
   
    gt_spike_features{chan_num} = extract_intra_spikes(spike_struct_gt, dvec, chan_num, args);

    non_gt_spike_features{chan_num} = extract_non_intra_spikes(chan_num, dvec, gt_spike_features{chan_num}, args);

    
    %%
    subplot(plot_rows, 4, idx);
    
    num_spikes=length(gt_spike_features{chan_num}.vec);
    spike_len=length(gt_spike_features{chan_num}.vec{1});
    spike_matrix=zeros(num_spikes, spike_len);
    
    % plot each waveform recorded by this channel
    for spike_num=1:num_spikes           
        if min_amp > min( gt_spike_features{chan_num}.vec{spike_num} )
            min_amp =  min( gt_spike_features{chan_num}.vec{spike_num} );
        end

        if max_amp < max( gt_spike_features{chan_num}.vec{spike_num} )
            max_amp =  max( gt_spike_features{chan_num}.vec{spike_num} );
        end
        
        plot(gt_spike_features{chan_num}.vec{spike_num}); hold on;   
        spike_matrix(spike_num, :)= gt_spike_features{chan_num}.vec{spike_num};
    end
    
    
    
    % plot mean waveform for this channel
    if chan_num ~= args.intra_chan
        mu=mean(spike_matrix);
        plot(mu, 'k', 'Linewidth', 2.0);
    end
    
    if chan_num == args.intra_chan
        true_spike_count=length(gt_spike_features{chan_num}.vec);
        ttt=sprintf('Ch%d, IC spikes=%d', chan_num, true_spike_count);
    else
        ttt=sprintf('Ch%d, GT EC spikes=%d', chan_num, num_spikes);
    end
    
    title(ttt);  
    ylabel('\muV');
end


for ii=1:length(args.chan_vec)
    subplot(plot_rows,4,ii)
    
    ylim([min_amp, max_amp]);
    xlim([0, spike_len]);
end


%% 

% [~,cols] = size(spike_matrix);
% non_spike_matrix = (rand(rows,cols)-0.5) * max(spike_matrix(:));

non_spike_matrix1=zeros(num_spikes, spike_len);



for idx=1:channel_count
    
    chan_num=args.chan_vec(idx);
    
    if chan_num == args.intra_chan
        continue;
    end
    
    num_non_intra_spikes=length(non_gt_spike_features{chan_num}.vec);
    spike_len=length(non_gt_spike_features{chan_num}.vec{1});
    non_intra_spike_matrix=zeros(num_non_intra_spikes, spike_len);
    
    subplot(plot_rows,4,4+idx);
    ttt=sprintf('Ch%d: Not GT EC spikes=%d', chan_num, num_non_intra_spikes);
    title(ttt); hold on;
    % plot each non GT EC waveform recorded by this channel
    for spike_num=1:num_non_intra_spikes
        plot(non_gt_spike_features{chan_num}.vec{spike_num}); hold on;
        spike_matrix(spike_num, :)= non_gt_spike_features{chan_num}.vec{spike_num};
    end
    mu=mean(spike_matrix);
    plot(mu, 'k', 'Linewidth', 2.0);
    ylim([min_amp, max_amp]);
    ylabel('\muV');
    xlim([0, spike_len]);
end



