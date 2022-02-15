function spike_features=plot_clusters_n_channels(spike_features, chan_vec, args)

% ****************************************************************
%% cluster all spikes (not just GT spikes) from all channels into p.k
% clusters,   and evict bad waveforms ... put into unclustered
% *****************************************************************


param;

% rate=args.Fs/1000;   % time steps per second (1000 ms per second)

%% get screen size and set figure position
if get(args.makeFigure, 'Value')
    ss = get(0,'ScreenSize');
    pos1 = ss .* 0.8;
    pos1(1) = pos1(1) + pos1(3)*0.15 ;
    pos1(2) = pos1(2) + pos1(3)*0.1 ;
    figure('NumberTitle','off', 'Visible', 'on', 'OuterPosition', pos1);
    
    if p.extraction==1
        ttt=sprintf('%s: channel %s EC (wavelets)', args.filename,  vect2str(chan_vec, 'formatstring', '%d'));
    elseif p.extraction == 2
        ttt=sprintf('%s: channel %s EC (PCA)', args.filename,  vect2str(chan_vec, 'formatstring', '%d'));
    else
        ttt=sprintf('%s: channel %s EC (none)', args.filename,  vect2str(chan_vec, 'formatstring', '%d'));
    end

    sgtitle(ttt);
end

%%
n_rows=4;
n_columns = 4;

num_channels=length(chan_vec);
amp_idx={};

for idx=1:length(spike_features)  % for each channel
    
    chan_num=chan_vec(idx);
    if chan_num == args.intra_chan
        continue;
    end
    
    mn= -1;  mx=  1; 
    
    if ~isfield(spike_features{idx}, 'vec')  % any spikes?
        continue;
    end
    
    %% allocate
    counter_vec=zeros(1, p.k+1);
    cols=length(spike_features{idx}.vec{1});
    
    clustered_matrix={p.k};
    mean_waves=zeros(p.k, cols);
    std_waves=zeros(p.k, cols);
    
    no_cluster_num=false;
    
    for ii=1:p.k
        if ~isfield(spike_features{idx}, 'cluster_num')
            no_cluster_num=true;
        else
            rows=sum(spike_features{idx}.cluster_num == ii);
            clustered_matrix{ii} = zeros(rows,cols);
        end
    end
    
    if no_cluster_num== true   % can't k-means this channel, not enough data?
        continue;
    end
    
    %%
    % aggregate waveforms into cells
    for ii=1:length(spike_features{idx}.vec)
        c_number = spike_features{idx}.cluster_num(ii);
        counter_vec(c_number)=counter_vec(c_number)+1;
        clustered_matrix{c_number}(counter_vec(c_number),:)=spike_features{idx}.vec{ii};
    end
    
    
    %%
    % Eviction of bad waveforms from their clusters.
    for c_number=1:p.k
        mean_waves(c_number,:)=mean( clustered_matrix{c_number} );  % centroids
        std_waves(c_number,:)=std( clustered_matrix{c_number} );
    end
    
    
    % Label bad fitting waveforms with cluster zero (p.k+1)
    for ii=1:length(spike_features{idx}.vec)  % each vec contains a spike waveform
        c_number = spike_features{idx}.cluster_num(ii);
        if c_number <= p.k
            diff_vec = abs(spike_features{idx}.vec{ii} - mean_waves(c_number,:));
            
            max_error = std_waves(c_number,:)*p.outlier;
            if sum(diff_vec > max_error) > 0
                spike_features{idx}.cluster_num(ii) = p.k+1; % cluster zero, unclustered
            end
        end
    end
    
    
    %%
    % reaggregate
    counter_vec=zeros(1, p.k+1);
    for ii=1:p.k+1
        rows=sum(spike_features{idx}.cluster_num == ii);
        clustered_matrix{ii} = zeros(rows,cols);
    end
    
    for ii=1:length(spike_features{idx}.vec)
        c_number = spike_features{idx}.cluster_num(ii);
        counter_vec(c_number)=counter_vec(c_number)+1;
        clustered_matrix{c_number}(counter_vec(c_number),:)=spike_features{idx}.vec{ii};
    end
    
    %% 
    % redo mean waveforms and rank according to max peak to trough distance
    max_amp=[];
    for c_number=1:p.k
        mean_waves(c_number,:)=mean( clustered_matrix{c_number} );
        max_amp(c_number)=max(mean_waves(c_number,:))-min(mean_waves(c_number,:));
    end
    [vals, amp_idx{idx} ] = sort(max_amp, 'descend');
    
    if sum(isnan(vals)) > 0
        continue;
    end
    
    spike_features{idx}.amp_idx=amp_idx{idx};   % return to gui and pass to plot_clustered_trains
    
    
    %%
    % counter_vec and plot each waveform
    counter_vec=zeros(1, p.k+1);
    offset= (idx-1)*n_columns;
    
    for ii=1:length(spike_features{idx}.vec)
        
        c_number = spike_features{idx}.cluster_num(ii);
        
        if c_number <= p.k
            counter_vec(c_number)=counter_vec(c_number)+1;
            c_grade = find(amp_idx{idx}==c_number);
            
            subplot(n_rows, n_columns, offset+c_grade);
            plot( clustered_matrix{c_number}(counter_vec(c_number),:) );  hold on;
        else
            counter_vec(c_number)=counter_vec(c_number)+1;  % unclustered ... evicted waveforms
            subplot(n_rows, n_columns, offset+p.k+1);
            plot( spike_features{idx}.vec{ii} );  hold on;
        end
    end
    
    %%
    % plot the mean waveform for each cluster
    
    for c_number=1:p.k
        
        c_grade = find(amp_idx{idx}==c_number);
        
        subplot(n_rows, n_columns, offset+c_grade);
        
        plot( mean_waves(c_number,:), 'Color', my_color(c_grade), 'Linewidth', 2.5); hold on;
