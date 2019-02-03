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

x_vals = [];
v_vals = [];

figure
hold on
for n = 1:length(BKPS)
  save_file = sprintf(BKP_ROOT, BKPS{n}{1});
  key(n,:) = sprintf('vid%02d', BKPS{n}{1});
  load('-binary', save_file, 'tm', 'front');
  velocities = (front(2:end, 6) - front(1:end-1, 6))' ./ (tm(2:end) - tm(1:end-1));
  velocities = max(velocities, 0.0); # get rid of initial negative velocities
  sm = smooth(velocities, 0.1); # exponential smoothing with factor of 0.1
  x = front(2:end, 6)' - BKPS{n}{3};
  plot(x, sm); # NB  smoothed velocity against distance
  xlim([0.0, 800.0]);
  ylim([0.0, 300.0]);
  
  if n != 1 & n != 3 # these look dodgy results
    x_vals = [x_vals, x]; # this is how to concatenate arrays in matlabroot
    v_vals = [v_vals, sm];
  endif
  #
endfor
legend(key);

# now find best straight line for first part of figure (need to do second one too)
ix = find(x_vals >= 0.0 & x_vals <= 400.0); # index to values of dist <= 400
[p, S] = polyfit(x_vals(ix), v_vals(ix), 1); # polynomial order 1 -> strt line
[v_fit, delta] = polyval(p, x_vals(ix), S);
# delta is estimate of std error at values of x. i.e. 95% error bars would be
# +/- 2 * delta
printf(' error +/- %d', 2 * delta(1))
plot(x_vals(ix), v_fit, 'r-');
plot(x_vals(ix), v_fit + 2 * delta, 'm--', x_vals(ix), v_fit - 2 * delta, 'm--')
#
# and second part...
ix = find(x_vals > 400.0 & x_vals <= 750.0); # index to values of dist > 400
[p, S] = polyfit(x_vals(ix), v_vals(ix), 1); # polynomial order 1 -> strt line
[v_fit, delta] = polyval(p, x_vals(ix), S);
# delta is estimate of std error at values of x. i.e. 95% error bars would be
# +/- 2 * delta
printf(' error +/- %d', 2 * delta(1))
plot(x_vals(ix), v_fit, 'r-');
plot(x_vals(ix), v_fit + 2 * delta, 'm--', x_vals(ix), v_fit - 2 * delta, 'm--')

# or fit a curve to the data - need to think about the likely physics
hold off