function plot_selected(args)

param;

if get(args.makeFigure, 'Value')
    figure;
end

t_str=sprintf('Data File: %s', args.filename);
t_str = strrep(t_str, '_', ' ');

rows=length(args.chan_vec);
%%
args.chan_num=-1;

if args.intra_chan ~= 0
    spike_struct_gt = get_ground_truth(args);
    %  sum(spike_struct_gt.events);
end


min_amp=1000000;
max_amp=-1000000;

%%
for row_num=1:rows
    
    chan_num=args.chan_vec(row_num);
    
    [~, max_idx, data_struct] = load_data(chan_num, args);
    
    if endsWith(args.filename, 'nwb')
        dvec=data_struct;
        %size(dvec)
    else
        dvec = get_data_vec(data_struct, max_idx, args);
    end
    
    [dvec,args] = preprocess_data(dvec, chan_num, args);  % <<<<<<<<<<<<<<<<<<<
   
    total_time = length(dvec)/args.Fs;    
    tvec = linspace(0, total_time, length(dvec) );
    
    if chan_num ~= args.intra_chan
        temp=max(dvec);
        if max_amp < temp
            max_amp=temp;
        end
        temp=min(dvec);
        if min_amp > temp
            min_amp =temp;
        end  
    end
        
     
    %%
    subplot(rows,1,row_num);
    plot(tvec, dvec); hold on;
    % xlim([tvec(1), tvec(end)]);
    
    args.chan_num=chan_num;
    spike_struct = detect_spikes(dvec, args);
    
    results.tp=0;
    results.fp=0;
    results.fn=0;
    % do if intra channel is present
    if args.intra_chan ~= 0
        results = test_spike_detection(spike_struct_gt, spike_struct, args);
    end
   
    % show threshold
    if args.filter_data_CB         % && chan_num ~= args.intra_chan
        temp=zeros(1, length(tvec))+spike_struct.thr;
        plot( tvec, temp, 'k');
    end
    
    % show spike indicators
     if args.filter_data_CB        % && chan_num ~= args.intra_chan
        for sp=1:length(tvec)
            if spike_struct.events(sp) == 1
                plot( tvec(sp), spike_struct.thr, 'r.');
            end
        end
     end
     
    startTime  = tvec(1);
    endTime    = tvec(end);
    timePeriod = endTime-startTime;
    
    dat1=sprintf('Chan %d, spikes %d,  %0.1f Hz, ', chan_num, spike_struct.count, spike_struct.count/timePeriod);
    
    if args.chan_num == args.intra_chan
        temp=p.threshold_intra;
    else
        temp=p.threshold_extra;
    end
    dat2=sprintf('Th = %0.2f, MAD = %0.2f',temp, args.mad );
%     dat2=sprintf('Th = %0.2f, MAD = %0.2f, TP=%0.2f, FP=%0.2f, FN=%0.2f', ...
%         temp, args.mad, results.tp, results.fp, results.fn);
    legend([dat1, dat2], 'Location', 'Northeast');
    
    
    xlim( [ startTime, endTime ] );
    if row_num == rows
        xlabel('time (s)');
    end
    %ylim( [ -100, 100 ] );
    %ylabel('\muV');
    if row_num==1
        title(t_str);
    end
    
    fprintf('Chan %d: TP=%0.2f, FP=%0.2f, FN=%0.2f \n', ...
        chan_num, results.tp, results.fp, results.fn);
end

for row_num=1:rows
    
    chan_num=args.chan_vec(row_num);
    
    if chan_num ~= args.intra_chan
        subplot(rows,1,row_num);
        ylim([min_amp, max_amp]);
    end
    
end

end
