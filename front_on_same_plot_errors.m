pkg load image
useful_functions; # NB this needs to be included if video_analysis hasn't just been run

STATS_SZ = 120;
BKP_ROOT = '%03d.bkp'; # make directory path match location of bkp files
BKPS = {{10, 10, 0}, # the number of video i.e. ..024.bkp.. padded with zeros to width 3
        {11, 6, 0},  # followed by tm offset in array steps and distance offset in mm
        {12, 10, 0},
        {13, 8, 0},
        {14, 11, 0},
        {23, 6, 0},
        {26, 6, 0},
        {25, 6, 0},
        {24, 11, 0},
        {27, 17, 0},
        {28, 13, 0},
        {29, 10, 0},
        {30, 6, 0},
        {32, 8, 0},
        {33, 5, 0},
        {34, 12, 0},
        {35, 5, 0},
        {36, 16, 0}};

stats = zeros(STATS_SZ, length(BKPS)); # to hold the shifted data
stats(:,:) = NaN; # to enable later use of nanmean(), nanstd() for different lengths of useful arrays 
key = char(zeros(1, 5)); #vid04 etc. filled in the loop below

h1 = figure("position",get(0,"screensize"))

hold on
for n = 1:length(BKPS)
  save_file = sprintf(BKP_ROOT, BKPS{n}{1}); # construct file name
  key(n,:) = sprintf('vid%02d', BKPS{n}{1}); # fill in legend key
  load('-binary', save_file, 'tm', 'front', 'DATA_STEP'); # load data to working memory
  offset = BKPS{n}{2}; # alias variable to make following code easier to read
  start_to = max(1, 1 - offset); # these are a bit messy to allow for negative shift
  start_from = max(1, 1 + offset); # values: useful to highlight one of the lines by
  end_to = min(length(front) - offset, STATS_SZ); # moving it out of the cluster to help
  end_from = min(length(front), STATS_SZ + offset); # determine the offset value to use
  stats(start_to: end_to, n) = front(start_from: end_from, 6); # copy front array to stats with offset
endfor

key(end+1,:) = 'error';
plot(tm(1:end), stats); # TODO check tm same length as stats
xlim([0.0, 13.0]);
ylim([0.0, 1000.0]);

key(end+1, :) = 'error';
legend(key);
xlabel('time(s)')
ylabel('distance(mm)')
title('fronts at greyscale 132')

pkg load statistics;

means = nanmean(stats, axis=2); # nanmean ignores NaN values, handy
# stderr is standard deviation divided by root n, the number of experiment runs
# needs to count non NaN values as there isn't a nancount()
stderr = nanstd(stats, flag=0, axis=2) ./ sum(!isnan(stats), axis=2) .^ 0.5;
# draw error bars. This might be better displayed differently.
errorbar(tm(1:STATS_SZ), means, stderr * 2.0,'k');

legend(key);
legend("location", "northeastoutside");
hold off

########## now try and do the velocities
FPS = 50.0; #NB reall this should be the const used in video_analysis but it wasn't saved bkp file
dt = DATA_STEP / FPS; # because of shifting back and forward it doesn't make sense to divide by array, so just use single value
velocities = (stats(2:end, :) - stats(1:end-1, :)) / dt;
v_means = nanmean(velocities, axis=2);
v_stderr = nanstd(velocities, flag=0, axis=2) ./ sum(!isnan(velocities), axis=2) .^ 0.5;

## v. time
h2 = figure("position",get(0,"screensize"))
hold on
title('velocity against time');
plot(tm(2:STATS_SZ), velocities, '.');
errorbar(tm(2:STATS_SZ), v_means, v_stderr * 2.0, '*k');
xlim([0.0, 13.0]);
ylim([0.0, 350.0]);
hold off

## v. distance
xc = [820.0, 820.0, 820.0]; # constrain at x values due to end of tank
yc = [0.0, 0.0, 0.0]; # constrain y or dy/dx or d2y/dx2
cc = [1, 0, 0; 0, 0, 0; 0, 0, 1]; # y at 820 = 0, d2y/dx2 = 0 constrained
con = struct('xc', xc, 'yc', yc, 'cc', cc);
pp = splinefit(means(2:STATS_SZ), v_means, 3, 'constraints', con); # three sections of spline (default to fit cubic)
v_fit = ppval(pp, means(2:STATS_SZ));

h3 = figure("position",get(0,"screensize"))
hold on
plot(means(2:STATS_SZ), velocities, '.', means(2:STATS_SZ), v_fit, '-r', 'LineWidth', 2);
errorbar(means(2:STATS_SZ), v_means, stderr(2:STATS_SZ) * 2.0, v_stderr * 2.0, '#~>*k');

xticklabels = [103, 200:100:900]; # tick at 100 doesn't show so tweak
xtick = (xticklabels - 100);
xticklabels(1) = 100;
set(gca, 'XTick', xtick, 'fontsize', 16, 'XTickLabel', xticklabels, 'fontsize', 16);
ylim([0.0, 250.0]);
leg = legend('1','2','3','4','5','6','7','8','9','10','11','12','13','15','16','17','18','19','Mean (best fit)', 'mean');
set(leg, 'fontsize', 16);
legend boxoff
xlabel('Distance (mm)', 'fontsize', 16);
ylabel('U (mm s^-^1)', 'fontsize', 16);

hold off

save('-binary', 'unobstructed_mean_tmVSdst.bkp', 'means', 'stderr', 'v_means', 'v_stderr', 'pp', 'v_fit') # swop save to load, whe you use this in other scripts.
figure_size(h1, 'dist_v_time.jpg', 30, 21);
figure_size(h2, 'vel_v_time.jpg', 30, 21);
figure_size(h3, 'vel_v_dist.jpg', 21, 15);