%         plot( mean_waves(c_number,:)+std_waves(c_number,:), 'Color', 'b', 'Linewidth', 1);
%         plot( mean_waves(c_number,:)-std_waves(c_number,:), 'Color', 'b', 'Linewidth', 1);
        
        if mn > min( mean_waves(c_number,:) )
            mn=min( mean_waves(c_number,:) );
        end
        
        if mx < max( mean_waves(c_number,:) )
            mx=max( mean_waves(c_number,:) );
        end
    end
end



for idx=1:length(spike_features)            % for each channel
    counter_vec=zeros(1, p.k+1);
    
    chan_num=chan_vec(idx);
    if chan_num == args.intra_chan
        continue;
    end
    
    for ii=1:length(spike_features{idx}.vec)
        
        c_number = spike_features{idx}.cluster_num(ii);
        if c_number <= p.k
            counter_vec(c_number)=counter_vec(c_number)+1;
        else
            counter_vec(c_number)=counter_vec(c_number)+1;  % unclustered ... evicted waveforms
        end
    end
    
    tot=sum(counter_vec(1:p.k));  % total number of clustered spikes
    
    offset= (idx-1)*n_columns;
    
    for c_number=1:p.k+1
        if c_number <= p.k
            c_grade = find(amp_idx{idx}==c_number);
        else
            c_grade=p.k+1;
        end
        
       % fprintf('cluster cn=%d: counter_vec = %d  tot=%d\n', c_number, counter_vec(c_number),tot);

        spk_count = counter_vec(c_number);
        pct=100* counter_vec(c_number)/tot;
        
        subplot(n_rows, n_columns, offset+c_grade);
        grid on;
        if c_number < p.k+1
            ttt=sprintf('Ch%d, C%d, spks=%d, %0.2f%%', chan_num, c_grade, spk_count, pct);
        else
            ttt=sprintf('Ch%d, C%d, unclustered=%d, ', chan_num, c_grade, spk_count);
        end
        title(ttt,  'FontSize', 8);
        margin=0.30 * (abs(mx)+abs(mn));
        
        ylim([mn-margin, mx+margin]);
        if c_grade == 1
            ylabel('\muV');
        end
        if idx==num_channels
            xlabel('time steps');
        end
        xlim([1 cols]);
    end
end


%     t_str=sprintf('Filename %s, Elec %d, Thr= %0.2f, MAD=%0.2f', args.filename, ...
%         spike_features{idx}.chan_num, p.threshold_extra, spike_features{idx}.mad);
%     
%     fprintf('%s \n', t_str);

end
