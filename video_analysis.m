# Script for image analysis of turbity current video frames 

# Required external functions:
# useful_functions     script file video grab functions
#

###########################################################################

# MANUAL INPUT PARAMETERS 
# loading .avi files into matlab (Jill)#
#
pkg load image

VIDEO = 'JRG_h00_r04.avi';   # video of experimental run
RESOLUTION = 1000 / 1666;  # mm per pixel
FPS = 50.0;
DATA_STEP = 5;             # only create a data point every n video frames
IMAGE_STEP = 50;           # record image array. NB needs to be a multiple of DATA_STEP

ROW_CROP = 412:711;  # this and the COL_CROP together crop the video to a specific rectangle to analyse. this mkaes analysis quicker and more accurate.
COL_CROP = 226:1705; # ditto

THRESH_R = 25; # top of tc. works out the first row that has 25 pixels of the 'right' colour (proxy for conc.)  these might need some tweaking,
THRESH_C = 7;  # front of tc. works out the first column that has 7 pixels of the 'right' colour (proxy for conc.)  also adjust crop ranges to get rid of bits at edges

START_TM = 40; # beginning of interest in s
STOP_TM = 47; # end of interst 

THRESHOLDS = [20, 45, 70, 93, 120, 145, 170]; # 
#VALUES = [10, 22, 33, 89, 193, 223, 238, 251]; # non-linear mapping need to play with this. figures relate to greyscale rgb values
VALUES = [10, 33, 58, 82, 103, 132, 158, 180]; # non-linear mapping need to play with this. figures relate to greyscale rgb values
ROW_POSN = 1:size(ROW_CROP)(2); # list of numbers increasing by 1 for working out mean values of contours in find_edges
COL_POSN = 1:size(COL_CROP)(2); # ditto but other dimension

useful_functions; # load functions in script file_in_loadpath

start_conversion(VIDEO, START_TM, STOP_TM, FPS); # this runs asynchronously so should keep in front of these calcs

tic #starts timer
waittxt = 'Extracting frames...';
z = waitbar(0, waittxt);

n_fr = floor((STOP_TM - START_TM) * FPS);  #works out the number of frames by taking the stop time and subtracting the start time and then multiplies by the number of frames per second.
images = {}; # empty cell array for images indexed by frame number
# arrays for data. Calculated values in mm
tm = []; area = []; mean_height = []; mean_dist = []; width = []; height = []; frame = []; front = [];
# pixel values for drawing over images
mean_row_px = []; mean_col_px = []; width_px = []; height_px = []; front_px = [];
for f = 1:DATA_STEP:n_fr
    [im, d.tm] = get_frame(f, 30.0, FPS, ROW_CROP, COL_CROP);  #waits 30 seconds for a specific file to apear in frame.#
    if f > 1 #this loop subtracts the 1st frame from all other frames
        im -= images{1};
    endif
    imp = posterize(im, THRESHOLDS, VALUES); #TODO save posterized?
    [d.area, d.mean_row, d.mean_col, d.width, d.height, d.front] = find_edges(imp, VALUES, ROW_POSN, COL_POSN, THRESH_C);
    tm(end + 1) = d.tm;
    frame(end + 1) = f;
    mean_row_px(end + 1, :) = d.mean_row;
    mean_height(end + 1, :) = (ROW_CROP(end) - ROW_CROP(1) - d.mean_row) * RESOLUTION;
    mean_col_px(end + 1, :) = d.mean_col;
    mean_dist(end + 1, :) = d.mean_row * RESOLUTION;
    width_px(end + 1, :) = d.width;
    width(end + 1, :) = d.width * RESOLUTION;
    height_px(end + 1, :) = d.height;
    height(end + 1, :) = d.height * RESOLUTION;
    area(end + 1, :) = d.area * RESOLUTION ^ 2;
    front_px(end + 1, :) = d.front;
    front(end + 1, :) = d.front * RESOLUTION;
    if rem(f, IMAGE_STEP) == 1 # save this image. NB im at f == 1 must be saved. Saves an image at every image step. If image step is 5 then it will save at 1, 6, 11, 16 etc..
        if f > 1
            im = im .* (1 - edge(imp, 'Canny')); # 0 lines round the contours of the THRESHOLDS in posterized version added to im
        endif
        images{f} = im;
    endif
    waitbar(f / n_fr, z);
endfor

close(z);           #closes waitbar
clear z waittxt     #removes waitbar
toc

save_file = sprintf('%s.bkp', strsplit(VIDEO, '.'){1});
save('-binary', save_file, 'images', 'mean_col', 'mean_col_px', 'mean_dist',...
     'mean_height', 'mean_row', 'mean_row_px', 'frame', 'tm', 'front', 'front_px',...
     'height', 'height_px', 'width', 'width_px', 'area',...
     'COL_CROP', 'ROW_CROP', 'DATA_STEP', 'IMAGE_STEP', 'START_TM', 'STOP_TM',...
     'RESOLUTION', 'THRESHOLDS', 'VALUES');

video_tidy();