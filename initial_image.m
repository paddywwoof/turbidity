#To get an image to get the crop pixels from gimp


video = "051.avi";
start_tm = 27;
stop_tm = 51;
frame_tm = (start_tm + stop_tm) * 0.354;


if not(exist('initial_images', 'file'))
    mkdir('initial_images')
endif

cmd = sprintf("ffmpeg -loglevel panic -i %s -ss %d -frames:v 1 initial_images/%s.png", video, frame_tm, strsplit(video, '.'){1});
cmd
[rslt] = system(cmd, false, 'async');