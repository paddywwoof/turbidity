# Script for image analysis of turbity current video frames 

# Required external functions:
# useful_functions     script file video grab functions
#

###########################################################################

# MANUAL INPUT PARAMETERS 

pkg load image

VIDEO = 'JRG_h00_r08.avi';   # video of experimental run

useful_functions; # NB this needs to be included if video_analysis hasn't just been run

save_file = sprintf('%s.bkp', strsplit(VIDEO, '.'){1});
load('-binary', save_file, 'images', 'mean_col_px', 'mean_dist',...
     'mean_height', 'mean_row_px', 'frame', 'tm', 'front', 'front_px',...
     'height', 'height_px', 'width', 'width_px', 'area',...
     'COL_CROP', 'ROW_CROP', 'DATA_STEP', 'IMAGE_STEP', 'START_TM', 'STOP_TM',...
     'RESOLUTION', 'THRESHOLDS', 'VALUES');
n_fr = frame(end);
jetc = jet(256);    # list of rgb values used by the jet colormap for 1 to 256
VALUES =  [10, 44, 78, 112, 144, 182, 217, 250];
#-------- plot difference images with boxes drawn over
#{
for i = 1:IMAGE_STEP:n_fr
    ix = find(frame == i); # ix is the index of the data arrays where frame number == i, easiest to do this by a lookup process
    fig_name = sprintf('Frame at time = %5.3fs mean row = %d, mean col = %d, area = %d', tm(ix), mean_height(ix, 5), mean_dist(ix, 5), area(ix, 5));
    figure('NumberTitle', 'off', 'Name', fig_name)
    colormap(jet);
    imagesc(images{i});
    hold on
    for j = 3:size(mean_row_px)(2) # i.e. 3 to number of VALUES in posterized image
        rectangle('Position', [mean_col_px(ix, j) - 0.5 * width_px(ix, j), mean_row_px(ix, j) - 0.5 * height_px(ix, j), ...
                  width_px(ix, j), height_px(ix, j)], 'EdgeColor', jetc(VALUES(j), :));
    endfor
    hold off
endfor
#}
n = 4:8; # the number of the contour in VALUES to use, can be number or range
key = char(zeros(1, 20));
for i = n
  entry = sprintf ("greyscale %d", VALUES(i));
  key (i - n(1) + 1, 1:size(entry)(2)) = entry;
endfor
size(key)
figure
title ('')
subplot (2,2,1)
#plot(tm, mean_height(:, n)' + 0.5 * height(:, n)'); #TODO is there any way to put distance on the top x axis? I think we could average at what times the current is at what distance.
plot(tm, mean_height(:, n) + 0.5 * height(:, n)); #removed the apostrophes and now the y axis is positive... which Jill thinks it should be, however, if this is wrong just remove this line and uncomment the one above
xlabel('time(s)')
ylabel('height(mm)')
title('Top of TC based on the average height of the thickest part')
legend (key)

subplot (2,2,2)
legend
plot(tm, front(:, n)');
xlabel('time(s)')
ylabel('distance(mm)')
title('front using average') #TODO calculations have now been update, so change this

subplot (2,2,3)
legend
plot(tm, area(:, n)' / 100);
xlabel('time(s)')
ylabel('area(mm^2)')
title('Change in the area of the TC over time')

subplot (2,2,4)
legend
velocities = (front(2:end, n) - front(1:end-1, n))' ./ (tm(2:end) - tm(1:end-1));
velocities = max(velocities, 0.0); # get rid of initial negative velocities
#sm = wilson(velocities(3,:), 50, 5, 20, 1.0); # exponential smoothing with factor of 0.1
sm = movmean(velocities, 7);
plot(tm(2:end), sm, '.');
xlabel('time(s)');
ylabel('velocity (mm/s)')
title('Velocity');