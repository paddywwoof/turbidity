# turbidity
This code has been developed for a 4th year project at Liverpool University UK.
The inital objective was to look at laboratory turbidity currents, hoever, this code could be applied (with suitable modifications) to other frame by frame video analysis

video analysis using octave (matlab like) software

this needs to have ffmpeg installed to extract frames from the video
on windows download and unzip the appropriate executables from
https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-20181208-fe0416f-win64-static.zip
though check because that will probably change, and put them in a sub-directory
of this. Ubuntu etc should just work if you install ffmpeg normally.

image files will get written into, and deleted from a subfolder called
frames which will be created if it doesn't exist.

