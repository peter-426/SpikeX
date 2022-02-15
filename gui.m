
function gui(p)

figg=figure('Name','SpikeX', 'NumberTitle','off', 'ResizeFcn',@resizeui, ...
    'MenuBar','None','Visible','off','units','normalized','outerposition',[0.06 0.06 0.90 .90]);

%%
panel1 = uipanel('Parent', figg, 'Units', 'normalized', 'BorderType', 'none', 'Position', [.02 0 1 1]);

panel2 = uipanel('Parent',figg, 'Units', 'pixels');
set(panel2,'Position',[0 15 152 650]);


set(figg,'Visible', 'on');

%%%%%%%%%% Open file, ... File selection will be done as part of each menu choice
mh1   = uimenu(figg,  'Label','File');
mh1a  = uimenu(mh1,'Label','Select',   'Separator','on' );
uimenu(mh1a,'Label','Select Data File', 'Separator','on', 'Accelerator','F', 'Callback',{@select_mat_Callback});

mh3=uimenu(figg,  'Label', 'View',       'Separator','on' );
uimenu(mh3,      'Label', 'Hide Side Panel',    'Separator','on', 'Accelerator', 'H',  'Callback', @hide_Callback);

mh2   = uimenu(figg,  'Label','Simple Plot');
uimenu(mh2,'Label','Plot Channels',                        'Separator','on', 'Accelerator', 'P', 'Callback',{@plot_selected_Callback});
uimenu(mh2,'Label','Plot IC and EC Spikes', 'Separator','on', 'Accelerator', 'I', 'Callback',{@plot_intra_extra_spikes_Callback});
uimenu(mh2,'Label','Plot Ground Truth Spikes',             'Separator','on', 'Accelerator', 'J', 'Callback',{@plot_GT_spikes_Callback});
uimenu(mh2,'Label','Plot Intracelluar Spikes NN',          'Separator','on', 'Accelerator', 'K', 'Callback',{@plot_intra_spikes_neural_net_Callback});

% spike sorted
mh5   = uimenu(figg,  'Label','Spike Sort 1 Channel');
uimenu(mh5,'Label','Spike sort 1',      'Accelerator', 'S', 'Separator','on', 'Callback',{@spike_sort_1_channel_Callback});
uimenu(mh5,'Label','Spike trains of k waveforms', 'Accelerator', 'T', 'Separator','on', 'Callback',{@plot_clustered_trains_Callback});

mh6   = uimenu(figg,  'Label', 'Spike Sort N Channels');
uimenu(mh6,'Label', 'Spike sort N channels',  'Accelerator', 'U', 'Separator','on', 'Callback',{@spike_sort_n_channels_Callback});

mh7   = uimenu(figg,  'Label', 'Spike Sort Tetrode');
uimenu(mh7,'Label', 'Spike sort tetrode',  'Accelerator', 'V', 'Separator','on', 'Callback',{@spike_sort_tetrode_Callback});


%%  Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%
mh8=uimenu(figg,  'Label', 'Parameters',        'Separator', 'on' );
uimenu(mh8,       'Label', 'Change parameters', 'Separator', 'on', 'Callback', @update_parameters_Callback);

mh9=uimenu(figg,  'Label', 'Quit', 'Separator', 'on' );
uimenu(mh9,       'Label', 'Save Filter Settings and Quit', 'Separator', 'on', 'Callback', @exit_Callback);

args.makeFigure  = uicontrol(panel2,  'Style','checkbox', 'String', 'Figure',   'Position',[1,575,100,15] );
% args.verbose = uicontrol(panel2,  'Style','checkbox', 'String', 'Verbose',  'Position',[1,545,100,15] );

textBoxFile = uicontrol(panel2, 'Style','edit','String','File:', 'Position',[5 520 145 14],...
    'BackgroundColor',[.7 .7 .9]);
uicontrol(panel2, 'Style','edit','String','Data length (s)', 'Position',       [5 498 145 14],...
    'BackgroundColor',[.7 .7 .9]);
