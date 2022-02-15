
function MAD = mad(dvec)
    % median absolute deviation (use instead of std deviation)
    MAD = median(abs(dvec))/0.6745;
end

