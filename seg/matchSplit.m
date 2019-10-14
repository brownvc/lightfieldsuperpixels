%%
%% Split matched regions that are longer than a threshold into 
%% smaller sub-regions
%%
%% The split is done by adding new line in between two matched lines.
%% To regularize the split regions across U and V directions, the slope
%% of the added lines comes from the estimated disparity map d
%%
function [m, lines] = matchSplit(m, lines, d, szEpi)

  while(true)

    % Find the smaller distance between the top and bottom endpoints of 
    % the lines forming each match
    dt = lines(m(:, 2), 1) - lines(m(:, 1), 1);
    db = lines(m(:, 2), 2) - lines(m(:, 1), 2);

    [D Di] = min([dt db], [], 2);
    idx = D > const.SegMaxWidth;
    
    n = sum(idx);
    if n <= 0
      % No more large matched regions remain, return.
      break;
    end

    % The slope/disparity of each match is taken as the minimum of the slope of 
    % the two bounding lines
    dx = min(lines(m(idx, 1), 2) - lines(m(idx, 1), 1), lines(m(idx, 2), 2) - lines(m(idx, 2), 1));
    Di = Di(idx);

    % The splitting line will be added at the midpoint of the segment
    mid = round((lines(m(idx, 1), 1) + dt(idx)/2 + lines(m(idx, 1), 2) + db(idx)/2)/2);
    dx = d(mid)';

    midt = mid - dx .* (ceil(szEpi(1) ./ 2) - 1);
    midb = mid + dx .* (ceil(szEpi(1) ./ 2) - 1);

    j = [1:n]' + size(lines, 1); % the indices of the newly added lines
    k = m(idx, 2);
    m(idx, 2) = j;

    % Update the set of matches ...
    m = cat(1, m, [j k]);

    % ... And also the set of lines to include the newly added lines.
    lines = cat(1, lines, [midt midb]);
  end
end
