%%
%% Given an edge confidence map C and a slope map Z, fit the line
%% templates provided in T to the edges. The slope of each line in T
%% is provided in m.
%%
%% The function returns a line set L, where each line is defined by its
%% top and bottom intercept on an EPI. The corresponding confidence of
%% each line is returned in Lc.
%%
function [L, Lc] = edges2lines( C, Z, T, m )
  szEpi = size(C);
  L = cell(szEpi(3), 1);
  Lc = cell(szEpi(3), 1);

  parfor i = 1:szEpi(3)
    [lines, conf] = fitLinesEPI( C(:, :, i), Z(:, :, i), T, m); 

    % Add dummy lines for the image edges
    lines = cat(1, lines, [1 1; szEpi(2) szEpi(2)]);
    conf = cat(1, conf, [max(conf); max(conf)]);

    L(i) = {lines};
    Lc(i) = {conf};
  end

end
