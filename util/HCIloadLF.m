%%
%% Load the light field images for the Old HCI dataset into a 
%% 5D array: (y, x, rgb, v, u)
%% Indices of the returned array follow Matlab's convention of (row, column):
%%                 u
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

function LF = HCIloadLF( fin, cspace)

  % Read light field from .H5 file
  LF = h5read(fin, '/LF');

  % Arrange the light field views to follow the dimensional format
  % outlined above
  LF = permute(LF, [3 2 1 5 4]);

  % Convert to desired image format
  if strcmp(cspace, 'lab')
    LF = rgb2lab(LF);
  elseif strcmp(cspace, 'ycbcr')
    LF = rgb2ycbcr(LF);
  else 
    LF = im2double(LF);		  
  end  

  % Flip in the v direction to ensure proper occlusion order in EPI
  LF = flip(LF, 4);
end
