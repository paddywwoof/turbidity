#FOLDER='C:\Users\Jill\turbidity\UDV'; # make sure you change 'xxx' to the right file path
TM_COL = 1; # column with time values
TM_FACTOR = 0.0651; # to convert time values to s
FILES = {'JILL_033.csv','JILL_034.csv','JILL_035.csv','JILL_036.csv'}; # actual names of files <<<<<<<<<<<<<<<<<<<<<
#FIRST_ROW_TM = [39.0, 35.0, 36.0, 41.0]; # time in seconds for first reading <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
FIRST_ROW_TM = [1.0, 1.0, 1.0, 1.0]; # time in seconds for first reading <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
FIRST_CH = 14; # *0.74mm sets the distance infront of the probe to average over
LAST_CH = 20; # *0.74mm sets the distance infront of the probe to stop averaging over
COLRS = ['r', 'b', 'g', 'm', 'c', 'k']; # use these colours sequentially

addpath('../'); # because of this directory changing!!
useful_functions;

#cd(FOLDER); #sets the folder

#d = dir('*.csv'); #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#data = {};
mean_vd = {};
t = {};
for i = 1:length(FILES); # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  csv_data = csvread(FILES{i}); # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  # excludes the first 3 lines by using 4:end and select certain columns which pertain
  # to a set of channels at a specific distance from the start of the window in front
  # of the UDV probe (chosen based on the channel distance)
  first_row = floor(FIRST_ROW_TM / TM_FACTOR); # have to make into an int <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< should do a check here that time isn't off the end! i.e. first_row < length(csv_data)
  mean_vd{i} = mean(csv_data(first_row:end, FIRST_CH:LAST_CH), axis=2) * -1; # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<calculates the average velocity over the channels chosen

  # do the smoothing process here
  #mean_vd{i} = wilson(mean_vd{i}', 50, 5, 15, 3.0); # NB I'v used 2 std as that seems more reasonbable
  mean_vd{i} = movmean(mean_vd{i}', 15); # compare with simple smoothing


  t{i} = csv_data(first_row:end, TM_COL) * TM_FACTOR - FIRST_ROW_TM(i); # <<<<<<<<<<<<<<<<<<<<<<<<<<< time of each data set in seconds (based on the frequency of the probe used)
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
title('velocity of turbidity currents at 0.65m downstream of the sluice gate and increasing height above base of flume')