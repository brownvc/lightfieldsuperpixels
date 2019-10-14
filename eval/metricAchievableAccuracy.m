%%
%% Given a ground-truth object-level segmentation map, this metric measures the 
%% achievable accuracy possible by the oversegmentation, for instance, in a later 
%% interactive object selection stage. 
%%
%% To compute the metric, we assign labels to superpixels according to the ground 
%% truth object labels from the synthetic HCI dataset. 
%% The label which maximizes overlap with a superpixel across views is the assigned label.
%%
%% Note: This code isn't optimized, and may take some time to run
%%
function [err, errView] = metricAchievableAccuracy(labels, labelsGT)

  % Non-labeled pixels cause indexing errors. Deal with them...
  labels(labels == 0) = max(max(max(max(labels)))) + 1;

  errView = zeros(size(labels, 1), size(labels, 2), 3, size(labels, 3), size(labels, 4));
  err = zeros(size(labels, 3), size(labels, 4));

  % For each unique label in the superpixel segmentation, find the ground truth
  % label that has maximum overlap with it
  %
  uniqueLabels = unique(labels);
  labelsXgt = zeros( size(uniqueLabels) );

  for i = uniqueLabels(:)'
    maxGtLabelOverlap = 0;

    for u = 1:size(labels, 4)
      for v = 1:size(labels, 3)
        mask = labels(:, :, v, u) == i;
        if ~any(mask)
          continue;
        end

        gt = labelsGT(:, :, v, u);
        [gtLabel, gtLabelOverlap] = mode(gt(mask));

        if gtLabelOverlap > maxGtLabelOverlap
          labelsXgt(i) = gtLabel;
          maxGtLabelOverlap = gtLabelOverlap;
        end

      end
    end
  end

  % Calculate the number of pixels in each view that has the wrong label.
  % Also create a visualization of the error.
  %
  for u = 1:size(labels, 4)
    for v = 1:size(labels, 3)
      l = labels(:, :, v, u);
      gt = labelsGT(:, :, v, u);
      lxgt = labelsXgt(l);

      % Calculate percentage of correct labels in each view
      wrongLabelMask = lxgt ~= gt;
      err(v, u) = sum(sum(~wrongLabelMask)) ./ numel(lxgt);

      % Visualize the achievable accuracy for each view  with wrong labels in red
      errRGB = ind2rgb(im2uint8(mat2gray(lxgt)), parula(256));
      errRGB = reshape(errRGB, [], 3);
      errRGB(wrongLabelMask, 1) = 1;
      errRGB(wrongLabelMask, 2) = 0;
      errRGB(wrongLabelMask, 3) = 0;
      errRGB = reshape(errRGB, size(lxgt, 1), size(lxgt, 2), 3);
      errView(:,:,:, v, u) = errRGB;
    end
  end

  err = mean(mean(err));
end
