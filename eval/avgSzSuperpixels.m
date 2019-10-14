%%
%% Returns the average size of superpixels for the given superpixel labeling
%% The size of each superpixel is calculated as the square root of the number of 
%% pixels (area) of the superpixel.
%%
function sz = avgSzSuperpixels(labels)
  labeluv = labels(:, :, ceil(size(labels, 3)/2), ceil(size(labels, 4)/2));
  u = unique(labeluv);
  sz = zeros(length(u), 1);
  for i = 1:length(u)
    lbl = u(i);
    sz(i) = sqrt(sum(sum(labeluv == lbl)));
  end
  sz = mean(sz);
end
