%%
%% Remove outliers from the line set L.
%% (See Section 3.1: Line Detection of the paper)
%% 
function L = filterOutliers(L, Lc, lfSz, level)
  % Neighborhood window size
  winSz = round([const.OutlierRejectionWinSzMultiplier * lfSz(1), ...
		 const.OutlierRejectionWinSzMultiplier * lfSz(1)]);

  % Project all lines into the central view
  px = cellfun(@(lines) round((lines(:, 1) + lines(:, 2)) ./ 2), L, 'UniformOutput', false);
  z = cellfun(@(lines) lines(:, 2) - lines(:, 1), L, 'UniformOutput', false);

  % Adding padding to the central view prevents issues with points 
  % projecting outside the image
  padding = 100 + winSz(1);
  Lproj = ones(lfSz(1) + 2 * padding, lfSz(2) + 2 * padding) .* 9999;
  Cproj = zeros(size(Lproj));
  
  for i = 1:length(L)
    Lproj(i + padding + 1, cell2mat(px(i)) + padding + 1) = cell2mat(z(i));
    Cproj(i + padding + 1, cell2mat(px(i)) + padding + 1) = cell2mat(Lc(i));
  end
  Cproj = Cproj ./ max(max(Cproj));

  % For each line projected into Lproj, consider a neighborhood of size winSz.
  % Reject the line if it fails the inclusion criterion detailed in Section 3.1 
  % of the paper.
  %
  for i = 1:length(L)
    x = cell2mat(px(i));
    lIdx = ones(1, length(x), 'logical');
    for j = 1:length(x)
      k = x(j);
      ic = i + padding + 1;
      kc = k + padding + 1;
      win = Lproj(ic - winSz(1):ic + winSz(1), kc - winSz(2):kc + winSz(2)); 
      c = sum(sum(abs(win - Lproj(ic, kc)) < 1)) ./ (size(win, 1) * size(win, 2));
      if c * Cproj(ic, kc) < 8e-5 + 8e-5 * level * 3
	lIdx(j) = 0;
      end
    end
    li = cell2mat(L(i));
    L(i) = {li(lIdx, :)};
  end
end

