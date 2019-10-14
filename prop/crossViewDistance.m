
function d = crossViewDistance(vi, ui, x, y, zprop, LF, szLF) 
  cviewIdx = ceil(szLF(3)/2);

  % The angular (u, v) coordinates of the views we will be projecting into;
  up = [repelem(cviewIdx, 1, szLF(3) - 1) 1:ui-1 ui+1:szLF(4)];
  vp = [1:vi-1 vi+1:szLF(3) repelem(cviewIdx, 1, szLF(4) - 1)];

  % The projected x and y coordinates are calculated based on the view offset
  % we're projecting into and the disparity proposal zprop
  xp = round((up - ui) .* zprop + x);
  yp = round((vp - vi) .* zprop + y);

  % Repeat angular indices row-wise for each depth proposal.
  up = repelem(up, numel(zprop), 1);
  vp = repelem(vp, numel(zprop), 1);

  % Identify pixels projecting off-screen. These are not included in the 
  % final distance estimation
  mask = xp <= 0 | xp > szLF(2) | yp <= 0 | yp > szLF(1);
  xp(mask) = x;
  yp(mask) = y;

  lIdx = sub2ind( size(LF), yp, xp, ones(size(xp)) .* 1, vp, up);  
  aIdx = sub2ind( size(LF), yp, xp, ones(size(xp)) .* 2, vp, up);  
  bIdx = sub2ind( size(LF), yp, xp, ones(size(xp)) .* 3, vp, up);  

  d = ( LF(lIdx) - LF(y, x, 1, vi, ui) ).^2 + ...
      ( LF(aIdx) - LF(y, x, 2, vi, ui) ).^2 + ...
      ( LF(bIdx) - LF(y, x, 3, vi, ui) ).^2;

  % normalize by the number of samples across views for a given z proposal
  d(mask) = 0;
  d = sum(d, 2) ./ (size(d, 2) - sum(mask, 2));
end
