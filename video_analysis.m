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

VIDEO = 'JRG_run05.avi';           # video of experimental run
RESOLUTION = 1907 / 1220;          # pixels -> mm
FPS = 50.0;

ROW_CROP = 412:711;  # to give clear  background
COL_CROP = 226:1705; # ditto

THRESH_R = 25; # these might need some tweaking,
THRESH_C = 7;  #  also adjust crop ranges to get rid of bits at edges

START_TM = 41; # beginning of interest in s
STOP_TM = 43;  # end of interst

video_grab; # load functions in script file_in_loadpath
start_conversion(VIDEO, START_TM, STOP_TM, FPS); # this runs asynchronously so should keep in front of these calcs

tic #starts timer
waittxt = 'Extracting frames...';
z = waitbar(0, waittxt);

n_fr = floor((STOP_TM - START_TM) * FPS);
for f = 1:n_fr
    [im{f}, tm(f)] = get_frame(f, 30.0, FPS, ROW_CROP, COL_CROP);
    if f > 1
        im{f} -= im{1};
    endif
    waitbar(f / n_fr, z);
endfor

dtime = diff(tm); # save time difference

close(z);           #closes waitbar
clear z waittxt     #removes waitbar
toc 

#-------- control plot (check if the extraction of frames is OK)
for i = 10:20:n_fr
    imp = posterize(im{i});
    [tp, frnt, area] = find_edges(imp, 193, THRESH_R, THRESH_C);
    fig_name = sprintf('Frame at time = %5.3fs top = %d, front = %d, area = %d', tm(i), tp, frnt, area);
    figure('NumberTitle', 'off', 'Name', fig_name)
    colormap(jet);
    imagesc(imp);
    hold on
    line([1, frnt, frnt], [tp, tp, size(imp)(1)]);
    hold off
endfor

# TODO - the posterize and find_edges should be done inside the image loading loop. There
# probably only needs to be a few images displayed (2 per second?) but the velocity and
# area of the sediment 'cloud' should be calculated more frequently (5 or 10 times per
# second?

# TODO 2 - in find_edges the areas of the different colours should also be returned