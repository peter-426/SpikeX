%
%
function spike_features = sort_spikes_1_channel(spike_features, args)

% first
%   wavelet decomposition, or
%   pca, or
%   none (use entire waveform)
% then
%   k means clustering

param;

if ~isfield(spike_features, 'vec')
    spike_features=[];
    return;
end

num_spikes=length(spike_features.vec);
len_spike =length(spike_features.vec{1});

% fprintf('sort_spikes_1_channel count = %d\n', spike_features.count );
% fprintf('sort_spikes_1_channel = %d\n\n', rows);

X=zeros(num_spikes, len_spike);

% spike_features.vec is an array of cells that
% contains the detected waveforms.   

for ii=1:length(spike_features.vec)
    yy=spike_features.vec{ii};
        
    X(ii,:)=yy';
end

%% extraction method set in parameter panel

if p.extraction == 1
    extraction_method='wav';
elseif p.extraction == 2
    extraction_method='pca';
else
    extraction_method='none';
end
    
% p.pc = number of wavelet features to extract for clustering
pct_explained=p.percent;   % pct of variance explained by first PCs

switch extraction_method
    case 'wav'
        % for each spike, do wavelet decomposition
        %    wavelet decomposition vector CW and the
        %    bookkeeping vector L for spike

        cc=zeros(num_spikes, len_spike);
        scales=4;
        
        for i=1:num_spikes              % wavelet decomposition of spikes X
            [CW,L]=wavedec(X(i,:), scales, 'haar');
            cc(i,1:len_spike)=CW(1:len_spike);
        end
        
        
        for i=1:len_spike                  % KS test for coefficient selection
            thr_dist = std(cc(:,i)) * 3;   % ignore features > 3 std from mean
            thr_dist_min = mean(cc(:,i)) - thr_dist;
            thr_dist_max = mean(cc(:,i)) + thr_dist;
            aux = cc(cc(:,i) > thr_dist_min & cc(:,i) < thr_dist_max,i);
            
            if length(aux) > 10
                %[ks_stat]=  ks_test(aux)
                [hypo, p_val, ks_stat, c_val] = kstest(aux); % Matlab's fx
                
                sd(i)=ks_stat;
                %disp(ks_stat)
            else
                sd(i)=0;
            end
        end
        [~, ind]=sort(sd, 'descend');  %put ks_stats in order
        spk_feats = cc(:, ind(1:p.pc) );
        
    case 'pca'
        [coeff, score, L, tsquared, explained, mu] = pca(X(:,:));
        cc=score;
        num_pc = find((cumsum(explained))> pct_explained, 1);
        spk_feats      = zeros(num_spikes, num_pc);
        spk_feats(:,:) = cc(:,1:num_pc);
    case 'none'
        cc = X;
        spk_feats=X;
    otherwise
        disp('sort_spikes_1_channels: no such case \n');
        return  
end


%% p.extraction
% 
if strcmp(extraction_method, 'pca')        
    spike_features.C=coeff;   % ?
    spike_features.S=score;
    spike_features.l=L;       % L;
    spike_features.tsquared=tsquared;
    spike_features.explained=explained;
    spike_features.mu=mu;
end

% kmeans
% idx is a vector of predicted cluster indices corrresponding to the observations in X. 
% C is a 3-by-2 matrix containing the final centroid locations.
%

rng(1); 

% [m, n]=size(S);

if spike_features.chan_num == args.intra_chan
    K=1;
else
    K=p.k;   % careful,  don't clobber p ... e.g. see kstat
end

%% 
% size(spk_feats) something like 273 spikes by 5 features
% centroids:  a k rows by p.pc columns matrix

[c_numbers, centroids, sumd, Dist] = kmeans(spk_feats, K, 'Replicates', 10); % <<<< 10 shd be variable

spike_features.cluster_num=c_numbers(:);

spike_features.kkk=[cc c_numbers];    % vector of cluster numbers in {1,2,3, ... k}

% store the distance of each waveform from its centroid
for ii=1:length(spike_features.cluster_num)
   cn=spike_features.cluster_num(ii);
   spike_features.cluster_dist(ii) = Dist(ii, cn);
end


%%
rng(1);
kmax=7;

% fprintf('running Cluster quality metric\n');
if spike_features.chan_num ~= args.intra_chan
    for k=2:kmax
        [c_numbers, centroids]= kmeans(cc, k, 'Replicates',10);   % <<<< 10 shd be variable
        [SS] = silhouette(cc, c_numbers);
        spike_features.sil(k) = mean(SS);
    end
end


end