pkg load image
useful_functions; # NB this needs to be included if video_analysis hasn't just been run

BKP_ROOT = 'bkp_files/JRG_h00_r%02d.bkp'; # make directory path match location of bkp files
BKPS = {{4, 263.9, 19.6, 11, 103}, # the number of video i.e. ..h00_r04... padded with zeros to width 2
        {5, 252.6, 146.5, 11, -1}, # followed by row of bottom of tank, col of start of TC,
        {6, 269.0, 152.4, 9, 89},  # time index for start and stop polyfit, if line is good to end
        {7, 258.0, 144.5, 26, -1}, # then put a value less than 1
        {8, 260.7, 146.1, 20, -1},
        {9, 262.3, 140.6, 25, -1},
        {10, 262.3, 144.5, 20, -1}};

for n = 1:length(BKPS)
  save_file = sprintf(BKP_ROOT, BKPS{n}{1});
  load('-binary', save_file, 'images', 'mean_col', 'mean_col_px', 'mean_dist',...
       'mean_height', 'mean_row', 'mean_row_px', 'frame', 'tm', 'front', 'front_px',...
       'height', 'height_px', 'width', 'width_px', 'area',...
       'COL_CROP', 'ROW_CROP', 'DATA_STEP', 'IMAGE_STEP', 'START_TM', 'STOP_TM',...
       'RESOLUTION', 'THRESHOLDS', 'VALUES');
  n_fr = frame(end);

  cf = zeros(size(front)(1), 3); # array to hold data to draw, orig, polynomial and zero dist line
  cf(:, 1) = front(:, 6); # this is data for greyscale = 132
  fr_tm = BKPS{n}{4}; 
  to_tm = BKPS{n}{5};
  if to_tm < 1
    to_tm = length(tm);
  endif
  p = polyfit(tm(fr_tm:to_tm), front(fr_tm:to_tm, 6)', 4);
  cf(:, 2) = p(1) * tm .^ 4 + p(2) * tm .^ 3 + p(3) * tm .^ 2 + p(4) * tm + p(5); # i.e. polynomial
  cf(:, 3) = BKPS{n}{3};
  figure
  plot(tm, cf);

  p(end) -= BKPS{n}{3}; # find tm when line crosses 'zero' distance on images
  r = roots(p);
  zero_tm = min(r(find(real(r) >= 0.0 & imag(r) == 0.0)))
  hold on
  line([zero_tm, zero_tm], [-100.0, 1000.0]);
  hold off
endfor
