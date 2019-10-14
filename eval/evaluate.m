%%
%% Use this function to generate all quantitative and qualitative evaluation results, 
%% including comparisons with our method, the k-means baseline, and LFSP on the old
%% HCI dataset.
%% 
%% The only arguments to the function are the path to the folder with your algorithm's 
%% results, and the output directory.
%%
%% The folder should contain a .mat file for each superpixel size (e.g. out_10.mat, 
%% out_25.mat, out.mat, etc). The file name is irrelevant -- the superpixel size is 
%% calculated automatically. But it's important to have only one result per .mat file.
%% 
%% The result should be a 4D array of light field labels indexed in order (y, x, v, u).
%%
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
%% If you compare to our algorithm, the k-means baseline, or LFSP, please remember to 
%% cite the following papers:
%%
%% @article{khan2019vclfs,
%%   title={View-consistent 4D Lightfield Superpixel Segmentation},
%%   author={Numair Khan, Qian Zhang, Lucas Kasser, Henry Stone, Min H. Kim, and James Tompkin},
%%   journal={International Conference on Computer Vision},
%%   year={2019},
%% }
%%
%% @inproceedings{zhu20174d,
%%   title={4D light field superpixel and segmentation},
%%   author={Zhu, Hao and Zhang, Qi and Wang, Qing},
%%   booktitle={Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition},
%%   pages={6384--6392},
%%   year={2017}
%%}
function evaluate( fin, fout, path2HCI )

  % HCI dataset light fields
  param = parameters;
  param.evalFilePathHCI = path2HCI;
  datasets = {'buddha', 'papillon', 'horses', 'stillLife'};
  datasetFiles = cell(length(datasets), 1);

  files = dir(fullfile(fin, '*.mat'));

  % A structure to hold the different evaluation results for the four
  % HCI light fields and all superpixel sizes
  Results.avgSzSuperpix = cell( length(datasets), 1);
  Results.aa = cell( length(datasets), 1 );
  Results.ue = cell( length(datasets), 1 );
  Results.br = cell( length(datasets), 1 );
  Results.cp = cell( length(datasets), 1 );
  Results.ss = cell( length(datasets), 1 );
  Results.lp = cell( length(datasets), 1 );

  % Evaluate metrics on users' results...
  %
  for i = 1:length(files)

    filename = fullfile(fin, files(i).name);
    
    disp(['Evaluating ' filename]);
    labels = struct2cell(load(filename));
    labels = labels{1};

    % Find which HCI dataset this labeling is of
    if ~isempty(strfind(files(i).name, 'buddha'))
      j = 1;
    elseif ~isempty(strfind(lower(files(i).name), 'papillon')) | ~isempty(strfind(files(i).name, 'butterfly'))
      j = 2;
    elseif ~isempty(strfind(lower(files(i).name), 'horses'))
      j = 3;
    elseif ~isempty(strfind(lower(files(i).name), 'stilllife'))
      j = 4;
    else
      disp(['WARNING! Could not recognize dataset for file ' files(i).name '. Skipping.']);
      disp('Please make sure the file name contains (buddha|horses|papillon|stilllife) to identify the HCI light field');
    end
    datasetFiles(j) = {cat(1, datasetFiles{j}, convertCharsToStrings(fullfile(fin, files(i).name)))};

    % Calculate average superpixel size
    avgSz = avgSzSuperpixels(labels);
    Results.avgSzSuperpix(j) = {[Results.avgSzSuperpix{j} avgSz]};
    disp(['  Average superpixel size: ' num2str(avgSz)]);

    % Evaluate metrics 
    disp('  Evaluating metrics...');
    [aa, ue, br, cp, ss, lp] = HCIevalOnDataset(labels, datasets{j}, param);

    Results.aa(j) = {[Results.aa{j} aa]};
    Results.ue(j) = {[Results.ue{j} ue]};
    Results.br(j) = {[Results.br{j} br]};
    Results.cp(j) = {[Results.cp{j} cp]};
    Results.ss(j) = {[Results.ss{j} ss]};
    Results.lp(j) = {[Results.lp{j} lp]};
  end

  filename = fullfile(fout, 'eval.mat');
  save(filename, 'Results');

  % Generate quantitative comparison figures with our method, LFSP, and the k-means baseline
  plotComparisonQuantitative( fout, fout );

  % Generate qualitative comparison figures for the HCI dataset...
  for d = 1:length(datasets)
    % Load pre-computed results for the HCI dataset
    vclfs = struct2cell(load(['./results/VCLFS/' datasets{d} '20.mat']));
    vclfs = vclfs{1};
    lfsp = struct2cell(load(['./results/LFSP-Wang/' datasets{d} '20.mat']));
    lfsp = lfsp{1};
    kmeans = struct2cell(load(['./results/k-means-Wang/' datasets{d} '20.mat']));
    kmeans = kmeans{1};

    [~, o] = sort(abs(Results.avgSzSuperpix{d} - 20));
    files = datasetFiles{d};
    filename = files(o(1));
    usersResults = struct2cell(load(filename));
    usersResults = usersResults{1};

    if strcmp( datasets{d}, 'buddha') 
      LF = HCIloadLF( [param.evalFilePathHCI '/' datasets{d} '/buddha.h5'], 0, 1, 'rgba' );
    else
      LF = HCIloadLF( [param.evalFilePathHCI '/' datasets{d} '/lf.h5'], 0, 1, 'rgba' );
    end
    plotComparisonQualitative( fout, datasets{d}, LF, usersResults, vclfs, lfsp, kmeans);
  end
end
