%%
%% The mean number of labels per pixel in the central view as projected into all 
%% other views via the ground truth disparity map. 
%%
%% Note: This code isn't optimized, and may take some time to run
%%
function err = metricLabelsPerPixel(labels, disparityGT)

  [h, w, nv, nu] = size(labels);

  % row, column subscripts
  [x, y] = meshgrid(1:w, 1:h);
  idx = [1:h * w]';

  result = zeros(h, w, nv, nu);

  for v = 1:nv
    for u = 1:nu
      
      % Project each pixel into the center view based on the disparity of this view
      px = round(x + disparityGT(:, :, 1, v, u));
      py = round(y - disparityGT(:, :, 2, v, u)); % subtract here since matlab y goes down

      pxOverflowIdx = px < 1 | px > w;
      pyOverflowIdx = py < 1 | py > h;
      px(pxOverflowIdx) = w; % temporarily, avoid out of range sub2ind transfer
      py(pyOverflowIdx) = h; 
      idxProj = sub2ind( [h, w], py, px);
      idxProj = idxProj(:);

      % Identify pixel indices in the center view which have more than one pixel
      % projecting onto them
      uniqueIdx = unique(idxProj);
      hg = hist(idxProj, uniqueIdx);
      idxProjDup = uniqueIdx(hg > 1);

      % Discard all pixels from the duplicate list
      I = ~(ismember(idxProj, idxProjDup));

      % Discard all out-of-range pixels 
      I(pxOverflowIdx) = false;
      I(pyOverflowIdx) = false;
    
      % Find the the foreground pixel in the duplicate list
      % These are added back to the list
      disparityh = disparityGT(:, :, 1, v, u);
      idxProjOcc = zeros(length(idxProjDup), 1);
      count = 1;
      for idup = idxProjDup(:)'
        subxy = find(idxProj == idup);
        % foregroud pixel -> min depth -> min disparity
        [~, i] = min(abs(disparityh(subxy)));
        idxProjOcc(count) = subxy(i);
        count = count +1;
      end
      % add back the foreground pixel from the duplicate list
      I(idxProjOcc) = true;

      l = labels(:, :, v, u);
      R = zeros(h, w);
      R(idxProj(I)) = l(idx(I));
      result(:, :, v, u) = R;
    end
  end

  result = reshape(result, h, w, []);
  err = zeros(h, w);
  centerView = labels(:, :, ceil(nv/2), ceil(nu/2));

  % Calculate the number of differing labels per pixel
  for i = 1:size(result, 3)
    for j = 1:w
      parfor k = 1:h
        % Consider a 3x3 window around the pixel to account for rounding errors
        % when reprojecting
        win = centerView( min(h, max(1, [k-1:k+1])), min(w, max(1, [j-1:j+1])) );
        win = win(:);
        if( ~sum(win == result(k, j, i)) )
	  err(k, j) = err(k, j) + 1;
        end
      end
    end
  end
 
  err = mean(err(:)); 
  err = err + 1; % The pixel has at least one label even if none differ
end


