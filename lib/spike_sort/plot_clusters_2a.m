function plot_clusters_2a(makeFigure, spike_features, args)

param;

rate=round(args.Fs/1000);  % steps per ms

ss = get(0,'ScreenSize');            % get screen size
pos1 = [ss(3), ss(4),  1200, 900] .* [ .1  .1   1  1];

if get(makeFigure, 'Value')
    fig=figure('NumberTitle','off', 'OuterPosition', pos1, 'Visible', 'off');
    set(fig,'Visible', 'on');
end


%%  plot k waveforms

count=zeros(1, p.k+1);
cols=length(spike_features.vec{1});
clustered_matrix={p.k};

for ii=1:p.k
    rows=sum(spike_features.cluster_num == ii);
    clustered_matrix{ii} = zeros(rows,cols);
end

for ii=1:length(spike_features.vec)
    cn = spike_features.cluster_num(ii);
    count(cn)=count(cn)+1;
    clustered_matrix{cn}(count(cn),:)=spike_features.vec{ii};
    
%     subplot(7,7,cn);
%     plot( spike_features.vec{ii}, 'Color', gray );  hold on;
end

low=10000; high=-10000;

tot=sum(count(1:p.k));

for cn=1:p.k
    subplot(7,7,cn);
    
    [rows, cols]=size(clustered_matrix{cn});
    if rows > 1
        wave = mean( clustered_matrix{cn});
    else
        wave = clustered_matrix{cn};
    end
    
    temp=min(wave);
    if low > temp
        low=temp;
    end
    temp=max(wave);   
    if high < temp
        high=temp;
    end
    
    plot( wave, 'Color', my_color(cn), 'Linewidth', 2.5); hold on;
    
    xlim([0, length(wave)]);
    
    set(gca,'fontsize',10);
    if cn == 1
        ylabel('\muV')
    end
    
    if cn > 1
        set(gca, 'ytick', []);
    end 
    %set(gca, 'xtick', []);
    xlabel('time steps');

    
    fprintf('cluster cn=%d: count = %d  tot=%d\n', cn, count(cn),tot);
    
    pct=100 * count(cn)/tot;
%     ti=sprintf('C%d: n=%d, pct=%0.2f%%', cn, count(cn), pct );
    ti=sprintf('C%d: n=%d', cn, count(cn) );
    title(ti);
end


subplot(15,10,31:150);

evokedCounts =zeros(1,p.k);
baselineCounts=zeros(1,p.k);


spike_counts=cell(3,1);

for ii=1:p.k
spike_counts{ii}=tvec .* 0;
end

num_stims = length(spike_features.stim_indices);
seconds = spike_features.length_of_trial * num_stims;

if num_stims < spike_features.max_idx
    num_stims = num_stims - 1;
end

fprintf('length of trials: %0.1f \n\n', spike_features.length_of_trial); 


current_stim=1;

for ii=1:length(spike_features.vec)
    cn = spike_features.cluster_num(ii);
    if cn > p.k                           % unclustered waveform
        continue;  
    end
    
    xx=spike_features.idx0(ii);
    
    for yy=current_stim:num_stims  % because don't want pre stim only
        
        dist = xx - spike_features.stim_indices(yy);
        
        if dist > 0 && dist <  max_idx2
            
            % fprintf('\n  >>  stim time: %d\n', round(spike_features.stim_indices(yy)/args.Fs));
            
            if dist > 0  && dist <= max_idx1
                evokedCounts(cn) = evokedCounts(cn) + 1;
            end
            
            if  dist > max_idx1 && dist < max_idx2
                baselineCounts(cn) = baselineCounts(cn) + 1;
            end
            
            my_idx=spike_features.stim_indices(yy); %  - round(stim_time * args.Fs);

            spike_counts{cn}( 1 + xx - my_idx ) = spike_counts{cn}( 1 + xx - my_idx ) + 1;
   
            ydt1=(p.k-cn+1)/(p.k+1);
            ydt0=(p.k-cn)/(p.k+1);
            line([dist dist], [yy-1+ydt0  yy-1+ydt1], 'Color', my_color(cn)); hold on;
            current_stim=yy;
            break
        end
    end
