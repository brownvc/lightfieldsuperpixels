%%
%% Project the given labeling for view (v, u) of the light field
%% into all other views based on the disparity map provided for 
%% the center view. We assume the light field under consideration is
%% regular, so that the disparity is the same in both horizontal and
%% vertical directions.
%%
%% Note: this code has not been optimized.
%% 
function lout = kmproj(labels, disparity, v, u, szLF)
  lout = zeros( szLF );
  lout(:, :, v, u) = labels;
  zout = zeros( szLF );

  for x = 1:szLF(2)
    for y = 1:szLF(1)
      for ui = 1:szLF(4)
	for vi = 1:szLF(3)
	  xproj = min(max(1, x + disparity(y, x) * (ui - u)), szLF(2));
	  yproj = min(max(1, y + disparity(y, x) * (vi - v)), szLF(1));

	  xprojc = ceil(xproj);
	  xprojf = floor(xproj);
	  yprojc = ceil(yproj);
	  yprojf = floor(yproj);

	  d = disparity(y, x);

	  if lout(yprojc, xprojc, vi, ui) == 0 | ...
		zout(yprojc, xprojc, vi, ui) <= d
	    lout(yprojc, xprojc, vi, ui) = labels(y, x);
	    zout(yprojc, xprojc, vi, ui) = d;
	  end

	  if lout(yprojf, xprojf, vi, ui) == 0 | ...
		zout(yprojf, xprojf, vi, ui) <= d
	    lout(yprojf, xprojf, vi, ui) = labels(y, x);
	    zout(yprojf, xprojf, vi, ui) = d;
	  end

	  if lout(yprojc, xprojf, vi, ui) == 0 | ...
		zout(yprojc, xprojf, vi, ui) <= d
	    lout(yprojc, xprojf, vi, ui) = labels(y, x);
	    zout(yprojc, xprojf, vi, ui) = d;
	  end

	  if lout(yprojf, xprojc, vi, ui) == 0 | ...
		zout(yprojf, xprojc, vi, ui) <= d
	    lout(yprojf, xprojc, vi, ui) = labels(y, x);
	    zout(yprojf, xprojc, vi, ui) = d;
	  end
	end

      end
    end
  end

end
