%%
%% Merge two sets of lines.
%% Lines are defined by their top and bottom intercepts on an EPI.
%% If cull is set to true, any line in L2 within cullrange of 
%% a line in L1 will be culled. Any lines in L2 that intersect lines 
%% in L1 will also be culled. 
%%
function L = mergeLines(L1, L2, cull, cullRange)
  L = L1;

  parfor i = 1:length(L2)
    q = cell2mat(L1(i));
    r = cell2mat(L2(i));

    if isempty(r) | isempty(q)
      L(i) = {[r; q]};
      continue;
    end

    if cull
      % Create matrices U, V to compare the top intercepts of each line in L1
      % to each line in L2. Matrices X, Y do the same for the bottom intercepts.
      U = repelem(q(:, 1), 1, size(r, 1));
      V = repelem(r(:, 1)', size(q, 1), 1);
      X = repelem(q(:, 2), 1, size(r, 1));
      Y = repelem(r(:, 2)', size(q, 1), 1);

      idx1 = sum(abs(U - V) <= cullRange & abs(X - Y) <= cullRange, 1) > 0;
      idx2 = sum((U < V & X > Y) | (U > V & X < Y)) > 0; % intersecting lines

      r = r(~(idx1 | idx2), :);
    end

    L(i) = {[r; q]};
  end
end
