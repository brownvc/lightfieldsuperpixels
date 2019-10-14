%%
%% Edge detection and line fitting at the specified 
%% pyramid level. 
%%
function [L, C] = lines(LF, level, param)

  % Resize the lightfield to the desired pyramid level (in the spatial domain)
  w = floor(size(LF, 2) / (2^level));
  h = floor(size(LF, 1) / (2^level));
  d = size(LF, 4);

  if level ~= 0
    LF = imresize(LF, [h w]);
  end
  EPI = permute(LF, [4 2 3 1]);

  % Generate the filters for edge detection, ...
  filterCount = ceil((param.maxAbsDisparity * d) / (2^level));
  [F, gx, gy] = genFilters( filterCount, [d w]);

  % ... and the line templates for line fitting
  [T, m] = genLines( filterCount, [d w]);

  % Calculate the edge confidence and slope maps
  [C, Z] = epis2edges( EPI, F, gx, gy);

  % Fit lines to the edges
  [L, Lc] = edges2lines(C, Z, T, m);

  % Remove outliers
  L = filterOutliers(L, Lc, [h, w, d], level);
end
