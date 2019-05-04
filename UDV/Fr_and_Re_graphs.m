pkg load image;
addpath('../');
useful_functions;

FILE = csvread('Fr_and_Re.csv');

FrUO = FILE(5,2);
FrO = FILE(6:10,2);

ReUO = FILE(5,3);
ReO = FILE(6:10,3);

H = FILE(6:10,5);
Hun = FILE(6,5);
#
f1 = figure;
subplot(1,2,1);
plot(FrO, H, 'xk', 'markersize', 10, FrUO, Hun, '.b', 'markersize', 20);
xlabel('Froude number', 'fontsize', 16);
ylabel('Zo/Zf', 'fontsize', 16);

xticklabels = [0, 0.4, 0.8, 1.2];
xtick = xticklabels + 0.05;
set(gca, 'XTick', xtick, 'fontsize', 16, 'XTickLabel', xticklabels, 'fontsize', 16);

subplot(1,2,2);
plot(ReO, H, 'xk', 'markersize', 10, ReUO, Hun, '.b', 'markersize', 20);
xlabel('Reynolds Number', 'fontsize', 16);
leg = legend('Obstructed','Unobstructed');
set(leg, 'fontsize', 12);
legend('boxoff');

xticklabels = [0, 2000, 4000, 6000];
xtick = xticklabels + 5;
set(gca, 'XTick', xtick, 'fontsize', 16, 'XTickLabel', xticklabels, 'fontsize', 16);

figure_size (f1, 'talk size froude and rerynolds numbers.jpeg', 10, 15)
#saveas(fig,'Froude and Reynods numbers.jpeg');
