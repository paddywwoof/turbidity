Folder='C:\Users\Jill\turbidity\UDV'; %make sure you change 'xxx' to the right file path
cd(Folder) %sets the folder

d = dir('*.csv');
#[m,n] = size(d);
p = length(d);
#data = cell(1,n);


for i = 1:1;
  f = csvread(d(i).name);
  f = sprintf('file_%d.csv', data(i));
  data1 = data{i};
endfor
# LOOP

#{
for n = f
 csvread(n{:});
 save_file = sprintf('file_%d.csv');
endfor
}#
