#FOLDER='C:\Users\Jill\turbidity\UDV'; # make sure you change 'xxx' to the right file path
TM_COL = 1; # column with time values
TM_FACTOR = 0.0651; # to convert time values to s
FIRST_ROW = 4;
FIRST_CH = 14;
LAST_CH = 20;
COLRS = ['r', 'b', 'g', 'm', 'c', 'k']; # use these colours sequentially

addpath('../'); # because of this directory changing!!
useful_functions;

#cd(FOLDER); #sets the folder

d = dir('*.csv');
#data = {};
mean_vd = {};
t = {};
for i = 1:length(d);
  csv_data = csvread(d(i).name);
  # excludes the first 3 lines by using 4:end and select certain columns which pertain
  # to a set of channels at a specific distance from the start of the window in front
  # of the UDV probe (chosen based on the channel distance)
  mean_vd{i} = mean(csv_data(FIRST_ROW:end, FIRST_CH:LAST_CH), axis=2) * -1; # calculates the average velocity over the channels chosen

  # do the smoothing process here
  mean_vd{i} = wilson(mean_vd{i}', 50, 5, 9, 3.0); # NB I'v used 2 std as that seems more reasonbable
  #mean_vd{i} = movmean(mean_vd{i}', 15); # compare with simple smoothing


  t{i} = csv_data(FIRST_ROW:end, TM_COL) * TM_FACTOR; # time of each data set in seconds (based on the frequency of the probe used)
  #data{i} = csv_data;
endfor

figure
hold on
for i = 1:length(t) # this is more general i.e. if you had a different number of files in directory
  plot(t{i}, mean_vd{i}, COLRS(1 + mod(i - 1, length(COLRS)))) # this mod() wraps the sequence if more than 6 files
endfor
xlabel('time (s)')
ylabel('U (mm s^{-1})')
legend('10 mm','40 mm','70 mm','100 mm'); # rather specific given the source of data 'just' iterating over whatever files happen to be in the directory. TODO link with file names in some way
title('velocity of turbidity currents at 0.9m downstream of the sluice gate and increasing height above base of flume')