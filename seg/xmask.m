
function bw = xmask(l1, l2, sz, wSz)
  m1 = sz(1) / (l1(1) - l1(2) + eps);
  m2 = sz(1) / (l2(1) - l2(2) + eps);
  c1 = -m1 * l1(2); % y = 0, we assume y values grow upwards
  c2 = -m2 * l2(2);

  x = (c2 - c1) / (m1 - m2);
  y = m1 * x + c1;
  y = round(sz(1) - y); % get y values in raster order
  x = round(x);

  bw = zeros(sz);
  bw( max(1, y - wSz):min( sz(1), y + wSz), max(1, x - wSz):min( sz(2), x + wSz) ) = 1;
end