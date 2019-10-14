%%
%% Compactness provides a measure of superpixel boundary curvature. 
%% We use Schick et al.'s compactness metric:
%% 
%% @inproceedings{schick2012measuring,
%%   title={Measuring and evaluating the compactness of superpixels},
%%   author={Schick, Alexander and Fischer, Mika and Stiefelhagen, Rainer},
%%   booktitle={Proceedings of the 21st international conference on pattern recognition (ICPR2012)},
%%   pages={930--934},
%%   year={2012},
%%   organization={IEEE}
%% }
%%
function c = metricCompactness(labels)
  labeluv = labels(:, :, ceil(size(labels, 3)/2), ceil(size(labels, 4)/2));
  u = unique(labeluv);
  c = zeros(length(u), 1);

  parfor i = 1:length(u)
    lbl = u(i);
    p = sum(sum(bwperim(labeluv == lbl)));;
    a = sum(sum(labeluv == lbl));
    qs = 4 * pi * a / (p.^2);
    c(i) = qs .* a ./ (size(labeluv, 1) .* size(labeluv, 2));
  end

  c = median(c);
end
