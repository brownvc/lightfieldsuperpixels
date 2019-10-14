
function createVideo(lf, ours, lfspgt, sdgt, lfspwang, sdwang)
  m = max( max(max(max(max(lfspgt)))), max(max(max(max(ours)))) );
  colors = rand(m, 3);
  
  sz = size(ours);
  padding = 32;
  
  vid = VideoWriter('out.avi');
  vid.Quality = 100;
  vid.FrameRate = 10;
  open(vid);

  idx = repmat([1:9 8:-1:2], 1, 10);

  for s = 5 %1:size(oursLabels, 4)
    for r = idx %1:size(oursLabels, 3)
      imout = [ lab2rgb(lf(:, :, :, r, s)) double(label2rgb( ours(:, :, r, s), colors )) ./ 255 ...
		double(label2rgb(lfspwang(:, :, r, s), colors)) ./ 255;
		zeros( padding, sz(2) * 3, 3);
		double(label2rgb(sdgt(:, :,  r, s), colors)) ./ 255 double(label2rgb( sdwang(:, :, r, s), colors )) ./ 255 ...
		double(label2rgb(lfspgt(:, :, r, s), colors)) ./ 255];
      imout = max(imout, 0);
      imout = min(imout, 1);
      writeVideo( vid, imout);
    end
  end
  
  for s = idx %1:size(oursLabels, 4)
    for r = 5 %1:size(oursLabels, 3)
      imout = [ lab2rgb(lf(:, :, :, r, s)) double(label2rgb( ours(:, :, r, s), colors )) ./ 255 ...
		double(label2rgb(lfspwang(:, :, r, s), colors)) ./ 255;
		zeros( padding, sz(2) * 3, 3);
		double(label2rgb(sdgt(:, :,  r, s), colors)) ./ 255 double(label2rgb( sdwang(:, :, r, s), colors )) ./ 255 ...
		double(label2rgb(lfspgt(:, :, r, s), colors)) ./ 255];
      imout = max(imout, 0);
      imout = min(imout, 1);
      writeVideo( vid, imout);
    end
  end
  close(vid);
end
