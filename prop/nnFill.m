function viewSparseLbl = nnFill( viewSparseLbl, viewColor )
  
  w = size( viewSparseLbl, 2);
  h = size( viewSparseLbl, 1);

  viewColor = imguidedfilter(viewColor, ...
			     'NeighborhoodSize', const.PropGuidedFilterNhoodSize, ...
			     'DegreeOfSmoothing', const.PropGuidedFilterDegSmoothing);
  [Y, X] = find( viewSparseLbl <= 0 );

  for k = 1:size(Y, 1)
    x = X(k); 
    y = Y(k);

    % top, bottom, left, right of neighborhood window
    nt = max(1, y - const.FillWinSz); 
    nb = min(h, y + const.FillWinSz);
    nl = max(1, x - const.FillWinSz);
    nr = min(w, x + const.FillWinSz);

    nhood = viewSparseLbl(nt:nb, nl:nr);
    [lbly, lblx] = find(nhood > 0);
    if isempty( lbly )
      continue;
    end

    % Get the image space indices of the labeled pixels in the neighborhood
    idx = sub2ind([h w], lbly + nt - 1, lblx + nl - 1);

    dc = (viewColor(y, x, 1) - viewColor(idx)).^2 + ...
	 (viewColor(y, x, 2) - viewColor(idx + w * h)).^2 + ...
	 (viewColor(y, x, 3) - viewColor(idx + w * h * 2)).^2;
    dxy = (lblx - size(nhood, 2)./2 ).^2 + (lbly - size(nhood, 1)./2 ).^2;
    d = const.FillWlab .* dc + const.FillWxy .* dxy;

    [~, minIdx] = min(d);
    label = nhood( lbly(minIdx), lblx(minIdx) );
    viewSparseLbl(y, x) = label;
  end


end

