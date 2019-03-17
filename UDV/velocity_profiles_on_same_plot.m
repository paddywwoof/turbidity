FILES = {'UDV_velocity_profllie_15cm.csv','UDV_velocity_profllie_51cm.csv','UDV_velocity_profllie_90cm.csv'};

COLRS = ['r', 'b','m'];
useful_functions;

height = [0.0, 10.0, 40.0, 70.0, 100.0];

figure
hold on
for i = 1:length(FILES);
  csv_data = csvread(FILES{i});
  #key = COLRS{i};
  #mean_vh{i} = csv_data(1,:);
  plot(csv_data, height)
endfor
#
xlabel('U (mm s^{-1})')
ylabel('Height (mm)')
legend('15cm','55cm', '86cm')
title('Velocity profiles with varying distance down stream')
holdoff