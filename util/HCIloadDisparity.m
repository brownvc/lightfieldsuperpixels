%%
%% Load the light field ground truth disparity maps for the Old HCI dataset into
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
%% The function returns a 5D array of disparity maps in format (y, x, d, v, u)
%% where d = 2 determines the disparity direction (horizontal or vertical views)
%% The disparity estimate is from the side to center views in each direction, with
%% the disparity at each pixel in the center view being zero.

function D = HCIloadDisparity( fin, flipu, flipv )

  % Read depth data from the .H5 file, and rearrange dimensions according
  % to the above specifications (y, x, v, u)
  Z = h5read(fin, '/GT_DEPTH');
  Z = permute(Z, [2 1 4 3]);

  % Read camera configuration information required to go from depth to disparity
  dH = h5readatt(fin, '/', 'dH');
  f = h5readatt(fin, '/', 'focalLength');
  shift = h5readatt(fin, '/', 'shift');

  cviewIdx = ceil(size(Z, 3) / 2);
  D = zeros( [size(Z, 1) size(Z, 2) 2 size(Z, 3) size(Z, 4)] );

  for v = 1:size(Z, 3)
    for u = 1:size(Z, 4)
      d = sqrt( (cviewIdx - u).^2 + (cviewIdx - v).^2);
      D(:, :, 1, v, u) = (dH * (cviewIdx - u)) * f ./ Z(:,:, v, u) - shift * (cviewIdx - u);
      D(:, :, 2, v, u) = (dH * (cviewIdx - v)) * f ./ Z(:,:, v, u) - shift * (cviewIdx - v);
    end
  end

  % Make sure the camera is moving to the left in both u & v directions
  % for our method to work.
  if flipu
    D = flip(D, 5);
  end
  if flipv
    D = flip(D, 4);
  end
end
