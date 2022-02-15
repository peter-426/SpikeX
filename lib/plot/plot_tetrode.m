function spike_features=plot_tetrode(spike_features, chan_vec, args)

param;

% rate=args.Fs/1000;   % time steps per second (1000 ms per second)

% get screen size and set figure position
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


n_columns = 3;

if p.k >= n_columns
    n_columns = p.k + 1;
end

%% all clustered

n_rows=3;  %  length(chan_list);
if n_rows <3
    n_rows=3;
end

k=p.k;

for idx=1:length(spike_features)  % for each channel
    
    mn= -1;  mx=  1;   idx0 = idx-1;
    
    if ~isfield(spike_features{idx}, 'vec')  % any spikes?
        continue;
    end
    
    %% allocate
    counter_vec=zeros(1, k+1);
    spike_len=length(spike_features{idx}.vec{1});
    
    clustered_matrix={k};
    mean_waves=zeros(k, spike_len);
    std_waves=zeros(k, spike_len);
    
    no_cluster_num=false;
    
    for ii=1:k
        if ~isfield(spike_features{idx}, 'cluster_num')
            no_cluster_num=true;
        else
            rows=sum(spike_features{idx}.cluster_num == ii);
            clustered_matrix{ii} = zeros(rows,spike_len);
        end
    end
    
    if no_cluster_num == true   % can't k-means this channel, not enough data?
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
    % Eviction of waveforms from their clusters.
    % First label bad fitting waveforms with cluster zero (K+1)
    for c_number=1:k
        mean_waves(c_number,:)=mean( clustered_matrix{c_number} );  % centroids
        std_waves(c_number,:)=std( clustered_matrix{c_number} );
    end
   
  
    
    for ii=1:length(spike_features{idx}.vec)  % each vec contains a spike waveform
        c_number = spike_features{idx}.cluster_num(ii);
        if c_number <= k
            diff_vec = abs(spike_features{idx}.vec{ii} - mean_waves(c_number,:));
            
            max_error = std_waves(c_number,:)*p.outlier;
            if sum(diff_vec > max_error) > 0
                spike_features{idx}.cluster_num(ii) = k+1; % cluster zero, unclustered
%                 spike_features{idx}.kkk(:,end)
            end
        end
    end
    
    
    %%
    % reaggregate
    counter_vec=zeros(1, k+1);
    for ii=1:k+1
        rows=sum(spike_features{idx}.cluster_num == ii);
        clustered_matrix{ii} = zeros(rows,spike_len);
    end
    
    for ii=1:length(spike_features{idx}.vec)
        c_number = spike_features{idx}.cluster_num(ii);
        counter_vec(c_number)=counter_vec(c_number)+1;
        clustered_matrix{c_number}(counter_vec(c_number),:)=spike_features{idx}.vec{ii};
    end
    
    %% redo mean waveforms and rank according to max peak minus trough
    max_amp=[];
    for c_number=1:k
        mean_waves(c_number,:)=mean( clustered_matrix{c_number} );
        max_amp(c_number)=max(mean_waves(c_number,:))-min(mean_waves(c_number,:));
    end
    [vals, amp_idx ] = sort(max_amp, 'descend');
    
    if sum(isnan(vals)) > 0
        continue;
    end
    
    spike_features{idx}.amp_idx=amp_idx;   % return to gui and pass to plot_clustered_trains
    
    %%
    % counter_vec and plot each waveform
    
    counter_vec=zeros(1, k+1);
    
    for ii=1:length(spike_features{idx}.vec)
        
        c_number = spike_features{idx}.cluster_num(ii);
        
        if c_number <= k
            counter_vec(c_number)=counter_vec(c_number)+1;
            c_grade = find(amp_idx==c_number);
            
            subplot(n_rows, n_columns, c_grade);
            plot( clustered_matrix{c_number}(counter_vec(c_number),:) );  hold on;
        else
            counter_vec(c_number)=counter_vec(c_number)+1;  % unclustered ... evicted waveforms
            subplot(n_rows, n_columns, c_number);
            plot( spike_features{idx}.vec{ii} );  hold on;
        end
    end
    
    %%
    % plot the mean waveform for each cluster
    for c_number=1:k
        
        c_grade = find(amp_idx==c_number);
        subplot(n_rows, n_columns, c_grade);
        
        plot( mean_waves(c_number,:), 'Color', my_color(c_grade), 'Linewidth', 2.5);
%         plot( mean_waves(c_number,:)+std_waves(c_number,:), 'Color', 'k', 'Linewidth', 0.5);
%         plot( mean_waves(c_number,:)-std_waves(c_number,:), 'Color', 'k', 'Linewidth', 0.5);
        
        if mn > min( mean_waves(c_number,:) )
            mn=min( mean_waves(c_number,:) );
        end
        
        if mx < max( mean_waves(c_number,:) )
            mx=max( mean_waves(c_number,:) );
        end
    end
    
    
    tot=sum(counter_vec(1:k));  % total number of clustered spikes
    
    for c_number=1:k+1
        if c_number <= k
            c_grade = find(amp_idx==c_number);
        else
            c_grade=k+1;
        end
        

        % fprintf('cluster cn=%d: counter_vec = %d  tot=%d\n', c_number, counter_vec(c_number),tot);
        
        %  pct=100* counter_vec(c_number)/tot;
        
        subplot(n_rows, n_columns, c_grade);
        grid on;
        if c_grade < p.k+1
            ttt=sprintf('C%d, spikes=%d',     c_grade, counter_vec(c_number));
        else
            ttt=sprintf('C%d unclustered=%d', c_grade, counter_vec(c_number));
        end
        title(ttt,  'FontSize', 8);
        margin=0.30 * (abs(mx)+abs(mn));
        
        ylim([mn-margin, mx+margin]);
        if c_grade == 1
            ylabel('\muV');
        end
        
        xlabel('time steps');
        
        xlim([0 spike_len]);
    end
    
