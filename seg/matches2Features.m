%%
%% Extract a feature vector for each matched region
%%
function [features, L] = matches2Features(M, L, dispMap, EPI)
  szEPI = [size(EPI, 1) size(EPI, 2) size(EPI, 4)];
  features = cell(size(M));

  for i = 1:szEPI(3)
     m = M{i};
     l = L{i};

     % Split matched segments that are longer than a threshold
     [m, l] = matchSplit(m, l, dispMap(i, :), szEPI);

     % Get the average LAB color of the EPI segment bounded by the matched lines
     [featuresLAB, featuresIdx] = matchFeaturesLAB(m, l, EPI(:, :, :, i));

     % Discard matched segments that are entirely occluded
     m = m(featuresIdx, :);
     featuresLAB = featuresLAB(featuresIdx, :);

     % The final set of features has size (n x 8) and is made up of 
     % the top and bottom intercepts of the two bounding lines (4 features), 
     % the EPI index (1 feature), and the LAB color (3 features)
     features{i} = [ matches2parallelograms(m, l), repelem(i, size(featuresLAB, 1), 1), featuresLAB];
     L{i} = l;
   end

end
