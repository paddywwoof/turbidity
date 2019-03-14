#FOLDER='C:\Users\Jill\turbidity\UDV'; # make sure you change 'xxx' to the right file path
TM_COL = 1; # column with time values
TM_FACTOR = 0.0651; # to convert time values to s
FILES = {'JILL_029.csv','JILL_030.csv','JILL_031.csv','JILL_032.csv'} # actual names of files <<<<<<
FIRST_ROW_TM = [39.5, 35.5, 36.5, 41.5]; # 0.5 seconds after TC is incident pn the probe. Time in seconds for first reading <<<<<<<<<<<<<
LAST_ROW_TM = [40.5, 36.5, 37.5, 42.5]; # jjjjjjj 1 second after first time in seconds for last reading 
FIRST_CH = 14;
LAST_CH = 20;
#DIST_A = ; #0.19mm
#DIST_B = ; #0.55mm
#DIST_C = ; #0.90mm
COLRS = ['r', 'b', 'g', 'm', 'c', 'k']; # use these colours sequentially

addpath('../'); # because of this directory changing!!
useful_functions;

#cd(FOLDER); #sets the folder

#d = dir('*.csv'); #<<<<<
#data = {};
mean_vd = {};
mean_vt = {};
t = {};
for i = 1:length(FILES); # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  csv_data = csvread(FILES{i}); # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  # excludes the first 3 lines by using 4:end and select certain columns which pertain
  # to a set of channels at a specific distance from the start of the window in front
  # of the UDV probe (chosen based on the channel distance)
  first_row = floor(FIRST_ROW_TM / TM_FACTOR); # have to make into an int <<< should do a check here that time isn't off the end! i.e. first_row < length(csv_data)
  last_row = floor(LAST_ROW_TM / TM_FACTOR); #jjjjjj
  mean_vd{i} = mean(csv_data(first_row:last_row, FIRST_CH:LAST_CH), axis=2) * -1; # <<<calculates the average velocity over the channels chosen
  mean_vt{i} = mean(mean_vd);  # jjjjj calculates the average velocity over the specific distance, for a specific time bracket.
  
  # do the smoothing process here
  #mean_vd{i} = wilson(mean_vd{i}', 50, 5, 15, 3.0); # NB I'v used 2 std as that seems more reasonbable
  #mean_vd{i} = movmean(mean_vd{i}', 15); # compare with simple smoothing
  #mean_vt{i} = movmean(mean_vt{i}', 15);

  t{i} = csv_data(first_row:last_row, TM_COL) * TM_FACTOR - FIRST_ROW_TM(i); # <<<<<< time of each data set in seconds (based on the frequency of the probe used)
  #data{i} = csv_data;
endfor

#{
figure
hold on
for i = 1:length(t) # this is more general i.e. if you had a different number of files in directory
  plot(t{i}, mean_vt{i}, COLRS(1 + mod(i - 1, length(COLRS)))) # this mod() wraps the sequence if more than 6 files
endfor
xlabel('time (s)')
ylabel('U (mm s^{-1})')
legend('10 mm','40 mm','70 mm','100 mm'); # rather specific given the source of data 'just' iterating over whatever files happen to be in the directory. TODO link with file names in some way
title('velocity of turbidity currents at 0.65m downstream of the sluice gate and increasing height above base of flume')
#}
figure
hold on
for i = 1:length(t)
  plot(mean_vt{i}, height, COLRS(1 + mod(i -1, length(COLRS))))
endfor
xlabel('U (mm s^{-1})')
ylabel('Height (mm)')
title('Velocity profile at 0.55m downstream of the sluice-gate')
