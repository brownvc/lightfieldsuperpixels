%%
%% Constants used by the algorithms
%% These should not be changed. Any run specific parameters can
%% be set in Param.m
%%
classdef const
   properties (Constant = true)

     % Propagation & Label Filling
     PropGuidedFilterNhoodSize = [7 7];
     PropGuidedFilterDegSmoothing = 75;
     PropWinSz = 10;
     PropWxy = 1.0;
     PropWlab = 1.0;
     PropWz = 1e-5;

     FillWinSz = 3;
     FillWxy = 3.0;
     FillWlab = 1.0;
     
     % Edge Detection & Line Fitting
     SegMinWidthMultiplier = 0.22;
     LineSparsifyMultiplier = 3;
     OutlierRejectionWinSzMultiplier = 0.065;

     % Line Matching
     SegMaxWidth = 15;
     MatchWeightDepth = 0.15;
     MatchWeightDistance = 1 - const.MatchWeightDepth;
     SegOccEdgeWindowSize = 10;      

     % Segment Clustering
     KmeansIterations = 20;
   end
end
