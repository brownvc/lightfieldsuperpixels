%%
%% Convert the matched segments into parallelograms by aligning
%% the bounding lines. The slope of both lines is set to the
%% minimum of the two slopes. This corresponds to setting the depth
%% to the farther of two depths
%%
function segs = matches2parallelograms(m, lines)

  segs = [ lines( m(:, 1), :) lines( m(:, 2), :) ];
  dxl = segs(:, 2) - segs(:, 1);
  dxr = segs(:, 4) - segs(:, 3);

  idx = dxl < dxr;
  segs(idx, 3) = segs(idx, 4) - dxl(idx);
  idx = ~idx;
  segs(idx, 2) = segs(idx, 1) + dxr(idx);
end
