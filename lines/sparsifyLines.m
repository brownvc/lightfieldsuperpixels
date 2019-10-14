%%
%% A dense set of EPI lines close to each other are made sparse.
%% Lines are defined by their top and bottom intercepts on an EPI.
%% The range parameter determines a 'dense' set of lines is.
%%
%% This function is used when merging lines from the vertical and
%% horizontal EPIs: any horizontal line in the spatial domain would 
%% appear as a dense block of lines in the horizontal EPI, and
%% vice versa. This makes subsequent matching difficult, especially 
%% if the lines intersect. To remedy this, we remove some of the lines.
%% 
function L = sparsifyLines(L, range)

  for i = 1:length(L)
    q = cell2mat(L(i));

    if isempty(q)
      L(i) = {q};
      continue;
    end

    % Create matrices U, V to compare the top intercept of each line to the top 
    % intercept of every other line. X, Y do the same for bottom intercepts.
    U = repelem(q(:, 1), 1, size(q, 1));
    V = repelem(q(:, 1)', size(q, 1), 1);
    X = repelem(q(:, 2), 1, size(q, 1));
    Y = repelem(q(:, 2)', size(q, 1), 1);

    % Find all pairs of line closer than const.LineSparsifyMultiplier * range
    M = (abs(U - V) < const.LineSparsifyMultiplier * range) ...
	& (abs(X - Y) < const.LineSparsifyMultiplier * range);
    M = M .* (1 - eye(size(M, 1)));

    idx = ones(size(q, 1), 1, 'logical');

    % Retain only one of the pair of close lines
    while(sum(sum(M)) > 0)
      [r, c] = find(M > 0);
      r = r(1);
      c = c(1);
      M(r, :) = 0;
      M(:, r) = 0;
      idx(r) = 0;
    end
    L(i) = {q(idx, :)};
  end
end
