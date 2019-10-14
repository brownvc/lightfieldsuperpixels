%%
%% A segment S in the ground truth segmentation image G divides a superpixel P into 
%% an IN and an OUT part. The undersegmentation error compares segment areas and provides
%% the percentage of superpixels which overlap ground-truth segment borders.
%%
%% Note: This code isn't optimized, and may take some time to run
%%
function err = metricUndersegmentationError(labels, labelsGT)

  [h, w, ~, ~] = size(labels);
  err = zeros(size(labels, 3), size(labels, 4));

  for u = 1:size(labels, 4)
    for v = 1:size(labels, 3)
      gt = labelsGT(:, :, v, u);
      label = labels(:,:, v, u);
      uniqueLabelsGT = unique(gt(:));
      UE = 0;

      for i = uniqueLabelsGT(:)'
        % For each unique ground truth labelled region, get the unique superpixel
	% labels that fall within that region
	mask = gt == i;
	overlapLabels = unique(label(mask));
	out = zeros(1, numel(overlapLabels));

	% Calculate the undersegmentation error based on the overlap between
	% the total number of pixels for a superpixel label, and the number of 
	% pixels fo the superpixel label that fall within a single GT region
	for j = 1:numel(overlapLabels)
	  regionNum = sum(sum(label == overlapLabels(j) ));
	  regionGTNum = sum(sum(label(mask) == overlapLabels(j) ));
            
          % the superpixel is within the object segmentation region
          if regionGTNum == regionNum 
            continue
          elseif regionGTNum > regionNum/2 % most of the regions are overlapping
            out(j) = out(j) + regionNum - regionGTNum;
          else 
	    % small overlapping region - the overlapped is regarded as error 
	    % (avoid big panelty for large superpixels)
            out(j) = out(j) + regionGTNum;
          end 
	end
	out = sum(out);
	UE = UE + out/sum(sum(mask));
      end
      err(v, u) = UE/length(uniqueLabelsGT);

    end
  end

  err = mean(mean(err));
end
