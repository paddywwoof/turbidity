pkg load image;
#useful_functions;

FILE = csvread('Fr_and_Re.csv');

FrUO = FILE(5,2);
FrO = FILE(6:10,2);

ReUO = FILE(5,3);
ReO = FILE(6:10,3);

H = FILE(6:10,5);
Hun = FILE(6,5);
#
f = figure;
subplot(1,2,1);
plot(FrO, H, 'xk', 'markersize', 10, FrUO, Hun, '.b', 'markersize', 20);
xlabel('Froude number', 'fontsize', 16);
ylabel('Zo/Zf', 'fontsize', 16);

f = get(gcf,'currentaxes');
set(f, 'fontsize', 16);

subplot(1,2,2);
plot(ReO, H, 'xk', 'markersize', 10, ReUO, Hun, '.b', 'markersize', 20);
xlabel('Reynolds Number', 'fontsize', 16);
leg = legend('Obstructed','Unobstructed');
set(leg, 'fontsize', 16);
legend boxoff

f = get(gcf,'currentaxes');
set(f, 'fontsize', 16);

figure_size (f, 'talk size froude and rerynolds numbers.jpeg', 10,15)
#saveas(fig,'Froude and Reynods numbers.jpeg');
