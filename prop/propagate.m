
function labelsSparse = propagate(labelsSparse, LF, viewDisp, viewIdx, szLF)

  % Get the indices of the pixels which are unlabeled in the sparse label map
  viewSparseLbl = labelsSparse(:, :, viewIdx(1), viewIdx(2));
  [Y, X] = find( viewSparseLbl <= 0 );

  % Label propagation uses the color, spatial proximity, and disparity estimate
  % of neighborhood pixels to label an unlabelled pixel...
  viewColor = imguidedfilter(LF(:, :, :, viewIdx(1), viewIdx(2)), ...
			     'NeighborhoodSize', const.PropGuidedFilterNhoodSize, ...
			     'DegreeOfSmoothing', const.PropGuidedFilterDegSmoothing);
  viewDisp( viewSparseLbl == 0 ) = inf;

  w = szLF(2);
  h = szLF(1);
       
  for k = 1:size(Y, 1)
    x = X(k); 
    y = Y(k);

    % top, bottom, left, right of neighborhood window
    nt = max(1, y - const.PropWinSz); 
    nb = min(h, y + const.PropWinSz);
    nl = max(1, x - const.PropWinSz);
    nr = min(w, x + const.PropWinSz);

    nhood = viewSparseLbl(nt:nb, nl:nr);
    [lbly, lblx] = find(nhood > 0);
    if isempty( lbly )
      continue;
    end

    % Get the image space indices of the labeled pixels in the neighborhood
    idx = sub2ind([h w], lbly + nt - 1, lblx + nl - 1);

    z = viewDisp(idx);
    [zu, ~, zuIdx] = unique(z);
    dz = crossViewDistance(viewIdx(1), viewIdx(2), x, y, zu, LF, szLF);
    [~, zminIdx] = min(dz);
    dz = dz(zuIdx);
    zmin = zu(zminIdx);

    dlab = (viewColor(y, x, 1) - viewColor(idx)).^2 + ...
	   (viewColor(y, x, 2) - viewColor(idx + w * h)).^2 + ...
	   (viewColor(y, x, 3) - viewColor(idx + w * h * 2)).^2;
    dxy = (lblx - size(nhood, 2)./2 ).^2 + (lbly - size(nhood, 1)./2 ).^2;
    d = const.PropWlab .* dlab + ...
	const.PropWxy  .* dxy  + ...
	const.PropWz   .* dz;

    [~, minIdx] = min(d);
    label = nhood( lbly(minIdx), lblx(minIdx) );

    labelsSparse(y, x, viewIdx(1), viewIdx(2)) = label;
    %zmin = z(minIdx);

    % Reproject label into other views based on estimated disparity
    for v = 1:szLF(3)
      for u = 1:szLF(4)
	xproj = round(min(max(1, x + zmin  * (u - viewIdx(2))), w));
	yproj = round(min(max(1, y + zmin  * (v - viewIdx(1))), h));

	if ( labelsSparse(yproj, xproj, v, u) == 0)
	  labelsSparse( yproj, xproj, v, u ) = label;
	end
      end
    end

  end
end
