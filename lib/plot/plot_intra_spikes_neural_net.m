function plot_intra_spikes_neural_net(args)

% invoked from GUI
% extracts waveforms at intra spike times for training set
% uses NN to classify the waveforms
% plots waveforms for each channel from one experiment (one *.dat file)

fprintf('plot_intra_spikes_neural_net \n');

param;

if args.cmd_line || get(args.makeFigure, 'Value')
    ss = get(0,'ScreenSize');
    pos1 = ss .* 0.8;
    pos1(1) = pos1(1) + pos1(3)*0.15 ;
    pos1(2) = pos1(2) + pos1(3)*0.1 ;
    figure('NumberTitle','off', 'Visible', 'on', 'OuterPosition', pos1);
    ttt=sprintf('NN Classification: %s GT EC spikes', args.filename);
    sgtitle(ttt);
end


plot_rows=3;
plot_cols=4;

%%

if args.intra_chan ~= 0
    spike_struct_gt = get_ground_truth(args);
    %  sum(spike_struct_gt.events);
end


min_amp=0;
max_amp=0;

plot_num=0;

chan_count=length(args.chan_vec);

inputs=[];
%%
for idx=1:chan_count
    
    chan_num=args.chan_vec(idx);
    
    if chan_num == args.intra_chan
        continue;
    end
    
    [~, max_idx, data_struct] = load_data(chan_num, args);
    
    dvec = get_data_vec(data_struct, max_idx, args);
    
    [dvec,args] = preprocess_data(dvec, chan_num, args);
    
    spike_features = extract_intra_spikes(spike_struct_gt, dvec, chan_num, args);
    
    %%
    plot_num=plot_num+1;
    subplot(plot_rows, plot_cols, plot_num);
    
    num_spikes=length(spike_features.vec);
    spike_len=length(spike_features.vec{1});
    
    spike_matrix=zeros(num_spikes, spike_len);
    
    for spike_num=1:num_spikes
        if min_amp > min( spike_features.vec{spike_num} )
            min_amp =  min( spike_features.vec{spike_num} );
        end
        
        if max_amp < max( spike_features.vec{spike_num} )
            max_amp =  max( spike_features.vec{spike_num} );
        end
        
        plot(spike_features.vec{spike_num}); hold on;
        spike_matrix(spike_num, :)= spike_features.vec{spike_num};
    end
    
    inputs=[inputs, spike_matrix'];
    
    if chan_num ~= args.intra_chan
        mu=mean(spike_matrix);
        plot(mu, 'k', 'Linewidth', 2.0);
    end
    
    if chan_num == args.intra_chan
        true_spike_count=length(spike_features.vec);
        ttt=sprintf('Ch%d, intra spikes=%d', chan_num, true_spike_count);
    else
        ttt=sprintf('Ch%d, GT EC spikes=%d', chan_num, num_spikes);
    end
    
    title(ttt);
    xlim([0, spike_len]);
    ylim([min_amp, max_amp]);
    ylabel('\muV');
    
end

%% For this algorithm, the data must be in column major format such that
% input: each row is a feature, each columns an instance (waveform)
% target: each row is a classification, each column is the correct class
% for the input instance in that column number

%% reformat data
[rows,cols] = size(spike_matrix');

spks1=[1; 0; 0; 0 ];  % four classes
spks2=[0; 1; 0; 0 ];
spks3=[0; 0; 1; 0 ];
spks4=[0; 0; 0; 1 ];


targets = [ repmat(spks1, 1,cols), repmat(spks2, 1,cols), repmat(spks3, 1,cols), repmat(spks4, 1,cols) ];

% https://www.mathworks.com/help/deeplearning/gs/classify-patterns-with-a-neural-network.html

%%
%% https://www.mathworks.com/help/deeplearning/pattern-recognition-and-classification.html
%%
% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.


% Create a Pattern Recognition Network
hiddenLayerSize = args.neurons;  % 20
trainFcn = 'trainscg';           % Scaled conjugate gradient backpropagation.
net = patternnet(hiddenLayerSize, trainFcn);

net.trainParam.showWindow = false;
% net.trainParam.  % tab to show fields

% Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio   = 15/100;
net.divideParam.testRatio  = 15/100;

size(inputs)
size(targets)

% Train the Network
[net,tr] = train(net,inputs,targets);

% Test the Network
y1 = net(inputs);
target_ind = vec2ind(targets);
pred_ind   = vec2ind(y1);
percent_errors = sum(target_ind ~= pred_ind)/numel(target_ind) * 100;
ttt_pct=sprintf('Overall pct correct: %0.3f\n', 100-percent_errors);

fprintf(ttt_pct);

% e = gsubtract(targets,y1);   % subtract target from predicted
% MSE=mean((e(:).^2))
% performance = perform(net,t,y);
% classes = vec2ind(y);

% View the Network diagram
if args.cmd_line == true
    view(net)
end

%% Plots

plot_num=plot_num+1;
subplot(plot_rows,plot_cols, plot_num);
p_vec= make_p_vec(y1,1, num_spikes);
b=bar(p_vec, 'Linewidth', 3);  hold on;
b.FaceColor = 'flat';
b.CData(1,:) = [.5 0 .5];
xlabel('class');
ylabel('probability');
ylim([0, 1]);
chan_num=args.chan_vec(1);
ttt=sprintf('ch%d true: mean p', chan_num);
title(ttt);
grid on;
if args.cmd_line == false
    disp(p_vec);
end
% text(10, 10, ttt_pct);


plot_num=plot_num+1;
subplot(plot_rows,plot_cols, plot_num);
p_vec= make_p_vec(y1,2, num_spikes);
b=bar(p_vec, 'Linewidth', 3);
b.FaceColor = 'flat';
b.CData(2,:) = [.5 0 .5];
xlabel('class');
ylabel('probability');
ylim([0, 1]);
chan_num=args.chan_vec(2);
ttt=sprintf('ch%d true: mean p', chan_num);
title(ttt);
grid on;
if args.cmd_line == false
    disp(p_vec);
end

plot_num=plot_num+1;
subplot(plot_rows,plot_cols, plot_num);
p_vec= make_p_vec(y1,3, num_spikes);
b=bar(p_vec, 'Linewidth', 3);
b.FaceColor = 'flat';
b.CData(3,:) = [.5 0 .5];
xlabel('class');
ylabel('probability');
ylim([0, 1]);
chan_num=args.chan_vec(3);
ttt=sprintf('ch%d true: mean p', chan_num);
title(ttt);
grid on;
if args.cmd_line == false
    disp(p_vec);
end

plot_num=plot_num+1;
subplot(plot_rows,plot_cols, plot_num);
p_vec= make_p_vec(y1,4, num_spikes);
b=bar(p_vec, 'Linewidth', 3);
b.FaceColor = 'flat';
b.CData(4,:) = [.5 0 .5];
xlabel('class');
ylabel('probability');
ylim([0, 1]);
chan_num=args.chan_vec(4);
ttt=sprintf('Ch%d true: mean p', chan_num);
title(ttt);
grid on;
if args.cmd_line == false
    disp(p_vec);
end

%%%%  confusion matrix shows the percent error on the test set in
%     lower right corner

if args.cmd_line == true
    %     figure, plotperform(tr);
    %     figure, plottrainstate(tr);
    figure, plotconfusion(targets,y1);
    figure, plotconfusion(unseen_test_set_targets,y2);
    %     figure, ploterrhist(e);
    %     figure, plotroc(t,y);
end


% net = feedforwardnet(10);
% [net,tr] = train(net,inputs,targets);
%
% output = net(inputs(1,:))


end
