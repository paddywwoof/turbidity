# Script for image analysis of turbity current video frames 

# Required external functions:
# video_grab     script file video grab functions
#

clear all, close all

###########################################################################
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

ROW_CROP = 412:711;  # to give clear  background
COL_CROP = 226:1705; # ditto

THRESH_R = 25; # these might need some tweaking,
THRESH_C = 7;  #  also adjust crop ranges to get rid of bits at edges

START_TM = 41; # beginning of interest in s
STOP_TM = 45;  # end of interst 

video_grab; # load functions in script file_in_loadpath
start_conversion(VIDEO, START_TM, STOP_TM, FPS); # this runs asynchronously so should keep in front of these calcs

tic #starts timer
waittxt = 'Extracting frames...';
z = waitbar(0, waittxt);

n_fr = floor((STOP_TM - START_TM) * FPS);
images = {}; # empty cell array for images
data = {}; # for data points
for f = 1:DATA_STEP:n_fr
    [im, d.tm] = get_frame(f, 30.0, FPS, ROW_CROP, COL_CROP);
    if f > 1
        im -= images{1};
    endif
    imp = posterize(im);
    [d.top, d.front, d.area] = find_edges(imp, 193, THRESH_R, THRESH_C);
    d.frame = f;
    data{f} = d; # d is a struct with top,front,area,frame,tm
    if rem(f, IMAGE_STEP) == 1 # save this image. NB im at f == 1 must be saved
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
    imp = posterize(images{i});
    d = data{i};
    fig_name = sprintf('Frame at time = %5.3fs top = %d, front = %d, area = %d', d.tm, d.top, d.front, d.area);
    figure('NumberTitle', 'off', 'Name', fig_name)
    colormap(jet);
    imagesc(imp);
    hold on
    line([1, d.front, d.front], [d.top, d.top, size(imp)(1)], 'Color', 'w');
    hold off
endfor

# extracting data - probably should save it in this format anyway!
#
tm = []; top = []; front = []; area = []; frame = [];
for data_rec = data
  d = data_rec{1};
  if not(isempty(d))
    tm(end + 1) = d.tm;
    top(end + 1) = d.top * RESOLUTION;
    front(end + 1) = d.front * RESOLUTION;
    area(end + 1) = d.area * (RESOLUTION ^ 2);
    frame(end + 1) = d.frame;
  endif
endfor

# produce plot of changes in top, front, area
plot(tm, top);
hold on;
plot(tm, front);
plot(tm, area / 100);
plot(tm, front ./ tm);
xlabel('seconds');
legend('top mm', 'front mm', 'area mm^2 / 10', 'velocity mm/s');
title('Turbidity change over time');
hold off;