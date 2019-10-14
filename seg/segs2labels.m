%%
%% Create a label map from the matched and labelled segments
%%
function Lbl = segs2labels(S, epiSz)
  h = epiSz(1);
  w = epiSz(2);

  parfor j = 1:length(S)
    l = zeros(h, w);
    segs = S{j};

    % The disparity of a segment is taken as the minimum of the slope
    % of the two bounding lines. This corresponds to assigning the segment
    % the farther depth of two options.
    z = min(segs(:, 2) - segs(:, 1), segs(:, 4) - segs(:, 3));

    % Sort segs by z-order
    [z, o] = sortrows(round(z));
    segs = segs(o, :);

    % Draw a parallelogram with the segment's label value into d
    for i = 1:size(segs, 1)
      tl = segs(i, 1);
      bl = segs(i, 2);
      tr = segs(i, 3);
      br = segs(i, 4);

      x = round( linspace( tl, bl, h)' + [0:tr-tl] );
      y = repelem([1:h]', 1, size(x, 2));
      idx = x > w | x < 1;
      x = x(~idx);
      y = y(~idx);

      l( sub2ind( size(l), y, x) ) = segs(i, end);
    end  

    Lbl(:, :, j) = l;
  end
end
