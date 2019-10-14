%%
%% Convert a set of lines on horizontal EPIs to ones defined 
%% on vertical EPIs. 
%%
function L = hor2vert( L, lfSz )

  % Convert the lines to points in the central LF view.
  % Each point is defined by x, y, and z (disparity)
  px = cellfun(@(l) round((l(:, 1) + l(:, 2)) ./ 2), L, 'UniformOutput', false);
  py = cellfun(@(l, i) repelem(i, size(l, 1), 1), L, num2cell([1:length(L)]'), ...
	       'UniformOutput', false);
  z = cellfun(@(l) (l(:, 2) - l(:, 1)) ./ lfSz(3), L, 'UniformOutput', false);
  px = vertcat(px{:});
  py = vertcat(py{:});
  z = vertcat(z{:});

  % Points outside the image region are rejected as they will map 
  % to non-existant vertical EPIs 
  idx = px < 1 | px > lfSz(2);
  px = px(~idx);
  py = py(~idx);
  z = z(~idx);

  [U, ~, X] = unique( px );

  % Group points by their x-coordinate rather than their y-coordinate to get 
  % all points lying on the same vertical EPI line
  A = accumarray(X, 1:size(px,1), [], @(r){[py(r, :) z(r, :)]});

  % Go from points back to lines
  M = cellfun(@(a) [a(:, 1) - lfSz(4) ./ 2 * a(:, 2) a(:, 1) + ...
		    lfSz(4) ./ 2 * a(:, 2)], A, 'UniformOutput', false);
  
  L = cell(1, lfSz(1));
  L(U) = M;
end
