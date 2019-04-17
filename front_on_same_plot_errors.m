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

figure
hold on
for n = 1:length(BKPS)
  save_file = sprintf(BKP_ROOT, BKPS{n}{1}); # construct file name
  key(n,:) = sprintf('vid%02d', BKPS{n}{1}); # fill in legend key
  load('-binary', save_file, 'tm', 'front'); # load data to working memory
  offset = BKPS{n}{2}; # alias variable to make following code easier to read
  start_to = max(1, 1 - offset); # these are a bit messy to allow for negative shift
  start_from = max(1, 1 + offset); # values: useful to highlight one of the lines by
  end_to = min(length(front) - offset, STATS_SZ); # moving it out of the cluster to help
  end_from = min(length(front), STATS_SZ + offset); # determine the offset value to use
  stats(start_to: end_to, n) = front(start_from: end_from, 6); # copy front array to stats with offset
endfor

plot(tm(1:end), stats); # TODO check tm same length as stats
xlim([0.0, 12.0]);
ylim([0.0, 1000.0]);

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
errorbar(tm(1:STATS_SZ), means, stderr * 2.0);
hold off
