
function createVideo(fname)
  load(['../results/ours_new/' fname '/' fname '_20.mat']);
  load(['../results/lfsp_wang/' fname '_lfsp_wang_20.mat']);
  load(['../results/simpledepth_wang/' fname '_simpledepth_wang_20.mat']);

  fnameIn = [const.fnameData '/' fname];
  [lr, lg, lb, sz] = lfLoad( fnameIn, 0, 1, 'rgba');
  cviewIdx = ceil(sz(1)/2);
  
  LF = zeros(sz(4), sz(3), 3, sz(1), sz(1));                                                  
  for r = 1:sz(2)                                                                             
    parfor s = 1:sz(1)                                                                        
      LF(:, :, :, r, s) = lab2rgb(cat(3, cell2mat(lr(r, s)), cell2mat(lg(r, s)), cell2mat(lb(r, s))));
    end                                                                                       
  end   
  LF(LF < 0) = 0;
  LF(LF > 1) = 1;
  LF = LF .* 255;

  lfsp = permute(lfsp, [3 4 1 2]);
  %[~, lfspErr] = correctLabelsConst(lfsp, fname);
  %[~, ourErr] = correctLabelsConst(N, fname);
  %[~, kmErr] = correctLabelsConst(lout, fname);
  ours = N;
  km = lout;
  lf = LF;
  sz = size(lf);
  
  %lf = flip(lf, 4);
  %lf = flip(lf, 5);

  vid = VideoWriter([fname '_lbl.avi']);
  vid.Quality = 100;
  vid.FrameRate = 10;
  open(vid);

  sh = [repmat([1:sz(4) sz(4)-1:-1:2], 1, 2) 1:ceil(sz(4)/2)];
  rh = repmat( ceil(sz(5)/2), 1, size(sh, 2));

  rv = [ceil(sz(5)/2):-1:2 repmat([1:sz(5) sz(5)-1:-1:2], 1, 2) 1:ceil(sz(5)/2)];
  sv = repmat( ceil(sz(4)/2), 1, size(rv, 2));

  rd1 = [ceil(sz(5)/2):-1:2 repmat([1:sz(5) sz(5)-1:-1:2], 1, 2) 1:ceil(sz(5)/2)]
  sd1 = [ceil(sz(4)/2):sz(4) - 1 repmat([sz(4):-1:2 2:sz(4)], 1, 2) sz(4):-1:ceil(sz(4)/2)]

  rd2 = [ceil(sz(5)/2):-1:2 repmat([1:sz(5) sz(5)-1:-1:2], 1, 2) 1:ceil(sz(5)/2)];
  sd2 = [ceil(sz(4)/2):-1:2 repmat([1:sz(4) sz(4)-1:-1:2], 1, 2) 1:ceil(sz(4)/2)];

  r = cat(2, rh, rv, rd1, rd2);
  s = cat(2, sh, sv, sd1, sd2);

  padding = 30; %pixels
  colors = rand( 2000, 3 );

  size(lf)
  for i = 1:length(s)
    frame = [lf(:, :, :, r(i), s(i)) zeros( sz(1), padding, 3 ) ...
	     label2rgb(squeeze(ours(:,  :,  r(i), s(i))), colors); ...
	     zeros( padding, sz(2) * 2 + padding, 3); ...
	     label2rgb(squeeze(km(:, :, r(i), s(i))), colors) ...
	     zeros( sz(1), padding, 3 ) ...
	     label2rgb(squeeze(lfsp(:, :, r(i), s(i))), colors)];
    writeVideo( vid, frame);
  end

% for i = 1:length(s)
%    frame = [lf(:, :, :, r(i), s(i)) zeros( sz(1), padding, 3 ) ...
%             squeeze(ourErr(:,  :, :, r(i), s(i))); ...
%             zeros( padding, sz(2) * 2 + padding, 3); ...
%             squeeze(kmErr(:, :, :, r(i), s(i))), ...
%             zeros( sz(1), padding, 3 ) ...
%             squeeze(lfspErr(:, :, :, r(i), s(i)))];
%    writeVideo( vid, frame);
%  end
%
  close(vid);
end
