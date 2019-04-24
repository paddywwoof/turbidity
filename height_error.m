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
  load('-binary', save_file, 'tm', 'height', 'DATA_STEP'); # load data to working memory
  offset = BKPS{n}{2}; # alias variable to make following code easier to read
  start_to = max(1, 1 - offset); # these are a bit messy to allow for negative shift
  start_from = max(1, 1 + offset); # values: useful to highlight one of the lines by
  end_to = min(length(height) - offset, STATS_SZ); # moving it out of the cluster to help
  end_from = min(length(height), STATS_SZ + offset); # determine the offset value to use
  stats(start_to: end_to, n) = height(start_from: end_from, 4); # copy height array to stats with offset
endfor

key(end+1,:) = 'error';
plot(tm(1:end), stats); # TODO check tm same length as stats
xlim([0.0, 13.0]);
ylim([0.0, 200.0]);

key(end+1, :) = 'error';
legend(key);
xlabel('time(s)')
ylabel('height(mm)')
title('heights at greyscale 113')

pkg load statistics;

h_means = nanmean(stats, axis=2); # nanmean ignores NaN values, handy
# stderr is standard deviation divided by root n, the number of experiment runs
# needs to count non NaN values as there isn't a nancount()
h_stderr = nanstd(stats, flag=0, axis=2) ./ sum(!isnan(stats), axis=2) .^ 0.5;
# draw error bars. This might be better displayed differently.
errorbar(tm(1:STATS_SZ), h_means, h_stderr * 2.0,'k');

legend(key);
legend("location", "northeastoutside");
hold off

## v. distance
load('-binary','unobstructed_mean_tmVSdst.bkp', 'means');

h3 = figure("position",get(0,"screensize"))
hold on
plot(means, h_means, '.');

xticklabels = [103, 200:100:900]; # tick at 100 doesn't show so tweak
xtick = (xticklabels - 100);
xticklabels(1) = 100;
set(gca, 'XTick', xtick, 'XTickLabel', xticklabels);
ylim([0.0, 200.0]);

legend('1','2','3','4','5','6','7','8','9','10','11','12','13','15','16','17','18','19','Mean (best fit)', 'mean');
legend boxoff
xlabel('Distance (mm)');
ylabel('Height (mm)');
hold off

save('-binary', 'unobstructed_mean_height.bkp','h_means', 'h_stderr') # swop save to load, whe you use this in other scripts.
figure_size(h1, 'height_v_time.jpg', 60, 42);
figure_size(h3, 'height_v_dist.jpg', 60, 42);