#FOLDER='C:\Users\Jill\turbidity\UDV'; # make sure you change 'xxx' to the right file path

TM_COL = 1; # column with time values
TM_FACTOR = 0.0651; # to convert time values to s
FILES = {'JILL_033.csv','JILL_034.csv','JILL_035.csv','JILL_036.csv'};  # actual names of files <<<<<<
FIRST_ROW_TM = [22.0, 19.0, 26.0, 29.0]; # after TC is incident pn the probe. Time in seconds for first reading <<<<<<<<<<<<<
LAST_ROW_TM = [27.0, 24.0, 31.0, 34.0]; # jjjjjjj 1 second after first time in seconds for last reading
# first times taken from the standard_deviation chart to allow for timing errors
# also takes account of 1.0s offset used in that script (i.e. start of peak looks
# to be 27.0s on 10mm line on chart -> actual time 28.0 as used above.)
FIRST_CH = 14;
LAST_CH = 20;
#DIST_A = ; #0.19mm
#DIST_B = ; #0.55mm
#DIST_C = ; #0.90mm
COLRS = ['r', 'b', 'g', 'm', 'c', 'k']; # use these colours sequentially
 
addpath('../'); # because of this directory changing!!
useful_functions;

#height = [10.0, 40.0, 70.0, 100.0]; #<@<@<@<@<@<@<@
height = [0.0, 10.0, 40.0, 70.0, 100.0]; #<@<@<@<@<@<@<@

mean_vd = {};
#mean_vt = [0.0, 0.0, 0.0, 0.0]; # could also do zeros(1, 4); <@<@<@<@<@<@<@<@
mean_vt = [0.0, 0.0, 0.0, 0.0, 0.0]; # could also do zeros(1, 4); <@<@<@<@<@<@<@<@
t = {};

for i = 1:length(FILES); # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  csv_data = csvread(FILES{i}); # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  first_row = floor(FIRST_ROW_TM / TM_FACTOR); # have to make into an int <<< should do a check here that time isn't off the end! i.e. first_row < length(csv_data)
  last_row = floor(LAST_ROW_TM / TM_FACTOR); #jjjjjj
  mean_vd{i} = mean(csv_data(first_row:last_row, FIRST_CH:LAST_CH), axis=2) * -1; # <<<calculates the average velocity over the channels chosen
  #mean_vt(1, i) = mean(mean_vd{i});  #<@<@<@<@<@ calculates the average velocity over the specific distance, for a specific time bracket.
  mean_vt(1, i + 1) = mean(mean_vd{i});  #<@<@<@<@<@ calculates the average velocity over the specific distance, for a specific time bracket.
  t{i} = csv_data(first_row:last_row, TM_COL) * TM_FACTOR - FIRST_ROW_TM(i); # <<<<<< time of each data set in seconds (based on the frequency of the probe used)
endfor

figure
plot(mean_vt, height)
xlabel('U (mm s^{-1})')
ylabel('Height (mm)')
title('Velocity profile at 0.90m downstream of the sluice-gate')

csvwrite('UDV_velocity_profllie_90cm.csv', mean_vt);