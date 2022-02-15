function spike_features=plot_clusters_1(spike_features, args)

param;

rate=args.Fs/1000;   % time steps per second (1000 ms per second)

% get screen size and set figure position
if get(args.makeFigure, 'Value')
    ss = get(0,'ScreenSize');            
    pos1 = ss .* 0.8;
    pos1(1) = pos1(1) + pos1(3)*0.15 ;
    pos1(2) = pos1(2) + pos1(3)*0.1 ;
    figure('NumberTitle','off', 'Visible', 'on', 'OuterPosition', pos1);
    if p.extraction==1
        ttt=sprintf('%s: channel %d EC (wavelets)', args.filename, args.chan_num);
    elseif p.extraction == 2
        ttt=sprintf('%s: channel %d EC (PCA)', args.filename, args.chan_num);
    else
        ttt=sprintf('%s: channel %d EC (none)', args.filename, args.chan_num);
    end
    sgtitle(ttt);
end

gray=[.8 .8 .8];

columns_1 = 4;
histo_offset = 8;
if p.k >= columns_1
    columns_1 = p.k + 1;
    histo_offset = columns_1 * 2;
end

%% all clustered

mn= -1;
mx=  1;

%%


if p.extraction==2  % 2 = pca
    
    subplot(3,columns_1, 1)
    title('Principal Components',  'FontSize', 11);  hold on;
    plot(spike_features.C(:,1));  hold on;
    plot(spike_features.C(:,2));
    plot(spike_features.C(:,3));
    legend('PC1', 'PC2', 'PC3', 'Location', 'Northeast');
    
    %%
    subplot(3,columns_1, 2)
    title('% of total variance explained',  'FontSize', 11);  hold on;
    plot(spike_features.explained);
    plot(spike_features.explained, '.', 'Markersize', 10);
    xlabel('feature number');
    ylabel('percent');
    xlim([0 length(spike_features.explained) ]);
end

%%
subplot(3,columns_1, 3)
plot(1:length(spike_features.sil), spike_features.sil, '-*b');
xlabel('number of clusters');
ylabel('quality of clusters');
title('Silhouette', 'FontSize', 8);


%% allocate space
counter_vec=zeros(1, p.k+1);
cols=length(spike_features.vec{1});

clustered_matrix={p.k};
mean_waves=zeros(p.k, cols);
std_waves=zeros(p.k, cols);

for ii=1:p.k
    rows=sum(spike_features.cluster_num == ii);
    clustered_matrix{ii} = zeros(rows,cols);
end

%%
% aggregate waveforms into cells
for ii=1:length(spike_features.vec)  
    c_number = spike_features.cluster_num(ii);
    counter_vec(c_number)=counter_vec(c_number)+1;
    clustered_matrix{c_number}(counter_vec(c_number),:)=spike_features.vec{ii};
end


%%
% Eviction of waveforms from their clusters.
% First label bad fitting waveforms with cluster zero (p.k+1)
for c_number=1:p.k
    mean_waves(c_number,:)=mean( clustered_matrix{c_number} );  % centroids
    std_waves(c_number,:)=std( clustered_matrix{c_number} );
end

for ii=1:length(spike_features.vec)
    c_number = spike_features.cluster_num(ii);
    if c_number <= p.k       
        diff_vec = abs(spike_features.vec{ii} - mean_waves(c_number,:));
        
        max_error = std_waves(c_number,:)*p.outlier;
        if sum(diff_vec > max_error) > 0
            spike_features.cluster_num(ii) = p.k+1; % cluster zero, unclustered
        end
    end
end

%%
% reaggregate 
counter_vec=zeros(1, p.k+1);
for ii=1:p.k+1
    rows=sum(spike_features.cluster_num == ii);
    clustered_matrix{ii} = zeros(rows,cols);
end

for ii=1:length(spike_features.vec)  
    c_number = spike_features.cluster_num(ii);
    counter_vec(c_number)=counter_vec(c_number)+1;
    clustered_matrix{c_number}(counter_vec(c_number),:)=spike_features.vec{ii};
end

%% redo mean waveforms and rank
max_amp=[];
for c_number=1:p.k
    mean_waves(c_number,:)=mean( clustered_matrix{c_number} );
    max_amp(c_number)=max(mean_waves(c_number,:))-min(mean_waves(c_number,:));
end
[vals, amp_idx ] = sort(max_amp, 'descend');

spike_features.amp_idx=amp_idx;   % return to gui and pass to plot_clustered_trains

%%
% counter_vec and plot each waveform

counter_vec=zeros(1, p.k+1);

for ii=1:length(spike_features.vec)
    
    c_number = spike_features.cluster_num(ii);
%      clustered_matrix{c_number}(counter_vec(c_number),:)=spike_features.vec{ii};
    
    if c_number <= p.k
        counter_vec(c_number)=counter_vec(c_number)+1;
        c_grade = find(amp_idx==c_number);
          
        subplot(3, columns_1, columns_1 + c_grade);
        plot( clustered_matrix{c_number}(counter_vec(c_number),:), 'Color', gray );  hold on;
    else
        counter_vec(c_number)=counter_vec(c_number)+1;  % unclustered ... evicted waveforms
        subplot(3, columns_1, columns_1 + c_number);
        plot( spike_features.vec{ii}, 'Color', gray );  hold on;
    end
end