textBoxDataLength = uicontrol(panel2, 'Style','edit','String','             ', 'Position',[5 475 145 14], ...
    'BackgroundColor',[.7 .7 .9]);

uicontrol(panel2,  'Style','text','String','Range',            'Position',[5,452,90,15], 'HorizontalAlignment','left');
uicontrol(panel2,  'Style','text','String','Start (s)',        'Position',[5,435,45,15], 'HorizontalAlignment','left');
textBoxStart = uicontrol(panel2, 'Style','edit','String','0',  'Position',[50 435 65 15]);
%set(textBoxStart, 'enable', 'off')

uicontrol(panel2,  'Style','text','String', 'End (s)','Position',[5,415,45,15], 'HorizontalAlignment','left')
textBoxEnd = uicontrol(panel2, 'Style','edit', 'String','2','Position',[50 415 65 15]);

filterCheckbox(1)=uicontrol(panel2, 'Style', 'checkbox', 'String', 'FIR 50Hz stop',    'Value', 0, 'Position',[1,390,95,20]);
filterCheckbox(2)=uicontrol(panel2, 'Style', 'checkbox', 'String', 'Remove artifacts', 'Value', 1, 'Position',[1,370,155,20]);
filterCheckbox(3)=uicontrol(panel2, 'Style', 'checkbox', 'String', 'Filter data',      'Value', 1, 'Position',[1,350,75,20]);

% low, high
% uicontrol(panel2,  'Style','text','String','Response type','Position',     [ 1,330,100,20 ]);
responseTypePopup = uicontrol(panel2, 'Style', 'popup','String', {'low', 'high', 'bandpass', 'stop' }, 'Position', [ 75,350,70,20 ], 'Value', 3 );

uicontrol(panel2,  'Style','text','String', 'Sampling Rate','Position',[1,330,70,15], 'HorizontalAlignment','left')
sampF_TB = uicontrol(panel2, 'Style','edit', 'String','0','Position',  [75 330 65 15]);

uicontrol(panel2,       'Style','text','String','Frequency A','Position', [ 1 310 70 15], 'HorizontalAlignment','left');
fcA_TB = uicontrol(panel2, 'Style','edit','String', 300, 'Position',      [75 310 65 15]);  % fset.fcA

uicontrol(panel2,  'Style','text','String','Frequency B','Position',  [ 1 290 70 15], 'HorizontalAlignment','left');
fcB_TB = uicontrol(panel2, 'Style','edit','String', 3000, 'Position', [75 290 65 15]);  % fset.fcB

% for datasets with ground truth recorded on a channel
uicontrol(panel2,  'Style','text','String','Intracellular chan','Position', [ 1 270 90 15], 'HorizontalAlignment','left');
intra_chan_TB = uicontrol(panel2, 'Style','edit','String', 0, 'Position',   [95 270 45 15]);  % intracellular ch?

msg_TB        = uicontrol(panel2, 'Style','edit','String','messages', 'Position',[5 236 120 14], 'BackgroundColor',[.7 .7 .9]);

uicontrol(panel2,  'Style','checkbox', 'Position',[130,235,21,13], 'Callback', @channel_buttons );
% guidata(panel2,  handles);
build_buttons();
drawnow();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% make channel selection buttons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function channel_buttons(h,~)
        tb=findall(gcf, 'Type', 'uicontrol');
        
        if isempty(tb) == 0
            for ii=1:length(tb)
                if strcmp(tb(ii).Style, 'togglebutton')
                    
                    if h.Value == 1
                        tb(ii).BackgroundColor = 'g';
                        tb(ii).Value = 1;
                        
                        str=str2double( char( tb(ii).String ) );
                        selected_mapObj_channels(str)=str;
                    else
                        tb(ii).BackgroundColor = [.94 .94 .94];
                        tb(ii).Value = 0;
                        
                        str=str2double( char( tb(ii).String ) );
                        remove(selected_mapObj_channels, str);
                    end
                end
            end
        end
    end

