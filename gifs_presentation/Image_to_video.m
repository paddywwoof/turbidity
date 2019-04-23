pkg load image

#
pics = dir('*.jpg'); #finds jpeg files in folder 026
pics = {pics.name}';
#}



v = VideoWriter('run_041.avi');
v.FrameRate = 0.5;
open(v)

for i = 1:length(pics)
  img = imread(pics{i});
  writeVideo(v,img)
endfor
close(v)
