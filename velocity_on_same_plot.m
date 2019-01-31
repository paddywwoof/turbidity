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
key = char(zeros(1, 5)); #vid04 etc
figure
hold on
for n = 1:length(BKPS)
  save_file = sprintf(BKP_ROOT, BKPS{n}{1});
  key(n,:) = sprintf('vid%02d', BKPS{n}{1});
  load('-binary', save_file, 'tm', 'front');
  velocities = (front(2:end, 6) - front(1:end-1, 6))' ./ (tm(2:end) - tm(1:end-1));
  velocities = max(velocities, 0.0); # get rid of initial negative velocities
  sm = smooth(velocities, 0.1); # exponential smoothing with factor of 0.1
  plot(front(2:end, 6)' - BKPS{n}{3}, sm);
  xlim([0.0, 800.0]);
  ylim([0.0, 300.0]);
  #
endfor
legend(key);
hold off