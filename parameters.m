
classdef parameters
   properties 

     % Multithreading
     nWorkers = 3;

     % The code requires the camera to move towards the RIGHT in both the horizontal (u) 
     % and vertical (v) directions. This ensures a uniform occlusion order for lines
     % in an EPI based on slope. 
     % Set the following parameters to ensure the light field is loaded in the 
     % correct order.
     uCamMovingRight = false;
     vCamMovingRight = true;

     % evaluation parameters
     evalFilePathHCI = './HCI';

     % Line Detection pyramid levels
     linesPyramidLevels = 2;

     % The maximum absolute disparity between two adjacent light field views
     maxAbsDisparity = 1.66; 
     
     % The different superpixel sizes to run the algorithm for
     szSuperpixels = [20];

     % Weights ...
     % See the supplemental document for a description of the effect of these
     % weights on the output of the algorithm.
     wxy = 1.0;
     wlab = 2.0;
     wz = 120.0;
   end
end
