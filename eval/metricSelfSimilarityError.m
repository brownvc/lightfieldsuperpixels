%%
%% Project the center of superpixels from each view into the center view, 
%% and compute the average deviation versus ground truth disparity. Smaller
%% errors indicate better consistency across views. 
%%
%% Note: This code isn't optimized, and may take some time to run
%%
function err = metricSelfSimilarityError(labels, disparityGT)

  [h, w, nv, nu] = size(labels);

  % row, column subscripts
  [x, y] = meshgrid(1:w, 1:h);

  % The projected (x, y) centroid of each superpixel (out of a total of (max(labels(:))) 
  % unique superpixels), in each of the nv * nu views.
  pc = ones(max(labels(:)), 2, nv, nu) * inf;

  for v = 1:nv
    for u = 1:nu
      labeluv = labels(:, : ,v, u);

      % Project each pixel into the center view based on the disparity of this view
      px = x + disparityGT(:, :, 1, v, u);
      py = y - disparityGT(:, :, 2, v, u); % subtract here since matlab y goes down

      % calculate the projected superpixel center as the mean of the projected
      % x and y values of that superpixel in the center view
      for i = unique(labeluv(:))'
	mask = labeluv == i;
	if any(mask(:))
          pc(i, :, v, u) = [mean(px(mask)), mean(py(mask))];
	end
      end
    end
  end

  % Calculate the difference from the superpixel centroid in the center view
  pc = pc - pc(:,:, ceil(nv/2), ceil(nu/2));
  err  = squeeze(sqrt( sum(pc .^2, 2) ));
  err = err(:);

  % discard superpixels that are entirely occluded in at least one view
  err(isnan(err)) = [];
  err(isinf(err)) = [];
  err = mean(err);
end
