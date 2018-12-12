# Script for image analysis of turbity current video frames 

# Required external functions:
# mmread         imports movie files into Matlab (Mathworks website)
# imrot          rotate an image based on a linear fit (Iris)
# extractframes  extracts multiple single colour pane frames from a video (Iris)
# turbfit1       fit top outline of the current (Jonathan)
# outlines       extracts leadingwave and interaction outlines from frames (Iris)
# bedfit1        fit bed in front of the current (Iris)
# erosionfit1    fit surface underneath th flow (Iris)
# wavefit1       determines peaks and troughs and mean wavelength of waves in a polynomial curve (Iris)
# thesis_*       to print pdf of figure directly (* = half, full or LS)
# video_grab     script file video grab functions
#
# Control plots in the script: 
# Figures added initially used to find manual input parameters/check output
# (can be put inactive)
# 
# Capital letters used for units in pixels, small letters used for mm.

clear all, close all

###############%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
####%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# MANUAL INPUT PARAMETERS 

# loading .avi files into matlab (Jill)#

#Folder = 'C:\Users\Jill\Desktop\1. Studying\4th Year\Masters\avi_original_videos'; cd(Folder)   # directory
#
pkg load image

#video = 'JRG_run01';            # video of experimental run
video = 'JRG_run05.avi';            # video of experimental run
h = fspecial('average');         # average filter
resolution = 1907 / 1220;          # pixels -> mm
fps = 50.0;

row_crop = 387:725;  # max y 540
col_crop = 81:1705; # max x 1700
rgb_ch1 = [0.5, 0.0, 0.5];    # rgb multiples for first frame
rgb_ch2 = [0.5, 0.0, 0.5];    # rgb multiples for rest of frames

# image rotation row, column, value - contour intervals NB pixels AFTER cropping
# TODO specify pre-cropped coordinates
r1 = [500, 725]; c1 = [1251, 1659]; contour1 = 92; #150;
r2 = [500, 725]; c2 = [1251, 1659]; contour2 = 92; #200;
c = +1; # either +1 or -1 depending on clockwise or anticlockwise rotation

start_tm = 49; # beginning of interest in s
stop_tm = 51;  # end of interst
#f1 = 60; f2 = 2; f3 = 190;  # just used for progress bar
# the actual frame number starts at 1 and increments in ones i.e. for f1 f2 f3 60:2:190
# final f would be 66
# TODO I'm not sure that this is what is intended as it seems v. illogical

Ybed = 531;                 # ybed on unflipped image 
Y0 = 145;                   # lowest point on top outline (px)
y0 = Y0 / resolution;       # lowest point on top outline (mm)
Ymax = 470;
Ymin = 50;
Xmax = 1680;
Xmin = 415;

TO = 1;                     # top outline (0 = manual, 1 = model)
LWO = 1;                    # leading wave outline (0 = hard bed, 1 = model)
IO = 1;                     # interaction outline (0 = hard bed, 1 = model)
ybedextra = 5;              # add to Ybed when extracting IO
IFy = 0;                    # interaction fit either up to: Y0(0) or Ybed(1)

# outline contour intervals
ctopmax = -16;
ctopmin = -19;
cbed1 = 7;
cmix1 = -6; 

#####%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#####%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

## load first video frame
#{
movie = mmread(video, 1); 
[im] = frame2im(movie.frames(1));
im = double(im);
frame1 = squeeze(im(240:840, :, rgb_ch1));
clear movie rgb im
#}
video_grab; # load functions in script file_in_loadpath
# TODO the number of frames system is odd - check it's what's wanted
#n_frames = 1 + floor((f3 - f1) / f2)
start_conversion(video, start_tm, stop_tm, fps); # this runs asynchronously so should keep in front of these calcs
[frame1, tm] = get_frame(1, rgb_ch1, 30.0, fps, row_crop, col_crop); # long wait for first frame to appear

## rotate correction: set surface of mud horizontal
r1 = (r1(1) - row_crop(1) + 1):(r1(2) - row_crop(1) + 1);
c1 = (c1(1) - col_crop(1) + 1):(c1(2) - col_crop(1) + 1);
r2 = r1;
c2 = c1;
[corr] = imrot(frame1, r1, c1, r2, c2, c, contour1, contour2, 1);
frame1 = imrotate(frame1, corr); # rotate control image (not included in loop below)
clear r1 r2 c1 c2 c contour1 contour2

## load rest of the frames

tic #starts timer
waittxt = 'Extracting frames...';
z = waitbar(0, waittxt);

