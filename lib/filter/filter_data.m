% Butterworth 2nd order (typical),  IIR parameters: low/high, cutoff freq

function dvec_filtered=filter_data(dvec, args)

param;

if strcmp(args.designType, 'butter' ) && strcmp(args.response_type, 'low') || strcmp(args.response_type, 'high' )
    
    fs    = args.Fs;            % sampling frequency
    fc1   = args.fc1;        % cutoff frequency
    fnorm = fc1/(fs/2);      % normalized cutoff frequency
    
    [b1,a1] = butter(p.filter_order,fnorm, args.response_type);    % 2=2nd order, ..., low/high pass
%     h=fdatoolButter;
%     h.sosMatrix
%     h.ScaleValues
    dvec_filtered = filtfilt(b1, a1, dvec);
    
elseif  strcmp(args.designType, 'butter' ) && strcmp(args.response_type, 'bandpass' )
    
    fs  = args.Fs;   % Sampling Frequency
    fc1 = args.fc1;  % First Cutoff Frequency
    fc2 = args.fc2;  % Second Cutoff Frequency
    
    fnorm = [fc1 fc2]/(fs/2);
    if fnorm(1) <= 0
        fnorm(1) = 0.01;
        disp('Filter boundary check: Frequency A too low');
    end
    
    if fnorm(2) >= 1
        fnorm(2) = 0.99;
        disp('Filter boundary check: Frequency B too high');
    end
    
    [b1,a1] = butter(2,fnorm, 'bandpass');     % 2nd order, ..., low/high pass
  
    dvec_filtered = filtfilt(b1, a1, dvec);

elseif  strcmp(args.designType, 'butter' ) && strcmp(args.response_type, 'stop' )
    fs  = args.Fs;      % Sampling Frequency
    fc1 = args.fc1;  % First Cutoff Frequency
    fc2 = args.fc2;  % Second Cutoff Frequency
    
    fnorm= [fc1 fc2]/(fs/2);
    
    [b1,a1] = butter(p.filter_order,fnorm, 'stop');     % 2nd order, ..., low/high pass
    dvec_filtered = filtfilt(b1, a1, dvec);
end

end
