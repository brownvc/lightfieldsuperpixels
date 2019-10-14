%%
%% Reproject the input segments into another row/column of light field views. 
%% Reprojection involves changing the EPI index of the segment, and is done
%% based on disparity. The viewOffset parameter specifies the offset of the 
%% row/column of views from the central one:
%%
%%          S -----------------> R      
%%        _____  .....  .....  _____
%%        |   |  :   :  :   :  |   |
%%        |___|  :...:  :...:  |___|
%%        _____  .....  .....  _____
%%        |   |  :   :  :   :  |   | 
%%        |___|  :...:  :...:  |___|
%%        _____  .....  .....  _____
%%        |   |  :   :  :   :  |   |
%%        |___|  :...:  :...:  |___|
%%
%%               |_________________| viewOffset = 3 

function R = segsReproject(S, viewOffset, sz)
  V = vertcat(S{:});
  d = (V(:, 2) - V(:, 1)) ./ sz(3);

  % Recalculate the EPI index feature based on disparity and viewOffset
  V(:, end-1) = round(V(:, end-1) + d * viewOffset);

  % Regroup V into cells based on EPI index
  u = [1:size(S, 1)]'; 
  u = num2cell(u, 2);
  R = cellfun(@(ui) V( V(:, end-1) == ui, :), u, 'UniformOutput', false);
end
