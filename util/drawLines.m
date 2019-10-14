%%
%% Utility function to draw vertically spanning EPI lines 
%%
function bw = drawLines(lines, sz)

  bw = zeros(sz, 'logical');

  for i = 1:size(lines, 1)
    x = [lines(i, 1) lines(i, 2)];  
    y = [1 sz(1)];                  
    nPoints = max(abs(diff(x)), abs(diff(y)) ) + 1; 
    rIndex = max(1, min(round(linspace(y(1), y(2), nPoints)), sz(1)));
    cIndex = max(1, min(round(linspace(x(1), x(2), nPoints)), sz(2)));
    index = sub2ind(sz, rIndex, cIndex);
    bw(index) = 1;
  end
end