#f = 1; # incremented to frame number - used later as number of frames
# TODO this is an odd bit of code
#for fr_num = f1:f2:f3
n_fr = floor((stop_tm - start_tm) * fps);
for f = 1:n_fr
    #{
    movie = mmread(video, fr_num);
    [IM{f}, time(f)] = extractframes(movie, rgb_ch2, corr, frame1);
    time(f) = movie.times;
    #}
    [IM{f}, time(f)] = get_frame(f, rgb_ch2, 10.0, fps, row_crop, col_crop);
    [IM{f}] = rotate_diff(IM{f}, corr, frame1);
    waitbar(f / n_fr, z);
endfor

#video_tidy();

dtime = diff(time); # save time difference

close(z);           #closes waitbar
clear z waittxt     #removes waitbar
toc 

#-------- control plot (check if the extraction of frames is OK)
#gaus1 = fspecial('gaussian', 1);
gaus2 = fspecial('gaussian', 8);
blur = fspecial('average');
#im = imfilter(IM{f}, gaus1);
im = IM{f} - imfilter(IM{f}, gaus2);
#sobel = fspecial('sobel');
#im = imfilter(imfilter(IM{f}, sobel), sobel');
im = imfilter(im, blur);
im = imadjust(imadjust(im),[0.7,1.0]);
figure
# b=1;
# for a = 1:f;
imagesc(im);
# b=b+1;
# end
clear im

clear movie fr_num f1 f2 f3

## FIT (1): top outline

#-------- determine new ybed
s = size(frame1);
Ybed = s(1) - Ybed; # new ybed = totaly of rotated image - ybed on unrotated image
ybed = Ybed / resolution;

if IFy == 0     # define if interaction fit is up to Y0 or (the new) Ybed
   IFy = Y0;
else
   IFy = Ybed;
endif

#-------- extract top outline (output in mm not in pixels)
if TO == 1
    for a = 1:f
        [y{a}, x{a}] = find(ctopmin < IM{a}(Y0:Ymax, Xmin:Xmax) & IM{a}(Y0:Ymax, Xmin:Xmax) < ctopmax);        
        x{a} = (x{a} + Xmin) / resolution;
        y{a} = y{a} / resolution;
    endfor
endif
clear a r c

#-------- load outline if manually extrated (output in mm not in pixels)

if TO == 0;
    xload = load('x_023');
    yload = load('y_023');
    for a = 1:f
        y{a} = (yload.y{1, a} - Y0) / resolution;
        x{a} = (xload.x{1, a}) / resolution;
    endfor
endif
clear xload yload

#-------- turbfit1 (JM): linear model
figure
for a = 1:f
    subplot(8, 9, a);
    [P(a, :), x0(a), xc(a), A(a), B(a), xl(a), xf(a, :), yf(a, :)] = turbfit1((x{a}), y{a}, 10);
    axis([0 max(x{a}) + 10 0 max(y{a}) + 10]);
    set(gca, 'ytick', [0 100], 'xtick', [0 500 1000], 'xticklabel', {'0'; '0.5'; '1.0'});
endfor
clear a

#-------- print figure
# thesis_LS 'run023_linfits'


## Extract leading wave and interaction outlines

#-------- extract leading wave and interaction outlines

for a = 1:f
    [x2{a}, y2{a}, A2(a), x3{a}, y3{a}, A3(a)] = outlines(IM{a}, LWO, IO, Y0, x0(a), Xmax, Ymin, Xmin, Ybed, resolution, ybedextra, IFy, cbed1, cmix1);
end

#-------- control plot (scatters on top of images)
# figure
# for a=1:f
# subplot(8,9,a)
# imagesc(IM{a})
# hold on
# plot((x{a}*resolution),(y{a}*resolution+Y0),'.b');
# plot((x2{a}*resolution),(y2{a}*resolution),'.k');
# plot((x3{a}*resolution),(y3{a}*resolution),'.w')
# end
# clear a

## FIT (2-3): bedfit1 and erosionfit1

#-------- bedfit1: surface in front of the flow (exponential)
if LWO == 1
    for a = 1:f
        [B2(a), A2(a), xf2(a, :), yf2(a, :)] = bedfit1(x2{a}, y2{a}, x0(a), y0, ybed);
    endfor    
endif
clear a

if LWO == 0
    for a = 1:f
        xf2(a,:) = x2{a};
        yf2(a,:) = y2{a};
    endfor
endif
clear a