selected_mapObj_channels=containers.Map('KeyType','double','ValueType','double');

    function build_buttons()
        
        tb=findall(gcf, 'Type', 'uicontrol');
        
        if isempty(tb) == 0
            for ii=1:length(tb)
                if strcmp(tb(ii).Style, 'togglebutton')
                    delete(tb(ii));
                end
            end
        end
        row=4;  col = 1;  side=18;  h=zeros(1,16);
        
        for ii=1:64
            xx= -14+(side * col);  
            yy= 143+(side * row);
            
            chan_num=num2str(ii);
            
            h(ii)=uicontrol(panel2, 'Style', 'togglebutton',...
                'String', { chan_num  },...
                'Position', [xx yy side side],...
                'Value', 0, 'FontSize', 5, ..., ...
                'Callback', @setmap);
            
            if mod(ii,8) == 0
                row=row-1;
                col=1;
            else
                col=col+1;
            end
        end
    end

    function setmap(a,~)
        val=get(a, 'Value');
        str=get(a, 'String');
        str=str2double(char(str));
        
        if val == 1
            selected_mapObj_channels(str)=str;
            set(a, 'BackgroundColor', 'g');
        else
            set(a, 'BackgroundColor', [.94 .94 .94]);
            remove(selected_mapObj_channels, str);
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function update_parameters_Callback(~,~)
        % Note: param file is 'param.m', defaults are in 'param_defaults.m';
        param_gui( );
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function select_mat_Callback(~,~)
        
        set_args();
        
        if args.Fs <= 0
            msgbox('Please set sampling rate');
            return;
        end
        
        temp='*.mat;*.dat;*.nwb';
        ff=fullfile(pathname, temp);
        [filename, temp_pathname] = uigetfile( ff,'Select data file (*.mat;*.dat).');
        
        
        if filename ~= 0
            pathname = temp_pathname;       %success, so remember the folder for next time     
            args.data_file=fullfile(pathname, filename);
            args.filename=filename;
            set(textBoxFile, 'String', filename, 'BackgroundColor',[.7 .9 .9]);
            chan_num=1;   % just getting length, so use chan num 1
            [max_time, max_idx, ~] = load_data(chan_num,args);
            data_length = sprintf('%0.2f', max_time);
            set(textBoxDataLength, 'String', data_length, 'BackgroundColor',[.7 .9 .9]);
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function resizeui(~,~)
        
        pos=get(gcf, 'Position');     %  gives x left, y bottom, width, heigh
        
        hhh=15;
        
        if (pos(4) > 1)
            hhh= 15 + ((pos(4)-1)*600);
        end
        %position = getpixelposition(panel1)
        set(panel2,'Position', [0 hhh 150 650]);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  plot data

    function plot_selected_Callback(~,~)
        
        if ~isfile(args.data_file)
            msgbox('Please select data file.');
            return;
        end
        
        set_args( );
        
        if args.intra_chan==0
            msgbox('Please set intracellular chan number.');
            return;
        end
        
        set(msg_TB, 'String', 'Working', 'BackgroundColor',[.7 .2 .2]);
        drawnow();
        ax=findall(gcf, 'type', 'axes');
        delete(ax);
        
        args.chan_vec=get_chan_vec(selected_mapObj_channels);
        
        if isempty(args.chan_vec)
            msgbox('Please select one or more channels.');
        else
            if ~get(args.makeFigure, 'Value')
                subplot(1,1,1, 'Parent', panel1);
            end
            
            plot_selected(args);
        end
        
        set(msg_TB, 'String', ' ', 'BackgroundColor',[.7 .9 .7]);
        drawnow();
    end