%     size(spike_features{idx}.chan_vec)
%     size(spike_features{idx}.cluster_num)
    
    max_count=0;
    
%     size(spike_features{idx}.chan_vec)
%     size(spike_features{idx}.cluster_num) % need to transpose!!!
    
    for c_number=1:p.k+1
        
        chan_spikes2 = sum(spike_features{idx}.chan_vec == 2 & ...
            spike_features{idx}.cluster_num' == c_number);
        
        chan_spikes3 = sum(spike_features{idx}.chan_vec == 3 & ...
            spike_features{idx}.cluster_num' == c_number);
    
        chan_spikes4 = sum(spike_features{idx}.chan_vec == 4 & ...
            spike_features{idx}.cluster_num' == c_number);
        
        chan_spikes5 = sum(spike_features{idx}.chan_vec == 5 & ...
            spike_features{idx}.cluster_num' == c_number);
        
        if c_number <= k
            c_grade = find(amp_idx==c_number);
        else
            c_grade=k+1;
        end
        
        temp=max([chan_spikes2, chan_spikes3, chan_spikes4, chan_spikes5]);
        if max_count < temp
            max_count = temp;
        end
        
        if c_number <= k
            c_grade = find(amp_idx==c_number);
        else
            c_grade=k+1;
        end
        
        subplot(n_rows, n_columns, k+1+c_grade); 
        
        % EC channels usually [1,2,3,4] or [2,3,4,5],
        bar(chan_vec, [chan_spikes2, chan_spikes3, chan_spikes4, chan_spikes5]);
        xlabel('channel number');
        if c_grade == 1
            ylabel('spike count');
        end
    end
    
    for ii=1:p.k+1
        subplot(n_rows, n_columns, k+1+ii);
        ylim([0, max_count]);
    end
end

if p.extraction == 2
    subplot(3,n_columns, (2*n_columns)+1)
    title('Principal Components',  'FontSize', 8);  hold on;
    plot(spike_features{1}.C(:,1));  hold on;
    plot(spike_features{1}.C(:,2));
    plot(spike_features{1}.C(:,3));
    xlim([0, spike_len]);
    legend('PC1', 'PC2', 'PC3', 'Location', 'best');
end

subplot(3,n_columns, (2*n_columns)+2)
plot(1:length(spike_features{1}.sil), spike_features{1}.sil, '-*b');
xlabel('number of clusters');
ylabel('quality of clusters');
title('Silhouette', 'FontSize', 8);


%% plot cluster points for first 2 or 3 features

subplot(3,n_columns, (2*n_columns)+3)

t_str=sprintf('Clusters');
title(t_str, 'FontSize', 8);  hold on;
%plot( S(:,1), S(:,2), '.' );

xlabel('1st feature scores');
ylabel('2nd feature scores');

feature_count = length(spike_features{1}.kkk(1,:));

for c_number=1:p.k
    
    c_grade = find(amp_idx==c_number);
    
    cluster = spike_features{1}.cluster_num == c_number;
    %  disp(sum(cluster))
    plot( spike_features{1}.kkk(cluster',1), spike_features{1}.kkk(cluster',2),...
        my_symbols(c_grade), 'Color', my_color(c_grade), 'Markersize', 7); hold on;
    
    % if many have same value, will see few points in cluster plot
    %         if c_grade==1
    %             disp( spike_features{1}.kkk(cluster',1))
    %             disp( spike_features{1}.kkk(cluster',2))
    %         end
end
grid on;
%plot(C(:,1),C(:,2), 'kx',  'Markersize', 10, 'LineWidth',3);


%%
if feature_count >= 3
    subplot(3,n_columns, (2*n_columns)+4)
    
    t_str=sprintf('Clusters');
    title(t_str, 'FontSize', 8);  hold on;
    %plot( S(:,1), S(:,2), '.' );
    
    xlabel('3rd feature scores');
    ylabel('2nd feature scores');
    
    for c_number=1:p.k
        
        c_grade = find(amp_idx==c_number);
        
        cluster = spike_features{1}.cluster_num == c_number;  % because some have been evicted to p.k+1
        plot( spike_features{1}.kkk(cluster',3), spike_features{1}.kkk(cluster',2),...
            my_symbols(c_grade), 'Color', my_color(c_grade), 'Markersize', 7); hold on;
    end
    grid on;
    %plot(C(:,1),C(:,2), 'kx',  'Markersize', 10, 'LineWidth',3);
end


% t_str=sprintf('Filename %s, Elec %d, Thr= %0.2f, MAD=%0.2f', args.filename, ...
%     spike_features{idx}.chan_num, p.threshold_extra, spike_features{idx}.mad);
% 
% fprintf('%s \n', t_str);

end
