function dvec_filtered=filter_50_hum(dvec, args)

% stop band filterType: 100 taps,  50Hz / 10,000 Hz sampling rate.
% [f1 f2] are normalised to the Nyquist frequency.
% 50/5000 = 0.01, f1 and f2 are 0.01 +/- .003

param;

fs     = args.Fs;        % sampling frequency
fc1    = args.fc1-0.3;   % cutoff frequency
fc2    = args.fc1+0.3;
fnorm= [fc1 fc2]/(fs/2);

[b1,a1] = butter(2, fnorm, 'stop');
dvec_filtered = filtfilt(b1, a1, dvec);

end