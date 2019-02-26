Folder='C:\Users\Jill\turbidity\UDV'; %make sure you change 'xxx' to the right file path
cd(Folder) %sets the folder

d = dir('*.csv');
p = length(d);
data = {'frodo','sam','merry','pippin'};
for i = 1:p;
data{i} = csvread(d(i).name);
[m,n] = size(data{i});
v = data{1,i}(4:m, :); #excludes the first 3 lines
vd = v(:,[14:20]); #all rows, certain columns which pretain to a set of channels at a specific distance from the start of the window in front of the UDV probe (chosen based on the channel distance)
mean_vd{i} = mean(vd')'*-1; #calculates the average velocity over the channels chosen
t{i} = v(:,1)*0.25; #time of each data set in seconds (9based on the frequency of the probe used)
endfor

figure
hold on
plot(t{1},mean_vd{1},'r')
plot(t{2},mean_vd{2},'b')
plot(t{3},mean_vd{3},'g')
plot(t{4},mean_vd{4},'m')
plot(t{5},mean_vd{5},'c')
plot(t{6},mean_vd{6},'k')
xlabel('time (s)')
ylabel('U (mm s^{-1})')
legend('10 mm','40 mm','70 mm','100 mm','? mm','test of storage');
title('velocity of turbidity currents at 0.65m downstream of the sluice gate and increasing height above base of flume')