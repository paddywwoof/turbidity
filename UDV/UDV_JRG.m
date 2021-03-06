#FOLDER='C:\Users\Jill\turbidity\UDV'; # make sure you change 'xxx' to the right file path
TM_COL = 1; # column with time values
TM_FACTOR = 0.09; # to convert time values to s
FIRST_ROW = 4;
FIRST_CH = 14;
LAST_CH = 20;
COLRS = ['r', 'b', 'g', 'm', 'c', 'k']; # use these colours sequentially

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
  t{i} = csv_data(FIRST_ROW:end, TM_COL) * TM_FACTOR; # time of each data set in seconds (based on the frequency of the probe used)
  #data{i} = csv_data;
endfor

figure
hold on
#{
plot(t{1},mean_vd{1},'r')
plot(t{2},mean_vd{2},'b')
plot(t{3},mean_vd{3},'g')
plot(t{4},mean_vd{4},'m')
#plot(t{5},mean_vd{5},'c')
#plot(t{6},mean_vd{6},'k')
xlabel('time (s)')
ylabel('U (mm s^{-1})')
legend('10 mm','40 mm','70 mm','100 mm');
title('velocity of turbidity currents at 0.55m downstream of the sluice gate and increasing height above base of flume')
#}
for i = 1:length(t) # this is more general i.e. if you had a different number of files in directory
  plot(t{i}, mean_vd{i}, COLRS(1 + mod(i - 1, length(COLRS)))) # this mod() wraps the sequence if more than 6 files
endfor
xlabel('time (s)')
ylabel('U (mm s^{-1})')
legend('10 mm','40 mm','70 mm','100 mm'); # rather specific given the source of data 'just' iterating over whatever files happen to be in the directory. TODO link with file names in some way
title('velocity of turbidity currents at 0.55m downstream of the sluice gate and increasing height above base of flume')

