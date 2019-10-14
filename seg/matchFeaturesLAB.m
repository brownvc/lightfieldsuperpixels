%%
%% Get the LAB features of each EPI segment.
%% An EPI segment (or match) is defined by a pair of line indices stored in m.
%% In addition to the features, the function also returns a logical array
%% denoting non-occluded segments.
%%
function [featuresLAB, featuresIdx] = matchFeaturesLAB(m, lines, epi)

  % Sort the matches/segments by the slope of its bounding lines
  [~, o] = sort(min(lines(m(:, 1), 2) - lines(m(:, 1), 1), lines(m(:, 2), 2) - lines(m(:, 2), 1)));

  % Create a mask for each match. 
  % Having the masks of all matches is useful when determining the color of occluded regions.
  %
  labels = zeros(size(epi, 1), size(epi, 2));
  sz = [size(epi, 1) size(epi, 2)];
  for i = 1:length(o) 
    mask = rightMask(lines(m(o(i), 1), :), sz) & leftMask(lines(m(o(i), 2), :), sz);
    labels(mask) = i;
  end

  featuresLAB = zeros( size(m, 1), 3);

  % Some segments may be completely occluded. We identify these...
  featuresIdx = zeros( size(m, 1), 1, 'logical');

  for i = 1:size(m, 1)
    bw = labels == i;
    s = sum(sum(bw));
    if s ~= 0
      featuresIdx( o(i) ) = 1;
      featuresLAB(i, :) = permute(sum(sum(epi .* bw)) ./ s, [1 3 2]);
    end
  end

  % Put the features back in original order
  [~, p] = sort(o);
  featuresLAB = featuresLAB(p, :);
end
