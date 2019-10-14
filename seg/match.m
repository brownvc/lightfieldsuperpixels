%%
%% Give a line set, return pairwise line matches based on EPI occlusion rules.
%% See Section 3.2 of the paper (Occlusion-aware EPI Segmentation) for a 
%% detailed description of matching rules.
%%
function [M, val] = match (lines, c)

  n = size(lines, 1);
  sz = [size(c, 1), size(c,2)];

  u = repmat(lines(:, 1), 1, n);
  v = repmat(lines(:, 2), 1, n);
  s = repmat(lines(:, 1)', n, 1);
  r = repmat(lines(:, 2)', n, 1);

  % Find all pairs of intersecting lines, and select the foreground line for each pair.
  % The foreground line is determined by the slope
  N = ((r <= v & s >= u) | (r >= v & s <= u)); % .* ((r - s) > (v - u));

  [lb, lf] = find(N .*((r - s) > (v - u)) > 0); 

  % Determine the occlusion direction using the confidence (edge) image.
  % The total confidence of an edge is lower on the occluded side. 
  % occDir will be 1 if the occlusion is from the left, 0 if from the right.
  c = c > 0;
  dOcc = cellfun( @(lf, lb) ...
		 sum(sum(c .* drawLines(lines(lb, :), sz) .* leftMask(lines(lf, :), sz) .* xmask( lines(lb, :, :), lines(lf, :, :), sz, const.SegOccEdgeWindowSize))) > ...
	         sum(sum(c .* drawLines(lines(lb, :), sz) .* rightMask(lines(lf, :), sz) .* xmask( lines(lb, :, :), lines(lf, :, :), sz, const.SegOccEdgeWindowSize))), ...
		 num2cell(lf), num2cell(lb) );

  X = ones(size(N));
  X(:, lf) = 0;
  X(lf, :) = 0;
  n = size(lines, 1);
  % If a line is being intersected from both the right and left direction, it's likely
  % a false positive - remove it from further consideration (of foreground lines ONLY)
  fp = intersect( lf(dOcc == 1), lf(dOcc == 0) );
  idx = ismember(lf, fp);
  lf(idx) = [];
  dOcc(idx) = [];

  % Create a graph (as an adjacency matrix) to represent all allowed line connections.
  % Each line is repeated twice to create left and right facing lines.
  %
  A = zeros( 2 * n, 2 * n );
  
  % The adjacency matrix is symmteric, and right-facing lines can't match with other right-facing
  % lines. Therefore, we can work only on creating the top-right submatrix and then use its 
  % transpose in the the bottom-left submatrix.
  B = ones(n, n); 

  % A right-facing line can't match with lines which are completely to its left, and vice versa
  right = (u > s) & (v > r);
  B = B .* ~right;
  % A right-facing line can't match with it's left-facing sibling, and vice-versa
  B = B .* ~(logical(eye(n)));

  for j = fp'
    if isempty(j)
       break;
    end
    left = find(B(:, j) .* ~N(:, j) > 0);
    right = find(B(j, :) .* ~N(j, :) > 0);
    [~, lidx] = max(segGain(left, repelem(j, length(left), 1), lines));
    [~, ridx] = max(segGain(repelem(j, 1, length(right)), right, lines));

    lidx = left(lidx);
    ridx = right(ridx);

    ml = lines(lidx, 1) - lines(lidx, 2);
    mr = lines(ridx, 1) - lines(ridx, 2);
    mj = lines(j, 1) - lines(j, 2);

    if abs(ml - mj) < abs(mr - mj)
      lf = cat(1, lf, j);
      dOcc = cat(1, dOcc, 0);
    else
      lf = cat(1, lf, j);
      dOcc = cat(1, dOcc, 1);
    end
  end
  fp = [];

  % Perform Bipartite matching only for the foreground intersecting lines.
  % A foreground, left-facing line can match to any line to its left EXCEPT lines that 
  % are to the right of a right-facing foreground line. The facing of a foreground line was 
  % determined above using the occlusion direction.

  % An indicator for every left-facing foreground line to every right-facing foreground line
  J = zeros(size(B));
  J(lf(dOcc == 1), lf(dOcc == 0)) = 1;

  % For a given line, get only the other right-facing foreground lines to the left of it
  J = J & (B .* ~N); 

  % Get all the lines that are to the left of the right-facing line L_r, and turn them off
  % for the foreground left-facing lines to the right of L_r. Do a similar operation for 
  % the foreground right-facing lines
  Bf = B .* (B * J == 0) .* (J * B == 0); 

  % Select only the foreground left-facing lines, we don't want to match other lines yet.
  % Also, no matching is allowed with intersecting lines (N).
  Y = zeros(size(N));
  Y(:, lf(dOcc == 0)) = 1;
  Y(lf(dOcc == 1), :) = 1;
  Bf = Bf .* Y .* ~N;

  % Calculate edge weights
  [arg1, arg2] = find( Bf > 0);
  g = segGain(arg1, arg2, lines); 
  Bf( sub2ind( size(Bf), arg1, arg2) ) = g;
  Bf( Bf == 0) = -inf;

  Bf(fp, :) = -inf;
  Bf(:, fp) = -inf;

  % Get a maximum value bipartite matching
  A(1:n, n + 1:end) = Bf; 
  A(n + 1:end, 1:n) = Bf'; 
  [val, mi, mj] = bipartite(A);
  idx = mi <= n;
  mi = mi(idx);
  mj = mj(idx) - n;
  M = [mi mj];

  % Remove foreground intersecting lines
  C = B;
  C(mi, :) = 0;
  C(:, mj) = 0;

  % Perform bipartite matching for all non-intersecting lines
  [arg1, arg2] = find( C > 0);
  g = segGain(arg1, arg2, lines);
  C( sub2ind( size(B), arg1, arg2) ) = g;
  C(C == 0) = -inf;

  A = zeros(2 * n, 2 * n);
  A(1:n, n + 1:end) = C;
  A(n + 1:end, 1:n) = C';

  % Perform Bipartite matching
  %
  [val, mi, mj] = bipartite(A);
  idx = mi <= n;
  mi = mi(idx);
  mj = mj(idx) - n;
  M = cat(1, M, [mi mj]);

end
