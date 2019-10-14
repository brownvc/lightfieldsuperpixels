%%
%% Run the k-means baseline on the given old HCI light field
%%
function lout = kmOnHCI(fin)

  LF = HCIloadLF(fin, 0, 1, 'lab');
  D = HCIloadDisparity(fin, 0, 1);

  szLF = [size(LF, 1) size(LF, 2) size(LF, 4) size(LF, 5)]; % light field size in y, x, v, u
  cviewIdx = ceil(szLF(3)/2);

  % central view disparity
  dc = -D(:, :, 2, cviewIdx - 1, cviewIdx); % negative since original is from side-to-center

  % Superpixel size
  spSz = 20;
  param = parameters;

  lc = km( LF(:, :, :, cviewIdx, cviewIdx), dc, spSz, param.wlab, param.wxy, param.wz);
  lout = kmproj(lc, dc, cviewIdx, cviewIdx, szLF);

  for vi = 1:szLF(3)
    for ui = 1:szLF(4)
      lout(:, :, vi, ui) = kmfill(lout(:, :, vi, ui), LF(:, :, :, vi, ui), 20);  
    end
  end

end
