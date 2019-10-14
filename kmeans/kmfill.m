%% 
%% Fill gaps in labels after projection from a central view.
%% Note: this code has not been optimized.
%%
function lout = kmfill(labels, LF, winSz)
  
  w = size(labels, 2);
  h = size(labels, 1);

  % Weight for color term in distance
  wdc = 400;

  % Weight for spatial term in distance
  wdxy = 1;

  lout = labels;
  lc = labels;

  LF = rgb2lab(LF);

  [u, v] = find(lc <= 0);
  for k = 1:size(u, 1)
    i = v(k);
    j = u(k);

    left = max(1, i-winSz);
    right = min(w, i+winSz);
    top = max(1, j-winSz);
    bottom = min(h, j+winSz);

    win = lc( top:bottom, left:right );
    [y, x] = find(win > 0);

    idx = sub2ind( size(LF), y + top - 1, x + left - 1);
    
    cr = LF(idx);
    cg = LF(idx + w * h);
    cb = LF(idx + w * h * 2);

    dxy = (x - size(win, 2)./2 ).^2 + (y - size(win, 1)./2 ).^2;
    dc = (LF(j, i, 1) - cr).^2 + (LF(j, i, 2) - cg).^2 + (LF(j, i, 3) - cb).^2;

    d = wdxy .* dxy + wdc .* dc; 

    if ~isempty(d)
      [~, minIdx] = min(d);
      lbl = win( y(minIdx), x(minIdx) );
      lout(j, i) = lbl;
    end
  end

end
