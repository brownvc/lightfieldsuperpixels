%%
%% Utility function that evaluates all metrics on the given superpixel labeling of the 
%% old HCI dataset. The metrics evaluated are achievable seg. accuracy, boundary recall,
%% undersegmentation error, compactness, self-similarity error, and average labels per pixel.
%%
%% Before calling the function, please make sure:
%%
%% 1. The path to the Old HCI light field dataset on the local machine has been correctly
%%    set in parameters.evalFilePathHCI.
%%
%%    The HCI dataset can be downloaded from: 
%%    http://lightfieldgroup.iwr.uni-heidelberg.de/?page_id=713
%%
%% 2. The input superpixel label maps are indexed in order (y, x, v, u).
%%                  u
%%    ---------------------------->
%%    |  ________    ________
%%    | |    x   |  |    x   |
%%    | |        |  |        |
%%  v | | y      |  | y      | ....
%%    | |        |  |        |     
%%    | |________|  |________|
%%    |           :
%%    |           :
%%    v
%%
function [aa, ue, br, cp, ss, lp] = HCIevalOnDataset(labels, dataset, param)
  
  aa = 0;
  ue = 0;
  br = 0;
  cp = 0;
  ss = 0;
  lp = 0;

  % Load ground truth disparity and label maps. 
  % Note: the Old HCI dataset uses a different name for the disparity file of 
  % the Buddha light field
  %
  if strcmp( dataset, 'buddha') 
    dispGT = HCIloadDisparity( [param.evalFilePathHCI '/' dataset '/buddha.h5'], 0, 1 );
  else
    dispGT = HCIloadDisparity( [param.evalFilePathHCI '/' dataset '/lf.h5'], 0, 1 );
  end

  labelsGT = HCIloadLabels( [param.evalFilePathHCI '/' dataset '/labels.h5'], 0, 1);

  % Evaluate metrics...
  %
  aa = metricAchievableAccuracy(labels, labelsGT);
  br = metricBoundaryRecall(labels, labelsGT);
  ue = metricUndersegmentationError(labels, labelsGT);
  cp = metricCompactness(labels);
  ss = metricSelfSimilarityError(labels, dispGT);
  lp = metricLabelsPerPixel(labels, dispGT);

end
