%%
%% The energy function for bipartite matching
%%
function g = segGain(i, j, l)
  g = 1 ./ (const.MatchWeightDepth * abs( (l(i, 1) - l(j, 1)) -  (l(i, 2) - l(j, 2)) ) ...
	    + const.MatchWeightDistance * abs( (l(i, 1) + l(i, 2))./2 - (l(j, 1) + l(j, 2))./2 ));
return;
