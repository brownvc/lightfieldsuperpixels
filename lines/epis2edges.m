%%
%% Detect edges by directional filtering with the filters provided
%% in F. The gradient of each filter is specified in gx, and gy
%%
function [C, Z] = epis2edges( EPI, F, gx, gy )
  szEpi = [size(EPI, 1) size(EPI, 2) size(EPI, 4)];
  C = zeros( szEpi );
  Z = zeros( szEpi );

  parfor i = 1:szEpi(3)
    [C(:, :, i) Z(:, :, i)] = findEdgesEPI( EPI(:, :, :, i), F, gx, gy);
  end

end
