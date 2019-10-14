%%
%% Generate qualitative comparison images for the light field I, given the superpixel
%% labels for the light field in varargin.
%% Results are output to fout/fname-roi.png, fout/fname-roi-detail.png
%%
function plotComparisonQualitative(fout, fname, I, varargin) 

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  DISPLAY PARAMETERS - Set these to control properties of the output figure    %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% The names of algorithms to display. Set only {1}
  algorithmNames{1} = 'Current';
  algorithmNames{2} = 'VCLFS';
  algorithmNames{3} = 'LFSP';
  algorithmNames{4} = 'K-means';

  % The grayscale value of the superpixel boundaries
  % White by default, but this may not be clearly visible on some light fields
  graySpxBoundary = 1; 

  % The points at which to zoom in
  % If left empty, the points are randomly chosen
  pROI = [];

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% Utility function definitions
  %%
  % Overlay superpixel boundaries
  boundary  = @(I, L, c)  im2double(imoverlay( I, bwmorph(boundarymask(L), 'thin', 1), c ));

  % Add border of size bSz, and color c around I
  addBorder = @(I, bSz, c) padarray(I, [bSz bSz], 0) + padarray( zeros(size(I)), ...
						[bSz bSz], 1 ) .* permute(c, [1 3 2]);

  concatVert = @(I, J, padSz) cat(1, I, ones(padSz, size(I, 2), 3), J);
  concatHorz = @(I, J, padSz) cat(2, I, ones(size(I, 1), padSz, 3), J);

  % Draw a rectangular region-of-interest on the image I at point p, with width w, 
  % border size bSz, and color c
  drawROI = @(I, p, w, bSz, c) insertShape(I, 'Rectangle', [p(2) - w/2 p(1) - w/2 w w], ...
					   'LineWidth', bSz, 'Color', c);
  
  % Return the w pixel wide cropped region around point p in image I
  closeup = @(I, p, w) I( round(p(1) - w/2:p(1) + w/2), round(p(2) - w/2:p(2) + w/2), : );

  for i = 1:nargin - 3
    labels(:, :, :, :, i) = varargin{i};
  end

  if isempty(pROI)
    pROI = rand(3, 2) .* [size(I, 1), size(I, 2)]; 
  end

  cviewIdx = ceil(size(labels, 4)/2);

  % The (u, v) indices of the views to show closeups of 
  vi = [1 cviewIdx size(labels, 3)];
  ui = [1 cviewIdx size(labels, 4)];

  bSzCloseup = 5;      % Border size of the closeup view
  bSzROI = 5;          % Border size of the ROI
  wCloseup = round([size(I, 1) size(I, 1)] ./ length(vi) - bSzCloseup * 2); % width of the closeup
  wROI = 150;          % Width in pixels of the ROI

  % Randomly generate Region of interest boundary colors
  cROI = perms([1 1 0 0]);
  cROI = unique(cROI(:, 2:end), 'rows');
  cROI = cROI(randperm(size(cROI, 1)), :);
    
  im = squeeze(I(:, :, :, cviewIdx, cviewIdx));

  % Handle situations in which the point of interest is too close to the edge of the image
  idx = pROI(:, 1) - wROI/2 < 1;
  pROI(idx, 1) = wROI/2 + 1;
  idx = pROI(:, 2) - wROI/2 < 1;
  pROI(idx, 2) = wROI/2 + 1;
  idx = pROI(:, 1) + wROI/2 > size(im, 1);
  pROI(idx, 1) = size(im, 1) - wROI/2;
  idx = pROI(:, 2) + wROI/2 > size(im, 2);
  pROI(idx, 2) = size(im, 1) - wROI/2;

  f = figure('Position', [0 0 wCloseup(1) * size(pROI, 1) * size(labels, 5) wCloseup(2) * length(vi)], 'visible', 'off');
  [ha, ~] = tight_subplot( length(vi), size(labels, 5) * size(pROI, 1), 0.005, 0.15, 0.15);

  for i = 1:size(pROI, 1) % iterate over all ROIs

    % Draw the ROI on the central image
    im = drawROI(im, pROI(i, :), wROI, bSzROI, cROI(i, :));

    for j = 1:size(labels, 5) % iterate over different algorithm outputs
      L = squeeze(labels(:, :, :, :, j));

      for k = 1:length(vi) % iterate over selected light field views
	set(f,'CurrentAxes', ha((k - 1) * size(labels, 5) * size(pROI, 1) + j + ((i - 1) * size(labels, 5)) ));
  	imc = addBorder(imresize(boundary(closeup(squeeze(I(:, :, :, vi(k), ui(k))), ...
		  				  pROI(i, :), ...
						  wROI), ...
					  closeup(squeeze(L(:, :, vi(k), ui(k))), ...
						  pROI(i, :), ...
						  wROI), ...
					  repelem(graySpxBoundary, 1, 3) ), ...
				 wCloseup ), ...
			bSzCloseup, cROI(i, :) );
	imshow(imc);

	set(gca, 'FontSize', 20);
	if(j == 1 && i == 1)
	  ylabel(['View (', int2str(vi(k)) ', ' int2str(ui(k)) ')']);
          yh = get(gca,'ylabel'); 
          p = get(yh,'position');
          p(1) = 0.1*p(1);    
          set(yh,'position',p);
	end
	if(k == length(vi))
	  xlabel(algorithmNames{j});
          xh = get(gca,'xlabel'); 
          p = get(xh,'position');
          p(2) = 0.9*p(2);    
          set(xh,'position',p);
	end
      end
	   
    end

  end

  saveas(f, [fout '/' fname '-roi-detail'], 'png');
  imwrite(im, [fout '/' fname '-roi.png']);
end
