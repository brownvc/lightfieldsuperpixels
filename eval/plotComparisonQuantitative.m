%%
%% Plot quantitative results in the specified output folder,
%% comparing custom results to our method (vclfs), lfsp, 
%% and the k-means baseline.
%%
%% The function assumes a file named eval.mat with evaluation
%% results for the custom method already exists in the fin folder.
%% It is recommended to use evaluate.m, which will automatically 
%% generate eval.m and plot the results.
%%
function plotComparisonQuantitative( fin, fout )

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  DISPLAY PARAMETERS - Set these to control properties of the output figure    %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% The names of algorithms to display. Set only {6}
  algorithmNames{1} = 'VCLFS';
  algorithmNames{2} = 'LFSP-Wang';
  algorithmNames{3} = 'LFSP-GT';
  algorithmNames{4} = 'K-means-Wang';
  algorithmNames{5} = 'K-means-GT';
  algorithmNames{6} = 'Current';

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  results = struct2cell(load(fullfile(fin, 'eval.mat')));
  results = results{1};

  vclfs = struct2cell(load('./results/VCLFS/eval.mat'));
  vclfs = vclfs{1};

  lfspGT = struct2cell(load('./results/LFSP-GT/eval.mat'));
  lfspWang = struct2cell(load('./results/LFSP-Wang/eval.mat'));
  lfspGT = lfspGT{1};
  lfspWang = lfspWang{1};

  kmeansGT = struct2cell(load('./results/k-means-GT/eval.mat'));
  kmeansWang = struct2cell(load('./results/k-means-Wang/eval.mat'));
  kmeansGT = kmeansGT{1};
  kmeansWang = kmeansWang{1};
  
  % Generate qualitative comparison figures...
  %
  datasets = {'Buddha', 'Papillon', 'Horses', 'StillLife'};
  methods = algorithmNames;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Individual Dataset Results %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Achievable Segmentation Accuracy
  %
  f = figure('Position', get(0, 'Screensize'), 'visible', 'off');
  for i = 1:length(datasets)
    subplot(1, length(datasets), i);
    plot(vclfs.avgSzSuperpix{i}, vclfs.aa{i}, 'k-o', ...
	 lfspWang.avgSzSuperpix{i}, lfspWang.aa{i}, ':x', ...
	 lfspGT.avgSzSuperpix{i}, lfspGT.aa{i}, '-s', ...
	 kmeansWang.avgSzSuperpix{i}, kmeansWang.aa{i}, '--d', ...
	 kmeansGT.avgSzSuperpix{i}, kmeansGT.aa{i}, '-.^', ...
	 results.avgSzSuperpix{i}, results.aa{i}, '--*');
    title(datasets{i});
    axis([10 45 0.96 1.0])
    xlabel('Superpixel size');
    ylabel('Achievable Segmentation Accuracy');
  end

  lgd = legend(methods);
  lgd.NumColumns = 3;
  lgd.Orientation = 'Horizontal';
  lgd.Location = 'southoutside';
  set(lgd,'Position', [0.4 0.3 0.2 0.025]);

  axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
  axis(axesHandles,'square')
  saveas(f, [fout '/aa'], 'png');

  % Boundary Recall
  %
  f = figure('Position', get(0, 'Screensize'), 'visible', 'off');
  for i = 1:length(datasets)
    subplot(1, length(datasets), i);
    plot(vclfs.avgSzSuperpix{i}, vclfs.br{i}, 'k-o', ...
	 lfspWang.avgSzSuperpix{i}, lfspWang.br{i}, ':x', ...
	 lfspGT.avgSzSuperpix{i}, lfspGT.br{i}, '-s', ...
	 kmeansWang.avgSzSuperpix{i}, kmeansWang.br{i}, '--d', ...
	 kmeansGT.avgSzSuperpix{i}, kmeansGT.br{i}, '-.^', ...
	 results.avgSzSuperpix{i}, results.br{i}, '--*');
    title(datasets{i});
    axis([10 45 0.6 1.01])
    xlabel('Superpixel size');
    ylabel('Boundary Recall');
  end

  lgd = legend(methods);
  lgd.NumColumns = 3;
  lgd.Orientation = 'Horizontal';
  lgd.Location = 'southoutside';
  set(lgd,'Position', [0.4 0.3 0.2 0.025]);

  axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
  axis(axesHandles,'square')
  saveas(f, [fout '/br'], 'png');

  % Undersegmentation Error
  %
  f = figure('Position', get(0, 'Screensize'), 'visible', 'off');
  for i = 1:length(datasets)
    subplot(1, length(datasets), i);
    plot(vclfs.avgSzSuperpix{i}, vclfs.ue{i}, 'k-o', ...
	 lfspWang.avgSzSuperpix{i}, lfspWang.ue{i}, ':x', ...
	 lfspGT.avgSzSuperpix{i}, lfspGT.ue{i}, '-s', ...
	 kmeansWang.avgSzSuperpix{i}, kmeansWang.ue{i}, '--d', ...
	 kmeansGT.avgSzSuperpix{i}, kmeansGT.ue{i}, '-.^', ...
	 results.avgSzSuperpix{i}, results.ue{i}, '--*');
    title(datasets{i});
    axis([10 45 0.0009 0.03])
    xlabel('Superpixel size');
    ylabel('Undersegmentation Error');
  end

  lgd = legend(methods);
  lgd.NumColumns = 3;
  lgd.Orientation = 'Horizontal';
  lgd.Location = 'southoutside';
  set(lgd,'Position', [0.4 0.3 0.2 0.025]);

  axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
  axis(axesHandles,'square')
  saveas(f, [fout '/ue'], 'png');

  % Compactness
  %
  f = figure('Position', get(0, 'Screensize'), 'visible', 'off');
  for i = 1:length(datasets)
    subplot(1, length(datasets), i);
    plot(vclfs.avgSzSuperpix{i}, vclfs.cp{i}, 'k-o', ...
	 lfspWang.avgSzSuperpix{i}, lfspWang.cp{i}, ':x', ...
	 lfspGT.avgSzSuperpix{i}, lfspGT.cp{i}, '-s', ...
	 kmeansWang.avgSzSuperpix{i}, kmeansWang.cp{i}, '--d', ...
	 kmeansGT.avgSzSuperpix{i}, kmeansGT.cp{i}, '-.^', ...
	 results.avgSzSuperpix{i}, results.cp{i}, '--*');
    title(datasets{i});
    axis([10 45 0 2.2e-3])
    xlabel('Superpixel size');
    ylabel('Compactness');
  end

  lgd = legend(methods);
  lgd.NumColumns = 3;
  lgd.Orientation = 'Horizontal';
  lgd.Location = 'southoutside';
  set(lgd,'Position', [0.4 0.3 0.2 0.025]);

  axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
  axis(axesHandles,'square')
  saveas(f, [fout '/cp'], 'png');

  % Self-similarity Error
  %
  f = figure('Position', get(0, 'Screensize'), 'visible', 'off');
  for i = 1:length(datasets)
    subplot(1, length(datasets), i);
    plot(vclfs.avgSzSuperpix{i}, vclfs.ss{i}, 'k-o', ...
	 lfspWang.avgSzSuperpix{i}, lfspWang.ss{i}, ':x', ...
	 lfspGT.avgSzSuperpix{i}, lfspGT.ss{i}, '-s', ...
	 kmeansWang.avgSzSuperpix{i}, kmeansWang.ss{i}, '--d', ...
	 kmeansGT.avgSzSuperpix{i}, kmeansGT.ss{i}, '-.^', ...
	 results.avgSzSuperpix{i}, results.ss{i}, '--*');
    title(datasets{i});
    if strcmp( datasets{i}, 'StillLife')
      axis([10 45 0 4])
    else
      axis([10 45 0 1.5])
    end
    xlabel('Superpixel size');
    ylabel('Self-similarity Error');
  end

  lgd = legend(methods);
  lgd.NumColumns = 3;
  lgd.Orientation = 'Horizontal';
  lgd.Location = 'southoutside';
  set(lgd,'Position', [0.4 0.3 0.2 0.025]);

  axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
  axis(axesHandles,'square')
  saveas(f, [fout '/ss'], 'png');

  % Self-similarity Error
  %
  f = figure('Position', get(0, 'Screensize'), 'visible', 'off');
  for i = 1:length(datasets)
    subplot(1, length(datasets), i);
    plot(vclfs.avgSzSuperpix{i}, vclfs.lp{i}, 'k-o', ...
	 lfspWang.avgSzSuperpix{i}, lfspWang.lp{i}, ':x', ...
	 lfspGT.avgSzSuperpix{i}, lfspGT.lp{i}, '-s', ...
	 kmeansWang.avgSzSuperpix{i}, kmeansWang.lp{i}, '--d', ...
	 kmeansGT.avgSzSuperpix{i}, kmeansGT.lp{i}, '-.^', ...
	 results.avgSzSuperpix{i}, results.lp{i}, '--*');
    title(datasets{i});
    set(gca, 'YScale', 'log');

    if strcmp( datasets{i}, 'StillLife')
      axis([10 45 2.5 18])
    else
      axis([10 45 2.5 4])
    end
    xlabel('Superpixel size');
    ylabel('Average number of labels per pixel');
  end

  lgd = legend(methods);
  lgd.NumColumns = 3;
  lgd.Orientation = 'Horizontal';
  lgd.Location = 'southoutside';
  set(lgd,'Position', [0.4 0.3 0.2 0.025]);

  axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
  axis(axesHandles,'square')
  saveas(f, [fout '/lp'], 'png');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Average Dataset Results %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%

  f = figure('visible', 'off');
  scalex = 1.2;
  scaley = 1.0;
  lineWidth = 2;
  fontSize = 16;

  %
  % Interpolate the algorithm's results at set superpixel sizes.
  % This is done to account for the fact that the user may not have
  % results for the same set of superpixel sizes for all datasets.
  % For the fairest comparison, it is recommended to provide results
  % at the specified sizes for the custom algorithm.
  % The pre-computed results for vclfs, lfsp, and k-means already
  % provide results at these sizes. We interpolate them here for fairness
  % and accuracy since the actual size may differ by a fractional amount.
  %
  qSz = [15 20 25 30 35 40];
  for i = 1:length(datasets)
    sz = results.avgSzSuperpix{i};
    results.aa(i) = {interp1(sz, results.aa{i}, qSz, 'linear', 'extrap')};
    results.br(i) = {interp1(sz, results.br{i}, qSz, 'linear', 'extrap')};
    results.ue(i) = {interp1(sz, results.ue{i}, qSz, 'linear', 'extrap')};
    results.ss(i) = {interp1(sz, results.ss{i}, qSz, 'linear', 'extrap')};
    results.cp(i) = {interp1(sz, results.cp{i}, qSz, 'linear', 'extrap')};
    results.lp(i) = {interp1(sz, results.lp{i}, qSz, 'linear', 'extrap')};

    sz = vclfs.avgSzSuperpix{i};
    vclfs.aa(i) = {interp1(sz, vclfs.aa{i}, qSz, 'linear', 'extrap')};
    vclfs.br(i) = {interp1(sz, vclfs.br{i}, qSz, 'linear', 'extrap')};
    vclfs.ue(i) = {interp1(sz, vclfs.ue{i}, qSz, 'linear', 'extrap')};
    vclfs.ss(i) = {interp1(sz, vclfs.ss{i}, qSz, 'linear', 'extrap')};
    vclfs.cp(i) = {interp1(sz, vclfs.cp{i}, qSz, 'linear', 'extrap')};
    vclfs.lp(i) = {interp1(sz, vclfs.lp{i}, qSz, 'linear', 'extrap')};

    sz = vclfs.avgSzSuperpix{i};
    vclfs.aa(i) = {interp1(sz, vclfs.aa{i}, qSz, 'linear', 'extrap')};
    vclfs.br(i) = {interp1(sz, vclfs.br{i}, qSz, 'linear', 'extrap')};
    vclfs.ue(i) = {interp1(sz, vclfs.ue{i}, qSz, 'linear', 'extrap')};
    vclfs.ss(i) = {interp1(sz, vclfs.ss{i}, qSz, 'linear', 'extrap')};
    vclfs.cp(i) = {interp1(sz, vclfs.cp{i}, qSz, 'linear', 'extrap')};
    vclfs.lp(i) = {interp1(sz, vclfs.lp{i}, qSz, 'linear', 'extrap')};
  end

  subplot(1, 3, 1);
  hold on
  plot(qSz, mean(vertcat(vclfs.aa{:})), 'k:o', ...
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspWang.aa{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspGT.aa{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansWang.aa{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansGT.aa{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(results.aa{:})), '--*', ... 
       'LineWidth', lineWidth); 
  set(gca,'FontSize',fontSize)
  axis([15 45 0.97 0.995])
  xticks([15 20 25 30 35 40 45])
  yticks([0.97 0.975 0.98 0.985 0.99 0.995])
  yticklabels({'97.0%', '97.5%', '98.0%', '98.5%', '99.0%', '99.5%'});
  xlabel('Superpixel size');
  ylabel('Achievable Accuracy');
  box on
  pbaspect([scalex scaley 1])

  subplot(1, 3, 2);
  hold on
  plot(qSz, mean(vertcat(vclfs.br{:})), 'k:o', ...
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspWang.br{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspGT.br{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansWang.br{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansGT.br{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(results.br{:})), '--*', ... 
       'LineWidth', lineWidth); 
  set(gca,'FontSize',fontSize)
  axis([15 45 0.75 1.0])
  xticks([15 20 25 30 35 40 45])
  yticks([0.75 0.80 0.85 0.90 0.95 1.00])
  yticklabels({'75.0%', '80.0%', '85.0%', '90.0%', '95.0%', '100.0%'})
  xlabel('Superpixel size');
  ylabel('Boundary Recall');
  box on
  pbaspect([scalex scaley 1]);

  subplot(1, 3, 3);
  hold on
  plot(qSz, mean(vertcat(vclfs.ue{:})), 'k:o', ...
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspWang.ue{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspGT.ue{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansWang.ue{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansGT.ue{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(results.ue{:})), '--*', ... 
       'LineWidth', lineWidth); 
  set(gca,'FontSize',fontSize)
  axis([15 45 0.005 0.014])
  xticks([15 20 25 30 35 40 45])
  yticks([0.005 0.0065 0.008 0.0095 0.011 0.0125 0.014])
  yticklabels({'0.5%', '0.65%', '0.8%', '0.95%', '1.10%', '1.25%', '1.40%'})
  xlabel('Superpixel size');
  ylabel('Undersegmentation Error');
  box on
  pbaspect([scalex scaley 1])

  lgd = legend(methods);
  lgd.Orientation = 'Horizontal';
  lgd.Location = 'southoutside';
  newPosition = [0.42 0.02 0.2 0.025];
  set(lgd,'Position', newPosition);
  set(gcf, 'position', [10 10 2048 512])

  axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
  saveas(f, [fout '/accuracy-metrics-avg'], 'png');	       

  f = figure('visible', 'off');

  subplot(1, 2, 1);
  hold on
  plot(qSz, mean(vertcat(vclfs.ss{:})), 'k:o', ...
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspWang.ss{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspGT.ss{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansWang.ss{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansGT.ss{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(results.ss{:})), '--*', ... 
       'LineWidth', lineWidth); 
  set(gca,'FontSize',fontSize)
  axis([15 45 0.3 1.8])
  xticks([15 20 25 30 35 40 45])
  yticks([0.3 0.6 0.9 1.2 1.5 1.8])
  yticklabels({'0.3px', '0.6px', '0.9px', '1.2px', '1.5px', '1.8px'})
  xlabel('Superpixel size');
  ylabel('Self-Similarity Error');
  box on
  pbaspect([scalex scaley 1])

  subplot(1, 2, 2);
  hold on
  plot(qSz, mean(vertcat(vclfs.lp{:})), 'k:o', ...
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspWang.lp{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspGT.lp{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansWang.lp{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansGT.lp{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(results.lp{:})), '--*', ... 
       'LineWidth', lineWidth); 
  set(gca,'FontSize',fontSize)
  axis([15 45 2 7])
  xticks([15 20 25 30 35 40 45])
  yticks([2 3 4 5 6 7])
  yticklabels({'2', '3', '4', '5', '6', '7'})
  xlabel('Superpixel size');
  ylabel('Avg. Number of Labels per Pixel');
  box on
  pbaspect([scalex scaley 1])

  lgd = legend(methods);
  lgd.Orientation = 'Horizontal';
  lgd.Location = 'southoutside';
  newPosition = [0.42 0.02 0.2 0.025];
  set(lgd,'Position', newPosition);
  set(gcf, 'position', [10 10 2048/3*1.9 512])

  axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
  saveas(f, [fout '/consistency-metrics-avg'], 'png');	       

  f = figure('visible', 'off');

  subplot(1, 1, 1);
  hold on
  plot(qSz, mean(vertcat(vclfs.cp{:})), 'k:o', ...
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspWang.cp{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(lfspGT.cp{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansWang.cp{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(kmeansGT.cp{:})), ':x', ... 
       'LineWidth', lineWidth); 
  hold on  
  plot(qSz, mean(vertcat(results.cp{:})), '--*', ... 
       'LineWidth', lineWidth); 
  set(gca,'FontSize',fontSize)
  axis([15 45 0.0 1.7e-3])
  xticks([15 20 25 30 35 40 45])
  yticks([3e-4 6e-4 8e-4 1.1e-3 1.4e-3 1.7e-3]);
  yticklabels({'0.3px', '0.6px', '0.9px', '1.2px', '1.5px', '1.8px'})
  xlabel('Superpixel size');
  ylabel('Compactness');
  box on
  pbaspect([scalex scaley 1]);
  set(gcf, 'position', [10 10 2048/3*1.1 625]);

  lgd = legend(methods);
  lgd.Orientation = 'Horizontal';
  lgd.Location = 'southoutside';
  newPosition = [0.42 0.01 0.2 0.025];
  set(lgd,'Position', newPosition);

  axesHandles = findobj(get(f,'Children'), 'flat','Type','axes');
  saveas(f, [fout '/shape-metrics-avg'], 'png');	       

end