%% plot extracted waveforms for selected channels from one expt
%  compare GT versus other EC spike waveforms
%
    function plot_intra_extra_spikes_Callback(~,~)
        
        if ~isfile(args.data_file)
            msgbox('Please select data file.');
            return;
        end
        
        if args.intra_chan==0
            msgbox('Please set intracellular chan number.');
            return;
        end
        
        set(msg_TB, 'String', 'Working', 'BackgroundColor',[.7 .2 .2]);
        drawnow();
        ax=findall(gcf, 'type', 'axes');
        delete(ax);
        set_args( );
        args.chan_vec=get_chan_vec(selected_mapObj_channels);
        
        if isempty(args.chan_vec)
            msgbox('Please select one or more channels.');
        else
            if ~get(args.makeFigure, 'Value')
                subplot(1,1,1, 'Parent', panel1);
            end
            
            plot_intra_v_extra_spikes(args)
        end     
        set(msg_TB, 'String', ' ', 'BackgroundColor',[.7 .9 .7]);
        drawnow();
    end


%% plot GT spikes
   function plot_GT_spikes_Callback(~,~)
        
        if ~isfile(args.data_file)
            msgbox('Please select data file.');
            return;
        end
        
        set(msg_TB, 'String', 'Working', 'BackgroundColor',[.7 .2 .2]);
        drawnow();
        ax=findall(gcf, 'type', 'axes');
        delete(ax);
        set_args( );
        args.chan_vec=get_chan_vec(selected_mapObj_channels);
        
        if isempty(args.chan_vec)
            msgbox('Please select one or more channels.');
        else
            if ~get(args.makeFigure, 'Value')
                subplot(1,1,1, 'Parent', panel1);
            end
            args.chan_num=args.intra_chan;
            plot_intra_spikes(args);    % IC spike times are GT spike times
        end
        
        set(msg_TB, 'String', ' ', 'BackgroundColor',[.7 .9 .7]);
        drawnow();
   end

%%
   function plot_intra_spikes_neural_net_Callback(~,~)
        
        if ~isfile(args.data_file)
            msgbox('Please select data file.');
            return;
        end
        
        set(msg_TB, 'String', 'Working', 'BackgroundColor',[.7 .2 .2]);
        drawnow();
        ax=findall(gcf, 'type', 'axes');
        delete(ax);
        set_args( );
        args.chan_vec=get_chan_vec(selected_mapObj_channels);
        
        args.intra_chan = 6;
        args.chan_num=6;

        if isempty(args.chan_vec) || length(args.chan_vec) ~= 4
            msgbox('Please select 4 extracellular channels.');
        else
            if ~get(args.makeFigure, 'Value')
                subplot(1,1,1, 'Parent', panel1);
            end
            args.chan_num=args.intra_chan;
            args.cmd_line=false;
            args.neurons=10;
            
            fprintf('using chan %d for intra channel.\n',   args.intra_chan);
            fprintf('using %d neurons for hidden layer.\n', args.neurons);
            
            plot_intra_spikes_neural_net(args);
        end
        
        set(msg_TB, 'String', ' ', 'BackgroundColor',[.7 .9 .7]);
        drawnow();
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Menu: spike sorting 1 channel