%%
% plot the mean waveform for each cluster
for c_number=1:p.k
    
    c_grade = find(amp_idx==c_number);
    subplot(3, columns_1, columns_1 + c_grade);
    
    plot( mean_waves(c_number,:), 'Color', my_color(c_grade), 'Linewidth', 2.5);
    plot( mean_waves(c_number,:)+std_waves(c_number,:), 'Color', 'r', 'Linewidth', 0.5);
    plot( mean_waves(c_number,:)-std_waves(c_number,:), 'Color', 'r', 'Linewidth', 0.5);
    
    if mn > min( mean_waves(c_number,:) )
        mn=min( mean_waves(c_number,:) );
    end
    
    if mx < max( mean_waves(c_number,:) )
        mx=max( mean_waves(c_number,:) );
    end
end


tot=sum(counter_vec(1:p.k));  % total number of clustered spikes

for c_number=1:p.k+1
    if c_number <= p.k
        c_grade = find(amp_idx==c_number);
    else
        c_grade=p.k+1;
    end
    

%     fprintf('cluster cn=%d: counter_vec = %d  tot=%d\n', c_number, counter_vec(c_number),tot);

    pct=100* counter_vec(c_number)/tot;
    if c_number <= p.k
        ttt=sprintf('Ch%d, C%d: %0.2f%%, %d spikes, %0.2f Hz', ...
            spike_features.chan_num, c_grade,  pct, counter_vec(c_number), counter_vec(c_number)/args.seconds );
    else
        ttt=sprintf('Unclustered: %d spikes?, %0.2f Hz', counter_vec(c_number), counter_vec(c_number)/args.seconds );
    end
    subplot(3,columns_1, columns_1+c_grade);
    grid on;
    title(ttt,  'FontSize', 8);
    ylim([mn*1.1, mx*1.1]);
    if c_grade == 1
        ylabel('\muV');
    end
    
    xlabel('time steps');
    %     ax=gca;
    %     xt=ax.XTick ./ (args.Fs/1000.0);
    %     set(gca, 'xticklabels', xt);
    xlim([0 cols]);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot cluster points for first 2 or 3 features

subplot(3,columns_1, 4)

t_str=sprintf('Clusters');
title(t_str, 'FontSize', 8);  hold on;
%plot( S(:,1), S(:,2), '.' );

xlabel('1st feature scores');
ylabel('2nd feature scores');
zlabel('3rd feature scores');

for c_number=1:p.k
    
    c_grade = find(amp_idx==c_number);
    
    cluster = spike_features.kkk(:,end) == c_number;
    plot( spike_features.kkk(cluster,1), spike_features.kkk(cluster,2),...
        'o', 'Color', my_color(c_grade), 'Markersize', 5); hold on;
end
grid on;
%plot(C(:,1),C(:,2), 'kx',  'Markersize', 10, 'LineWidth',3);



%% plot cluster points, 2nd, 3rd, ... features
% if feature_count >= 3
%     
%     subplot(3,columns_1, 4)
%     title('Clusters', 'FontSize', 8);  hold on;
%     %plot( S(:,2), S(:,3), '.' );
%     
%     xlabel('3rd feature scores');
%     ylabel('2nd feature scores');
%     zlabel('4th feature scores');
%     
%     for c_number=1:p.k
%         c_grade = find(amp_idx==c_number);
%         cluster = spike_features.kkk(:,end) == c_number;
%         plot( spike_features.kkk(cluster,3), spike_features.kkk(cluster,2),...
%             'o', 'Color', my_color(c_grade), 'Markersize', 5); hold on;
%     end
%     grid on;
%     %plot(C(:,1),C(:,2), 'kx',  'Markersize', 10, 'LineWidth',3);
% end


%% histograms
%
maximum=0;
for c_number=1:p.k
    
    if c_number <= p.k
        c_grade = find(amp_idx==c_number);
    else
        c_grade=p.k+1;
    end
    
    peak_indices=spike_features.amplitudes_idx( spike_features.cluster_num == c_number );
    isi_data=diff(peak_indices)/rate;
    
    subplot(3,columns_1, histo_offset + c_grade);
    
    h=histogram(isi_data,'FaceColor', my_color(c_grade), 'EdgeColor', my_color(c_grade)); hold on;
    h.BinEdges = 0:10:1000;
    
    ax=gca;
    ax.XTickLabelRotation=90;
        
    if c_grade == 1
        ylabel('frequency');
    end
    
    xlab=sprintf('ISIs (ms)');
    xlabel( xlab );
    
    tot=sum(h.Values);
    t1=sprintf('C%d: %d ISIs, ', c_grade, tot);
    t2=sprintf('mean %0.0f ms.', mean( isi_data ));
    title([t1, t2],  'FontSize', 8);
    
    temp=max(h.Values);
    if maximum < temp
        maximum=temp;
    end
end


for cn=1:p.k
    subplot(3,columns_1, histo_offset + cn);
    if maximum <= 0
        ylim([0 1]);
    else
        ylim([0 maximum]);
    end
end

% args.figtitle.String = sgtitle(args.filename);
% drawnow;

if get(args.verbose, 'Value')
    t_str=sprintf('Filename %s, Elec %d, Thr= %0.2f, MAD=%0.2f', args.filename, ...
        spike_features.chan_num, p.threshold_extra, spike_features.mad);
    
    fprintf('%s \n', t_str);
end

% figure(10);
% plot(spike_features.C(:,1));  hold on;
% plot(spike_features.C(:,2));
% plot(spike_features.C(:,3));
% legend(['PC1', 'PC2', 'PC3'], 'Location', 'Northeast');

end



