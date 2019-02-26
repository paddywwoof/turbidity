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

std_vd = mean(mean_vd);
upperstd = std_vd+2*std(mean_vd);
lowerstd = std_vd-2*std(mean_vd);

t{i} = v(:,1)*0.25; #time of each data set in seconds (9based on the frequency of the probe used)
endfor