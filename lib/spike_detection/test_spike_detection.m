function test_results_struct = test_spike_detection(spike_struct_gt, spike_struct, args)

param;

% gt: ground truth
num_true_spikes=sum(spike_struct_gt.events);
if num_true_spikes <= 0
    num_true_spikes = 1;
end

num_tp=0;
num_fp=0;
num_fn=0;

pre_offset  = round(p.pre_offset*args.Fs/1000);
post_offset = round(p.post_offset*args.Fs/1000);

last_idx=min(length(spike_struct_gt.events), length(spike_struct.events));

for ii=1:last_idx
    
    if pre_offset >= ii
        pre=1;
    else
        pre=ii-pre_offset;
    end
    
    if post_offset+ii > last_idx
        post = last_idx;
    else
        post = post_offset+ii;
    end
    
    if spike_struct_gt.events(ii) == 1      &&  ismember(1,spike_struct.events(pre:post))
        num_tp = num_tp+1;
        
    elseif  ~ismember(1,spike_struct_gt.events(pre:post)) &&  spike_struct.events(ii)==1
        num_fp = num_fp + 1;
        
    elseif  spike_struct_gt.events(ii) == 1 &&  ~ismember(1,spike_struct.events(pre:post))
        num_fn = num_fn + 1;
        
    end
    
    test_results_struct.pre_offset  = pre_offset;
    test_results_struct.post_offset = post_offset;
    
    test_results_struct.num_true_spikes = num_true_spikes;
    test_results_struct.tp=num_tp/num_true_spikes; % (num_tp+num_tp+num_tp);
    test_results_struct.fp=num_fp/num_true_spikes; % (num_tp+num_tp+num_tp);
    test_results_struct.fn=num_fn/num_true_spikes; % (num_tp+num_tp+num_tp); 
end