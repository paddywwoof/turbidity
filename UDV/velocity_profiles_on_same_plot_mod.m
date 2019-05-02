#FOLDER='C:\Users\Jill\turbidity\UDV'; # make sure you change 'xxx' to the right file path

TM_COL = 1; # column with time values
TM_FACTOR = 0.09; # to convert time values to s

FIFTEEN      = {{'JILL_024.csv','JILL_025.csv','JILL_027.csv','JILL_028.csv'}, [0.0, 10.0, 40.0, 70.0, 100.0, 120.0], [33, 33, 43, 37], [2, 2, 2, 2], 'unobstructed at 15cm'},
FIFTYONE     = {{'JILL_029.csv','JILL_030.csv','JILL_031.csv','JILL_032.csv'}, [0.0, 10.0, 40.0, 70.0, 100.0, 110.0], [39, 35, 37, 41], [2, 2, 2, 2], 'unobstructed at 51cm'},
SEVENTYEIGHT = {{'JILL_033.csv','JILL_034.csv','JILL_035.csv','JILL_036.csv'}, [0.0, 10.0, 40.0, 70.0, 100.0, 130.0], [42, 32, 37, 39], [121, 121, 121, 121], 'unobstructed at 78cm'},

TWO  = {{'JILL_045.csv','JILL_046.csv'}, [0.0, 10.0, 40.0, 120.0], [32, 33], [121, 121], 'after 2cm obstacle'},
FOUR = {{'JILL_048.csv','JILL_049.csv'}, [0.0, 10.0, 40.0, 140.0], [31, 32], [121, 121], 'after 4cm obstacle'},
SIX  = {{'JILL_051.csv','JILL_052.csv'}, [0.0, 10.0, 40.0, 120.0], [36, 32], [121, 121], 'after 6cm obstacle'},
TEN  = {{'JILL_054.csv','JILL_055.csv'}, [0.0, 10.0, 40.0, 110.0], [35, 36], [121, 121], 'after 10cm obstacle'};
         # actual names of files, height, first_row_tm, first_ch, title

addpath('../'); # because of this directory changing!!
useful_functions;

Zf =  93.107;



for k = 1:length(FILES)
  height = FILES{k}{2};
  mean_vd = {};
  mean_vt = zeros(size(height)); # same size as height. should be two bigger than the number of files
  # i.e. the first and the last mean_vt will be zero.
  if size(mean_vt)(1) != (length(FILES{k}{1}) + 2)
    printf('size mean_vt should be two more than the number of csv files!');
  endif
  t = {};
  for i = 1:length(FILES{k}{1})
    csv_data = csvread(FILES{k}{1}{i});
    first_row_tm = FILES{k}{3}(i);
    last_row_tm = first_row_tm + 5.0;
    first_ch = FILES{k}{4}(i);
    last_ch = first_ch + 6;
    
    first_row = floor(first_row_tm / TM_FACTOR); # have to make into an int <<< should do a check here that time isn't off the end! i.e. first_row < length(csv_data)
    last_row = floor(last_row_tm / TM_FACTOR); #jjjjjj
    mean_vd{i} = mean(csv_data(first_row:last_row, first_ch:last_ch), axis=2) * -1; # <<<calculates the average velocity over the channels chosen
    #mean_vt(1, i) = mean(mean_vd{i});  #<@<@<@<@<@ calculates the average velocity over the specific distance, for a specific time bracket.
    mean_vt(1, i + 1) = mean(mean_vd{i});  #<@<@<@<@<@ calculates the average velocity over the specific distance, for a specific time bracket.
    t{i} = csv_data(first_row:last_row, TM_COL) * TM_FACTOR - first_row_tm; # <<<<<< time of each data set in seconds (based on the frequency of the probe used)
  endfor

  UaveZ1 = 0;
  for i = 1:(length(mean_vt) -1);
    UaveZ1 += (height(i+1) - height(i)) * (mean_vt(i+1) + mean_vt(i)) * 0.5; #intergral equation thought of as a graph (trapeziumm rule)
  endfor
  UaveZ1 /= 1e6; # changing from mm to m( height and velocity are in mm)

  U2aveZ1 = 0;
  for i = 1:(length(mean_vt) -1);
    U2aveZ1 += (height(i+1) - height(i)) * ((mean_vt(i+1))^2 + (mean_vt(i))^2) * 0.5; #intergral equation thought of as a graph (trapeziumm rule)
  endfor
  U2aveZ1 /= 1e9; #changing from mm to m (height and velcity are measured in mm)

  Uave = U2aveZ1/UaveZ1;

  Z1 = UaveZ1^2/U2aveZ1;

  g_prime = 9.81*(1004.67 - 1000)/1000;
  Frb = Uave/(g_prime * Z1 * cos (deg2rad(0.27)))^0.5

  nu = 8.9e-4/1000;
  Reb = UaveZ1/ nu
    
  h1 = figure
  plot(mean_vt, height/Zf)
  xlim([-60,100]);
  ylim([0,1.5]);
  xlabel('U (mm s^{-1})')
  ylabel('Z/Zf')
  title(FILES{k}{5})

  figure_size(h1, sprintf('velocity %s.jpg', FILES{k}{5}), 7, 15);
  csvwrite(sprintf('UDV for %s.csv', FILES{k}{5}), mean_vt);
  csvwrite(sprintf('Frb and Reb for %s.csv', FILES{k}{5}), [Frb, Reb]); # in the file, the 1st number if the Froude and the 2nd is the Reynolds
endfor