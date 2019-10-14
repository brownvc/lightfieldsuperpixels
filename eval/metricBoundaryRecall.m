%%
%% Given a ground truth boundary image G and an algorithm's boundary image B, we compute 
%% the fraction of ground truth edges that fall within a certain distance d of at least 
%% one superpixel
%%
function err = metricBoundaryRecall(labels, labelsGT)

% Chessboard distance range
d = 2; 

[h, w, ~, ~] = size(labels);

[X, Y] = meshgrid(1:w, 1:h);
winX = repmat(-d:d, d * 2 + 1, 1);
winX = winX(:);
winY = repmat([-d:d]', d * 2 + 1, 1);

err = zeros(size(labels, 3), size(labels, 4));

for v = 1:size(labels, 3)
  for u = 1:size(labels, 4)
    gt = labelsGT(:, :, v, u); 
    [gMagGT, gdirGT] = imgradient(gt);
    [gMagOurs, gDirOur] = imgradient(labels(:, :, v, u));
    
    % Get indices of pixels with non-zero gradient values (edges)
    mask = gMagGT > 0;
    x = X(mask);
    y = Y(mask);

    % Compute the indices of all edge neighbors
    xall = bsxfun(@plus, x', winX);
    yall = bsxfun(@plus, y', winY);
    xall = max(1, min(w, xall(:)));
    yall = max(1, min(h, yall(:)));
    ind = sub2ind([h, w], yall, xall);
    
    % Check if there exist an edge within a distance, in our segmentation
    edgeNeighbors = gMagOurs(ind);
    edgeNeighbors = reshape(edgeNeighbors, (2 * d + 1)^2, []);
    edgeNeighborExist = sum(edgeNeighbors, 1);

    err(v, u) = length(find(edgeNeighborExist))/ size(edgeNeighborExist, 2);
  end
end

err = mean(mean(err));

end
