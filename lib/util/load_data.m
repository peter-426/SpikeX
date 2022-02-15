function [max_time, max_idx, data_vec] = load_data(chan_num, args)

param;
max_time=0;
max_idx=0;
data_vec=[];

% Since we are about to open a new file, close all open
% data files.  Can't change or delete open files.   

fclose('all');

if endsWith(args.data_file, 'mat')
    data_vec = matfile(args.data_file)
    max_idx = length(data_vec.data);
    max_time = max_idx/args.Fs;
elseif endsWith(args.data_file, 'dat')
    try
        data_vec = LoadBinary(args.data_file, chan_num); % channel
        max_idx  = length(data_vec);
        max_time = max_idx/args.Fs;
    catch MException
        msg=sprintf('load_data file: %s', MException.message);
        msgbox(msg);
    end
elseif endsWith(args.data_file, 'nwb')
    try
        % convert to double in case want to filter
        data_len = args.end - args.start;
        % fprintf('load data chan=%d, start=%d, count=%d\n', chan_num, args.start, args.end);
        % stride=3.0;
        
        start = [chan_num args.start];
        count = [1 data_len];  % read from 1 channel (row)
        
%       fprintf('load_data chan_num=%d, start=%d, data len=%d\n', chan_num, args.start, data_len);
         
        data_vec = double(h5read(args.data_file, args.datasetname, start, count ));
        max_idx=length(data_vec);
%         [aa,bb]=size(data_vec);
%         fprintf('rows=%d, cols=%d\n', aa,bb);
        
        info=h5info(args.data_file, args.datasetname);
        max_time = info.Dataspace.Size(2)/args.Fs;
    catch MException
        msg=sprintf('load_data file .nwb: %s', MException.message);
        msgbox(msg);
    end
end
end
