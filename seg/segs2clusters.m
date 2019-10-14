%%
%% Joint k-means clustering of the vertical and horizontal EPI segments.
%%
%% Each segment is converted into a point p = (x, y, z, l, a, b).
%%
%% The y value is the EPI index.
%% The x value is the horizontal center of the projection of the segment
%% into the central light field view:
%%
%%     _________________________
%%    |          /       /     |
%%    |         /       /      |
%%    |--------/---x---/-------|--> This EPI row corresponds to the projection
%%    |       /       /        |    of the segment into the center view
%%    |______/_______/_________|
%%
%% The z value is the depth of the segment.
%% The l, a, b values are the average LAB color of the segment
%%
function [labelsu, labelsv] = segs2clusters(Sv, Su, szLF, szSP, wxy, wz, wlab)

  % Count the total number of segments in the horizontal and 
  % vertical segmentations. Each segment is a point in the clustering
  n = zeros(2, 1);
  n(1) = sum(cellfun(@(s) size(s, 1), Sv));
  n(2) = sum(cellfun(@(s) size(s, 1), Su));

  % Get the point features from the vertical and horizontal segments
  % Using separate arrays for the point coordinates showed better performance
  px = zeros( n(1) + n(2), 1);
  py = zeros( n(1) + n(2), 1);
  pz = zeros( n(1) + n(2), 1);
  pl = zeros( n(1) + n(2), 1);
  pa = zeros( n(1) + n(2), 1);
  pb = zeros( n(1) + n(2), 1);

  s = cell2mat(Sv);
  pz  (1:n(1))    = (s(:, 2) - s(:, 1)) ./ szLF(3);
  % For the vertical direction, x and y are flipped...
  py (1:n(1), :) = [(s(:, 2) - s(:, 1)) ./ 2 + (s(:, 1) + s(:, 3)) ./ 2];
  px (1:n(1), :) = [s(:, 5)];
  pl (1:n(1), :) = [s(:, 6)];
  pa (1:n(1), :) = [s(:, 7)];
  pb (1:n(1), :) = [s(:, 8)];

  s = cell2mat(Su);
  pz (n(1) + 1:n(2) + n(1))    = (s(:, 2) - s(:, 1)) ./ szLF(4);
  px (n(1) + 1:n(2) + n(1), :) = [(s(:, 2) - s(:, 1)) ./ 2 + (s(:, 1) + s(:, 3)) ./ 2];
  py (n(1) + 1:n(2) + n(1), :) = [s(:, 5)];
  pl (n(1) + 1:n(2) + n(1), :) = [s(:, 6)];
  pa (n(1) + 1:n(2) + n(1), :) = [s(:, 7)];
  pb (n(1) + 1:n(2) + n(1), :) = [s(:, 8)];

  % Normalize the depth values
  pz = pz + abs(min(pz));
  pz = pz ./ max(pz);

  % Initialize the cluster centers
  % Cluster centers are created on a regular grid in the spatial domain
  % and then assigned the value of the closest point
  %
  [cx, cy, cz] = meshgrid( szSP/2: szSP: szLF(2) - szSP/2, ...
			   szSP/2: szSP: szLF(1) - szSP/2, ...
			   0);
  cx = cx(:);
  cy = cy(:);
  cz = cz(:);
  cl = zeros(size(cx));
  ca = zeros(size(cx));
  cb = zeros(size(cx));

  nLabels = size(cx, 1);
  labels = zeros( n(1) + n(2), 1);
  
  parfor i = 1:nLabels
    dxy = (px - cx(i)).^2 + (py - cy(i)).^2;
    [~, minIdx] = min(dxy);
    
    cx(i) = px(minIdx);
    cy(i) = py(minIdx);
    cz(i) = pz(minIdx);
    cl(i) = pl(minIdx);
    ca(i) = pa(minIdx);
    cb(i) = pb(minIdx);
  end

  % K-Means clustering
  %
  for j = 1:const.KmeansIterations
    parfor i = 1:n(1) + n(2)
      dxy  = sqrt((cx - px(i)).^2 + (cy - py(i)).^2);
      dlab = sqrt((cl - pl(i)).^2 + (ca - pa(i)).^2 + (cb - pb(i)).^2);
      dz   = abs(cz - pz(i));

      d = wxy .* dxy + wz .* dz + wlab .* dlab;  %compactness test
      [~, minIdx] = min(d(:));
      labels(i) = minIdx;
    end

    parfor i = 1:nLabels
      idx = find(labels == i);
      cx(i) = mean(px(idx));
      cy(i) = mean(py(idx));
      cz(i) = mean(pz(idx));
      cl(i) = mean(pl(idx));
      ca(i) = mean(pa(idx));
      cb(i) = mean(pb(idx));
    end
  end

  labelsv = mat2cell(labels(1:n(1)), cellfun(@(s) size(s, 1), Sv), 1);
  labelsu = mat2cell(labels(n(1) + 1: n(1) + n(2)), cellfun(@(s) size(s, 1), Su), 1);
end
