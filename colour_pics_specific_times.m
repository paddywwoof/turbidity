# Script for image analysis of turbity current video frames 

# Required external functions:
# useful_functions     script file video grab functions
#

###########################################################################

# MANUAL INPUT PARAMETERS 

pkg load image

FONTSIZE = 24; # this seems about OK for the size of graphs produced here.
VIDEO = '055.avi';   # video of experimental run
#VIDEO = 'JRG_h00_r10.avi';   # video of experimental run

useful_functions; # NB this needs to be included if video_analysis hasn't just been run

file_stem = strsplit(VIDEO, '.'){1};
save_file = sprintf('%s.bkp', file_stem);
load('-binary', save_file, 'images', 'mean_col_px', 'mean_dist',...
     'mean_height', 'mean_row_px', 'frame', 'tm', 'front', 'front_px',...
     'height', 'height_px', 'width', 'width_px', 'area',...
     'COL_CROP', 'ROW_CROP', 'DATA_STEP', 'START_TM', 'STOP_TM',...
     'RESOLUTION', 'THRESHOLDS', 'VALUES');
n_fr = frame(end);
jetc = jet(256);    # list of rgb values used by the jet colormap for 1 to 256
VALUES = [10, 44, 79, 113, 147, 181, 216, 250];
IMAGE_STEP = 50;
pics = IMAGE_STEP*50);
if not(exist(file_stem, 'file')) # create a directory for pictures and data if it's not there already
    mkdir(file_stem)
endif

#-------- plot difference images with boxes drawn over
#
for i = 1:pics
    ix = find(frame == i); # ix is the index of the data arrays where frame number == i, easiest to do this by a lookup process
    fig_name = sprintf('Frame at time = %5.3fs mean row = %d, mean col = %d, area = %d', tm(ix), mean_height(ix, 5), mean_dist(ix, 5), area(ix, 5));
    fig = figure('NumberTitle', 'off', 'Name', fig_name)
    colormap(jet);
    sz_im = size(images{i});
    images{i}(1:4,1:4) = 0;
    images{i}(1:4,5:8) = 175;
    im = imagesc(images{i});
    xticklabels = [103, 200:100:900]; # tick at 100 doesn't show so tweak
    xtick = (xticklabels - 100) / RESOLUTION; # tick positions converted back to pixel locations
    xticklabels(1) = 100; # then correct value
    set(gca, 'XTick', xtick, 'XTickLabel', xticklabels);
    yticklabels = [0:50:100, 146]; # put the tick just before end of axis
    ytick = sz_im(1) - yticklabels / RESOLUTION;
    yticklabels(end) = 150;
    set(gca, 'YTick', ytick, 'YTickLabel', yticklabels);
    set(gca, 'DataAspectRatio', [1, 0.5, 1]); # [x, y, z] scaling NB 0.5 makes it twice as big on the chart
    set(gca, 'fontsize', FONTSIZE);
    clb = colorbar ();
    ytick = get(clb,"ytick");
    set(clb, 'YTick', THRESHOLDS, 'YTickLabel', [0:7]);
    hold on
    #{
    for j = 3:size(mean_row_px)(2) # i.e. 3 to number of VALUES in posterized image
        rectangle('Position', [mean_col_px(ix, j) - 0.5 * width_px(ix, j), mean_row_px(ix, j) - 0.5 * height_px(ix, j), ...
                  width_px(ix, j), height_px(ix, j)], 'EdgeColor', jetc(VALUES(j), :));
    endfor
    #}
    figure_size(fig, sprintf('%s/post_im_at_%5.3f.jpg', file_stem, tm(ix)), 30, 21);
    #print(sprintf('%s/post_im_at_%5.3f.jpg', file_stem, tm(ix))); # %s is replaced by first variable (file_stem) and treated as string...
    # %5.3f is replaced by second variable tm(ix) and treated as floating point 5 wide to 3 dec places
endfor
#}
n = 4:8; # the number of the contour in VALUES to use, can be number or range
key = char(zeros(1, 20));
for i = n
  entry = sprintf ("greyscale %d", VALUES(i));
  key (i - n(1) + 1, 1:size(entry)(2)) = entry;
endfor