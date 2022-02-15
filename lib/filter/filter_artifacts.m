function dvec=filter_artifacts(dvec, ~)

param;

med=1;                % use median
if med==1
    MAD = mad(dvec);  % median absolute deviation
    art_det=p.artifact_detect;
    art_ext=p.artifact_extend;
else
    MAD=std(dvec);
    art_det=p.artifact_detect;
    art_ext=p.artifact_extend;
end


% fprintf( '>> removing artifacts: values < (max_low * MAD) and values > (max_high * MAD) are set to zero. \n' );
% fprintf( sprintf('range = %0.1f * %f to %0.1f * %f median absolute deviations.\n', max_dev, MAD, max_dev, MAD) );

mark=NaN;   % set extreme values to NaN, then interpolate "missing" values

data_abs=abs(dvec);


%%
% remove left side of detected high abs value artifact
art_det_vec = data_abs > (art_det * MAD);
max_idx=length(art_det_vec);

for ii=1:length(art_det_vec)
    
    if art_det_vec(ii) == 1
        jj=ii;
        while jj> 0 && jj <= max_idx && data_abs(jj) > (art_ext * MAD)
            dvec(jj) = mark;
            jj=jj-1;
        end
    end
end


% remove right side of detected high abs value artifact
%
for ii=1:length(art_det_vec)
    
    if art_det_vec(ii) == 1
        jj=ii;
        while jj <= max_idx && data_abs(jj) > (art_ext * MAD)
            dvec(jj) = mark;
            jj=jj+1;
        end
    end
end

nanx = isnan(dvec);
time_points    = 1:numel(dvec);
dvec(nanx) = interp1(time_points(~nanx), dvec(~nanx), time_points(nanx));

end