%
%
function spike_features_agg = sort_spikes_tetrode(spike_features,args)

% wavelet decomposition
% pca
% k means clustering

param;

if ~isfield(spike_features{1}, 'vec')
    spike_features=[];
    return;
end

% spike_features
% 
% return;

num_channels = length(spike_features);

len_spike=length(spike_features{1}.vec{1});
num_spikes=0;
for ii = 1:num_channels
    num_spikes=num_spikes+length(spike_features{ii}.vec);
end

% fprintf('sort_spikes_tetrode count = %d\n', spike_features.count );
% fprintf('sort_spikes_tetrode = %d\n\n', rows);

X=zeros(num_spikes, len_spike);

% spike_features.vec is an array of cells that
% contains the detected waveforms.   

% aggregate waveforms into one group and reformat for clustering
spike_features_agg.vec={};
spike_features_agg.chan_vec=[];
spike_count=0;

for hh=1:num_channels
    for ii=1:length(spike_features{hh}.vec)
        spike_count=spike_count+1;
        yy=spike_features{hh}.vec{ii};
        spike_features_agg.vec{spike_count}=yy;
        spike_features_agg.chan_vec(spike_count)=spike_features{hh}.chan_num;
        
        X(spike_count,:)=yy';
    end
end


% do_wavelets=false;
% 
% if do_wavelets==true
%     % for each spike, do wavelet decomposition
%     %    wavelet decomposition vector CW and the
%     %    bookkeeping vector L for spike
%     scales=4;
%     
%     for ii=1:rows
%         [CW, L]=wavedec(X(ii,:),scales,'haar');
%         cc(ii,1:cols)=CW(1:cols);
%     end
%     
%     % do principal components analysis on the
%     % on the coefficients for each waveform
%     [C, S, l, tsquared, explained, mu] = pca(cc);
% else
%     [C, S, l, tsquared, explained, mu] = pca(X(:,:));
% end
% 
% 
% 
% spike_features_agg.C=C;
% spike_features_agg.S=S;
% spike_features_agg.l=l;
% spike_features_agg.tsquared=tsquared;
% spike_features_agg.explained=explained;
% spike_features_agg.mu=mu;
% 
% % kmeans
% % idx is a vector of predicted cluster indices corrresponding to the observations in X. 
% % C is a 3-by-2 matrix containing the final centroid locations.
% %
% rng(1); % For reproducibility
% 
% 
% [m,n]=size(S);
% 


% 
% K=p.k;
% 
%     
% [idx, C, sumd, D] = kmeans(S(:,1:p.pc), K, 'Replicates', 5);
% 
% spike_features_agg.cluster_num=idx(:)';
% 
% spike_features_agg.kkk=[S idx];
% 
% % store the distance of each waveform from its centroid
% for ii=1:length(spike_features_agg.cluster_num)
%    cn=spike_features_agg.cluster_num(ii);
%    spike_features_agg.cluster_dist(ii) = D(ii, cn);
% end
% 
% 
% rng(1);
% kmax=5;
% 
% for k=2:kmax
%     [idx,C]= kmeans(S(:,1:p.pc), k, 'Replicates',5);
%     [SS] = silhouette(S(:,1:p.pc), idx);
%     spike_features_agg.sil(k) = mean(SS);
% end
% 
% 
% end

%% extraction method set in parameter panel

if p.extraction == 1
    extraction_method='wav';
elseif p.extraction == 2
    extraction_method='pca';
else
    extraction_method='waveform';
end
    
% p.pc = number of features to extract for clustering

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
                [ks_stat]=ks_test(aux);
                sd(i)=ks_stat;
            else
                sd(i)=0;
            end
        end
        [max_std, ind]=sort(sd, 'descend');
        coeff=ind(1:p.pc);
        
    case 'pca'
        [pcaC, S, L, tsquared, explained, mu] = pca(X(:,:));
        cc=S; % (:,1:p.pc);   
        coeff = 1:size(S,2);   
    case 'waveform'
        cc = X;
        coeff = 1:len_spike;
end

% feature matrix of waveforms for clustering


if p.extraction == 1 || p.extraction == 2
    spk_feats=zeros(num_spikes,p.pc);
    
    for i=1:num_spikes
        for j=1:p.pc
            spk_feats(i,j)=cc(i,coeff(j));
        end
    end
else
    spk_feats=X;
end
    

if p.extraction==2           % 2 = pca
    spike_features_agg.C=pcaC;   % ?
    spike_features_agg.S=S;
    spike_features_agg.l=0;      % L;
    spike_features_agg.tsquared=tsquared;
    spike_features_agg.explained=explained;
    spike_features_agg.mu=mu;
end

% kmeans
% c_numbers is a vector of predicted cluster indices corrresponding to the 
% observations in X. 
% centroids is a 3-by-2 matrix containing the final centroid locations.
%
rng(1); % For reproducibility

%% 
% size(spk_feats)  5 something like 273 spikes by 5 features
% centroids:  a k rows by p.pc columns matrix

[c_numbers, centroids, sumd, Dist] = kmeans(spk_feats, p.k, 'Replicates', 10); % <<<< 10 shd be variable

spike_features_agg.cluster_num=c_numbers(:);


spike_features_agg.kkk=[cc c_numbers];    % vector of cluster numbers in {1,2,3, ... k}

% store the distance of each waveform from its centroid
for ii=1:length(spike_features_agg.cluster_num)
   cn=spike_features_agg.cluster_num(ii);
   spike_features_agg.cluster_dist(ii) = Dist(ii, cn);
end


%%
rng(1);
kmax=7;

% fprintf('running Cluster quality metric\n');

for k=2:kmax
    [c_numbers, centroids]= kmeans(cc, k, 'Replicates',10);   % <<<< 10 shd be variable
    [SS] = silhouette(cc, c_numbers);
    spike_features_agg.sil(k) = mean(SS);
end



end