end
grid on;
ylim([0, num_stims]);
line([0 0], [0 num_stims], 'Color', [0,0,0]); hold on;

xlim([0 max_idx2]);
ax=gca;
xt=get(ax, 'xtick');
set(ax, 'xticklabel', round(xt./args.Fs));

xt=get(ax, 'ytick');
set(ax, 'yticklabel', xt);

xlabel('time (s)');
ylabel('trial number');

set(gca,'fontsize',10);


%%  stats 


% convert counts to Hz
evokedHz   =  evokedCounts/(num_stims    * stim_time);
baselineHz =  baselineCounts/(num_stims * base_time);

preHz  = sum(evokedCounts) /(num_stims  * stim_time);
postHz = sum(baselineCounts)/(num_stims * base_time);


subplot(11,10,8)

b=bar([evokedHz; baselineHz]);
ylim([ 0 max( [evokedHz baselineHz] ) ]);
xlim([0.5 2.5]);
for cn=1:p.k
    b(cn).FaceColor =  my_color(cn);
    b(cn).FaceColor =  my_color(cn);
    b(cn).FaceColor =  my_color(cn);
end

t_str = sprintf('\\fontsize{10}Elec %d: spike rates', spike_features.chan_num);
title(t_str);

set(gca,'fontsize',10)
set(gca, 'XTick', []);
ylabel('Hz');
xl=sprintf('\\fontsize{10}%d s stim; %d s post',  stim_time, base_time);
xlabel(xl);


subplot(11,10,10)

bar( [preHz; postHz] );
t_str = sprintf('\\fontsize{10}Elec %d:  spike rates', spike_features.chan_num);
title(t_str);

set(gca,'fontsize',10)
set(gca, 'XTick', []);
ylabel('Hz');
xl=sprintf('\\fontsize{10}%d s stim; %d sec post',  stim_time, base_time);
xlabel(xl);

t_str = sprintf('\\fontsize{12}Spike Trains:  %s animal, channel %d, trials 1 to %d',...
    args.age_group, spike_features.chan_num, num_stims);
mtit(t_str, 'xoff',0,'yoff',.045);


%% convolve with a gaussian window, e.g. 100 ms wide
pos1 = [ss(3), ss(4),  1200, 900] .* [ .1  .1   1  1];

fig=figure('NumberTitle','off', 'OuterPosition', pos1, 'Visible', 'off');
set(fig,'Visible', 'on');

tvec=tvec/args.Fs;

g_window=0.100;

maximum=0;

for cn=1:p.k
    subplot(p.k, 1, cn);
    
    gau_sdf = conv2(spike_counts{cn}(:), gausswin( round( g_window*args.Fs) ), 'same');
    gau_sdf = ((1/g_window) * gau_sdf)/num_stims;
    
    plot(tvec, gau_sdf,'Color', my_color(cn));  hold on;
    
    title(sprintf('cluster %d', cn),'fontsize',10);
    temp=max(gau_sdf);
    if maximum < temp
        maximum=temp;
    end

    xlim([0, tvec(end)]);  
%     ax=gca;
%     xl=ax.XTick - stim_time;
%     set(ax, 'XTickLabel', xl );
    ylabel('Hz');
end
xlabel('time (s)');

for cn=1:p.k
    subplot(p.k, 1, cn);
    ylim([0, maximum]);
end

% strrep(args.filename, '_','\_')

t_str = sprintf('\\fontsize{12}Firing Rates for Experiment %s: %s animal, channel %d, trials 1 to %d',...
    args.experiment_number, args.age_group, spike_features.chan_num, num_stims);
mtit(t_str, 'xoff',0,'yoff',.045);

set(findall(gcf,'-property','FontSize'),'FontSize',12);

end