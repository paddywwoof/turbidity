pkg load image
useful_functions; # NB this needs to be included if video_analysis hasn't just been run

BKP_ROOT = '%03d.bkp'; # make directory path match location of bkp files
#{
BKPS = {{10, 263.9, 19.6, 11, 103}, # the number of video i.e. ..h00_r04... padded with zeros to width 2
        {11, 252.6, 146.5, 11, -1}, # followed by row of bottom of tank, col of start of TC,
        {12, 269.0, 152.4, 9, 89},  # time index for start and stop polyfit, if line is good to end
        {13, 258.0, 144.5, 26, -1}, # then put a value less than 1
        {14, 260.7, 146.1, 20, -1},
        {15, 262.3, 140.6, 25, -1},
        {23, 262.3, 144.5, 20, -1}
        {26, 262.3, 144.5, 20, -1}};
#}
BKPS = [10:14,23:30,32:36];
key = char(zeros(1, 6)); #vid04 etc

x_vals = [];
v_vals = [];

fig1 = figure;
hold('on'); # to make each file plot on the same graph
for n = 1:length(BKPS)
  save_file = sprintf(BKP_ROOT, BKPS(n)); # BKPS(n)
  key(n,:) = sprintf('run %02d', BKPS(n));
  load('-binary', save_file, 'tm', 'front');
  velocities = (front(2:end, 4) - front(1:end-1, 4))' ./ (tm(2:end) - tm(1:end-1)); # i.e. this is just using col #6 i.e. greyscale 181
  #velocities = max(velocities, 0.0); # get rid of initial negative velocities
  #sm = smooth(velocities, 0.1); # exponential smoothing with factor of 0.1
  #sm = movmean(velocities, 5);
  sm = wilson(velocities, 24, 5, 15, 3);
  #x = front(2:end, 6)' - BKPS{n}{3}; # i.e. this is just using col #6 i.e. greyscale 181
  x = front(2:end, 4)'; # i.e. this is just using col #6 i.e. greyscale 181
  plot(x, sm, '-'); # NB  smoothed velocity against distance
  xlim([0.0, 800.0]);
  #ylim([0.0, 300.0]);
  
 # if n != 1 & n != 3 # these look dodgy results
    x_vals = [x_vals, x]; # this is how to concatenate arrays in matlabroot
    v_vals = [v_vals, sm];
  #endif
  #
endfor
legend(key);
xlabel('Distance (mm)')
ylabel('Velocity (ms^-1)')

ix = find(x_vals > 50.0 & x_vals <= 800.0); # index to values of dist > 400
[p, S] = polyfit(x_vals(ix), v_vals(ix), 4); # polynomial order 1 -> strt line
[v_fit, delta] = polyval(p, x_vals(ix), S);
# delta is estimate of std error at values of x. i.e. 95% error bars would be
# +/- 2 * delta
ix = find(x_vals(1,1:100) > 50.0 & x_vals(1,1:100) <= 800.0); # change '100' to be the size(front) check in command window
v_fit = v_fit(1,1:length(ix));
delta = delta(1,1:length(ix));
text(250,200,sprintf('95%% confidence +/- %d', 2 * delta(1))); #2*delta means it's 2 strd deviations away from best fit '%%' shows as '%' on the graph
text(250,220,sprintf('ploynomial %.2ex^4 + %.2ex^3 + %.2ex^2 + %.2ex + %.2e', p(1,1), p(1,2), p(1,3), p(1,4), p(1,5)));
plot(x_vals(ix), v_fit, 'r-', 'LineWidth',2); #best-fit line
plot(x_vals(ix), v_fit + 2 * delta, 'm--', 'LineWidth', 2, x_vals(ix), v_fit - 2 * delta, 'm--', 'LineWidth', 2) #error bar lines

# or fit a curve to the data - need to think about the likely physics
hold('off'); # any plot after now produce a new graph (or overwrite last one)

saveas(fig1,'velocity_on_same_plot_greyscale113_with_4_order_polynomial_error.jpeg')