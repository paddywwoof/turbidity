pkg load image;
#useful_functions;

FILE = csvread('Fr_and_Re.csv');

FrUO = FILE(5,2);
FrO = FILE(6:10,2);

ReUO = FILE(5,3);
ReO = FILE(6:10,3);

H = FILE(6:10,4);
Hun = FILE(6,4);
#
f = figure;
subplot(1,2,1);
plot(FrO, H, 'xk', 'markersize', 10, FrUO, Hun, '.b', 'markersize', 20);
xlabel('Froude number', '');
ylabel('Height of obstacle(mm)');

subplot(1,2,2);
plot(ReO, H, 'xk', 'markersize', 10, ReUO, Hun, '.b', 'markersize', 20);
xlabel('Reynolds Number');
legend('Obstructed','Unobstructed');
legend boxoff

#figure_size (f, 'sized froude and rerynolds numbers.jpeg', 11,15)
#saveas(fig,'Froude and Reynods numbers.jpeg');
