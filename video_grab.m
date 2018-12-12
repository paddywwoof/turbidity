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

function [IM, tm] = get_frame(f_num, rgb_ch, max_tm, fps, r_slice, c_slice)
    # f_num    frame number
    # rgb_ch   1D array of three factors for greyscaling
    # max_tm   give up if it take longer than this
    # fps      use to calc tm for frame f_num
    # r_slice  row range of image to crop
    # c_slice  column range to crop
    fname_stem = 'frames/vid_fr%d.bmp'; # will reuse this in the tidy stage below
    fname = sprintf(fname_stem, f_num);
    last_tm = time();
    while (true)
        tmnow = time();
        if (tmnow > last_tm + max_tm) # timeout
            IM = [;];
            tm = -1.0; # to indicate failure
            break;
        endif
        if (exist(fname, 'file'))
            # fairly horrible broadcasting c.f. numpy!
            IM = imread(fname)(r_slice, c_slice, :) .* permute(rgb_ch, [3, 1, 2]);
            IM = double(sum(IM, 3));
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

##### split out so can be done separately on subsequent frames
function [IM] = rotate_diff(img, corr, frame1)
    imp2 = imrotate(img, corr);     # rotate image
    IM = squeeze(imp2 - frame1);     # flipped up-down difference image
endfunction

##### final tidy up images from hard drive
function video_tidy()
    delete('frames/vid_fr*.bmp')
endfunction