
%% split the signal recorded from one channel
%  into k spike trains according to the k waveforms
%
%  plot the k spike trains
%
function plot_clustered_trains(spike_features, makeFigure, args)

param;

rate = args.Fs/1000;

%
ss = get(0,'ScreenSize');
pos1 = [ss(3), ss(4),  800, 600] .* [ .1  .1   1  1];

if get(makeFigure, 'Value')
    fig1=figure('NumberTitle','off', 'OuterPosition', pos1, 'Visible', 'off');
    set(fig1,'Visible', 'on');
    if p.extraction==1
        ttt=sprintf('%s: channel %d EC (wavelets)', args.filename, args.chan_num);
    elseif p.extraction == 2
        ttt=sprintf('%s: channel %d EC (PCA)', args.filename, args.chan_num);
    else
        ttt=sprintf('%s: channel %d EC (none)', args.filename, args.chan_num);
    end
    sgtitle(ttt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%  plot k waveforms   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(spike_features, 'vec')
    % disp('spike features vec does not exists.');
    return;
end


counter=zeros(1, p.k+1);
cols =length(spike_features.vec{1});

clustered_matrix={p.k+1};

for ii=1:p.k+1
    rows=sum(spike_features.cluster_num == ii);
    clustered_matrix{ii} = zeros(rows,cols);
end

for ii=1:length(spike_features.vec)
    c_number = spike_features.cluster_num(ii);
    counter(c_number)=counter(c_number)+1;
    clustered_matrix{c_number}(counter(c_number),:)=spike_features.vec{ii};
end

high=1;
low=-1;

%% plot the clustered waveforms

tot=sum(counter(1:p.k));

for c_number=1:p.k+1
    
    if c_number < p.k+1
        c_grade= find(spike_features.amp_idx==c_number);
    else
        c_grade=c_number;
    end
    
    subplot(p.k+1, p.k+1, c_grade);
    
    [rows, cols]=size(clustered_matrix{c_number});
    if rows > 1
        wave = mean( clustered_matrix{c_number});
    else
        wave = clustered_matrix{c_number};
    end
    
    %% We just want the low and high of the k clusters, not the unclustered waveforms.
    if c_number < p.k+1
        temp=max(wave);
        if high < temp
            high = temp;
        end
        
        temp = min(wave);
        if low > temp
            low=temp;
        end
    end
    
    plot( 1:length(wave), wave, 'Color', my_color(c_grade), 'Linewidth', 2.5); hold on;
    
    ax=gca;
    set(ax, 'fontsize',6);

    %set(ax, 'XTicklabel', ax.XTick/rate);
    xlabel('time steps')

    
%     if c_number == 2
%         set(ax, 'XTicklabel', []);
%         xlabel( sprintf('duration = %0.1f ms', length(wave)/rate ));
%     end
    
    %     if c_number > 1
    %         set(gca, 'ytick', []);
    %     end
    if c_number <= p.k
        pct=100 * counter(c_number)/tot;
        title( sprintf('C%d, n=%d, pct=%0.1f%%', c_grade, counter(c_number), pct) );
    else
        title( sprintf('C0, n=%d', counter(c_number)) );
    end
end

%%
subplot(p.k+1,p.k+1,1)
ylabel('\muV');


%% plot the unclustered waveforms
subplot(p.k+1, p.k+1, p.k+1);

for ii=1:length(spike_features.vec)
    c_number = spike_features.cluster_num(ii);
    if c_number == p.k+1
        counter(c_number)=counter(c_number)+1;
        clustered_matrix{c_number}(counter(c_number),:)=spike_features.vec{ii};
        plot( spike_features.vec{ii}, 'Color', [.8 .8 .8] );  hold on;
    end
end

wave=mean( clustered_matrix{p.k+1});
plot( wave, 'Color', [.6 .6 .6], 'Linewidth', 2.5); hold on;

% wavelength=length(spike_features.vec{1});

for c_position=1:p.k+1
    subplot(p.k+1,p.k+1, c_position);
    ylim([low high]);
    xlim([0, cols]);
end



%% plot the spike trains

spike_trains = zeros(p.k,spike_features.data_length);

high=1;
low=-1;

for ii=1:length(spike_features.vec)
    c_number = spike_features.cluster_num(ii);
    
    if c_number <= p.k
                
        wave=spike_features.vec{ii};
        spike_trains(c_number, spike_features.vec_idx{ii} ) = wave;
        
        temp=max(wave);
        if high < temp
            high = temp;
        end
        
        temp = min(wave);
        if low > temp
            low=temp;
        end
    end
end


%% plot the k spike trains
for c_number=1:p.k
    
    c_grade= find(spike_features.amp_idx==c_number);
            
    subplot(p.k+1, 1, 1+c_grade)
    tvec=(1:length(spike_trains(c_number,:)))./args.Fs;
    
    plot(tvec(1:end), spike_trains(c_number,1:end), 'Color', my_color(c_grade) );
    hold on;
    %xlim([tvec(spike_features.zeroOutIndex+1) tvec(end)]);
    ylabel('\muV');
    t_str=sprintf('Cluster %d,  channel %d, Thr= %0.1f, MAD=%0.2f', ...
        c_grade, spike_features.chan_num, p.threshold_extra, spike_features.mad);
    
    title(t_str);
    
    ax=gca;
    set(ax, 'fontsize',8);
end

% xt=ax.XTick/args.Fs;
% set(ax, 'xticklabel', xt);
subplot(p.k+1, 1, p.k+1)
xlabel('time (s)');

end