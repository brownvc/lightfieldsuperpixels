%%
%% Load the light field ground truth labels for the Old HCI dataset into
%% a 4D array: (y, x, v, u).
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
%% The input file should be in .h5 format.

function Lbl = HCIloadLabels( fin, flipu, flipv )

  % Read light field from a .H5 file
  Lbl = h5read(fin, '/GT_LABELS');

  % Arrange the light field views to follow the dimensional format
  % outlined above
  Lbl = permute(Lbl, [2 1 4 3]);

  % Make sure the camera is moving to the left in both u & v directions
  % for our method to work.
  if flipu
    Lbl = flip(Lbl, 4);
  end
  if flipv
    Lbl = flip(Lbl, 3);
  end
end
