%%
%% Create a piecewise constant disparity map from the  matched epi segments
%%
function D = segs2disparity(S, epiSz)
  h = epiSz(1);
  w = epiSz(2);

  parfor j = 1:length(S)
    d = zeros(h, w);
    segs = S{j};

    % The disparity of a segment is taken as the minimum of the slope
    % of the two bounding lines. This corresponds to assigning the segment
    % the farther depth of two options.
    z = min(segs(:, 2) - segs(:, 1), segs(:, 4) - segs(:, 3));

    % Sort segs by z-order
    [~, o] = sortrows(round(z));
    z = z(o);
    z = z ./ epiSz(1);
    segs = segs(o, :);

    % Draw a parallelogram with the segment's disparity value into d
    for i = 1:size(segs, 1)
      l = segs(i, 1);
      r = segs(i, 3);
      dl = (segs(i, 2) - l)/ (h - 1);
      dr = (segs(i, 4) - r)/ (h - 1);
      for k = 1:h
        d(k, min(max(1, round(l + dl * (k - 1) ) : round(r + dr * (k - 1))), w)) = z(i);
      end
    end  

    D(:, :, j) = d;

  end
end
