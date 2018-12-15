# Script for image analysis of turbity current video frames 

# Required external functions:
# video_grab     script file video grab functions
#

###########################################################################

# MANUAL INPUT PARAMETERS 
# loading .avi files into matlab (Jill)#
#
pkg load image

VIDEO = 'JRG_run05.avi';   # video of experimental run
RESOLUTION = 1000 / 1666;  # mm per pixel
FPS = 50.0;
DATA_STEP = 5;             # only create a data point every n video frames
IMAGE_STEP = 50;           # record image array. NB needs to be a multiple of DATA_STEP

ROW_CROP = 412:711;  # this and the COL_CROP together crop the video to a specific rectangle to analyse. this mkaes analysis quicker and more accurate.
COL_CROP = 226:1705; # ditto

THRESH_R = 25; # top of tc. works out the first row that has 25 pixels of the 'right' colour (proxy for conc.)  these might need some tweaking,
THRESH_C = 7;  # front of tc. works out the first column that has 7 pixels of the 'right' colour (proxy for conc.)  also adjust crop ranges to get rid of bits at edges

START_TM = 41.65; # beginning of interest in s
STOP_TM = 52;  # end of interst 

THRESHOLDS = [20, 45, 70, 93, 120, 145, 170]; # 
VALUES = [10, 22, 33, 89, 193, 223, 238, 251]; # non-linear mapping need to play with this
ROW_POSN = 1:size(ROW_CROP)(2); # list of numbers increasing by 1 for working out mean values of contours in find_edges
COL_POSN = 1:size(COL_CROP)(2); # ditto but other dimension

video_grab; # load functions in script file_in_loadpath

start_conversion(VIDEO, START_TM, STOP_TM, FPS); # this runs asynchronously so should keep in front of these calcs

tic #starts timer
waittxt = 'Extracting frames...';
z = waitbar(0, waittxt);

n_fr = floor((STOP_TM - START_TM) * FPS);  #works out the number of frames by taking the stop time and subtracting the start time and then multiplies by the number of frames per second.
images = {}; # empty cell array for images
data = {}; # for data points
for f = 1:DATA_STEP:n_fr
    [im, d.tm] = get_frame(f, 30.0, FPS, ROW_CROP, COL_CROP);  #waits 30 seconds for a specific file to apear in frame.#
    if f > 1 #this loop subtracts the 1st frame from all other frames
        im -= images{1};
    endif
    imp = posterize(im, THRESHOLDS, VALUES); #TODO save posterized?
    [d.area, d.mean_row, d.mean_col, d.width, d.height] = find_edges(imp, VALUES, ROW_POSN, COL_POSN);
    d.frame = f;
    data{f} = d; # d is a struct with top,front,area,frame,tm
    if rem(f, IMAGE_STEP) == 1 # save this image. NB im at f == 1 must be saved. Saves an image at every image step. If image step is 5 then it will save at 1, 6, 11, 16 etc..
        images{f} = im;
    endif
    waitbar(f / n_fr, z);
endfor

#dtime = diff(tm); # save time difference TODO

close(z);           #closes waitbar
clear z waittxt     #removes waitbar
toc

#-------- control plot (check if the extraction of frames is OK)
for i = 1:IMAGE_STEP:n_fr
    imp = posterize(images{i}, THRESHOLDS, VALUES);
    d = data{i};
    fig_name = sprintf('Frame at time = %5.3fs mean row = %d, mean col = %d, area = %d', d.tm, d.mean_row(5), d.mean_col(5), d.area(5));
    figure('NumberTitle', 'off', 'Name', fig_name)
    colormap(jet);
    imagesc(imp);
    hold on
    # TODO plot triangles for several dark areas.
    for i = 3:size(d.mean_row)(2)
        line([d.mean_col(i), d.mean_col(i) + 0.5 * d.width(i), d.mean_col(i), d.mean_col(i)], [d.mean_row(i), d.mean_row(i), d.mean_row(i) - 0.5 * d.height(i), d.mean_row(i)], 'Color', 'w');
    endfor
    hold off
endfor

# extracting data - probably should save it in this format anyway!
#
tm = []; area = []; mean_row = []; mean_col = []; width = []; height = []; frame = [];
for data_rec = data
  d = data_rec{1};
  if not(isempty(d))
    tm(end + 1) = d.tm;
    mean_row(end + 1) = d.mean_row(5) * RESOLUTION;
    mean_col(end + 1) = d.mean_col(5) * RESOLUTION;
    width(end + 1) = d.width(5) * RESOLUTION;
    height(end + 1) = d.height(5) * RESOLUTION;
    area(end + 1) = d.area(5) * (RESOLUTION ^ 2);
    frame(end + 1) = d.frame;
  endif
endfor

# produce plot of changes in top, front, area
plot(tm, mean_row - 0.5 * height); #TODO is there any way to put distance on the top x axis? I think we could average at what times the current is at what distance.
hold on;
plot(tm, mean_col + 0.5 * width);
plot(tm, area / 100);
velocities = (mean_col(2:end) + 0.5 * width(2:end) -...
             (mean_col(1:end-1) + 0.5 * width(1:end-1))) ./ (tm(2:end) - tm(1:end-1));
velocities = max(velocities, 0.0); # get rid of initial negative velocities
plot(tm(2:end), smooth(velocities, 0.1)); # exponential smoothing with factor of 0.1
xlim([0.5, 12.0]);
ylim([0.0, 750.0]);
xlabel('seconds');
legend('top mm', 'front mm', 'area mm^2 / 10', 'velocity mm/s');
title('Turbidity change over time');
hold off;

video_tidy();

# TODO put this smoothing function into video_grab and rename that file to something
# like 'useful_functions'?
function smoothed_vals = smooth(vals, factor)
    # simple moving average. Uses factor of each val + (1- factor) prev av. Takes av. of first
    # round(1 / factor) values as starting av.
    av = vals(1);
    n = round(1 / factor);
    if size(vals)(2) >= n
        av = mean(vals(1:n));
    endif
    smoothed_vals = [av];
    for v = vals(2:end)
        smoothed_vals(end + 1) = smoothed_vals(end) * (1.0 - factor) + v * factor;
    endfor
endfunction