# Script for image analysis of turbity current video frames 

# Required external functions:
# useful_functions     script file video grab functions
#

###########################################################################

# MANUAL INPUT PARAMETERS 

pkg load image

VIDEO = '040.avi';   # video of experimental run

useful_functions; # NB this needs to be included if video_analysis hasn't just been run

save_file = sprintf('%s.bkp', strsplit(VIDEO, '.'){1});
load('-binary', save_file, 'images', 'mean_col_px', 'mean_dist',...
     'mean_height', 'mean_row_px', 'frame', 'tm', 'front', 'front_px',...
     'height', 'height_px', 'width', 'width_px', 'area',...
     'COL_CROP', 'ROW_CROP', 'DATA_STEP', 'IMAGE_STEP', 'START_TM', 'STOP_TM',...
     'RESOLUTION', 'THRESHOLDS', 'VALUES');
n_fr = frame(end);
jetc = jet(256);    # list of rgb values used by the jet colormap for 1 to 256
VALUES = [10, 44, 79, 113, 147, 181, 216, 250];
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
n = 6; # the number of the contour in VALUES to use, can be number or range
key = char(zeros(1, 20));
for i = n
  entry = sprintf ("greyscale %d", VALUES(i));
  key (i - n(1) + 1, 1:size(entry)(2)) = entry;
endfor
size(key)
figure
title ('')

#{
subplot(2,2,1)
plot(front(2:end, 2), mean_height(:, n) + 0.5 .* height(:, n)); #removed the apostrophes and now the y axis is positive... which Jill thinks it should be, however, if this is wrong just remove this line and uncomment the one above
xlabel('distance (mm)')
ylabel('height(mm)')
title('Top of TC based on the average height of the thickest part')
legend (key)

subplot(2,2,4)
#

velocities = (front(2:end, n) - front(1:end-1, n))' ./ (tm(2:end) - tm(1:end-1));
velocities = max(velocities, 0.0); # get rid of initial negative velocities
sm = movmean(velocities, 21); # for a smoothing factor of 21 (always an odd number), it takes a window of 10 on either side and one in the middle and averages that whole window and replaces the 'one in the middle' with this new avaerage. 21 is similar to the Wilson paper, but a more logical number.
plot(front(2:end, 2),sm)
xlabel('distance (mm)')
ylabel('velocity (mm/s)')
legend (key)
title('Velocity')
#} 
plot(mean_dist(2:end, n) + 0.5 * width(2:end, n), sm) 
hold on 
plot(front(2:end, n) + 0.5 * width(2:end, n), sm) 
hold off
xlabel('distance (mm)')
ylabel('velocity (mm/s)')
legend (key)
title('Velocity')
#