#-------- erosionfit1: erosion/mixing under the flow (poly+linear)
if IO == 1
    figure
    for a = 1:f
        subplot(8,9,a);
        [P3(a, :), A3(a), B3(a), xl3(a), xf3(a, :), yf3(a, :)] = erosionfit1(x3{a}, y3{a}, x0(a), y0, 10);
    endfor
endif
clear a

if IO == 0
    for a = 1:f
        xf3(a, :) = x3{a};
        yf3(a, :) = y3{a};
    endfor
endif
clear a

#-------- control plots (fits on top of images)

# polynomials and exponential on image
# figure
# for a=1:f
# subplot(8,9,a)
# imagesc(IM{a})
# hold on
# plot((xf(a,:)*resolution),(yf(a,:)*resolution+Y0),'linewidth',2,'color','w')
# plot((xf2(a,:)*resolution),(yf2(a,:)*resolution),'linewidth',2,'color','b')
# plot((xf3(a,:)*resolution),(yf3(a,:)*resolution+Y0),'linewidth',2,'color','k')
# end
# clear a

# model fits on image
figure
for a = 1:f
    subplot(8,9,a)
    imagesc(IM{a})
    hold on
    plot(([x0(a) xl(a) max(x{a})]) * resolution, (B(a) * [0 xl(a) - x0(a) xl(a) - x0(a)]) * resolution + Y0, 'linewidth', 2, 'color', 'r')
    plot((xf2(a, :) * resolution), (yf2(a, :) * resolution), 'linewidth', 2, 'color', 'b')
    if IO == 1
       plot(([x0(a) xl3(a) max(x3{a})]) * resolution, (B3(a) * [0 xl3(a) - x0(a) xl3(a) - x0(a)]) * resolution + Y0, 'linewidth', 2, 'color', 'g')
    else 
       plot((xf3(a, :) * resolution), (yf3(a, :) * resolution), '-g');
    endif
endfor
clear a

# fits only
# figure
# for a=1:f
# subplot(8,9,a)
# plot([x0(a) xl(a) max(x{a})],((B(a)*[0 xl(a)-x0(a) xl(a)-x0(a)])+y0)-ybed,'-r')
# hold on
# plot(xf(a,1:3:end),(yf(a,1:3:end)+y0)-ybed,'.r')
# 
# line([0 1220],[0 0],'color','k','linestyle','-');
# line([0 1220],[y0-ybed y0-ybed],'color','k','linestyle',':');
# 
# if LWO == 1
#    plot(xf2(a,:),yf2(a,:)-ybed,'-b')
#    plot(xf2(a,1:10:end),yf2(a,1:10:end)-ybed,'.b')
# else
#    plot(xf2(a,:),yf2(a,:)-ybed,'-b')
#    plot(xf2(a,:),yf2(a,:)-ybed,'.b')
# end
# 
# if IO == 1;
#    plot([x0(a) xl3(a) max(x3{a})],((B3(a)*[0 xl3(a)-x0(a) xl3(a)-x0(a)])+y0)-ybed,'-g')
#    plot(xf3(a,1:5:end),(yf3(a,1:5:end)+y0)-ybed,'.g')
# else
#    plot(xf3(a,:),yf3(a,:)-ybed,'-g')
#    plot(xf3(a,:),yf3(a,:)-ybed,'.g')
# end
# end
# clear a

## CALCULATIONS: apply model results

#-------- head velocity

dx0 = diff(x0) * -1;

for a = 1:(f - 1)
    hv(a) = dx0(a) / dtime(a);
endfor
clear a

mafilter = [1/3 1/3 1/3]; # 3pt average filter
hvma = filter(mafilter, 1, hv);
hvma = hvma(3: end);

time2 = time(1: (end - 1)) + dtime(1);
time3 = time2(3: end);

p2 = polyfit(time2, hv, 1);
hv2 = polyval(p2, time2);

p3 = polyfit(time3, hvma, 1);
hvma2 = polyval(p3, time3);

# figure
# subplot(1,2,1),plot(time2,hv,'.-k',time2,hv2,'r');
# title('a) Head velocity (original)');
# xlabel('time (s)')
# ylabel('velocity (mm/s)')
# 
# subplot(1,2,2),plot(time3,hvma,'.-k',time3,hvma2,'r');
# title('b) Head velocity (3pt average)');
# xlabel('time (s)')
# ylabel('velocity (mm/s)')


# # print figure
# thesis_half 'run023_plots_hv'


#-------- slope, height, erosion depth changes 

for a = 1:f
    yl(a) = (y0 + B(a) * (xl(a) - x0(a))) - ybed;
endfor
clear a

