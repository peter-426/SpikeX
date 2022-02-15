% param.m,  see also param_defaults.m
%
% FILTER
% p.filter_order: usually 2 for Butterworth filter
% p.artifact_detect:  number of MADs.
% p.artifact_extend:  number of MADs (artifact extension to adjacent data points).
%
% DETECT
% p.threshold_intra: (MADs) spike amplitude (intracellular spike detection).
% p.threshold_extra: (MADs) spike amplitude (extracellular spike detection).
%
% p.min_width: (time steps) consecutive data points over spike threshold (spike detection).
% p.refractory (ms) time period after spike detection where spikes not possible 
%
% EXTRACT
% p.extraction: 1 wav, 2 pca, or 3 none
% p.offset1: (ms) before max amplitude (waveform extraction).
% p.offset2: (ms) after max amplitude  (waveform extraction).
% p.pc: number of wavelet features to extract (then cluster).
% p.percent: features extracted  percent of variance (then clustered).
%
% CLUSTER
% p.k: number of clusters for kmeans (1 channel)
% p.outlier: max std deviations of any wave pt from centroid wave (eviction from cluster).
%
% TEST for true positives, 
% p.pre_offset:   ms before intracelluar spike time
% p.post_offset;  ms after intracelluar spike time
p.filter_order=2;
p.artifact_detect=15;
p.artifact_extend=10;
p.threshold_intra=10;
p.threshold_extra=-5;
p.min_width=1;
p.refractory=7;
p.extraction=2;
p.offset1=1;
p.offset2=1;
p.pc=3;
p.percent=90;
p.k=3;
p.outlier=3;
p.pre_offset=1;
p.post_offset=1;
