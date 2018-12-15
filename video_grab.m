#script file of video frame grab functions
# first line can't be function, so...
1;
function start_conversion(video, start_tm, stop_tm, fps)
    # video : path and name of video file relative to 'this'
    # start_tm : first frame time in seconds
    # stop_tm : last frame time is seconds
    # fps : fps
    # this will always start at frame 1
    if not(exist('frames', 'file'))
        mkdir('frames')
    endif
    if stop_tm <= start_tm
        end_fr = 1
    else
        end_fr = floor((stop_tm - start_tm) * fps);
    endif
    cmd = sprintf("ffmpeg -loglevel panic -i %s -ss %d -frames:v %d frames/vid_fr%%d.bmp", video, start_tm, end_fr);
    cmd
    [rslt] = system(cmd, false, 'async');
endfunction


function [im, tm] = get_frame(f_num, max_tm, fps, r_slice, c_slice)
    # f_num :   frame number
    # max_tm :  give up if it take longer than this
    # fps :     use to calc tm for frame f_num
    # r_slice : row range of image to crop
    # c_slice : column range to crop
    fname_stem = 'frames/vid_fr%d.bmp'; # will reuse this in the tidy stage below
    fname = sprintf(fname_stem, f_num);
    last_tm = time();
    while (true)
        tmnow = time();
        if (tmnow > last_tm + max_tm) # timeout
            im = [;];
            tm = -1.0; # to indicate failure
            break;
        endif
        if (exist(fname, 'file'))
            pause(0.25); # to ensure file is full written before trying to read it!
            im = rgb2gray(imread(fname)(r_slice, c_slice, :));
            tm = (f_num - 1.0) / fps;
            for i = 2:f_num # don't delete frame1 TODO make this bit toggleable
                fname = sprintf(fname_stem, i);
                if exist(fname, 'file')
                    delete(fname); # do some tidying as we go!
                endif
            endfor
            break;
        endif
    endwhile
endfunction


# posterize function creating to quantize and remap grayscale to new values
function new_img = posterize(img, THRESHOLDS, VALUES)
    # img : grayscale to posterize
    # THRESHOLDS : values in existing to quantize to
    # VALUES : new values to replace into new image
    new_img = zeros(size(img)); # new empty image
    #new_img = imquantize(img, threshRGB, value);
    new_img = imquantize(img, THRESHOLDS, VALUES);
    new_img = uint8(new_img); # has to be converted back to bytes for some reason
endfunction


# find the top and the front of the turbity 'cloud'
function [area, mean_row, mean_col, width, height] = find_edges(img, VALUES, ROW_POSN, COL_POSN)
    # function goes through the VALUES array in reverse order finding the area,
    # mean row, mean column, width at mean row, height at mean column. Each return
    # value is an array of resuts, one entry for each value in VALUES
    # img : grayscale, posterized image
    # VALUES : array of values to use in determining areas - see posterize function above
    # ROW_POSN : array of numbers 1 to height of img 
    # COL_POSN : array of number to width of img
    area = []; mean_row = []; mean_col = []; width = []; height = [];
    for value = VALUES # go through each contour value
        dark_patch = img(:,:) >= value; # 1 if it's greater or equal, 0 otherwise
        # the _v ending is for vals this loop to be added to the return arrays
        area_v = sum(dark_patch(:));
        if area_v > 0
            row_sum = sum(dark_patch, dim=2)'; # sum across rows i.e. array length equals height of img NB transpose to 1,n array
            col_sum = sum(dark_patch, dim=1); # sum down cols i.e. array length equals width of img
            mean_row_v = sum(row_sum .* ROW_POSN) / area_v; # this is cunning! it calculates the mean horizontal
            mean_col_v = sum(col_sum .* COL_POSN) / area_v; # and vertical positions of the dark_patch
            width_v = row_sum(round(mean_row_v));
            height_v = col_sum(round(mean_col_v));
            #top_edge = find(sum(dk_orange, dim=2) >= thresh_r)(3); # add rows then find (nearly) first one above threshld count
            #front_edge = find(sum(dk_orange, dim=1) >= thresh_c)(end); # add cols and take last one above different thshld
        else
            mean_row_v = 1; mean_col_v = 1; width_v = 0; height_v = 0;
            #top_edge = size(img)(1);
            #front_edge = 1;
        endif
        area(end+1) = area_v; mean_row(end+1) = mean_row_v; mean_col(end+1) = mean_col_v;
        width(end+1) = width_v; height(end+1) = height_v;
    endfor
endfunction


##### final tidy up images from hard drive
function video_tidy()
    delete('frames/vid_fr*.bmp')
endfunction