if IO == 1
    for a = 1:f
        yl3(a) = (y0 + B3(a) * (xl3(a) - x0(a))) - ybed;
    endfor
else
    yl3 = 0;
endif
clear a

# figure
# subplot(1,3,1),plot(time,B,'.-k');
# title('a) Frontal slope');
# xlabel('time (s)')
# ylabel('B (mm^{-1})')
# 
# subplot(1,3,2),plot(time,yl,'.-k');
# title('b) Current height');
# xlabel('time (s)')
# ylabel('y (mm)')
# 
# subplot(1,3,3),plot(time,yl3,'.-k');
# title('c) Erosion depth');
# xlabel('time (s)')
# ylabel('y (mm)')

# # print figure
# thesis_half 'run023_plots_shape'

#-------- changes in volume flow rate (area * 300 mm = width of the tank)

# OLD
# VFRflow = (A-A3)*300;
# VFRlw = A2*300;
# VFRint = (A2+(y0*(Xmax/resolution-x0)+A3)-A2)*300;
# VFRnet = (A2+(y0*(Xmax/resolution-x0)+A3))*300;

# NEW
yy0 = y0 - ybed;
xmax = Xmax / resolution;
#xxmax = 1880*1220/1907;

AreaA1 = (A - A3); 
AreaA2 = A2; 
AreaA3 = (abs(yy0 * (xmax - x0) + A3));

Areas =  [AreaA1; AreaA3; AreaA2];
for a = 1:length(Areas)
    AreasP(1, a) = Areas(1, a) / sum(Areas(:, a)); # flow
    AreasP(2, a) = Areas(2, a) / sum(Areas(:, a)); # interaction
    AreasP(3, a) = Areas(3, a) / sum(Areas(:, a)); # leading wave
endfor

# NEW y2 and yf2   # NOTE THEY ALSO NEED CHANGING !!!!
# y2=y2-ybed;
# yf2 = yf2-ybed;


# OLD
# figure
# subplot(1,4,1),plot(time,VFRflow,'.-k');
# title('a) Flow');
# xlabel('time (s)')
# ylabel('flow volume (mm^3)')
# 
# subplot(1,4,2),plot(time,VFRlw,'.-k');
# title('b) Leading wave');
# xlabel('time (s)')
# ylabel('flow volume (mm^3)')
# 
# subplot(1,4,3),plot(time,VFRint,'.-k');
# title('c) Interaction');
# xlabel('time (s)')
# ylabel('flow volume (mm^3)')
# 
# subplot(1,4,4),plot(time,VFRnet,'.-k');
# title('d) Net change in bed');
# xlabel('time (s)')
# ylabel('flow volume (mm^3)')

# # print figure
# thesis_half 'run023_plots_flowrate'


## KH waves on the top outline

figure
for a = 1:f
    [KHxt{a}, KHyt{a}, KHxp{a}, KHyp{a}, KHdxta(a), KHdxpa(a), KHwh{a}, KHwha(a)] = wavefit1(x0(a), P(a, :), time(:, a), 10);
    hold on
endfor

for a = 1:f
    np(a) = numel(KHyp{a});
    nt(a) = numel(KHyt{a});
endfor

# # print figure
# thesis_half 'run023_KHplots'

## Waves underneath the flow

if IO == 1;
    figure
    for a=1:f
        [SWxt{a}, SWyt{a}, SWxp{a}, SWyp{a}, SWdxta(a), SWdxpa(a), SWwh{a}, SWwha(a)] = wavefit1(x0(a),P3(a,:), time(:, a), 10);
        hold on
    endfor
endif
clear a

# # print figure
# thesis_half 'run023_SWplots'

## Save model outputs

# save('parameters_023')
# save('parameters_023','resolution','x0','x','y','x2','y2','x3','y3','xl','xl3','xf','yf','xf2','yf2','xf3','yf3','B','B2','B3','A','A2','A3','yl','yl3','y0','ybed')

# 15/04/2013 new areas and parameters calculated with the right ybed
#save('Areas_023','AreaA1','AreaA2','AreaA3','AreasP')

# save('hv_023','hv','hv2','time2','hvma','hvma2','time3');
# save('dimensions_023','time','B','yl','yl3');
# save('VFR_023','time','VFRflow','VFRlw','VFRint','VFRnet');
# save('KH_023','time','KHxt','KHyt','KHxp','KHyp','KHdxta','KHdxpa','KHwh','KHwha');
# save('SW_023','time','SWxt','SWyt','SWxp','SWyp','SWdxta','SWdxpa','SWwh','SWwha');
