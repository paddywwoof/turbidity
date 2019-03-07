#To get an image to get the crop pixels from gimp


video = "030.avi";
start_tm = 37;
stop_tm = 47;
frame_tm = (start_tm + stop_tm) * 0.5;


if not(exist('initial_images', 'file'))
    mkdir('initial_images')
endif

cmd = sprintf("ffmpeg -loglevel panic -i %s -ss %d -frames:v 1 initial_images/%s.png", video, frame_tm, strsplit(video, '.'){1});
cmd
[rslt] = system(cmd, false, 'async');