%%
%% Return a k-means superpixel clustering of the input LAB image 
%% using features (L, A, B, X, Y, Z) where Z, the disparity, is
%% provided. The weights for the different terms are also provided
%%
%% Note: this code has not been optimized.
%%
function labels = km (imlab, disparity, superpixelSize, wlab, wxy, wz)

  Z = [];
  Y = [];
  X = [];
  L = [];
  A = [];
  B = [];
  num = [];

  sz = size(imlab);

  [X, Y] = meshgrid(1:size(imlab, 2), 1:size(imlab, 1));
  X = X(:);
  Y = Y(:);

  imlab = reshape(imlab, [], 3, 1);
  L = imlab(:, 1);
  A = imlab(:, 2);
  B = imlab(:, 3);

  Z = double(disparity(:));
  Z = Z + abs(min(Z));
  Z = Z ./ max(Z);

  q = superpixelSize;
  [cx, cy, cz] = meshgrid(q/2:q:sz(2)-q/2, q/2:q:sz(1)-q/2, 0);
  cl = zeros( size(cx) );
  ca = zeros( size(cx) );
  cb = zeros( size(cx) );

  labels = zeros(1, size(X, 1));
  nLabels = numel(cx);

  parfor i = 1:nLabels
    dxy = (X - cx(i)).^2 + (Y - cy(i)).^2;
    [m, lmin] = min(dxy);
   
    cx(i) = X(lmin);
    cy(i) = Y(lmin);
    cz(i) = Z(lmin);

    cl(i) = L(lmin);
    ca(i) = A(lmin);
    cb(i) = B(lmin);
  end

   for k = 1:10
    for i = 1:size(X, 1)
      dxy = sqrt((cx - X(i)).^2 + (cy - Y(i)).^2);
      dlab = sqrt((cl - L(i)).^2 + (ca - A(i)).^2 + (cb - B(i)).^2);
      dz = abs(cz - Z(i));

      d = wxy .* dxy + wz .* dz + wlab .* dlab;
      [m, lmin] = min(d(:));
      labels(i) = lmin;
    end

    for i = 1:nLabels
      idx = find(labels == i);
      cx(i) = mean(X(idx));
      cy(i) = mean(Y(idx));
      cz(i) = mean(Z(idx));
      
      cl(i) = mean(L(idx));
      ca(i) = mean(A(idx));
      cb(i) = mean(B(idx));
    end
  end

  labels = reshape(labels, sz(1), sz(2));
end
