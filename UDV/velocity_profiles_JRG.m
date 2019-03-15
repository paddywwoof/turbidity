#FILES = {'JILL_029.csv','JILL_030.csv','JILL_031.csv','JILL_032.csv'} # actual names of files
dd = dir('*.csv');
FILES = {dd.name};
data = cell(numel(FILES),2);

COLRS = ['r', 'b', 'g', 'm', 'c', 'k']; # use these colours sequentially
#FIRST_CH = 2; # skips the No. of the measurement. gives a window of 5.18mm. given the starting disance of 20mm
#LAST_CH = 9; #window is from 20mm to 25.18mm infront of probe.
#FIRST_ROW = 4;

TM_COL = 1; # column with time values
TM_FACTOR = 0.0651;

#useful_functions;
mean_vd = {};
velocity = {};
time = {};
for i = 1:length(FILES); # <<<<<
  csv_data = csvread(FILES{i}); # 
  velocity{i} = csv_data(4,:);
  mean_vd = mean(velocity,[,2:9]);
  time{i} = csv_data(:, 1) * TM_FACTOR;
endfor

figure
#holdon
plot(velocity{i}, time{i});
xlabel('time (s)')
ylabel('Velocity(mm s^{-1})')
#legend('','','','',)