%%
%% Run the segmentation code on multiple lightfields, 
%% saving results to file. 
%%
function runOnLightfields ( D )
  addpath('./prop', './lines', './seg', './util');
  
  % Results are saved in a a folder with the current timestamp as the name
  %
  tstamp = datestr(datetime, 'dd-mmm-yyyy HHMM');
  tstamp( isspace(tstamp) ) = '_';
  folder = ['./results/' tstamp 'hrs'];
  mkdir(folder);

  % The output file name is the name of the input .H5 file, or the name of 
  % the input folder containing the light field images
  fout = {};
  for i = 1:length(D)
    [filepath, name, ext] = fileparts( D{i} );
    if isempty(ext)
      str = D{i};
      if str(end) == '/'
        str(end) = [];
      end
      s = strsplit(str, '/');
      fout{i} = s{end};
    else
      fout{i} = [name];
    end
  end

  % Run parameters
  % Change these to evaluate the output with different settings for different 
  % light fields
  param = parameters;

  % Initialize Matlab's parpool
  cluster = parcluster('local');
  cluster.NumWorkers = param.nWorkers;
  saveProfile(cluster);
  
  delete(gcp('nocreate'));
  parpool(param.nWorkers);

  % Run...
  for i = 1:length(D)

    % Load the lightfield images
    %LF = loadLF( D{i}, param.uCamMovingRight, param.vCamMovingRight, 'lab');

    % Uncomment the following line if you would like to use the utility function for 
    % reading the .H5 files of the old HCI dataset.
    LF = HCIloadLF( D{i}, 'lab');

    if isempty(LF)
      return;
    end

    VCLFS( LF, [folder '/' fout{i}], param); 
  end
end
