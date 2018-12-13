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
function new_img = posterize(img)
    threshRGB = [20, 45, 70, 93, 120, 145, 170];
    value =   [10, 22, 33, 89, 193, 223, 238, 251]; # non-linear mapping need to play with this
    new_img = zeros(size(img)); # new empty image
    new_img = imquantize(img, threshRGB, value);
    new_img = uint8(new_img); # has to be converted back to bytes for some reason
endfunction


# find the top and the front of the turbity 'cloud'
function [top_edge, front_edge, area] = find_edges(img, edge_shade, thresh_r, thresh_c)
    # img : grayscale, posterized image
    # edge_shade : value to use in determining front and top edges - see posterize function above
    # thresh_r : number of pixels in a row to look for
    # thresh_c : number of pixels in a column to look for
    dk_orange = img(:,:) == edge_shade; # look for the red value, 1 if it is, 0 otherwise
    # in case less than 8 rows or 1 colum found this is in a try catch
    try
        top_edge = find(sum(dk_orange, dim=2) >= thresh_r)(8); # add rows then find (nearly) first one above threshld count
        front_edge = find(sum(dk_orange, dim=1) >= thresh_c)(end); # add cols and take last one above different thshld
    catch
        top_edge = size(img)(1);
        front_edge = 1;
    end_try_catch
    area = sum((img(:,:) >= edge_shade)(:));
endfunction


##### final tidy up images from hard drive
function video_tidy()
    delete('frames/vid_fr*.bmp')
endfunction