spike_features=cell(1,1);
spike_features{1}.amp_idx=[];
spike_features{1}.vec=[];



    function spike_sort_1_channel_Callback(~,~,~)
        
        if ~isfile(args.data_file)
            msgbox('Please select data file.');
        end
        
        ax=findall(gcf, 'type', 'axes');
        delete(ax);
       
        chan_num=get_chan(selected_mapObj_channels);  
        
        if isempty(chan_num)
            msgbox('Please select one channel.');
            set(msg_TB, 'String', '  ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
            return
        end
        
        set(msg_TB, 'String', 'Working', 'BackgroundColor',[.7 .2 .2]);  drawnow();
        
        set_args( );
                          
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        args.chan_num=chan_num;
        spike_features{chan_num}=extract_spikes(chan_num, args);
        spike_features{chan_num}=sort_spikes_1_channel(spike_features{chan_num}, args );
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
        
        if ~isfield( spike_features{chan_num}, 'cluster_num')
            msgbox('No spikes.');
        elseif isempty(spike_features{chan_num}.cluster_num)
            msgbox('cluster number is empty. Not clustered.');            
        else
            if ~get(args.makeFigure, 'Value')
                subplot(1,1,1, 'Parent', panel1);
            end
            spike_features{chan_num} = plot_clusters_1(spike_features{chan_num}, args);
        end
        
        set(msg_TB, 'String', '  ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
    end

    %% plot_clustered_trains_Callback: split into spike trains
    % This fx assumes that the selected channel has already been sorted.
    %
    function plot_clustered_trains_Callback(~,~,~)
        
        chan=get_chan(selected_mapObj_channels);
        if isempty(chan)
            msgbox('Please select one channel.');
            set(msg_TB, 'String', '  ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
            return
        end
        
        % reset spike_features to 1 empty cell
        if ~iscell(spike_features)
            spike_features = cell(1,1);
        end

        if ~isfield(spike_features{chan}, 'cluster_num')
            msgbox('Must spike sort this channel first.');
            set(msg_TB, 'String', '   ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
            return;
        end
        
        if ~isfield(spike_features{chan}, 'vec')
            msgbox('Must spike sort this channel first.');
            set(msg_TB, 'String', '   ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
            return;
        end
        
        ax=findall(gcf, 'type', 'axes');
        delete(ax);
        
        set(msg_TB, 'String', 'Working', 'BackgroundColor',[.7 .2 .2]);
        drawnow();
        set_args( );
        
        if p.k < 1
            msgbox('Parameter p.k must be >= 1');
            set(msg_TB, 'String', '   ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
            return
        end         
             
        if ~get(args.makeFigure, 'Value')
            subplot(1,1,1, 'Parent', panel1);
        end
        % split signal into p.k spike trains 
        plot_clustered_trains(spike_features{chan}, args.makeFigure, args);

        set(msg_TB, 'String', '   ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
    end

%%
   function spike_sort_n_channels_Callback(~,~,~)
        
        if ~isfile(args.data_file)
            msgbox('Please select data file.');
        end
        
        ax=findall(gcf, 'type', 'axes');
        delete(ax);
       
        chan_list=get_chan_vec(selected_mapObj_channels);
        
        if isempty(chan_list)
            msgbox('Please select up to 4 EC channels.');
            set(msg_TB, 'String', '  ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
            return
        end
        
        if length(chan_list) > 4
            msgbox('Please select up to 4 EC channels.');
            set(msg_TB, 'String', '  ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
            return
        end
        
        set(msg_TB, 'String', 'Working', 'BackgroundColor',[.7 .2 .2]);  drawnow();
        set_args( );
                   
  
        success=false;
        
        % for each selected EC channel, extract all detected spikes
        for ii=1:length(chan_list)
            chan_num=chan_list(ii);
            args.chan_num=chan_num;
            spike_features_n{ii}=extract_spikes(chan_num, args);
            spike_features_n{ii}=sort_spikes_1_channel( spike_features_n{ii},args );
            spike_features_n{ii}.chan_num=chan_num;
            
            if isfield(spike_features_n{ii}, 'vec') % got spikes?
                success=true;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if success == true
            if ~get(args.makeFigure, 'Value')
                subplot(1,1,1, 'Parent', panel1);
            end
         
            spike_features_n = plot_clusters_n_channels(spike_features_n, chan_list, args);
        else
            msgbox('No spikes.');
        end
        
        set(msg_TB, 'String', '  ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
   end

%%
   function spike_sort_tetrode_Callback(~,~,~)
        
        if ~isfile(args.data_file)
            msgbox('Please select data file.');
        end
        ax=findall(gcf, 'type', 'axes');
        delete(ax);
        chan_list=get_chan_vec(selected_mapObj_channels);
        if isempty(chan_list) || length(chan_list) < 4
            msgbox('Please select 4 channels, e.g. 2,3,4,5.');
            set(msg_TB, 'String', '  ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
            return
        end
        set(msg_TB, 'String', 'Working', 'BackgroundColor',[.7 .2 .2]);  drawnow();
        set_args( );
        success=false;
        
        spike_features_tet={};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for ii=1:length(chan_list)
            chan_num=chan_list(ii);
            args.chan_num=chan_num;
            spike_features_n{ii}=extract_spikes(chan_num, args);
            spike_features_n{ii}.chan_num=chan_num;
                      
            if isfield(spike_features_n{ii}, 'vec') % got spikes?
                success=true;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        spike_features_tet{1}=sort_spikes_tetrode( spike_features_n,args );

  
        if success == true
            if ~get(args.makeFigure, 'Value')
                subplot(1,1,1, 'Parent', panel1);
            end
            
            if args.intra_chan ~= 0
                args.spike_struct_gt = get_ground_truth(args);
            end
         
            plot_tetrode(spike_features_tet, chan_list, args);
        else
            msgbox('No spikes.');
        end
        
        set(msg_TB, 'String', '  ', 'BackgroundColor',[.7 .9 .7]);  drawnow();
   end

%%
    function hide_Callback(~,~)
        
        if strcmp(panel2.Visible, 'on')
            set(panel2, 'Visible', 'off');
        else
            set(panel2, 'Visible', 'on');
        end
    end

%%
pathname='.';    % used to open files in last used folder
%
%
args.datasetname='/acquisition/timeseries/recording1/continuous/processor102_100/data';

args.Fs= str2double( get(sampF_TB, 'String'));
args.fc1= str2double( get(fcA_TB, 'String'));
args.fc2= str2double( get(fcB_TB, 'String'));
args.intra_chan = str2double( get(intra_chan_TB, 'String'));

args.filter_50_hum_CB    = get(filterCheckbox(1), 'Value');
args.filter_artifacts_CB = get(filterCheckbox(2), 'Value');
args.filter_data_CB      = get(filterCheckbox(3), 'Value');

temp   =get(responseTypePopup, 'String');
tempVal=get(responseTypePopup, 'Value');
args.response_type=temp{tempVal};

args.designType = 'butter';
args.data_file='';
args.filename='';
% args.figtitle = sgtitle(' ');

%%
    function set_args()
        clear param;
        param;
        refresh;
        figtitle('SpikeX');
        datasetname='/acquisition/timeseries/recording1/continuous/processor102_100/data';
        args.Fs= str2double( get(sampF_TB, 'String'));
        args.fc1= str2double( get(fcA_TB, 'String'));
        args.fc2= str2double( get(fcB_TB, 'String'));
        args.intra_chan = str2double( get(intra_chan_TB, 'String'));
        
        args.filter_50_hum_CB    = get(filterCheckbox(1), 'Value');
        args.filter_artifacts_CB = get(filterCheckbox(2), 'Value');
        args.filter_data_CB      = get(filterCheckbox(3), 'Value');
        
        temp   =get(responseTypePopup, 'String');
        tempVal=get(responseTypePopup, 'Value');
        args.response_type= temp{tempVal};
        args.designType  = 'butter';
        
        args.data_struct=[];
      
        args.start = 1+str2double(get(textBoxStart, 'String')) *args.Fs;
        args.end   = str2double(get(textBoxEnd,   'String'))   *args.Fs;
        if args.end > args.start
            args.seconds = (args.end - args.start)/args.Fs;    % duration
        else
            args.seconds=0;
        end
    end


%% save state, i.e. filter settings
    function exit_Callback(~,~)
        fcA_TB = get(fcA_TB, 'String');
        fcB_TB = get(fcB_TB, 'String');
        
        line1=sprintf('fset.fcA=%s;\n', fcA_TB );
        line2=sprintf('fset.fcB=%s;\n', fcB_TB );
        
        fid=fopen('filter_settings.m','w');
        fprintf(fid, line1);
        fprintf(fid, line2);
        
        fclose(fid);
        
        close all force;
    end
end

