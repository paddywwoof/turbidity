csv_data = csvread('Turbidity_currents_01_01.$ls.csv');
g = csv_data(124:137,5); 
pc = csv_data(124:137,2); 

E_Boss_data = ('E_Boss_data.mat');
E_g = E_Boss_data(:,1);
E_pc = E_Boss_data(:,2);

%{
p = polyfit(g, pc, 1);
g1 = polyval(p, g);

E_p = polyfit(E_g, E_pc, 1);
E_g1 = polyval(E_p, E_g);
%}

fig2 = figure;

hold on
plot(g, pc,'-ok')
plot(E_g, E_pc, '--ok')
xlabel('Grain size (um)')
ylabel('Percentage %')
legend('Sieved sediment', 'non-sieved sediment')

width = 9;
height = 12;
set(gca, 'units', 'centimeters');

figure_size(fig2, 'seived_grain-size_anlysis.jpeg',11,11);