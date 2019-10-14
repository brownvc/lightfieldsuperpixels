%%
%% Convert the line set L into a set of EPI segments.
%%
%% The result is returned in two formats:
%% In M (size: n x 2), each EPI segment is represented as 
%% a pair of indices into the corresponding set in L.
%% In S (size: n x 4), the top and bottom intercepts of the 
%% two bounding lines are returned.
%%
function [M, S] = lines2matches(L, Lc, szEPI)
  S = cell(size(L));
  M = cell(size(L));
  parfor i = 1:szEPI(3)
     lines = cell2mat(L(i));

     % Get the pairwise line matches, 
     % Each pairwise line match represents a segmented EPI region
     [seg, ~] = match(lines, Lc(:, :, i));

     M{i} = seg;
     S{i} = [ lines( seg(:, 1), :) lines( seg(:, 2), :) ];
   end

end
